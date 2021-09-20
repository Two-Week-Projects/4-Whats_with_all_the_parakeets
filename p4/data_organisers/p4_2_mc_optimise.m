function parameters = p4_2_mc_optimise(statistics, old_parameters)



    parameters = struct();
    parameters.graph = struct(...
        "tit", "Parakeet Sim. %i parakeets, on day %i"...
        );
    parameters.needs = struct(... % constants for energy depletion with distance etc.
        "hunger_per_m", 10/1000,...
        "socialising_min_distance", 50, ... % minimum distance for a parakeet to socialise
        "flight_distance_per_day", 1000, ... % the maximum distance a parakeet can fly per day
        "nourishment", 50, ... % the max amount of nourishment you get from a food source per day
        "days_without_nourishment", 5, ... % the number of days a parakeet can survive without food
        "days_without_social", 5, ... % the number of days alone before a parakeet will die
        "days_without_environment", 5, ... % number of days away from a park before a parakeet will die
        "criticals", struct(... % the values at which shit gets critical
            "nourishment", 30,...
            "social", 30,...
            "environment", 30)...
        );
    parameters.life = struct(... % reproduction constants
        "life_expectancy", 40,... % that maximum life expectancy of a parakeet
        "breeding_age", 3,... % the minimum age that parakeets can start breeding
        "breeding_min_distance", 10,... % breed if you're within 10 metres
        "beeding_success_per_nourishment", 0.5 / 100, ... % hungry mothers are less likely to have fledlings
        "roost_numbers", [1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5], ...
        "breeding_season", [0, 100]... % breed between day 1st Jan and 10th Apr
        );
end