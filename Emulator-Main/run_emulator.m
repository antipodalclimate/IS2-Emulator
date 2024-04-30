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
n_images = 1; 

[length_all,sample_orients,length_ice] = nan(n_images,n_crossings);
[true_SIC,true_OW] = nan(n_images);

for i = 1:n_images

    %%
    surface_class = (h5read(image_location{i},'/classification'));

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
    
    % Take a random set of X/Y points that are in the domain as tie points
    sample_points = randi(numel(Xmeas),[n_crossings 1]);
    % Only allow x/y samples that are actually measured. This may have a
    % slight bias in the tie points if there are more X than Y points - not
    % 100% sure. It might not. 
    sample_x = Xmeas(sample_points);
    sample_y = Ymeas(sample_points);
    
    % Longer than the image size. We just want to create the endpoints of
    % our "IS2" track intersecting the image
    L= max(nx,ny);

    % Start with a random image point and trace the line with the correct
    % orientation w.r.t. true north backwards and forwards.
    xend = sample_x + L*cos(sample_orients);
    xinit = sample_x - L*cos(sample_orients);

    % Same for y points
    yend = sample_y + L*sin(sample_orients);
    yinit = sample_y - L*sin(sample_orients);

   
    %% Initially crossing the image, display things
    close 

    subplot(311)
    histogram(sample_orients,1:180);
    xlabel('Orientation Angle')
    ylabel('Histogram')
    grid on; box on; 

    subplot('position',[.1 .1 .8 .5])
    imagesc(X,Y,surface_class); % show the image itself. 
    hold on

    for j = 1:n_crossings

        % use only those points that are not nan for distance computation
        d = point_to_line([Xmeas Ymeas],[xinit(j) yinit(j)],[xend(j) yend(j)]);
        measured = d < 1;
        measured_map(measurable) = measured_map(measurable) + measured; 
        scatter(xinit(1),yinit(1),10,'filled')
        plot([xinit(j) xend(j)],[yinit(j) yend(j)]);

        % Total IS-2 length is all those points close to the line
        length_measured(i,j) = sum(class_measurable(measured) > 0);
        % Length of ice measured is the close points that are ice
        icearea_measured(i,j) = sum(class_measurable(measured) == 1);

        drawnow
    
    end

    %%
 




end