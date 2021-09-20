classdef p2_parakeet < handle
    % Parakeet model
    %   The collection of variables and functions do define one parakeet.
    
    properties
        %% All of the metrics that define a single parakeet
        id
        needs = struct(...
                "nourishment", 100,... % How hungry is the parakeet? (affected by food, flight, breeding, and affects breeding success)
                "environment", 100,... % How happy is the parakeet in its environment? (affected by parkness/buildingness and crampedness)
                "social", 100,... % How sociable/lonely is the parakeet? (affected by proximity to other parakeets, affects breeding success)
                "safety", 100)
        age = 0
        gender = "male"
        location = struct("x", 0, "y", 0)
        desired_location = struct("x", 0, "y", 0)
        mating = struct("paired_with", false, "successful", false, "shut_up_im_mating", false)
        brood % A map of the resources around you
    end
    
    methods
        function self = p2_parakeet(age, gender, brood, location)
            t_id = char(java.util.UUID.randomUUID.toString);
            self.id = t_id(1:8);
            %% Construct a new parakeet
            self.age = age;
            self.gender = gender;
            self.brood = brood;
            self.location = location;
        end
        function tick(self)
            global parameters
            %% Like the "tick" in Unreal Engine, called every time step (which is every day)
            
            % Reduce needs by one day's worth
            self.needs.nourishment = self.needs.nourishment - (100 / parameters.needs.days_without_nourishment);
            self.needs.environment = self.needs.environment - (100 / parameters.needs.days_without_environment);
            self.needs.social = self.needs.social - (100 / parameters.needs.days_without_social);
            self.age = self.age + (1 / 365); % age the budgie by one day
            self.needs.safety = min(self.needs.safety + 1, 100);
            
            %% Check that you're not dieing
            if self.needs.nourishment <= 0 || ...
                    self.needs.environment <= 0 || ...
                    self.needs.social <= 0 || ...
                    self.needs.safety <= 0 || ... % attacked by a predator
                    self.age > parameters.life.life_expectancy
                self.die()
            end                                 
            
            %% Need processing
            [in_food_source, food_source, ~] = self.in_food_source();
            if in_food_source
                [~, have_food] = food_source.available_food();
                self.needs.nourishment = min(self.needs.nourishment + have_food, 100);
            end
            if self.in_park()
                self.needs.environment = min(self.needs.environment +...
                    parameters.needs.boosters.environment, 100);
            end
            tmp_nearest_parakeet = self.find_nearest_parakeet();
            if tmp_nearest_parakeet ~= false
                tmp_distance_to_nearest_parakeet = self.find_distance_to(tmp_nearest_parakeet.location);
                if tmp_distance_to_nearest_parakeet <= parameters.needs.min_distances.socialising_min_distance
                    self.needs.social = min(self.needs.social + parameters.needs.boosters.social, 100);
                end
            end
            
            %% Take action based on your priorities
            priority = self.eval_needs();
            switch string(priority)
                case "nourishment"
                    self.find_food()
                case "environment"
                    self.find_park()
                case "social"
                    self.find_friends()
                otherwise
                    if ~self.mating.shut_up_im_mating
                        self.find_random_spot();
                    end
            end
            
            %% Flying behaviour
            self.fly();
        end
        function priority = eval_needs(self)
            global parameters
            %% Evaluate the parakeets priority
            priority = false; % no priority, so do whatever.
            if self.needs.nourishment <= parameters.needs.criticals.nourishment
                priority = "nourishment";
                return
            elseif self.needs.social <= parameters.needs.criticals.social
                priority = "social";
                return
            elseif self.needs.environment <= parameters.needs.criticals.environment
                priority = "environment";
                return
            end            
        end
        function find_food(self)
            %% Find the nearest food source, and set it to your desired location.
            [in_food, ~, closest_food_point] = self.in_food_source();
            if in_food ~= true
                self.desired_location = self.brood.assure_location(closest_food_point);
            else    
                self.find_random_spot();
            end
        end
        function find_park(self)
            %% Find the nearest park.
            [~, ~, closest_park_point] = self.brood.closest_park(self);
            self.desired_location = self.brood.assure_location(closest_park_point);
            
        end
        function find_friends(self)
            %% Fly to the nearest parakeet for some company.
            nearest_parakeet = self.find_nearest_parakeet();
            if nearest_parakeet ~= false
                self.desired_location = self.brood.assure_location(nearest_parakeet.location); 
            else
                self.find_random_spot();
            end
        end
        function [i_am_near, closest_food_source, closest_food_point] = in_food_source(self)
            global parameters
            %% Find the nearest food source to the parakeets
            [i_am_near, closest_food_source, closest_food_point] = self.brood.closest_food_source(self); 
            if i_am_near ~= true
                distance_to_food_source = self.find_distance_to(closest_food_point);
                if distance_to_food_source <= parameters.needs.min_distances.food_min_distance
                   i_am_near = true; 
                end
            end
        end
        function i_am_in_park = in_park(self)
            global parameters
            %% Check if you are in a park.
           [i_am_in_park, ~, closest_point_to_park] = self.brood.closest_park(self); 
           if i_am_in_park ~= true
               distance_to_park = self.find_distance_to(closest_point_to_park);
               if distance_to_park <= parameters.needs.min_distances.park_min_distance
                  i_am_in_park = true; 
               end
           end
        end
        function find_mate(self)
            %% Find the nearest mate that is the opposite gender (sorry 2021) and doesn't have a partner, that is old enough
            global parameters
            if self.mating.paired_with == false && self.mating.successful == false
                if self.age >= parameters.life.breeding_age
                    ignore_list = [];
                    for i = 1:length(self.brood.parakeets)
                        % look at every other parakeet and determine if they would be a viable mate
                        nearest = self.find_nearest_parakeet(ignore_list);
                        if nearest == false
                            return
                        end
                        if (nearest.mating.paired_with == false || nearest.mating.paired_with == self)...
                                && nearest.age >= parameters.life.breeding_age...
                                && nearest.gender ~= self.gender
                            self.mating.paired_with = nearest;
                            nearest.mating.paired_with = self; % bit rapey, but sure, whatever.
                            break
                        else
                            ignore_list = [ignore_list, nearest];
                        end
                    end
                end            
            end
        end
        function mate(self)
            self.find_mate()
            %% Attempt to mate with your partner, or find one if you don't have one and you're old enough
            % this function is initiated every January
            global parameters
            if self.mating.paired_with ~= false && self.mating.successful ~= true
            % if you are paired with another parakeets and so far you've not successfully mated...
                if self.find_distance_to(self.mating.paired_with.location) <= parameters.needs.min_distances.breeding_min_distance
                % if you and your paired parakeeet are within the breeding min distance then breed successfully
                    % give them twice as likely a random chance to breed each day of the mating season
                    if randi([0, round(range(parameters.life.breeding_season) / 10)]) == 1
                        if self.gender == "female"
                            egg_count = get_rand(parameters.life.roost_numbers);
                            success_chance = parameters.life.breeding_success_per_nourishment * self.needs.nourishment;
                            fledgelings = round(success_chance * egg_count);
                            for i = 1:fledgelings
                                self.brood.spawn_parakeet(0, get_rand(["female", "male"]), self.location);
                                self.brood.statistics.day_statistics.life_stats.parakeets_born = ...
                                                self.brood.statistics.day_statistics.life_stats.parakeets_born + 1;
                            end
                        end
                        self.mating.paired_with.desired_location = self.mating.paired_with.location; % Don't let that parakeet fly away
                        self.mating.successful = true;
                        self.mating.paired_with = false;
                        self.mating.shut_up_im_mating = false;
                    else
                        self.find_random_spot();
                    end
                else
                % otherwise go find your parakeet, young lovers
                    self.desired_location.x = (self.location.x + self.mating.paired_with.location.x) / 2;
                    self.desired_location.y = (self.location.y + self.mating.paired_with.location.y) / 2;
                    self.mating.shut_up_im_mating = true;
                end
            end
        end
        function fly(self)
            %% Fly towards your desired location
            global parameters
            
            init_loc = self.location;
            
            des_loc_dist = self.find_distance_to(self.desired_location);
            if des_loc_dist <= parameters.needs.flight_distance_per_day
                self.location = self.desired_location;
            else
                travel_vector = [0, 0];
                travel_vector(1) = self.desired_location.x - self.location.x;
                travel_vector(2) = self.desired_location.y - self.location.y;
                u_trvl_vector = travel_vector./norm(travel_vector);
                tmp_location = self.location;
                loc_vector = self.brood.assure_location(...
                    u_trvl_vector .* parameters.needs.flight_distance_per_day...
                );
                self.location.x = loc_vector.x + self.location.x;
                self.location.y = loc_vector.y + self.location.y;
            end
            
            %% Reduce nourishment due to flight
            travel_distance = self.find_distance_to(init_loc);
            self.needs.nourishment = self.needs.nourishment - (travel_distance * parameters.needs.hunger_per_m);
            
        end
        function die(self)
            global parameters
            %% remove yourself from the brood list
            death_note = "unknown causes";
            if self.needs.nourishment <= 0
                death_note = "starvation";
            elseif self.needs.social <= 0
                death_note = "crippling loneliness";
            elseif self.needs.environment <= 0
                death_note = "hating their environment";
            elseif self.needs.safety <= 0
                death_note = "being attacked by a predator";
            elseif self.age > parameters.life.life_expectancy
                death_note = "old age";
            end
            self.brood.remove_parakeet(self, death_note)
        end
        function nearest = find_nearest_parakeet(self, ignores)
            %% find the nearest parakeet to you, and ignore those specified
            self_index = find(self.brood.parakeets==self);
            parakeet_local = self.brood.parakeets(self.brood.parakeets ~= self);
            para_Xs = self.brood.plotting.X;
            para_Ys = self.brood.plotting.Y;
            para_Xs(self_index) = [];
            para_Ys(self_index) = [];
            if nargin ~= 2
                ignores = [];  % default empty
            end
            for each = ignores % ignore all the parakeets in the ignore list
                ignore_index = find(parakeet_local==each);
                para_Xs(ignore_index) = [];
                para_Ys(ignore_index) = [];
                parakeet_local(ignore_index) = [];
            end
            if length(para_Xs) < 1 || length(parakeet_local) < 1
                nearest = false;
                return
            end
            distances_sqd = (self.location.x - para_Xs).^ 2 + (self.location.y - para_Ys).^ 2;
            
            distances_sqd = distances_sqd(1:min(length(parakeet_local), length(distances_sqd)));
            nearest = parakeet_local(distances_sqd == min(distances_sqd));
            if length(nearest) > 1
                nearest = nearest(1); % if there are multiple equidistant, just choose the first one that comes up
            end
        end
        function distance = find_distance_to(self, location)
            %% find the RMS distance between yourself and a given location
            location = self.brood.assure_location(location);
            x = self.location.x - location.x;
            y = self.location.y - location.y;
            distance = sqrt(x^2 + y^2);            
        end
        function attacked_by_predator(self)
            %% placeholder function to evaluate if you've been killed by a predator
            if self.age <= 1 || self.age >= 15
                damage = 100;
            else
                damage = 51;
            end
            self.needs.safety = self.needs.safety - damage;
            self.needs.nourishment = self.needs.nourishment - 20;
            self.brood.plotting.healths.X = [self.brood.plotting.healths.X, self.location.x + 2];
            self.brood.plotting.healths.Y = [self.brood.plotting.healths.Y, self.location.y + 2];
        end
        function find_random_spot(self)
            global parameters
            pfd = parameters.needs.flight_distance_per_day;
            while true
                prop_x = self.location.x + randi([-pfd, pfd]);
                prop_y = self.location.y + randi([-pfd, pfd]);
                if inpolygon(prop_x, prop_y, ...
                        self.brood.environment.boundary.X, self.brood.environment.boundary.Y)
                    % confine the parakeets to the environment boundaries
                    self.desired_location.x = prop_x;
                    self.desired_location.y = prop_y;
                   break
                end
            end
        end
    end
end
