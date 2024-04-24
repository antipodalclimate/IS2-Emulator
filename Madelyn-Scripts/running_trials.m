
% Need to make sure variables are set-up on individual code pages

% ---------------------------------------------------------------------

% SET-UP VARIABLES

nsurfaces = 3; 
nruns = 2; % sets of lines per surface
nlines = 10; % also in emulator, should either match or just do one

% ---------------------------------------------------------------------


trueSICs = zeros(nsurfaces);
SIC_estimates = zeros(nlines,nruns,nsurfaces);
dist_covered = zeros(nlines,nruns,nsurfaces);


for b = 1:nsurfaces;
    run random_surface_generator.m; % pull surface type of choice
    trueSICs(b) = trueSIC;
    for a = nruns;
        run IS2_emulator.m
        SIC_estimates(:,a,b) = est_SIC;
        dist_covered(:,a,b) = distance / area_total; % records as fraction of area covered
    end
end