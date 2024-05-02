%% Overall code driver for instructions
clear
close all

% First add the relevant data in a data directory (I use Data and symlink
% to the imagery, metadata, and orientation within that)

Code_folder = pwd;

%%

% Second, preprocess two thngs

% First the Orbital angles (should be done in this repo)
addpath('Orbital-Incidence/')

try load([Code_folder '/Orbital-Incidence/Orientation_Histograms.mat'])

catch errload
    preprocess_orbits;
    % Saves in Orbital-Incidence a histogram of IS2 azimuths for the RFT at
    % each latitude band

end
%%
% Now the image metadata
addpath('Locations-of-Scenes/')

try load([Code_folder '/Locations-of-Scenes/Image_Metadata.mat'])

catch errload

    preprocess_metadata; % This generates a list of summary statistics of each image
    % Note one thing - in July 17 2024, one entry is repeated (image number
    % 4405). I delete this before running this code, but it is not necessary to
    % do so if the data is downloaded fresh.

end

addpath('Emulator-Main')

try load([Code_folder '/Emulator_Main/Emulator_Data.mat'])

    if sum(isnan())

catch errload
    % Now do some emulation
    run_emulation;

end


%%

% Now do some plotting
addpath('Plotting');
plot_single_image;

