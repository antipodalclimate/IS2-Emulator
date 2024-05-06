
% Number of images, sequential crossings, and therefore number of potential
% permutations of those crossings
n_images = size(length_measured,1);
n_crossings = size(length_measured,2);
n_perms = n_crossings;

% Measured SIC when accumulating crossings
im_meas_SIC = nan(n_images,n_crossings,n_perms);
tot_length = im_meas_SIC; 

% For each permutation, take the cumulative sum in each image of the random
% permutation of images. 
for j = 1:n_perms

    % randomly permute the number of crossings
    rp = randperm(n_crossings);

    im_meas_SIC(:,:,j) = cumsum(length_ice_measured(:,rp),2)./cumsum(length_measured(:,rp),2);
    tot_length(:,:,j) = cumsum(length_measured(:,rp),2);

end


%% Compute bias fields

% Difference between actual SIC and the accumulated SIC
SIC_bias = bsxfun(@minus,true_SIC,im_meas_SIC);

% Take the mean bias as a function of crossing number, across all
% permutations. 

% Mean bias per crossing averaged over all permutations and images
Bias_bar_angle = 100*squeeze(mean(mean(SIC_bias,3),1,"omitnan")); 

% Mean absolute bias per crossing, across all permutations and images
Bias_abs_bar_angle = 100*squeeze(mean(mean(abs(SIC_bias),3),1,"omitnan")); 

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


subplot(221)
% Plot the mean over all images and permutations as a function of crossing
% number
plot(1:n_crossings,Bias_bar_angle,'k','linewidth',1); 
hold on
jbfill(1:n_crossings,Bias_bar_angle + Bias_std_all,Bias_bar_angle - Bias_std_all,[.4 .4 .4],[0 0 0],1,0.25); 
jbfill(1:n_crossings,Bias_bar_angle + Bias_std_angle,Bias_bar_angle - Bias_std_angle,[.4 .4 .4],[0 0 0],1,0.25); 
grid on; box on; 
xlim([1 n_crossings])
title('Mean Biases and Confidence Intervals')

subplot(223)
% Now looking at absolute biases
plot(1:n_crossings,Bias_abs_bar_angle,'r','linewidth',1); 
hold on

jbfill(1:n_crossings,Bias_abs_595_all(1,:),Bias_abs_595_all(2,:),[.8 .4 .4],[0 0 0],1,0.25); 
hold on
plot(1:n_crossings,Bias_abs_barfirst_angle,'g','linewidth',1); 
jbfill(1:n_crossings,Bias_abs_595_barfirst(1,:),Bias_abs_595_barfirst(2,:),[.4 .8 .4],[0 0 0],1,0.25); 
grid on; box on; 
xlim([1 n_crossings])


title('Absolute Biases and Confidence Intervals')

%%
% plot(1:n_crossings,SIC_bias_std);
subplot(222)
histogram(100*SIC_bias(:,1,:),-50:1:50)
hold on
histogram(100*SIC_bias(:,5,:),-50:1:50)
histogram(100*SIC_bias(:,10,:),-50:1:50)
grid on; box on; 
xlim([-20 20])
xline([-2.5 2.5],'linewidth',2)
legend('Crossing 0','Crossing 5','Crossing 10');

%% 
subplot(224)
r = sum(abs(SIC_bias) < 0.025,[1 3]) / numel(SIC_bias(:,1,:));
s = sum(abs(SIC_bias) < 0.05,[1 3]) / numel(SIC_bias(:,1,:));

plot(1:n_crossings,r,'k')
hold on; 

plot(1:n_crossings,s,'r')
grid on; box on; 
xlim([1 n_crossings]); 