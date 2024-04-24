% clc
% clear all
% close all

% SET-UP VARIABLES
% -------------------------------------------------------------------

% Create the grid
dx = 1; % m 
nx = 2500; % unitless
Lx = nx*dx; % m

dy = 1;
ny = 2500;
Ly = ny*dy;

max_SIC_generator = .67;
ideal_SIC = 0.95; % if greater than floe generator can handle, reverses ice and water (so open water patches on ice surface)


% --------------------------------------------------------------------------------
% map the ice

% Create the x and y coordinates and the meshed grid
x = linspace(0,(nx-1)*dx,nx);
y = linspace(0,(ny-1)*dy,ny);

[X,Y] = meshgrid(x,y);

if ideal_SIC > max_SIC_generator % flipping generator for high SIC
    coverage_percent = 1 - ideal_SIC;
end


% borrowed code to generate floes / open water circles with edits mainly
% contained to variable definitions
for ii=1:5
    repeat=1;
    while repeat == 1
        
        %% Setting up the algorithm (input parameters)

        Aspect_Ratio=Lx/Ly;                  % Lengtth to width aspect ratio of the domain (Length_ice_domain/Width_ice_domain)

        P=0;                             % P parameter determines whether the overall number of Ice pieces is an input parameter or the size of the domain.
                                         % If the value of P = 0 then the input parameter is the length of the Ice domain and Length_ice_domain is to be chosen.
                                         % If the value of P = 1 then the input parameter is number of Ice pieces and N_ice_pieces is to be chosen.

        N_ice_pieces=1802;               % Number of ice sheets to scatter   (1802)
        Length_ice_domain=Lx;           % Length of the ice domain [cm]
        elapsed_time_constraint=1;       % Cut=off time (time limit) for the while loop [min]

        %% Calculating dimensions of the domain
        % The distribution of floe size against possibility is suggested to follow a log-normal function taken from 
        % Guo C, Xie C, Zhang J, Wang S, Zhao D. Experimental investigation of the resistance performance and heave and pitch motions of ice-going container ship under pack ice conditions. China Ocean Eng 2018;32:169–78. https://doi.org/10.1007/s13344-018-0018-9
        
        Length_ice_domain=Length_ice_domain/100;                           % Length of the ice domain [m]
        A_pieces=[0.0025,0.01,0.0225,0.04,0.0625,0.09,0.1225];             % Relevant areas of ice pieces
        Probability=[0.0622,0.1681,0.2653,0.2037,0.1326,0.0882,0.0799];    % Probability of the ice area to be found in the sample
        elapsed_time=0;                                                    % Initialisation for the cut-off time

        if P == 0

             Width_ice_domain=Length_ice_domain/Aspect_Ratio;                                       % Width of the ice domain  [m]
             A_domain=Length_ice_domain*Width_ice_domain;                                           % Overall area of the Ice domain [m^2]
             A_IcePieces_Overall= A_domain*coverage_percent;                                    % Overall area covered by ice [m^2]

             syms q1 q2 q3 q4 q5 q6 q7 N_ice_pieces
             [q1,q2,q3,q4,q5,q6,q7,N_ice_pieces]=vpasolve(N_ice_pieces*Probability(1,1)==q1,N_ice_pieces*Probability(1,2)==q2,N_ice_pieces*Probability(1,3)==q3,N_ice_pieces*Probability(1,4)==q4,...
                      N_ice_pieces*Probability(1,5)==q5,N_ice_pieces*Probability(1,6)==q6,N_ice_pieces*Probability(1,7)==q7,...
                         q1*A_pieces(1,1)+q2*A_pieces(1,2)+q3*A_pieces(1,3)+q4*A_pieces(1,4)+q5*A_pieces(1,5)+q6*A_pieces(1,6)+q7*A_pieces(1,7)==A_IcePieces_Overall, q1,q2,q3,q4,q5,q6,q7,N_ice_pieces);

             N_ice_pieces=double(N_ice_pieces);                       % Number of ice sheets to scatter
             N_ice_piece=round(double([q1,q2,q3,q4,q5,q6,q7]));
             N_ice_pieces=sum(N_ice_piece);                           % Number of ice sheets to scatter
             A_IcePieces_Overall=sum(A_pieces.*N_ice_piece);          % Overall area covered by ice [m^2]

        elseif P == 1

            N_ice_piece=[round(N_ice_pieces*Probability(1,1)),round(N_ice_pieces*Probability(1,2)),round(N_ice_pieces*Probability(1,3)),round(N_ice_pieces*Probability(1,4)),...
                                             round(N_ice_pieces*Probability(1,5)),round(N_ice_pieces*Probability(1,6)),round(N_ice_pieces*Probability(1,7))];   % Number of ice pieces of a certain area
            A_IcePieces_Overall=sum(A_pieces.*N_ice_piece);     % Overall area covered by ice [m^2]
            N_ice_pieces=sum(N_ice_piece);

            Length_ice_domain=sqrt((A_IcePieces_Overall/coverage_percent)*Aspect_Ratio);       % Length of the ice domain [m]
            Width_ice_domain=Length_ice_domain/Aspect_Ratio;                                       % Width of the ice domain  [m]    

        else

            disp(['Err: Parameter P has been erroneously defined. It cannot take any other value apart from 0 and 1.'])
            return

        end

        %% Initial random distribution

        rng('shuffle')         % produces a random number in a different way every time it is called
        circles=zeros(N_ice_pieces,3);      % Matrix listing all parameters to arrange X=[Cx1,Cy1,r1;Cx2,Cy2,r2;Cx3,Cy3,r3;...]
        a1=0;

        for n=1:length(A_pieces)

            for i=a1+1:a1+N_ice_piece(1,n)

                circles(i,1)=rand*Length_ice_domain;
                circles(i,2)=rand*Width_ice_domain;
                circles(i,3)=sqrt(A_pieces(1,n)/pi);

            end

            a1=a1+N_ice_piece(1,n);

        end

        circles=circles';
        circles_sorted=(fliplr(circles))';
        i=1;
        Cx=circles_sorted(i,1);
        Cy=circles_sorted(i,2);
        r=circles_sorted(i,3);
        start=tic;

        while i <= N_ice_pieces && elapsed_time <= elapsed_time_constraint

            % Sea ice domain constraints
            if Cx-r>=0

            else
                Cx=Cx+abs(Cx-r)+0.01*(abs(Cx-r));
                circles_sorted(i,1)=Cx;    
            end


            if Length_ice_domain >= Cx+r

            else
                Cx=Cx-(Cx+r-Length_ice_domain)-0.01*(Cx+r-Length_ice_domain);
                circles_sorted(i,1)=Cx;
            end


            if Cy-r>=0

            else
                Cy=Cy+abs(Cy-r)+0.01*abs(Cy-r);
                circles_sorted(i,2)=Cy;
            end


            if Width_ice_domain >= Cy+r

            else
                Cy=Cy-(Cy+r-Width_ice_domain)-0.01*(Cy+r-Width_ice_domain);
                circles_sorted(i,2)=Cy;
            end



            % Sea ice overlap constraints
             if i==1
               % disp(['Ice Piece No ', num2str(i), ' / ' num2str(N_ice_pieces), ' successfully settled'])
                i=i+1;
             else   

                n=0;
                Cx_n=circles_sorted(n+1,1);
                Cy_n=circles_sorted(n+1,2);
                r_n=circles_sorted(n+1,3);
                RadiusDistance=sqrt(((Cx-Cx_n)^2)+((Cy-Cy_n)^2));

                while RadiusDistance>=abs(r+r_n) && n <= i-1

                    n=n+1;
                    Cx_n=circles_sorted(n,1);
                    Cy_n=circles_sorted(n,2);
                    r_n=circles_sorted(n,3);
                    RadiusDistance=sqrt(((Cx-Cx_n)^2)+((Cy-Cy_n)^2));

                end

                if n == i

                   % disp(['Ice Piece No ', num2str(i), ' / ' num2str(N_ice_pieces), ' successfully settled'])
                    i=i+1;

                else

                    Cx=rand*Length_ice_domain;
                    Cy=rand*Width_ice_domain;
                    circles_sorted(i,1)=Cx;
                    circles_sorted(i,2)=Cy;
                    r=circles_sorted(i,3);

                end
             end

             elapsed_time=(toc(start))/60;

        end

        if elapsed_time > elapsed_time_constraint

            repeat=1;

        else

            repeat=0;

        end 
    end
end

% ------------------------------------------------------------------------------

% apply ice to grid

if ideal_SIC > max_SIC_generator % if greater than .67
    ice_surface = ones(size(X)); % make ice surface of 1s
    for i = 1:height(circles_sorted)
        xcen = circles_sorted(i,1)*100;
        ycen = circles_sorted(i,2)*100;
        rad = circles_sorted(i,3)*100;
        in_circle =((X-xcen).^2 + (Y-ycen).^2).^(1/2) < rad; % and map open water circles of 0s on top
        ice_surface(in_circle) = 0;
    end
end

if ideal_SIC <= max_SIC_generator % do the opposite from above
    ice_surface = zeros(size(X));
    for i = 1:height(circles_sorted)
        xcen = circles_sorted(i,1)*100;
        ycen = circles_sorted(i,2)*100;
        rad = circles_sorted(i,3)*100;
        in_circle =((X-xcen).^2 + (Y-ycen).^2).^(1/2) < rad;
        ice_surface(in_circle) = 1;
    end
end

% -------------------------------------------------------------------------

% helpful stats
area_total = Lx*Ly;
area_ice = dx*dy*sum(ice_surface(:));
SIC = area_ice/area_total;