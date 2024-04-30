close

% this uses madelyns_data.mat
% folder includes trueSIC, estSIC, and distance (dist) data sets for IceBridge (IB), pancake, and random surfaces 
% also includes IceBridge surfaces I used in order just in case
% for the dist and estSIC doubles, dimensions are nlines x nruns x nsurfaces (like everything else)
% all SIC data is in percent form

load madelyns_data.mat

AD_rand = zeros(15,31,30); % AD = absolute difference
AD_panc = zeros(150,31,30);
AD_IB = zeros(200,31,30);

for j = 1:30
    AD_rand(:,:,j) = abs(random_estSIC(:,1:31,j) - random_trueSIC(1,j));
    AD_panc(:,:,j) = abs(pancake_estSIC(:,:,j) - pancake_trueSIC(1,j));
    AD_IB(:,:,j) = abs(IB_estSIC(:,:,j) - IB_trueSIC(1,j));
end


% histogram of error on IceBridge trials
figure()
edges = linspace(0,25,26); % all error is between 0-25
histogram(AD_IB(2,:,1:28),edges,'FaceColor',[0.3010 0.7450 0.9330]) % 2nd run, light blue color, set integer bins
hold on
histogram(AD_IB(8,:,1:28),edges,'FaceColor','b') % 8th run, same bins
histogram(AD_IB(20,:,1:28),edges,'FaceColor','black') % 20th run
legend('2nd transect', '8th transect', '20th transect')
xlabel('Error')
ylabel('Number of Trials')
title('Histogram of IceBridge Error')
box on; grid on


% scatterplot of averages across each surface
figure()
npoints = 15; % set how many transects you want in scatterplot
averages = zeros(3,npoints);
for j = 1:npoints
    averages(j,1) = mean(mean(AD_rand(j,:,:))); % randomized, take mean across trials and then surfaces for each
    averages(j,2) = mean(mean(AD_panc(j,:,:))); % circle
    averages(j,3) = mean(mean(AD_IB(j,:,:))); % IceBridge
end
scatter(1:npoints,averages(:,1),100,'*','b') % randomized
hold on
scatter(1:npoints,averages(:,2),100,'b') % circle
scatter(1:npoints,averages(:,3),100,'+','b') % IceBridge
legend('randomized','circle','IceBridge')
xlabel('Number of transects')
ylabel('Error')
yline(3,'--k','PM standard error')
box on; grid on
title('Average Absolute Error')



% for the last one, need to run an emulator trial and use that data

% everything below should be set up for after running IS2_emulator once
% % needed variables -- ice surface, measured map, area measured, area IS2,
% % area ice, area total, true SIC, nlines
% 
% figure()
% % ice surface
% subplot(221)
% imagesc(ice_surface0) % desired ice surface
% colormap(cmocean('ice'))
% title('Ice Surface')
% box on; grid on
% 
% % measured map
% subplot(222)
% imagesc(measured_map)
% title('Number of Times Measured')
% box on; grid on
% % colormap('jet') % image isn't super clear under the ice colormap, looks better with this one
% 
% % estimated SIC by transect
% subplot(223)
% scatter(1:nlines,100*area_measured./area_IS2, 50,'blue'); % scatter measurements along individual transects
% hold on
% plot(1:50,100*cumsum(area_measured)./cumsum(area_IS2),'blue','LineWidth',2); % plot running estimated SIC by transect
% yline(100*area_ice/area_total,'--k','LineWidth',2); % line at true SIC
% ylabel('Estimated SIC');
% xlim([0 nlines])
% xlabel('Number of Transects')
% title('Estimated SIC')
% legend('transect SIC','estimated SIC','true SIC')
% box on; grid on
% 
% % error by transect
% absdiff = abs(100*cumsum(area_measured)./cumsum(area_IS2) - trueSIC);
% subplot(224)
% xlabel('Number of Transects')
% xlim([0,nlines])
% hold on
% ylabel('Error')
% title('Absolute Error')
% scatter(1:nlines,absdiff,36,'MarkerFaceColor',[0,.375,.99],'MarkerEdgeColor','k')
% yline(3,'--k','PM standard error','LineWidth',2); % line at PM standard error
% box on; grid on
