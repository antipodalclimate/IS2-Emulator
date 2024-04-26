% get_image_orientation
% this code looks at individual scenes from icebridge data and calculates
% their lat/lon and relative orientation to north.
clear
close all

% Set these personally
Data_folder = '/Users/chorvat/Code/IS2-Emulator/Data/';

addpath(Data_folder)

load('Image_Metadata.mat');

