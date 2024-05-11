%% plot_error_bias

load([Emulator_folder '/Emulator_Data.mat']);

% Create random permutations of crossings for evaluating LIF

n_images = length(image_done);
n_crossings = size(length_measured,2);
n_perms = n_crossings;

im_meas_SIC = nan(n_perms,n_crossings);

measured_SIC = nan(n_images,n_crossings,n_perms);

for im_ind = 1:n_images
    for perm_ind = 1:n_perms

        % randomly permute the number of crossings
        rp = randperm(n_crossings);

        measured_SIC(im_ind,:,perm_ind) = cumsum(length_ice_measured(im_ind,rp))./cumsum(length_measured(im_ind,rp));


    end

end