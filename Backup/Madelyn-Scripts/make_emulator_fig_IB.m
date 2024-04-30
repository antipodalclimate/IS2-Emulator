% make_fig_emulator
clear
close all

load('madelyns_data.mat')
load('examp_lines.mat'); 
filelist = dir('/Users/chor531/Dropbox (Brown)/Research Projects/Active/ICESAT-2/LIF/Emulator-Code/h5IceBridge/*.h5'); 
horvat_colors

%% 
error_rand = bsxfun(@minus,random_estSIC,permute(random_trueSIC,[3 1 2]));
error_pancake = bsxfun(@minus,pancake_estSIC,permute(pancake_trueSIC,[3 1 2])); 
error_IB = bsxfun(@minus,IB_estSIC,permute(IB_trueSIC,[3 1 2]));

[ntrials,nit,nexamp] = size(error_IB); 

examp_ID = 25; 
examp_surface = IB_surfaces(:,:,examp_ID); 
filename = filelist(examp_ID).name(1:5); 

X = (1:size(examp_surface,1)); 
Y = (1:size(examp_surface,2));

figure(1)
clf
Ax{1} = subplot('position',[.05 .05 .4 .9]); 

imagesc(X,Y,examp_surface)
colormap(cmocean('ice')); 
shading flat; 
set(gca,'xticklabel',{},'yticklabel',{})
grid on; box on; 
title(['OIB Image ' filename],'interpreter','latex')

hold on

for i = 1:15
    line(X_save{i},Y_save{i},'color',clabs(1,:),'Linestyle','--'); 
end

Ax{2} = subplot('position',[.525 .575 .45 .375]);
plot(1:15,squeeze(error_IB(1:15,:,examp_ID)),'color',[.9 .9 .9],'linewidth',1)
hold on; 
plot(1:15,squeeze(error_IB(1:15,randi(nit),examp_ID)),'color','k','linewidth',1)
boxplot(error_IB(:,:,examp_ID)','symbol','','whisker',0);
xlim([1 15])
ylim([-10 10])
yline(2.0,'--','color',clabs(1,:),'linewidth',1); 
yline(-2.0,'--','color',clabs(1,:),'linewidth',1); 

grid on; box on; 
ylabel('SIC error');
title(['SIC Error for OIB Image ' filename],'interpreter','latex')


Ax{3} = subplot('position',[.525 .1 .45 .375]);

yvals = reshape(error_IB(:,:,:),[],nit*nexamp)'; 
xvals = 1:ntrials; 

p1 = plot(xvals,median(yvals),'linewidth',2,'color',[.5 .5 .5]);
hold on
jbfill(xvals,prctile(yvals,75),prctile(yvals,25),[.5 .5 .5],[.5 .5 .5],1,.25); 



%
yvals = reshape(error_pancake(:,:,:),[],nit*nexamp)'; 
xvals = 1:size(error_pancake,1); 

hold on
p2 = plot(xvals,median(yvals),'linewidth',2,'color',clabs(2,:));
jbfill(xvals,prctile(yvals,75),prctile(yvals,25),clabs(2,:),clabs(2,:),1,.25); 

yvals = reshape(error_rand(:,:,:),[],nit*nexamp)'; 
xvals = 1:15; 
hold on

p3 = plot(xvals,median(yvals),'linewidth',2,'color',clabs(3,:));
jbfill(xvals,prctile(yvals,75),prctile(yvals,25),clabs(3,:),clabs(3,:),1,.25); 

p4 = yline(2.0,'--','color',clabs(1,:),'linewidth',1); 
yline(-2.0,'--','color',clabs(1,:),'linewidth',1); 
% 
% boxplot(r'symbol','','colors',[.5 .5 .5],'BoxStyle','filled','Widths',1);
% hold on
% boxplot(reshape(error_rand,[],nit*nexamp)','symbol','','colors','b')
xlim([1 15])
ylim([-5 5])
xlabel('Crossing Number');
grid on; box on; 
ylabel('SIC error');
title(['SIC Error'],'interpreter','latex')

legend([p1,p2,p3 p4],'OIB','Pancakes','Random','Winter Bias');

for i = 1:length(Ax)
    set(Ax{i},'fontsize',8);
end

pos = [6.5 3.5];
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
print('/Users/chor531/Dropbox (Brown)/Apps/Overleaf/IS2-Concentration/Figures/emulator.pdf','-dpdf','-r1200');
% 