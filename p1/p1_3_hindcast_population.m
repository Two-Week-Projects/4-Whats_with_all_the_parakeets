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

split.female_percentage = 0.5;
split.breeding_percentage = stats_dat(use_stats_dats).breeding_percnt;
split.dieing_percentage = 1 / stats_dat(use_stats_dats).life_expectancy;

%% Choose specific condition to simulate towards
graph_tit = "London"; % default value

% Wraysbury GP
% graph_tit = "Wraysbury GP"
% year_pop_WGP = [[1983, 51]; [1989, 142]];

% London statistics, 1983 -> 2002
year_pop_WGP = [[1983, 500]; [2002, 5800]];

% London statistics, 1994 -> 2006
% year_pop_WGP = [[1994, 1700]; [2006, 6000]];

% London statistics, 2002 -> 2012
% year_pop_WGP = [[2002, 5800]; [2012, 32000]];

%% Run the simulations in a while loop so as to get a proposed year for a specific starting population
  % We will assume that the population only ever increases
  % (which so far has been a non-mentioned but obvious assumption)

hindcasted_year_pops = [];

tolerance = 0.05;

starting_population = year_pop_WGP(1,2) - 1;
year_in_question = year_pop_WGP(1,1) - 1;
while true % year_in_question loop
    this_population = starting_population;
    if starting_population <= 2
        fprintf("Adam and Eve found on %i", year_in_question)
        break
    end
    if year_in_question <= 1865
        fprintf("I've gone as far back as 1865 and still can't find an answer!\n")
        break
    end
    while true % starting population loop
        
        % run the simulation to estimate what the results would be if they
        % started on the proposed date with the proposed population.
        this_report = p1_reports([year_in_question, year_pop_WGP(1, 1)],...
                                 [this_population, year_pop_WGP(1, 2)]);
        this_report = this_report.run_sim(reproduction, split);
        
        if this_report.eval_valid(tolerance)
            % If your forecast is within the tolerance then state that this
            % population is the starting population for this year.
            hindcasted_year_pops = [hindcasted_year_pops;...
                [year_in_question, this_population]];
            % reset the starting population to this population (as you go
            % backwards each year there's no point starting at a higher
            % population than the next year).
            starting_population = this_population;
            year_in_question = year_in_question - 1;
            break
        else
            this_population = this_population - 1;
        end
        if this_population <= 1
            year_in_question = year_in_question - 1;
            break
        end
            
    end
end

%% Run simulations

figure
subplot(2, 1, 1);
plot(hindcasted_year_pops(:,1), hindcasted_year_pops(:,2))
graph_title = sprintf("Hindcasted based on %s @ %i & %i, tol=%.3f", graph_tit, year_pop_WGP(1, 1), year_pop_WGP(2, 1), tolerance);
title(graph_title)
xlabel("Year")
ylabel("Population")
grid on

%% Year on year population change
rate_year_pops = zeros(length(hindcasted_year_pops), 1);
for ii = 2:length(rate_year_pops)
   rate_year_pops(ii) = (((hindcasted_year_pops(ii, 2)) - (hindcasted_year_pops(ii-1, 2))) / ...
       ((hindcasted_year_pops(ii, 1)) - (hindcasted_year_pops(ii-1, 1)))) / ...
       hindcasted_year_pops(ii-1, 2);
end
subplot(2, 1, 2);
plot(hindcasted_year_pops(:,1), rate_year_pops)
hold on
plot([hindcasted_year_pops(1,1), hindcasted_year_pops(end,1)], [mean(rate_year_pops), mean(rate_year_pops)],...
    "--r");
hold off
graph_title = "Rate of change of population";
title(graph_title)
xlabel("Year")
ylabel("\Delta Pop. per Year per Population")
grid on

