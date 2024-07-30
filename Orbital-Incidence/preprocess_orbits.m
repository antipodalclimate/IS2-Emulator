% This code examines the angle of incidence of IS2 RGTs
savestr = [Output_folder '/Orientation_Histograms']; 

disp('Creating Histograms of Azimuthal angles from IS2 KMLs')

%% Load in all orbit RGTs

earthellipsoid = referenceSphere('earth','km');

disp('Loading KML Data');
orbit_struct = kmz2struct([Data_folder '/Orbit-Data/Arctic_repeat1_GT7.kmz']);
disp('Done')

%%
orientations = cell(1);
latvals = cell(1);

for i = 1:length(orbit_struct)
    
    fprintf('.')
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

% Discretize to every disc degree
disc = .25; % degrees
lat_vals = floor(latvals*(1/disc))*disc;

[vals,~,locs] = unique(lat_vals);


neach = accumarray(locs,1);

% Azimuth discretization for plotting/use
orients = 1:disc:180; 
orient_disc = 0.5*(orients(1:end-1) + orients(2:end));

% Latitude discretization
lat_disc = 65:disc:87; 

orientation_hist = nan(length(lat_disc),length(orients)-1);

for i = 1:length(lat_disc)

    orientation_hist(i,:) = histcounts(orientations(lat_vals == lat_disc(i)),orients,'Normalization','probability');

end

%% Save this for use with the emulator

save(savestr,'orientation_hist','orient_disc','lat_disc')

fprintf('\n Output saved at %s.mat \n',savestr)
