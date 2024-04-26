%% Overall code driver for instructions

% First add the relevant data in a data directory (I use Data and symlink
% to the imagery, metadata, and orientation within that)

% Second, preprocess two thngs

% First the Orbital angles (should be done in this repo)
addpath('Orbital-Incidence/')
get_orbit_kmls; 

% Saves in Orbital-Incidence a histogram of IS2 azimuths for the RFT at
% each latitude band

% Now the image metadata
addpath('Locations-of-Scenes/')
preprocess_metadata; % This generates a list of summary statistics of each image


