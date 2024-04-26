% This code examines the angle of incidence of IS2 RGTs

Data_folder = '../Data/Orbit-Data/';

%% Load in all orbit RGTs

earthellipsoid = referenceSphere('earth','km');

orbit_struct = kmz2struct([Data_folder 'Arctic_repeat1_GT7.kmz']);

%%
orientations = cell(1);
latvals = cell(1);

for i = 1:length(orbit_struct)

    lats = orbit_struct(i).Lat;
    lons = orbit_struct(i).Lon;

    % Formula for the azimuth
    % azimuth(lat1,lon1,lat2,lon2,ellipsoid)
    % atan2(x,y)
    % x = sin(dlon)cos(lat2)
    % y = cos(lat1)sin(lat2) - sin(lat1)cos(lat2)cos(dlon)

    orientations{i} = azimuth(lats(1:end-1),lons(1:end-1),lats(2:end),lons(2:end),earthellipsoid);
    latvals{i} = 0.5*(lats(1:end-1) + lats(2:end));

end

orientations = cell2mat(orientations);

% make orientations non-symmetric
% Orientation 90 is direct W-E and same as 270
% Orientation 180 is direct N-S and same as 360

orientations(orientations > 180) = 360 - orientations(orientations > 180);

latvals = cell2mat(latvals);

%% Form a PDF of incidence angle as a function of latitude


% Discretize to 0.1 degree
latvals = floor(latvals*5)/5;

[val,~,locs] = unique(latvals);

neach = accumarray(locs,1);

orients = 1:180; 

for i = 1:length(val)

    ohist(i,:) = histcounts(orientations(latvals == val(i)),orients,'Normalization','percentage');

end

%% Save this for use with the emulator



