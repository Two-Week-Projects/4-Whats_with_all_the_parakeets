%% Inits (grabbed from p1_0)

% reproduction constants
reproduction = {};
reproduction.age = 3;
reproduction.numbers = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2]; % [1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5]; 


stats_dat(1).life_expectancy = 10;
stats_dat(1).breeding_percnt = 0.563;
stats_dat(2).life_expectancy = 40;
stats_dat(2).breeding_percnt = 0.334;
stats_dat(3).life_expectancy = 15;
stats_dat(3).breeding_percnt = 0.461;
stats_dat(4).life_expectancy = 30;
stats_dat(4).breeding_percnt = 0.36;

use_stats_dats = 4;

%% Run simulations

graph_tit = "London"; % default value

% Wraysbury GP
% graph_tit = "Wraysbury GP";
% year_pop_WGP = [[1983, 51]; [2021, 0]];
% overlay = 0;

% London statistics, 1983 -> 2002
% year_pop_WGP = [[1983, 500]; [2021, 0]];
% overlay = 1;
% color = [0, 0, 1];

% London statistics, 1994 -> 2006
% year_pop_WGP = [[1994, 1700]; [2021, 0]];
% overlay = 2;
% color = [0, 1, 0];

% London statistics, 2002 -> 2012
year_pop_WGP = [[2002, 5800]; [2021, 0]];
overlay = 3;
color = [1, 0, 0];

this_report = p1_reports([year_pop_WGP(1, 1), year_pop_WGP(2, 1)],...
                         [year_pop_WGP(1, 2), year_pop_WGP(2, 2)]);

split.female_percentage = 0.5;
split.breeding_percentage = stats_dat(use_stats_dats).breeding_percnt;
split.dieing_percentage = 1 / stats_dat(use_stats_dats).life_expectancy;

results = this_report.run_sim(reproduction, split);

fprintf("Population in %s, forecasted from %i@%i, %i is estimated to be %i\n",...
    graph_tit, year_pop_WGP(1, 1), year_pop_WGP(1, 2),...
    year_pop_WGP(2, 1), this_report(end).results)

h = animatedline("Color", color);
axis([min(results.year), max(results.year), min(results.population), max(results.population)])
xlabel("Year")
ylabel("Population")
ylim([0, 50000])
title(sprintf("Forecasting from year %i to year %i", min(results.year), max(results.year)));
set(gcf, 'Position', [300, 200, 1067, 600]);
filename = sprintf("overlay_%i_v2.gif", overlay);%%sprintf("im_%i_to_%i.gif", min(results.year), max(results.year));
for k = 1:length(results.year)
    addpoints(h,results.year(k),results.population(k));
    drawnow
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256); 
    if k == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
        imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
end