

usable = true_SIC < .99 & true_SIC > 0.1 & ~isnan(true_SIC);


% Number of images, sequential crossings, and therefore number of potential
% permutations of those crossings
n_images = sum(usable);
n_crossings = size(length_measured,2);
perm_length = 50; 
n_perms = 4*n_crossings;


% Measured SIC when accumulating crossings
im_meas_SIC = nan(n_images,perm_length,n_perms);
tot_length = im_meas_SIC; 

% For each permutation, take the cumulative sum in each image of the random
% permutation of images. 
for j = 1:n_perms

    % randomly permute the number of crossings
    rp = randi(n_crossings,[perm_length 1]);
    im_meas_SIC(:,:,j) = cumsum(length_ice_measured(usable,rp),2)./cumsum(length_measured(usable,rp),2);
    tot_length(:,:,j) = cumsum(length_measured(usable,rp),2);

end


%% Compute bias fields

% Difference between actual SIC and the accumulated SIC. 
SIC_bias = bsxfun(@minus,true_SIC(usable),im_meas_SIC);

% Long-term LIF
LIF_star = mean(im_meas_SIC(:,end,:),3);
% Bias from true value
Bias_i = true_SIC(usable) - LIF_star; 
% Variability at end of crossings
Std_i = 100*std(SIC_bias(:,end,:),[],3,'omitnan'); 

% Take the mean bias as a function of crossing number.

% Mean bias per crossing averaged over all permutations and images
Bias_n = 100*squeeze(mean(SIC_bias,[1 3],"omitnan")); 

% Mean absolute bias per crossing, across all permutations and images
Bias_abs_n = 100*squeeze(mean(mean(abs(SIC_bias),3),1,"omitnan")); 

Std_n = 100*squeeze(mean(std(SIC_bias,[],3,'omitnan'),1,'omitnan')); 

%%

% Mean absolute bias per crossing, when we average over all permutations
% first, then take the absolute value and average across all images
Bias_abs_barfirst_angle = 100*squeeze(mean(abs(mean(SIC_bias,3,'omitnan')),'omitnan')); 

% Mean absolute bias per crossing, when we average over all images first
% first, then take the absolute value and average over all permutations.
% I think this one should basically be zero since the mean bias per image
% is pretty low. 
Bias_abs_bar_anglefirst = 100*squeeze(mean(abs(mean(SIC_bias,1,'omitnan')),'omitnan')); 


%% Standard deviations

% Take the standard deviation of the average bias after averaging out all
% permutations
Bias_std_angle = 100*squeeze(std(mean(SIC_bias,3),[],1,"omitnan")); 
% Take the standard deviation of all including all permutations. This will
% decay faster because all individual images have a decaying part. 
Bias_std_all = 100*squeeze(std(SIC_bias,[],[1 3],'omitnan')); 

Bias_abs_595_all = 100*squeeze(prctile(abs(SIC_bias),100*[exp(-2) 1 - exp(-2)],[1 3])); 
Bias_abs_595_barfirst = 100*squeeze(prctile(abs(mean(SIC_bias,3)),100*[exp(-2) 1 - exp(-2)],[1])); 

figure(1)
clf

subplot(321)
histogram(Bias_i)

subplot(322)
histogram(Std_i); 

%%


subplot(312)
% Plot the mean over all images and permutations as a function of crossing
% number
plot(1:perm_length,Bias_n,'k','linewidth',1); 
hold on
jbfill(1:perm_length,Bias_n + Std_n,Bias_n - Std_n,[.4 .4 .4],[0 0 0],1,0.25); 
jbfill(1:perm_length,Bias_n + Bias_std_angle,Bias_n - Bias_std_angle,[.4 .4 .8],[0 0 0],1,0.25); 
grid on; box on; 
xlim([1 perm_length])
title('Mean Biases and Confidence Intervals','interpreter','latex')

subplot(313)
% Now looking at absolute biases
plot(1:perm_length,Bias_abs_n,'k','linewidth',1); 
hold on

jbfill(1:perm_length,Bias_abs_595_all(1,:),Bias_abs_595_all(2,:),[.4 .4 .4],[0 0 0],1,0.25); 
hold on
plot(1:perm_length,Bias_abs_barfirst_angle,'b','linewidth',1); 
jbfill(1:perm_length,Bias_abs_595_barfirst(1,:),Bias_abs_595_barfirst(2,:),[.4 .4 .8],[0 0 0],1,0.25); 
grid on; box on; 
xlim([1 perm_length])


title('Absolute Biases and Confidence Intervals','interpreter','latex')

%%
% plot(1:n_crossings,SIC_bias_std);
% subplot(222)
% histogram(100*SIC_bias(:,1,:),-50:1:50)
% hold on
% histogram(100*SIC_bias(:,5,:),-50:1:50)
% histogram(100*SIC_bias(:,10,:),-50:1:50)
% grid on; box on; 
% xlim([-20 20])
% xline([-2.5 2.5],'linewidth',2)
% legend('Crossing 0','Crossing 5','Crossing 10');

%% 
subplot(313)
r = 100*sum(abs(SIC_bias) < 0.025,[1 3]) / numel(SIC_bias(:,1,:));
s = 100*sum(abs(SIC_bias) < 0.05,[1 3]) / numel(SIC_bias(:,1,:));

plot(1:n_crossings,r,'k')
hold on; 

plot(1:n_crossings,s,'r')
grid on; box on; 
xlim([1 n_crossings]); 
ylim([0 100])
legend('Bias < 2.5\%','Bias < 5\%')

allAxesInFigure = findall(gcf,'type','axes');
letter = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(e)','(c)'};

for i = 1:length(allAxesInFigure)
    
 posy = get(allAxesInFigure(i),'position');

    set(allAxesInFigure(i),'fontname','times','fontsize',8,'xminortick','on','yminortick','on')
    
    annotation('textbox',[posy(1) - .025 posy(2)+posy(4) + .035 .025 .025], ...
        'String',letter{i},'LineStyle','none','FontName','Helvetica', ...
        'FontSize',8,'Tag','legtag');

end

pos = [6.5 4];
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
print([Figure_folder '/bias-figure.pdf'],'-dpdf','-r1200');
