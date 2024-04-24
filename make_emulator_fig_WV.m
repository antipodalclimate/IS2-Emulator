% make_fig_emulator
clear
close all

% Add plotting tools
addpath('~/Dropbox (Brown)/Research Projects/Plot-Tools/');
horvat_colors

% list of OIB files
OIB_filelist = dir('h5IceBridge/*.h5'); 

% First load in the WorldView Data from Ellen
filename = 'WVclass_forChris/WV02_20200407221636_classification.h5';
ice_surface = double(h5read(filename,'/classification'));
dx = 0.5; % m

% If we want to take a subset
skipper = 10; 


% Take a slightly reduced inset
ice_surface = ice_surface(100:end-100,100:end-100);
ice_surface = ice_surface(1:skipper:end,1:skipper:end);

dx = dx*skipper; 
[nx,ny] = size(ice_surface); 
% Create the x and y coordinates and the meshed grid
X = linspace(0,(nx-1)*dx,nx);
Y = linspace(0,(ny-1)*dx,ny);


% Some basic statistics
% Create a masked surface
binary_surface = nan*ice_surface; % All incl. border
binary_surface(ice_surface == 1) = 1; % Ice
binary_surface(ice_surface == 2) = 0; % Open Water
binary_surface(ice_surface == 3) = 1; % Melt Pond
binary_surface(ice_surface == 4) = 1; % New Ice

% SIC (assuming even spacing)
WV_SIC = 100*sum(binary_surface(:)) / numel(binary_surface(:));
ASI_SIC = 94.5; 
OSI_SIC = 99.9; 
CDR_SIC = 100; 

dolines = 1;

if dolines
    
    nlines = 25; % number of example trials
    [X_save,Y_save,area_measured,icearea_measured,measuredSIC] = IS2_emulator(binary_surface,nlines,dx);
    
    save('generated_lines','X_save','Y_save','area_measured','icearea_measured','measuredSIC');
    
else
    
    load('generated_lines');
    nlines = length(X_save); 
    
end

%% Now compute error statistics


% load in statistics from Madelyn's work
load('madelyns_data.mat');

error_rand = bsxfun(@minus,random_estSIC,permute(random_trueSIC,[3 1 2]));
error_pancake = bsxfun(@minus,pancake_estSIC,permute(pancake_trueSIC,[3 1 2]));
error_IB = bsxfun(@minus,IB_estSIC,permute(IB_trueSIC,[3 1 2]));

% Look at WV 
error_WV = measuredSIC - WV_SIC; 

figure(1)
clf
Ax{1} = subplot('position',[.075 .075 .4 .85]);

imagesc(X,Y,binary_surface)
colormap(cmocean('ice'));
shading flat;
set(gca,'xticklabel',{},'yticklabel',{})
grid on; box on;
title(['WV Image 20200407221636'],'interpreter','latex')

hold on

for i = 1:nlines
    line(X_save{i},Y_save{i},'color',clabs(1,:),'Linewidth',1,'Linestyle','--');
end

Ax{2} = subplot('position',[.535 .575 .45 .375]);
hold on
scatter(1:nlines,100*icearea_measured./area_measured,20,'+','MarkerEdgeColor',clabs(1,:)); 
plot(measuredSIC,'color',clabs(2,:)); 
yline(WV_SIC,'k','linewidth',1,'label','True SIC','LabelHorizontalAlignment','center'); 
yline(ASI_SIC,'color',clabs(3,:),'linewidth',1,'label','AMSR2-ASI'); 
yline(OSI_SIC,'color',clabs(4,:),'linewidth',1,'label','OSI-450','LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right'); 
yline(CDR_SIC,'color',clabs(5,:),'linewidth',1,'label','CDR','LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left'); 

% 
% yline(WV_SIC + 2,'--k','linewidth',0.5);
% yline(WV_SIC - 2,'--k','linewidth',0.5); 

grid on; box on; 
xlabel(''); 
ylabel('SIC (\%)'); 
legend('Individual','Cumulative','location','best'); 
xlim([1 15]);
title('Convergence for WV image','interpreter','latex'); 
%

[maxtrials,nit,nexamp] = size(error_IB); 


examp_ID = randi(nexamp,1); 
examp_it = randi(nit,1); 


% Ax{3} = subplot('position',[.525 .575 .45 .375]);
% cla
% plot(1:nlines,squeeze(error_IB(1:nlines,:,examp_ID)),'color',[.9 .9 .9],'linewidth',1)
% hold on;
% plot(1:nlines,squeeze(error_IB(1:nlines,examp_it,examp_ID)),'color','k','linewidth',1)
% boxplot(error_IB(:,:,examp_ID)','symbol','','whisker',0);
% xlim([1 15])
% ylim([-10 10])
% yline(2.0,'--','color',clabs(1,:),'linewidth',1);
% yline(-2.0,'--','color',clabs(1,:),'linewidth',1);
% 
% grid on; box on;
% ylabel('SIC error');
% title(['SIC Error for OIB Image ' OIB_filelist(examp_ID).name(1:5)],'interpreter','latex')
% 

Ax{3} = subplot('position',[.535 .1 .45 .375]);

yvals = reshape(error_IB(:,:,:),[],nit*nexamp)';
xvals = 1:maxtrials;

p1 = plot(xvals,median(yvals),'linewidth',2,'color',[.5 .5 .5]);
hold on
jbfill(xvals,prctile(yvals,75),prctile(yvals,25),[.5 .5 .5],[.5 .5 .5],1,.25);



%
% yvals = reshape(error_pancake(:,:,:),[],nit*nexamp)';
% xvals = 1:size(error_pancake,1);
% 
% hold on
% p2 = plot(xvals,median(yvals),'linewidth',2,'color',clabs(2,:));
% jbfill(xvals,prctile(yvals,75),prctile(yvals,25),clabs(2,:),clabs(2,:),1,.25);

yvals = reshape(error_rand(:,:,:),[],nit*nexamp)';
xvals = 1:15;
hold on

% p3 = plot(xvals,median(yvals),'linewidth',2,'color',clabs(3,:));
% jbfill(xvals,prctile(yvals,55),prctile(yvals,5),clabs(3,:),clabs(3,:),1,.25);
% hold on

% p4 = plot(1:nlines,error_WV,'linewidth',2,'color',clabs(1,:)); 
% hold on

p5 = yline(2.2,'--','color',clabs(1,:),'linewidth',1);
yline(-2.2,'--','color',clabs(1,:),'linewidth',1);
xline(8,'--k')
xlim([1 15])
ylim([-5 5])
xlabel('Crossing Number');
grid on; box on;
ylabel('SIC error (\%)');
title(['SIC error (\%)'],'interpreter','latex')


%
h2 = legend([p1,p5],'OIB','Winter Bias');



letter = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(e)','(c)'};


for i = 1:length(Ax)
    
   
    
end
for i = 1:length(Ax)
    
 posy = get(Ax{i},'position');

    set(Ax{i},'fontname','times','fontsize',8,'xminortick','on','yminortick','on')
    
    annotation('textbox',[posy(1) - .025 posy(2)+posy(4) + .035 .025 .025], ...
        'String',letter{i},'LineStyle','none','FontName','Helvetica', ...
        'FontSize',8,'Tag','legtag');

end

pos = [6.5 3.5];
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
print('/Users/chorvat/Dropbox (Brown)/Apps/Overleaf/IS2-Concentration/Figures/emulator.pdf','-dpdf','-r1200');
%