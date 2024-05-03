
n_images = size(length_measured,1);
n_crossings = size(length_measured,2);
n_perms = n_crossings;

im_meas_SIC = nan(n_images,n_crossings,n_perms);

for i = 1:n_images
    for j = 1:n_perms

        % randomly permute the number of crossings
        rp = randperm(n_crossings);

        im_meas_SIC(i,:,j) = cumsum(length_ice_measured(i,rp))./cumsum(length_measured(i,rp));


    end

end

%%
SIC_bias = bsxfun(@minus,true_SIC,im_meas_SIC);
% Average across all images, and all permutations. 
SIC_bias_mean = 100*mean(squeeze(nanmean(SIC_bias,1)),2);
% Take STD across all images, meaned across all permutations. 
SIC_bias_std = 100*mean(squeeze(nanstd(SIC_bias,[],1)),2); 
figure(1)
clf


subplot(221)
plot(1:n_crossings,SIC_bias_mean(:,1),'k','linewidth',1); 
hold on
jbfill(1:n_crossings,SIC_bias_std',-SIC_bias_std',[.4 .4 .4],[0 0 0]);

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
subplot(212)
r = sum(abs(SIC_bias) < 0.025,[1 3]) / numel(SIC_bias(:,1,:));
s = sum(abs(SIC_bias) < 0.05,[1 3]) / numel(SIC_bias(:,1,:));

plot(1:n_crossings,r,'k')
hold on; 

plot(1:n_crossings,s,'r')
grid on; box on; 
xlim([1 n_crossings]); 