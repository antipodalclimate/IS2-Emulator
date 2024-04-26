% This code examines the angle of incidence of IS2 RGTs

% Set these personally
Data_folder = '/Users/chorvat/Code/IS2-Emulator/Data/Orbit-Data/';
Plot_folder = '/Users/chorvat/Dropbox (Brown)/Research Projects/Plot-Tools';

addpath(Plot_folder)
addpath(Data_folder)

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

% Discretize to every disc degree
disc = 1; % degrees
lat_vals = floor(latvals*(1/disc))*disc;

[vals,~,locs] = unique(lat_vals);




neach = accumarray(locs,1);

% Azimuth discretization for plotting/use
orients = 1:disc:180; 
orient_disc = 0.5*(orients(1:end-1) + orients(2:end));

% Latitude discretization
lat_disc = 65:disc:87; 

orientation_hist = nan(length(val),length(orients)-1);

for i = 1:length(lat_disc)

    orientation_hist(i,:) = histcounts(orientations(lat_vals == lat_disc(i)),orients,'Normalization','probability');

end


%% Make a supporting figure

subplot(211)
pcolor(orient_disc,lat_disc,orientation_hist);
shading flat; 

ylabel('Latitude');
xlabel('Azimuth')
title('Azimuth pdf by latitude','fontname','helvetica','fontsize',12)
colormap(cmocean('thermal'))
clim([0 1])
grid on; box on; 
set(gca,'fontname','helvetica','fontsize',9,'xminortick','on','yminortick','on')

subplot(212)

plot(orient_disc,orientation_hist(lat_disc == 70,:),'linewidth',1,'color','k')
hold on
plot(orient_disc,orientation_hist(lat_disc == 80,:),'linewidth',1,'color','b')
plot(orient_disc,orientation_hist(lat_disc == 87,:),'linewidth',1,'color','r')
hold off
xlabel('Azimuth');
ylabel('PDF');
grid on; box on; 
set(gca,'fontname','helvetica','fontsize',9,'xminortick','on','yminortick','on')

legend('70N','80N','87N','Location','best')

pos = [6.5 3.5]; 
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');

print('/Users/chorvat/Dropbox (Brown)/Apps/Overleaf/IS2-Concentration-Part-2/Figures/SI-azimuth.pdf','-dpdf','-r1200');

%% Save this for use with the emulator

save('Orientation_Histograms','orientation_hist','orient_disc','lat_disc')

