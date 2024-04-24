function ice_surface = h5_to_surface(file, ybeg,yend, xbeg,xend)

subset = file(ybeg:yend, xbeg:xend);

% 0- DMS image border
% 1- undeformed sea ice
% 2- deformed sea ice
% 3- open water
% 4- dark melt pond
% 5- medium melt pond
% 6- light melt pond


% The icebridge surfaces have a lot of these DMS image border points in the
% middle of them, which I tried to avoid as much as possible. I noted how
% many border points were included in each of the surfaces I ended up using
% beside them in ice_bridge surfaces.mat
% When I was finding surfaces, I included the following so it would print
% how many border points were included if any each time I ran the function
% and check the size just in case
% B = (subset == 0);
% if sum(B,'all') > 0
%     sum(B,'all')
%     ((xend-xbeg+1)*(yend-ybeg+1))
% end

binsubset = subset;
binsubset(subset~=3) = 1;
binsubset(subset==0) = 0;
binsubset(subset==3) = 0;

ice_surface = double(binsubset);

end