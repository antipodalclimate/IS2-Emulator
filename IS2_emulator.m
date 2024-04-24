function [X_save,Y_save,area_measured,icearea_measured,measuredSIC] = IS2_emulator(ice_surface,nlines,dx)
% [X_save,Y_save,est_SIC,trueSIC,distances,measuredSIC] = IS2_emulator(ice_surface,nlines,dx)
% Takes as input a binary ice_surface
% And emulates nlines number of passes
% Where the grid spacing of all points is dx = dy. 

% X_save and Y_save are the coordinates
% trueSIC is the actual value
% distances is the amount of distance intersected by each pass
% measuredSIC is the estimated SIC for each pass
% est_SIC is estimated SIC after each successive passes
%         = cumsum(distances * measuredSIC)/cumsum(distances)

[X_save,Y_save] = deal(cell(nlines,1)); 

[nx,ny] = size(ice_surface); 
Lx = nx*dx; % m
Ly = ny*dx; 
dA = dx*dx; % m^2 

% Create the x and y coordinates and the meshed grid
x = linspace(0,(nx-1)*dx,nx);
y = linspace(0,(ny-1)*dx,ny);

[Xgrid,Ygrid] = meshgrid(y,x);

% Total area, along with total ice area and actual SIC
area_total = Lx*Ly;
area_ice = dA*sum(ice_surface(:));

% Width of the IS2 beam (units m). 
% We just use one for now to avoid double-counting measured areas
IS2_footprint = 1;

% set up grid to record passes over each point
% This is the number of times they've been passed over
measured_map = 0*ice_surface;
[icearea_measured,area_measured] = deal(zeros(nlines,1));

% Now run through the number of intersections
for i = 1:nlines
    % Parametric representation
    % Vertex 1:2Lx are on the bottom (0:Lx-1) or top (Lx:2Lx-1);
    % Verices 2Lx:(2Lx + 2Ly - 1) are on the left side (2lx:2Lx+Ly-1) or right (the rest)
    
    % first vertex
    same_side = true;
    
    % Ensure 2 different sides of ice surface 
    while same_side
        
        % Pick two points on the boundary.
        boundary_vertices = floor((2*(Lx+Ly))*rand(2,1));
        
        
        vert_beg = boundary_vertices(1);
        vert_end = boundary_vertices(2);
        
        if vert_beg >= (2*Lx)
            
            % Is either 0 or Lx.
            xbeg = Lx*floor((vert_beg - 2*Lx)/Ly);
            ybeg = mod(vert_beg - 2*Lx,Ly);
            
        else % is an x point
            
            xbeg = mod(vert_beg,Lx);
            ybeg = Ly*floor(vert_beg/Lx);
            
        end
        
        % Now for ending vertex
        if vert_end >= (2*Lx)
            
            % Is either 0 or Lx.
            xend = Lx*floor((vert_end - 2*Lx)/Ly);
            yend = mod(vert_end - 2*Lx,Ly);
            
        else % is an x point
            
            xend = mod(vert_end,Lx);
            yend = Ly*floor(vert_end/Lx);
            
        end
    
        % If the vertex points aren't the same in x or y, we go ahead and
        % use it
        if xbeg ~= xend && ybeg ~= yend
            same_side = false;
        end
        
    end

    % This first line is the center of the IS2 array
    % distance from all points on the line to the points in the matrix using point_to_line command from online
    d = reshape(point_to_line([Xgrid(:) Ygrid(:)],[xbeg ybeg],[xend yend]),size(Xgrid));
    
    % if within footprint, points are measured by IS2
    measured = d < IS2_footprint;
    
    % add points to measured_map
    measured_map = measured_map + measured;

    % Total IS-2 area is all those points close to the line
    area_measured(i) = dA*sum(measured(:));
    % Area of ice measured is the close points that are ice
    icearea_measured(i) = dA*sum(measured(:).*ice_surface(:));
    
    X_save{i} = [xbeg xend]; 
    Y_save{i} = [ybeg yend];
    
end

% successive SIC measurement 
measuredSIC = 100*cumsum(icearea_measured)./cumsum(area_measured);