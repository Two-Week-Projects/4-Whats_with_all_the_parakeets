 
clear
close("all")

global suppress_output
suppress_output = true;

global await_key
await_key = 0.001; % put a fraction for a second delay,
% await_key = 13
% put an integer for a key press ("Enter" = 13)

load("ext_data/park_boundaries.mat");

load handel % super necessary..... :p
halleluliah = y;
clear y

boundary = p4_boundary(...
    [-33000, 33000, 33000, -33000],...
    [-15000, -15000, 15000, 15000]...
    );

%% Parameters
global parameters
parameters = struct();
parameters.graph = struct(...
    "tit", "Parakeet Sim. %i parakeets, on day %i"...
    );
parameters.needs = struct(... % constants for energy depletion with distance etc.
    "hunger_per_m", 5/1000,...
    "flight_distance_per_day", 250, ... % the maximum distance a parakeet's "home" can move per day
    "days_without_nourishment", 6, ... % the number of days a parakeet can survive without food
    "days_without_social", 6, ... % the number of days alone before a parakeet will die4
    "days_without_environment", 6, ... % number of days away from a park before a parakeet will die
    "min_distances", struct(...
        "socialising_min_distance", 2000, ... % minimum distance for a parakeet to socialise
        "breeding_min_distance", 100,... % breed if you're within this many metres
        "park_min_distance", 1000, ... % if you are this close to a park then get some value from it.
        "food_min_distance", 1350 ... % the furthest you can be from a food source to still eat from it.
        ),...
    "boosters", struct(...
        "nourishment", 75, ... % the max amount of nourishment you get from a food source per day
        "environment", 80, ... % the amount of environment boost you get from being in a park
        "social", 75), ... % the amount of social boost you get from being near another parakeet
    "criticals", struct(... % the values at which shit gets critical
        "nourishment", 60,...
        "social", 50,...
        "environment", 50)...
    );
parameters.life = struct(... % reproduction constants
    "life_expectancy", 40,... % that maximum life expectancy of a parakeet
    "breeding_age", 3,... % the minimum age that parakeets can start breeding
    "breeding_success_per_nourishment", 0.5 / 100, ... % hungry mothers are less likely to have fledlings
    "roost_numbers", [1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5], ...
    "breeding_season", [3, 100]... % breed between day 1st Jan and 10th Apr
    );
parameters.scalers = struct(...
    "nourishment_per_sq_m2", 0.1 ... % the amount of food a park will contain
    );
parameters.predators = struct(...
    "needs", struct(...
        "nourishment", 500),... % predators can survive a lot longer.
    "hunting", struct(...
        "distance", 400,... % the furthest a predator can be from a parakeet to attack
        "nourishment", 450),... % the amount of nourishment a predator will get from attacking
    "vegan", struct(...
        "nourishment", 250),...
    "min_distances", struct(...
        "flight_distance_per_day", 350 ... % the maximum distance a predator can fly in a day
        )...
    );

%% Parks
background_image = 'ext_data/london_small_scale.png';
I = size(imread(background_image));
x_size = I(2);
y_size = I(1);
parks = [];
foods = [];
warning("off")
for each = park_boundaries
    k = cell2mat(each);
    X = map_vars(k(1:end,1), [2, x_size+1], [boundary.bounding.minX, boundary.bounding.maxX], true);
    Y = map_vars(k(1:end,2), [2, y_size+1], [boundary.bounding.maxY, boundary.bounding.minY], true);
    food = p4_food_source(X,Y);
    foods = [foods, food];
    parks = [parks, p4_park(X,Y, food)];
end
warning("on")

%% Initialise London
start_park = p4_park(...
    [-2000, 1500, 1500, -2000],...
    [3500, 3500, 5000, 5000], false);

environment = p4_environment(boundary, foods, parks, background_image);

% goal = struct("day", 0, "population", 0, "limit", 1);
for i = 1:1 % do not exceed this many runs
    run_name = "hindsighting_10";
    warning("off")
    mkdir(sprintf("exports/hindcasting/%s", run_name));
    warning("on")
    [population, statistics] = p4_0_brood_and_predators(365 * 20, 10, 0, environment, start_park, run_name, true);
%     parameters = p4_2_mc_optimise(statistics, parameters); % optimise the parameters based on the results
    sound(halleluliah, Fs);
end