% examp_trial

load('madelyns_data.mat','IB_surfaces'); 
examp_ID = 25; 
ice_surface = IB_surfaces(:,:,examp_ID); 

[X_save,Y_save,est_SIC,trueSIC,distances,measuredSIC] = IS2_emulator(ice_surface); 

%%
pcolor(ice_surface)