%% Overall code driver for instructions

% First add the relevant data in a data directory (I use Data and symlink
% to the imagery, metadata, and orientation within that)

Code_folder = '/Users/chorvat/Code/IS2-Emulator';

% Second, preprocess two thngs

% First the Orbital angles (should be done in this repo)
addpath('Orbital-Incidence/')
preprocess_orbits; 

% Saves in Orbital-Incidence a histogram of IS2 azimuths for the RFT at
% each latitude band

% Now the image metadata
addpath('Locations-of-Scenes/')
preprocess_metadata; % This generates a list of summary statistics of each image
% Note one thing - in July 17 2024, one entry is repeated (image number
% 4405). I delete this before running this code, but it is not necessary to
% do so if the data is downloaded fresh. 

% Now do some emulation
addpath('Emulator-Main')
run_emulation; 


