% clc
% clear all
% close all

% SET-UP VARIABLES
% -------------------------------------------------------------------
dx = 1; % m 
nx = 2500; % unitless
Lx = nx*dx; % m

dy = 1;
ny = 2500;
Ly = ny*dy;

% Create the x and y coordinates and the meshed grid
x = linspace(0,(nx-1)*dx,nx);
y = linspace(0,(ny-1)*dy,ny);

[X,Y] = meshgrid(x,y);

ideal_SIC = 0.95;

% --------------------------------------------------------------------

ice_surface = zeros(size(X)); % start with grid of 0s (open water)
for i = 1:nx
    for j = 1:ny % for each (i,j) coordinate
        r = rand; % generate random number 0-1
        if r < ideal_SIC % if less than desired SIC
            ice_surface(i,j) = 1; % make it a 1 (ice)
        end
    end
end

% ------------------------------------------------------------------------
% helpful stats
area_total = Lx*Ly;
area_ice = dx*dy*sum(ice_surface(:));
trueSIC = 100*area_ice/area_total;