% Run-Emulator
% this code takes in optically-classified imagery, identifies the latitude,
% and draws from a distribution of potential satellite angles.
n_crossings = 100;
n_images = length(image_location);

savestr = [Output_folder '/Emulator_Data']; 

% Initialize data

try load(savestr)

    fprintf('Have done %d images out of %d \n',sum(image_done~=0),n_images);
        
    if n_images > length(image_done)

        % We have added new data
        length_measured(end:n_images,:) = nan;
        sample_orients(end:n_images,:) = nan;
        length_ice_measured(end:n_images,:) = nan;
        sample_points(end:n_images,:) = nan;
        true_SIC(end:n_images)  = nan;
        true_OW(end:n_images) = nan;
        image_done(end:n_images)  = 0;
        
    end
    
catch errload

    disp('No data yet')
    [length_measured,sample_orients,length_ice_measured,sample_points] = deal(nan(n_images,n_crossings));
    [true_SIC,true_OW] = deal(nan(n_images,1));
    image_done = zeros(n_images,1);

end

images_todo = length(image_done) - sum(image_done~=0);

%%

% Include a parametric depiction of flyover x-y coordinates.
% If 0, use a distance calculation
parametric_lines = 1;

block_length = 100;

nblocks = ceil(n_images/block_length);

try
parpool(4) 
catch 

end

for block_ind = 1:nblocks

    blockids = block_length*(block_ind - 1) + 1 :block_length*block_ind;
    blockids(blockids > length(image_done)) = [];

    % Initialize temporary variables in this block
    TEMP_image_done = image_done(blockids);
    TEMP_true_SIC = true_SIC(blockids);
    TEMP_length_measured = length_measured(blockids,:);
    TEMP_length_ice_measured = length_ice_measured(blockids,:);
    TEMP_sample_orients = sample_orients(blockids,:);
    TEMP_sample_points = sample_points(blockids,:);

    % TEMP_sample_x = sample_x(blockids,:); 
    % TEMP_sample_y = sample_x(blockids,:); 

    % Parallelize the sub-blocks

    if sum(TEMP_image_done == 0) > 0

        disp('------------------------------');
        fprintf('BLOCK %d of %d \n',block_ind,nblocks);
        disp('------------------------------');


        parfor block_subind = 1:length(blockids)

            % Index of the image itself in the overall dataset, not just
            % the sub block. 
            image_ind = block_length*(block_ind - 1) + block_subind;

            if image_done(image_ind) == 0

                fprintf('Image Number %d \n',image_ind);

                %%

                try

                    surface_class = (h5read(image_location{image_ind},'/classification'));

                    %%

                    % All scene points that have ice/ocean data
                    measurable = surface_class > 0;

                    % initial map showing the locations which are hit by IS2
                    measured_map = zeros(size(surface_class));

                    % Specification of classified points that are measured
                    class_measurable = surface_class(measurable);

                    TEMP_true_SIC(block_subind) = sum(class_measurable == 1)./sum(class_measurable > 0);


                    % Gridding things
                    [nx,ny] = size(surface_class);
                    X = 1:nx;
                    Y = 1:ny;
                    [Xgrid,Ygrid] = meshgrid(X,Y);

                    % This gridding swaps rows and columns. So we take the transpose to
                    % make it have the same dimensions as the data
                    Xgrid = Xgrid';
                    Ygrid = Ygrid';

                    % Smaller subdomain which is x/y points that have data
                    Xmeas = Xgrid(measurable);
                    Ymeas = Ygrid(measurable);

                    % Get orientation distribution of satellite tracks
                    local_lat = image_latitude(image_ind);
                    [~,latid] = min(abs(lat_disc - local_lat));

                    local_orient_dist = orientation_hist(latid,:);
                    local_orient_dist(isnan(local_orient_dist)) = 0;

                    % Now draw a number of samples from that distribution using inverse
                    % sampling
                    samples = rand(n_crossings,1);
                    % Add the linear spacing to help with zeroes that appear at the end of
                    % the cdf
                    cum_pdf = cumsum(local_orient_dist) + linspace(0,1e-10,length(local_orient_dist));

                    % Interpolate the cdf/samples to get the orientations
                    TEMP_sample_orients(block_subind,:) = interp1(cum_pdf,orient_disc,samples,'nearest');

                    % Dummy input
                    % disp('Overwriting Sample Orientation Angles to 0');
                    % sample_orients(i,:) = 0;


                    % Take a random set of X/Y points that are in the domain as tie points
                    TEMP_sample_points(block_subind,:) = randi(numel(Xmeas),[n_crossings 1]);
                    % Only allow x/y samples that are actually measured. This may have a
                    % slight bias in the tie points if there are more X than Y points - not
                    % 100% sure. It might not.
                    
                    sample_x = Xmeas(TEMP_sample_points(block_subind,:))';
                    sample_y  = Ymeas(TEMP_sample_points(block_subind,:))';

                    % Longer than the image size. We just want to create the endpoints of
                    % our "IS2" track intersecting the image
                    L= max(nx,ny);

                    % Start with a random image point and trace the line with the correct
                    % orientation w.r.t. true north backwards and forwards.

                    % Orientation angles are taken from North, not from East. For a right
                    % triangle the azimuth plus the altitude is pi/2. So we subtract
                    % the sampled azimuths from pi/2 to get the altitude angle.

                    elevation_angle = pi/2 - pi*TEMP_sample_orients(block_subind,:)/180;

                    xend = sample_x + L*cos(elevation_angle);
                    xinit = sample_x - L*cos(elevation_angle);

                    % Same for y points
                    yend = sample_y + L*sin(elevation_angle);
                    yinit = sample_y - L*sin(elevation_angle);


                    %% Initially crossing the image, display things

                    for j = 1:n_crossings

                        if parametric_lines


                            %%
                            % Parametric Values of intersection points
                            xvals = round(linspace(xinit(j),xend(j),5*(nx+ny)));
                            yvals = round(linspace(yinit(j),yend(j),5*(nx+ny)));

                            usable = (xvals > 0 & xvals <= nx & yvals > 0 & yvals <= ny);
                            xvals = xvals(usable);
                            yvals = yvals(usable);

                            % These are actual coordinates/indices
                            coords = unique([xvals; yvals]','rows','stable');


                            coord_ind = sub2ind(size(measured_map),coords(:,1),coords(:,2));
                            measured_map(coord_ind) =  measured_map(coord_ind) + 1;

                            % Total IS-2 length is all those points close to the line
                            TEMP_length_measured(block_subind,j) = sum(surface_class(coord_ind) > 0);
                            % Length of ice measured is the close points that are ice
                            TEMP_length_ice_measured(block_subind,j) = sum(surface_class(coord_ind) == 1);

                            % if plotting == 1
                            %
                            %     subplot('position',[.5 .05 xscale*.4 .3])
                            %     imagesc(measured_map')
                            %     drawnow;
                            %     set(gca,'YDir','normal')
                            %
                            % end

                        else

                            % use only those points that are not nan for distance computation
                            d = point_to_line([Xmeas Ymeas],[xinit(j) yinit(j)],[xend(j) yend(j)]);
                            measured = d < 1;
                            measured_map(measurable) = measured_map(measurable) + measured;

                            % Total IS-2 length is all those points close to the line
                            TEMP_length_measured(block_subind,j) = sum(class_measurable(measured) > 0);
                            % Length of ice measured is the close points that are ice
                            TEMP_length_ice_measured(block_subind,j) = sum(class_measurable(measured) == 1);


                        end
                    end


                    TEMP_image_done(block_subind) = 1;

                catch loaderr

                    TEMP_image_done(block_subind) = -1;


                end % LIF calculation


            end % has LIF been calculated for this image

        end % block_subind loop over images

        image_done(blockids) = TEMP_image_done;
        length_measured(blockids,:) = TEMP_length_measured;
        length_ice_measured(blockids,:) = TEMP_length_ice_measured;
        true_SIC(blockids) = TEMP_true_SIC;
        sample_orients(blockids,:) = TEMP_sample_orients;
        sample_points(blockids,:) = TEMP_sample_points; 

        save(savestr,'length_measured','length_ice_measured','image_done','sample_orients','sample_points','true_SIC','image_done')

    end % if we have any undone images

end % block loop

fprintf('\nOutput saved at %s \n',savestr)