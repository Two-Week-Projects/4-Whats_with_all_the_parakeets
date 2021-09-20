%% Inits (grabbed from p1_0)
% every distance is in metres!
% the time step is every day
function [population, statistics] = p4_0_brood_and_predators(days, start_population, start_predators, environment, start_park, run_name, plotting)
    %% Return the population at a given enddate
    close 

    global render_figure

    % Initialise
    if plotting == true
        plotting = environment.plot_env();
    end
    
    brood = p4_brood(environment);
    
    [bound_X, bound_Y] = boundingbox(start_park.shape);
    
    %% Generate initial parakeet population
    for each = 1:start_population
        i_location.x = randi(bound_X);
        i_location.y = randi(bound_Y); 
        brood.spawn_dead_parakeet(i_location, randi([1, 30]), randi([1, 5])); % assume all parakeets died in last 3 years
    end
    for each = 1:start_predators
        [bound_X, bound_Y] = boundingbox(environment.boundary.shape);
        i_location.x = randi(bound_X);
        i_location.y = randi(bound_Y); 
        brood.spawn_predator(randi([1, 3]), get_rand(["male", "female"]), i_location);
    end

    % Tick
    brood.run_days(days, run_name);
    population = brood.time_history;
    emoji = ":)";
    if population.para_count(end) == 0
        emoji = ":(";
    end
    fprintf("%i parakeets on day %i. %s\n", population.para_count(end), population.day(end), emoji);
    statistics = brood.statistics;
    f = figure(2);
    plot(population.day, population.para_count);
    xlabel("Days");
    ylabel("Population");
    camelled = replace(run_name, "_", " ");
    title(camelled);
    set(f, 'Position', [300, 200, 1067, 600]);
    exportgraphics(f, sprintf("exports/hindcasting/%s/%s_timehistory.png", run_name, run_name), "resolution", 300);
%     if plotting == true
%         close(render_figure)
%     end
end