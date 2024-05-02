function plot_single_image(Figure_folder,image_location,image_done,true_SIC,length_ice_measured,length_measured,sample_orients)

% This produces a bias plot

usable = find(image_done == 1 & true_SIC > .6);

length_ice_measured = length_ice_measured(usable,:);
length_measured = length_measured(usable,:);
true_SIC = true_SIC(usable);
sample_orients = sample_orients(usable,:);

n_images = length(true_SIC);
n_crossings = size(length_measured,2);
n_perms = n_crossings;

observed_SIC = nan(n_images,n_perms,n_crossings);

for i = 1:length(true_SIC)

    for j = 1:n_perms

        % randomly permute the number of crossings
        rp = randperm(n_crossings);

        observed_SIC(i,j,:) = cumsum(length_ice_measured(i,rp))./cumsum(length_measured(i,rp));


    end

end


SIC_bias = bsxfun(@minus,true_SIC,observed_SIC);

%% First plot is of the image itself

close
image_ind = randi(length(usable),1); 

surface_class = (h5read(image_location{usable(image_ind)},'/classification'));
% Gridding things
surface_class(surface_class == 0) = -1;
surface_class(surface_class > 1) = 0;


Ax{1} = subplot('position',[.025 .1 .5 .8]);
cla
imagesc(surface_class')
colormap([1 1 1; ...
    .4 .4 .8; ...
    .8 .8 .8])

set(gca,'YDir','normal','XTickLabel','','YTickLabel','')
xlabel('');
ylabel('');
hold on
grid on; box on;

% All scene points that have ice/ocean data
measurable = surface_class >= 0;

% Gridding things
[nx,ny] = size(surface_class);
X = 1:nx;
Y = 1:ny;
[Xgrid,Ygrid] = meshgrid(X,Y);

% This gridding swaps rows and columns. So we take the transpose to
% make it have the same dimensions as the data
Xgrid = Xgrid';
Ygrid = Ygrid';

% Smaller subdomain which is x/y points that have data
Xmeas = Xgrid(measurable);
Ymeas = Ygrid(measurable);

% Take a random set of X/Y points that are in the domain as tie points
sample_points = randi(numel(Xmeas),[n_crossings 1]);
sample_x = Xmeas(sample_points)';
sample_y = Ymeas(sample_points)';

% Longer than the image size. We just want to create the endpoints of
% our "IS2" track intersecting the image
L= max(nx,ny);

% Start with a random image point and trace the line with the correct
% orientation w.r.t. true north backwards and forwards.

% Orientation angles are taken from North, not from East. For a right
% triangle the azimuth plus the altitude is pi/2. So we subtract
% the sampled azimuths from pi/2 to get the altitude angle.

elevation_angle = pi/2 - pi*sample_orients(image_ind,:)/180;

xend = sample_x + L*cos(elevation_angle);
xinit = sample_x - L*cos(elevation_angle);

% Same for y points
yend = sample_y + L*sin(elevation_angle);
yinit = sample_y - L*sin(elevation_angle);

for j = 1:n_crossings

    scatter(sample_x(j),sample_y(j),50,'filled','MarkerFaceColor',[.8 .4 .4])
    plot([xinit(j) xend(j)],[yinit(j) yend(j)],'k');
    drawnow
                  
end

title(h5readatt(image_location{image_ind},'/','source_image'),'interpreter','latex');

Ax{2} = subplot('position',[.625 .7 .35 .2]);

edges = 1:2:180; 
p = histcounts(sample_orients(image_ind,:),1:2:180); 
p = p / sum(p);
centers = 0.5*(edges(1:end-1) + edges(2:end)); 

bar(centers,p,'EdgeColor',[.8 .4 .4],'Facecolor',[.8 .4 .4]);
xlabel('Azimuth');
ylabel('Frequency'); 
grid on; box on; 

Ax{3} = subplot('position',[.625 .4 .35 .2]);
plot(1:n_crossings,length_measured(image_ind,:),'Color',[.4 .4 .8]);
hold on
plot(1:n_crossings,length_ice_measured(image_ind,:),'Color',[.8 .8 .8]);
grid on; box on; 
ylabel('Length (m)'); 
xlim([1 50])
xlabel('Crossing No.')


Ax{4} = subplot('position',[.625 .1 .35 .2]);
plot(1:n_crossings,cumsum(length_ice_measured(image_ind,:))./cumsum(length_measured(image_ind,:)),'Color','k','linewidth',2);
yline(true_SIC(image_ind),'r')
hold on

Mplot = cumsum(length_ice_measured(image_ind,:))./cumsum(length_measured(image_ind,:));
Splot = squeeze(std(abs(SIC_bias(image_ind,:,:)),[],2));

% Take average SIC for each permutation as a function of crossing number
% Want to see how they converge, so plot against the mean
M2plot = squeeze(mean(observed_SIC(image_ind,:,:),2));

% plot(1:n_crossings,Mplot,'b','linewidth',2); 
plot(1:n_crossings,M2plot + Splot,'--k','linewidth',1); 
plot(1:n_crossings,M2plot - Splot,'--k','linewidth',1); 
grid on; box on; 
xlim([1 50])
xlabel('Crossing No.')
ylabel('%');

% Plot bias as a function of crossing



letter = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(e)','(c)'};
for i = 1:length(Ax)
    
 posy = get(Ax{i},'position');

    set(Ax{i},'fontname','times','fontsize',8,'xminortick','on','yminortick','on')
    
    annotation('textbox',[posy(1) - .025 posy(2)+posy(4) + .035 .025 .025], ...
        'String',letter{i},'LineStyle','none','FontName','Helvetica', ...
        'FontSize',8,'Tag','legtag');

end

pos = [6.5 4];
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
set(gcf,'windowstyle','normal','position',[0 0 pos],'paperposition',[0 0 pos],'papersize',pos,'units','inches','paperunits','inches');
print([Figure_folder '/emulator-example.pdf'],'-dpdf','-r1200');
