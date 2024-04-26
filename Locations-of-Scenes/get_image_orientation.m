% get_image_orientation
% this code looks at individual scenes from icebridge data and calculates
% their lat/lon and relative orientation to north.
clear
close all

% Set these personally
Data_folder = '/Users/chorvat/Code/IS2-Emulator/Data/';

addpath(Data_folder)

imagery_metadata = dir([Data_folder 'NOAA*.txt']);

% List all hdf5 images
image_list = dir([Data_folder '*/*/*/*.h5']);

for i = 1:1
 
    textfile = ['NOAA_LSA_PODS.Arc.SummerMelt.v01.' strrep(image_list(i).folder(end-10:end),'/','')]
    
    



end

