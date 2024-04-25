% This code examines the angle of incidence of IS2 RGTs

Data_folder = '../Data/Orbit-Data/'

orbitlist = dir([Data_folder '*.kmz']);

dummy_struct = kmz2struct([orbitlist(1).folder '/' orbitlist(1).name]);

%% Load in all orbit RGTs

earthellipsoid = referenceSphere('earth','km');

for orbit_ind = 1:length(orbitlist)

    fprintf('Orbit %d \n',orbit_ind); 
    dummy_struct = kmz2struct([orbitlist(orbit_ind).folder '/' orbitlist(orbit_ind).name]);


    for i = 1:length(dummy_struct)


        lats = dummy_struct(i).Lat;
        lons = dummy_struct(i).Lon;

        % Formula for the azimuth
        % azimuth(lat1,lon1,lat2,lon2,ellipsoid)
        % atan2(x,y)
        % x = sin(dlon)cos(lat2)
        % y = cos(lat1)sin(lat2) - sin(lat1)cos(lat2)cos(dlon)

        orientations{orbit_ind,i} = azimuth(lats(1:end-1),lons(1:end-1),lats(2:end),lons(2:end),earthellipsoid);
        latvals{orbit_ind,i} = 0.5*(lats(1:end-1) + lats(2:end));

    end

end
%% Form a PDF of incidence angle as a function of latitude

orientations = cell2mat(orientations);

latvals = cell2mat(latvals);

% Discretize to 0.1 degree
latvals = floor(latvals*10)/10;

[val,~,locs] = unique(latvals);

neach = accumarray(locs,1);







%% Save this for use with the emulator



