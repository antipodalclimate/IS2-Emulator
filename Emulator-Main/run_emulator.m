% Run-Emulator
% this code takes in optically-classified imagery, identifies the latitude,
% and draws from a distribution of potential satellite angles.

clear
close all

% Set these personally
Data_folder = '/Users/chorvat/Code/IS2-Emulator/Data/';
Code_folder = '/Users/chorvat/Code/IS2-Emulator';
Scripts_folder = '/Users/chorvat/Code/IS2-Emulator/Scripts';

addpath(Data_folder)
addpath(Code_folder);
addpath(Scripts_folder)
addpath([Code_folder '/Orbital-Incidence']);

load('Image_Metadata.mat');
load('Orientation_Histograms.mat')

n_crossings = 50;
n_images = length(image_location);

% Initialize data

try load([Code_folder '/Emulator_output'])

    disp('Loaded data')
    fprintf('Have done %d images out of %d \n',sum(image_done),length(image_done));

catch errload

    disp('No data yet')
    [length_measured,sample_orients,length_ice_measured] = deal(nan(n_images,n_crossings));
    [true_SIC,true_OW,EB_SIC,EB_MPF] = deal(nan(n_images,1));
    image_done = zeros(n_images,1);

end


%%

for i = 1:10

    if image_done(i) == 0

        fprintf('Image Number %d \n',i);

        %%
        surface_class = (h5read(image_location{i},'/classification'));
        EB_SIC(i) = image_SIC(i);
        EB_MPF(i) = image_MPF(i);
        %%

        % All scene points that have ice/ocean data
        measurable = surface_class > 0;

        % initial map showing the locations which are hit by IS2
        measured_map = zeros(size(surface_class));

        % Specification of classified points that are measured
        class_measurable = surface_class(measurable);

        true_SIC(i) = sum(class_measurable == 1)./sum(class_measurable > 0);


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
        local_lat = image_latitude(i);
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
        sample_orients(i,:) = interp1(cum_pdf,orient_disc,samples,'nearest');

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

        elevation_angle = pi/2 - pi*sample_orients(i,:)/180;

        xend = sample_x + L*cos(elevation_angle);
        xinit = sample_x - L*cos(elevation_angle);

        % Same for y points
        yend = sample_y + L*sin(elevation_angle);
        yinit = sample_y - L*sin(elevation_angle);


        %% Initially crossing the image, display things


        plotting = 1;

        if plotting == 1

            close
            subplot('position',[.7 .4 .2 .5])
            histogram(sample_orients(i,:),1:180);
            xlabel('Orientation Angle')
            ylabel('Histogram')
            grid on; box on;

            xscale = nx/ny;

            subplot('position',[.1 .4 xscale*.5 .5])
            imagesc(surface_class'); % show the image itself.
            set(gca,'YDir','normal')
            hold on

        end
c
        for j = 1:n_crossings

            

            % use only those points that are not nan for distance computation
            d = point_to_line([Xmeas Ymeas],[xinit(j) yinit(j)],[xend(j) yend(j)]);
            measured = d < 1;

            measured_map(measurable) = measured_map(measurable) + measured;

            if plotting == 1
                scatter(sample_x(j),sample_y(j),150,'r','filled')
                plot([xinit(j) xend(j)],[yinit(j) yend(j)]);
                drawnow

            end

            % Total IS-2 length is all those points close to the line
            length_measured(i,j) = sum(class_measurable(measured) > 0);
            % Length of ice measured is the close points that are ice
            length_ice_measured(i,j) = sum(class_measurable(measured) == 1);


        end

        %% 
        if plotting == 1

            subplot('position',[.1 .1 .8 .25])
            cla
            % plot(cumsum(length_ice_measured(i,:))./cumsum(length_measured(i,:)),'k')
            hold on
            yline(0,'r','linewidth',2)

            for j = 1:n_crossings
                rp = randperm(n_crossings); 
                est(j,:) = cumsum(length_ice_measured(i,rp))./cumsum(length_measured(i,rp)); 

            end

            plot(mean(est,2) - true_SIC(i),'k','linewidth',2); 
            plot(std(est,[],2),'--','color',[.8 .8 .8]); 
            plot(-std(est,[],2),'--','color',[.8 .8 .8]); 
            hold off
        end

        %%
        image_done(i) = 1;

        save([Code_folder '/Emulator_Data'],'length_measured','sample_orients','length_ice_measured','true_SIC,true_OW,EB_SIC,EB_MPF','image_done')


    end

end