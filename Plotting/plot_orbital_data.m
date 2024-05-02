function plot_orbital_data(Figure_folder, orientation_hist, lat_disc, orient_disc)
% PLOT_ORBITAL_DATA - Plot azimuth distribution by latitude and specific latitudes
%
% Syntax:  plot_orbital_data(Figure_folder, orientation_hist, lat_disc, orient_disc)
%
% Inputs:
%    Figure_folder - Path to the folder where the figure will be saved
%    orientation_hist - 2D matrix of orientation histograms
%   
%    lat_disc - Array of discrete latitude values for orientation_hist
%    orient_disc - Array of discrete azimuth values for orientation_hist
%
% Outputs: SI-azimuth.pdf saved in Figure_folder.
%     
% Author: Christopher Horvat
% Date: 02-May-2024

plot_ohist_2d = orientation_hist; 
plot_ohist_2d(plot_ohist_2d == 0) = nan; 

% Create the figure
figure(1);
clf
set(gcf, 'WindowStyle', 'normal', ...
         'Units', 'inches', ...
         'PaperUnits', 'inches', ...
         'Position', [0, 0, 6.5, 3.5], ...
         'PaperPosition', [0, 0, 6.5, 3.5], ...
         'PaperSize', [6.5, 3.5]); 


% Plot the azimuth probability density function by latitude
Ax{1} = subplot('position',[.1 .575 .8 .35]);
pcolor(orient_disc, lat_disc, plot_ohist_2d);
shading flat;
colormap([1 1 1; cmocean('amp')]);
clim([0 .5]); % Set color axis scaling
colorbar('position',[.925 .575 .025 .35]);
% xlabel('Azimuth','interpreter','latex');
ylabel('Latitude','interpreter','latex');
title('Azimuth PDF by Latitude', 'FontName', 'Helvetica', 'FontSize', 12,'interpreter','latex');

grid on;
box on;

% Plot PDF for specific latitudes
Ax{2} = subplot('position',[.1 .1 .8 .35]);
hold on;
plot(orient_disc, orientation_hist(lat_disc == 70, :), 'LineWidth', 1, 'Color', 'k');
plot(orient_disc, orientation_hist(lat_disc == 80, :), 'LineWidth', 1, 'Color', 'b');
plot(orient_disc, orientation_hist(lat_disc == 87, :), 'LineWidth', 1, 'Color', 'r');
hold off;
xlabel('Azimuth','interpreter','latex');
ylabel('PDF','interpreter','latex');
grid on;
box on;
legend('70°N', '80°N', '87°N', 'Location', 'best');
title('PDF for Selected Latitudes', 'FontName', 'Helvetica', 'FontSize', 12,'interpreter','latex');

% Annotate subplots with letters
letters = {'(a)', '(b)'};

for i = 1:length(Ax)
    pos = get(Ax{i}, 'Position');
    annotation('textbox', [pos(1) - 0.025, pos(2) + pos(4) + 0.035, 0.025, 0.025], ...
               'String', letters{i}, 'LineStyle', 'none', 'FontName', 'Helvetica', ...
               'FontSize', 8, 'Tag', 'legtag');
    set(Ax{i},'FontName', 'Helvetica', 'FontSize', 9, 'XMinorTick', 'on', 'YMinorTick', 'on')
end

% Save the figure to a file
print([Figure_folder '/SI-azimuth.pdf'], '-dpdf', '-r1200');

end