%% Overall code driver for instructions
clear
close all

% First add the relevant data in a data directory (I use Data and symlink
% to the imagery, metadata, and orientation within that)

% Locations of various subfolders. Change if necessary.  
Code_folder = pwd;
Data_folder = [Code_folder '/Data']; % Data is not included in the Github repo and so this should likely be edited on your local machine
Orbit_folder = [Code_folder '/Orbital-Incidence'];
Metadata_folder = [Code_folder '/Locations-of-Scenes'];
Emulator_folder = [Code_folder '/Emulator-Main'];
Plotting_folder = [Code_folder '/Plotting']; 
Figure_folder = '/Users/chorvat/Dropbox (Brown)/Apps/Overleaf/IS2-Concentration-Part-2/Figures';
%%

% Second, preprocess two thngs

% First the Orbital angles (should be done in this repo)
% See if we have latitude-based orientation histograms. This is easy to
% make with the IS2 KMLs so shouldn't be a problem. 

try load([Orbit_folder '/Orientation_Histograms.mat'])

    disp('Loaded Orbital Data');

catch errload

    disp('Creating Orbital Data');
    addpath(Orbit_folder)
    preprocess_orbits;
    % Saves in Orbital-Incidence a histogram of IS2 azimuths for the RFT at
    % each latitude band

end

%% Now the image metadata

try load([Metadata_folder '/Image_Metadata.mat'])

        fprintf('Loaded Image MetaData for %d Images \n',length(image_SIC));

catch errload

    disp('Creating Image metadata');
    addpath(Metadata_folder)
    preprocess_metadata; % This generates a list of summary statistics of each image
    % Note one thing - in July 17 2024, one entry is repeated (image number
    % 4405). I delete this before running this code, but it is not necessary to
    % do so if the data is downloaded fresh.
    fprintf('\nCreated Image MetaData for %d Images \n',length(image_SIC));
    
end

%% Now do the actual emulation

try load([Emulator_folder '/Emulator_Data.mat'])
    
    disp('Loaded Existing Emulation Data')

    fprintf('%d out of %d images have LIF data \n',sum(image_done ~= 0),length(image_location));
    
    if sum(image_done ~= 0) < length(image_location)
        throw(errload)
    else
        disp('Not running emulator')
    end

catch errload

    disp('Running the emulator...')
    addpath('Emulator-Main')
    % Now do some emulation
    run_emulation;

end


%%
clearvars -except *_folder

load([Orbit_folder '/Orientation_Histograms.mat']);
load([Emulator_folder '/Emulator_Data.mat']);
load([Metadata_folder '/Image_Metadata.mat']);

% Now do some plotting
addpath('Plotting');

% Orbital orientation figure
plot_orbital_data(Figure_folder,orientation_hist,lat_disc,orient_disc);

% Figure of emulation on a single random image


plot_single_image(Figure_folder,image_location,image_done,true_SIC,length_ice_measured,length_measured,sample_orients)
