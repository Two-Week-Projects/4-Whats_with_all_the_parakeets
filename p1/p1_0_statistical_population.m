%% Initialise population of the parakeet

% Assumptions
% 1. The number of breeding parakeets is ~1/2 the total number of parakeets
% (each pair obviously contains 1 male and 1 female)
% 2. We will assume 50:50 male:female split
% 3. Each pair above the age of 3 will produce between 1 and 5 young (in
% highly-bounded distribution)

% reproduction constants
reproduction = {};
reproduction.age = 3;
reproduction.numbers = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2]; % [1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5]; 

graph_tit = "London" % default value


%% Run simulations

% Wraysbury GP
% graph_tit = "Wraysbury GP"
year_pop_WGP = [[1983, 51]; [1989, 142]];

% London statistics, 1983 -> 2002
% year_pop_WGP = [[1983, 500]; [2002, 5800]];

% London statistics, 1994 -> 2006
% year_pop_WGP = [[1994, 1700]; [2006, 6000]];

% London statistics, 2002 -> 2012
% year_pop_WGP = [[2002, 5800]; [2012, 32000]];

this_report = p1_reports([year_pop_WGP(1, 1), year_pop_WGP(2, 1)],...
                         [year_pop_WGP(1, 2), year_pop_WGP(2, 2)]);

% Populate scenarios
scn = 1;
fp_v = 0.5;
bp_v = 0.15:0.005:0.75;
dp_v = 0.03:0.005:0.085;
clear splits

for i = fp_v
    for j = bp_v
        for k = dp_v
            splits(scn).female_percentage = i; % percentage that are females
            splits(scn).breeding_percentage = j; % percentage in breeding pairs
            splits(scn).dieing_percentage = k; % each year 25% die due to age
            scn = scn + 1;
        end
    end
end


for i = 1:length(splits)
    this_report.run_sim(reproduction, splits(i));
end

%% Plot results
tolerance = 0.05; % if the result is within 10% then say it was "correct"
fig = figure
hold on
valids = this_report.eval_valid(tolerance);
bp_polyfit = [];
dp_polyfit = [];
for i = 1:length(splits)
    display = false;
    if valids(i)
        bp_polyfit = [bp_polyfit, this_report.splits(i).breeding_percentage];
        dp_polyfit = [dp_polyfit, this_report.splits(i).dieing_percentage];
        scatter3(...
            this_report.splits(i).breeding_percentage,...
            this_report.splits(i).dieing_percentage,...
            this_report.splits(i).female_percentage, ".r")
        text(...
            this_report.splits(i).breeding_percentage,...
            this_report.splits(i).dieing_percentage,...
            this_report.splits(i).female_percentage,...
            sprintf('%.2f', valids(i)))
    end
end
graph_title = sprintf("%s between %i and %i, tol=%.3f", graph_tit, year_pop_WGP(1, 1), year_pop_WGP(2, 1), tolerance)
title(graph_title)
zlabel("% that are female")
xlabel("% that form breeding pairs")
ylabel("% that die each year")
grid on
hold off

results_polyfit = polyfit(bp_polyfit, dp_polyfit, 1);
m = results_polyfit(1)
c = results_polyfit(2)
    

