% Run-Emulator
% this code takes in optically-classified imagery, identifies the latitude,
% and draws from a distribution of potential satellite angles.
n_crossings = 50;
n_images = length(image_location);

% Initialize data

try load([Emulator_folder '/Emulator_Data.mat'])

    disp('Loaded data')
    fprintf('Have done %d images out of %d \n',sum(image_done),length(image_done));

catch errload

    disp('No data yet')
    [length_measured,sample_orients,length_ice_measured] = deal(nan(n_images,n_crossings));
    [true_SIC,true_OW] = deal(nan(n_images,1));
    image_done = zeros(n_images,1);

end


%%

plotting = 0;

% Include a parametric depiction of flyover x-y coordinates.
% If 0, use a distance calculation
parametric_lines = 1;

block_length = 100;

nblocks = ceil(n_images/block_length);


for block_ind = 1:nblocks

    disp('------------------------------');
    fprintf('BLOCK %d of %d \n',block_ind,nblocks);
    disp('------------------------------');

    blockids = block_length*(block_ind - 1) + 1 :block_length*block_ind;
    blockids(blockids > length(image_done)) = []; 

    % Initialize temporary variables
    TEMP_image_done = image_done(blockids); 
    TEMP_true_SIC = true_SIC(blockids); 
    TEMP_length_measured = length_measured(blockids,:);
    TEMP_length_ice_measured = length_ice_measured(blockids,:); 
    TEMP_sample_orients = sample_orients(blockids,:);

    % Parallelize the sub-blocks
    parfor block_subind = 1:length(blockids); 

        % Index of the image itself
        image_ind = block_length*(block_ind - 1) + block_subind;

        %%

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
                sample_points = randi(numel(Xmeas),[n_crossings 1]);
                % Only allow x/y samples that are actually measured. This may have a
                % slight bias in the tie points if there are more X than Y points - not
                % 100% sure. It might not.
                sample_x = Xmeas(sample_points)';
                sample_y = Ymeas(sample_points)';

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


                %
                % if plotting == 1
                %
                %     close
                %     subplot('position',[.7 .4 .2 .5])
                %     histogram(sample_orients(i,:),1:180);
                %     xlabel('Orientation Angle')
                %     ylabel('Histogram')
                %     grid on; box on;
                %
                %     xscale = nx/ny;
                %
                %     Ax_surf = subplot('position',[.1 .4 xscale*.5 .5]);
                %     imagesc(surface_class'); % show the image itself.
                %     set(gca,'YDir','normal')
                %     hold on
                %
                % end
                %

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
                    %
                    % if plotting == 1
                    %
                    %     scatter(Ax_surf,sample_x(j),sample_y(j),150,'r','filled')
                    %     plot(Ax_surf,[xinit(j) xend(j)],[yinit(j) yend(j)]);
                    %     drawnow
                    %
                    % end



                end

                %%
                % if plotting == 1
                %
                %     subplot('position',[.1 .1 .8 .25])
                %     cla
                %     % plot(cumsum(length_ice_measured(i,:))./cumsum(length_measured(i,:)),'k')
                %     hold on
                %     yline(0,'r','linewidth',2)
                %
                %     for j = 1:n_crossings
                %         rp = randperm(n_crossings);
                %         est(j,:) = cumsum(length_ice_measured(i,rp))./cumsum(length_measured(i,rp));
                %
                %     end
                %
                %     plot(mean(est,2) - true_SIC(i),'k','linewidth',2);
                %     plot(mean(est,2) - true_SIC(i) + std(est,[],2),'--','color',[.8 .8 .8]);
                %     plot(mean(est,2) - true_SIC(i) -std(est,[],2),'--','color',[.8 .8 .8]);
                %     hold off
                % end

                %%

                %

                TEMP_image_done(block_subind) = 1;

            catch loaderr

                TEMP_image_done(block_subind) = -1;


            end


        end
        
    end

    image_done(blockids) = TEMP_image_done;
    length_measured(blockids,:) = TEMP_length_measured;
    length_ice_measured(blockids,:) = TEMP_length_ice_measured;
    true_SIC(blockids) = TEMP_true_SIC;
    sample_orients(blockids,:) = TEMP_sample_orients;

    save([Code_folder '/Emulator-Main/Emulator_Data'],'image_location','length_measured','length_ice_measured','image_done','sample_orients','true_SIC','image_done')


end

