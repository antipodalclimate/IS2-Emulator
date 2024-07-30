figure(1)
clf

set(gcf, 'WindowStyle', 'normal', ...
    'Units', 'inches', ...
    'PaperUnits', 'inches', ...
    'Position', [0, 0, 6.5, 3], ...
    'PaperPosition', [0, 0, 6.5, 3.5], ...
    'PaperSize', [6.5, 3.5]);

% These are the images we will consider. For just visual purposes we want
% significant SIC - though this won't represent all imagery. 
usable = find(image_done == 1 & true_SIC > .6);

% Take one of thsoe images.
usable_image_ind = randi(length(usable),1); 
image_ind = usable(usable_image_ind); 

image_ind = 9374; 

fprintf('Using image %d',image_ind);

im_length = length_measured(image_ind,:); 
im_ice_length = length_ice_measured(image_ind,:);
im_true_SIC = true_SIC(image_ind); 
im_orients = sample_orients(image_ind,:);


n_crossings = size(im_length,2);
n_perms = n_crossings;

im_meas_SIC = nan(n_perms,n_crossings);

for j = 1:n_perms

    % randomly permute the number of crossings
    rp = randperm(n_crossings);

    im_meas_SIC(j,:) = cumsum(im_ice_length(rp))./cumsum(im_length(rp));


end

im_bias = bsxfun(@minus,im_true_SIC,im_meas_SIC); 
im_bias_std = squeeze(std(abs(im_bias),[],1));
im_mean_LIF = squeeze(mean(im_meas_SIC,1));
im_name = h5readatt(image_location{image_ind},'/','source_image');

%% 
subplot(121)


grid on; box on; 



