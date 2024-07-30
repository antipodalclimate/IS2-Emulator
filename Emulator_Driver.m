%% Overall code driver for instructions
% Clear all variables and close all figures
clear
close all

% Define the folder paths relative to the current directory
Code_folder = pwd;
Data_folder = [Code_folder '/Data']; % Adjust based on your local setup
Output_folder = [Code_folder '/Output']; % Adjust based on your local setup
Orbit_folder = [Code_folder '/Orbital-Incidence'];
Metadata_folder = [Code_folder '/Locations-of-Scenes'];
Emulator_folder = [Code_folder '/Emulator-Main'];
Plotting_folder = [Code_folder '/Plotting']; 
Script_folder = [Code_folder '/Scripts']; 

% Figure_folder = '~/Library/CloudStorage/Dropbox-Brown/Apps/Overleaf/IS2-Concentration-Part-2/Figures';
Figure_folder = '/Users/chorvat/Dropbox (Brown)/Apps/Overleaf/IS2-Concentration-Part-2/Figures';

%% Load or create orbital data

% Second, preprocess two thngs

% First the Orbital angles (should be done in this repo)
% See if we have latitude-based orientation histograms. This is easy to
% make with the IS2 KMLs so shouldn't be a problem. 

try load([Output_folder '/Orientation_Histograms.mat'])

    disp('Loaded Orbital Data');

catch errload

    disp('Creating Orbital Data');
    addpath(Orbit_folder)
    preprocess_orbits;
    % Saves in Orbital-Incidence a histogram of IS2 azimuths for the RFT at
    % each latitude band

end

%% Load or create image metadata

try load([Output_folder '/Image_Metadata.mat'])

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

%% Load LIF data and decide whether to run emulation

try load([Output_folder '/Emulator_Data.mat'])
    
    disp('Loaded Existing Emulation Data')

    fprintf('%d out of %d images have LIF data \n',sum(image_done ~= 0),length(image_location));
    
    if sum(image_done ~= 0) < length(image_location)
        error('Incomplete data: we need to run the emulator.');
    else
        disp('Data is complete')
    end

catch err_em

    disp(err_em.message)
    addpath('Emulator-Main')
    run_emulation; % Run LIF calculator for those images without an LIF

end

%% Plotting 

% Cleanup workspace, except for folder paths
clearvars -except *_folder

load([Output_folder '/Orientation_Histograms.mat']);
load([Output_folder '/Emulator_Data.mat']);
load([Output_folder '/Image_Metadata.mat']);

% Now do some plotting
addpath(Plotting_folder)
addpath(Script_folder)

% Orbital orientation figure
plot_orbital_data(Figure_folder,orientation_hist,lat_disc,orient_disc);

%%
% Figure of emulation on a single random image
plot_single_image(Figure_folder,image_location,image_done,true_SIC,length_ice_measured,length_measured,sample_orients,sample_points);



%% Now examine 
plot_bias_data; 

%% Now plot the LIF global biases vs non