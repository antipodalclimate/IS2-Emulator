% Code to plot a supporting figure for orbital data

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