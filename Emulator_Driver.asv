%% Overall code driver for instructions
clear
close all

% First add the relevant data in a data directory (I use Data and symlink
% to the imagery, metadata, and orientation within that)

% Locations of various subfolders. Change if necessary.  
Code_folder = pwd;
Orbit_folder = [Code_folder '/Orbital-Incidence'];
Metadata_folder = [Code_folder '/Location-of-Scenes'];
Emulator_folder = [Code_folder '/Emulator-Main'];
Plotting_folder = [Code_folder '/Plotting']; 

%%

% Second, preprocess two thngs

% First the Orbital angles (should be done in this repo)
% See if we have latitude-based orientation histograms. This is easy to
% make with the IS2 KMLs so shouldn't be a problem. 

try load([Orbit_folder 'Orientation_Histograms.mat'])

    disp('Loaded Orbital Data');

catch errload

    disp('Creating Orbital Data');
    addpath(Orbit_folder)
    preprocess_orbits;
    % Saves in Orbital-Incidence a histogram of IS2 azimuths for the RFT at
    % each latitude band

end

%%
% Now the image metadata

try load([Metadata_folder '/Image_Metadata.mat'])

catch errload

    addpath(Metadata_folder)
    preprocess_metadata; % This generates a list of summary statistics of each image
    % Note one thing - in July 17 2024, one entry is repeated (image number
    % 4405). I delete this before running this code, but it is not necessary to
    % do so if the data is downloaded fresh.

end

%% Now do the actual emulation



try load([Emulator_folder '/Emulator_Data.mat'])
    
    

catch errload

    addpath('Emulator-Main')
    % Now do some emulation
    run_emulation;

end


%%

% Now do some plotting
addpath('Plotting');
plot_single_image;

