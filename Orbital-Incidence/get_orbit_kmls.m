% This code examines the angle of incidence of IS2 RGTs

Data_folder = '../Data/Orbit-Data/'

orbitlist = dir([Data_folder '*.kmz']); 

dummy_struct = kmz2struct([orbitlist(1).folder '/' orbitlist(1).name]);

% Load in all orbit RGTs

% At a specified latitude, get the angles of potential incidence 

% Form a PDF of incidence angle as a function of latitude

% Save this for use with the emulator
