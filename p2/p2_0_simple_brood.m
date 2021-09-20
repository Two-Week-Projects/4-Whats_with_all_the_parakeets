%% Inits (grabbed from p1_0)
% every distance is in metres!
% the time step is every day
function [population, statistics] = p2_0_simple_brood(days, start_population, environment, start_park, run_name, plotting)
    %% Return the population at a given enddate
    close 

    global render_figure

    % Initialise
    if plotting == true
        plotting = environment.plot_env();
    end
    
    brood = p2_brood(environment);
    
    [bound_X, bound_Y] = boundingbox(start_park.shape);
    
    %% Generate initial parakeet population
    for each = 1:start_population
        i_location.x = randi(bound_X);
        i_location.y = randi(bound_Y); 
        brood.spawn_parakeet(randi([3, 15]), get_rand(["male", "female"]), i_location);
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
    exportgraphics(f, sprintf("exports/%s/%s_timehistory.png", run_name, run_name), "resolution", 300);
%     if plotting == true
%         close(render_figure)
%     end
end