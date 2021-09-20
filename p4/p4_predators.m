classdef p4_predators < handle
    % Parakeet model
    %   The collection of variables and functions do define one parakeet.
    
    properties
        %% All of the metrics that define a single predator
        id
        needs = struct(...
                "nourishment", 0)% How hungry is the predator? (affected by food, flight, breeding, and affects breeding success)
        age = 0
        gender = "male"
        location = struct("x", 0, "y", 0)
        desired_location = struct("x", 0, "y", 0)
        brood % A map of the resources around you
        mate_cool_down = 365;
    end
    
    methods
        function self = p4_predators(age, gender, brood, location)
            t_id = char(java.util.UUID.randomUUID.toString);
            self.id = t_id(1:8);
            %% Construct a new predator
            global parameters
            self.age = age;
            self.gender = gender;
            self.brood = brood;
            self.location = location;
            self.needs.nourishment = parameters.predators.needs.nourishment;
        end
        function tick(self)
            global parameters
            %% Like the "tick" in Unreal Engine, called every time step (which is every day)
            
            % Reduce needs by one day's worth
            self.needs.nourishment = self.needs.nourishment - (50 / parameters.needs.days_without_nourishment);
            self.age = self.age + (1 / 365); % age the predator by one day
            
            %% Check that you're not dieing
            if self.needs.nourishment <= 0 || self.age > 4
                self.die()
            end                                 
            
            %% Take action based on your priorities
            priority = self.eval_needs();
            switch string(priority)
                case "nourishment"
                    self.hunt();
                case "dire_nourishment"
                    self.go_vegan();
                otherwise
                    pfd = parameters.predators.min_distances.flight_distance_per_day;
                    while true
                        prop_x = self.location.x + randi([-pfd, pfd]);
                        prop_y = self.location.y + randi([-pfd, pfd]);
                        if inpolygon(prop_x, prop_y, ...
                                self.brood.environment.boundary.X, self.brood.environment.boundary.Y)
                            % confine the predators to the environment boundaries
                            self.desired_location.x = prop_x;
                            self.desired_location.y = prop_y;
                           break
                        end
                    end
            end
            
            %% Flying behaviour
            self.fly();
            if self.gender == "female" && self.mate_cool_down == 0 && self.needs.nourishment >= 450 && self.age > 1
                self.brood.spawn_predator(0, get_rand(["female", "male"]), self.location);
                self.mate_cool_down = 365;
            end
            self.mate_cool_down = max(self.mate_cool_down - 1, 0);
        end
        function priority = eval_needs(self)
            %% Evaluate the predator's priority
            priority = false; % no priority, so do whatever.
            if self.needs.nourishment <= 100
                priority = "dire_nourishment";
                return
            end            
            if self.needs.nourishment <= 150
                priority = "nourishment"; % hunt parakeets
                return
            end            
        end
        function go_vegan(self)
            global parameters
            %% Find the nearest food source, and set it to your desired location.
            [in_food, ~, closest_food_point] = self.in_food_source();
            if in_food ~= true
                self.desired_location = self.brood.assure_location(closest_food_point);
            else
                self.needs.nourishment = min(self.needs.nourishment + parameters.predators.vegan.nourishment, ...
                    parameters.predators.needs.nourishment);
            end
        end
        function hunt(self)
            global parameters
            %% hunt for a parakeet
            nearest_parakeet = self.find_nearest_parakeet();
            if nearest_parakeet == false
                return
            end
            if self.find_distance_to(nearest_parakeet.location) <= parameters.predators.hunting.distance
                nearest_parakeet.attacked_by_predator();
                self.needs.nourishment = min(self.needs.nourishment + parameters.predators.hunting.nourishment,...
                    parameters.predators.needs.nourishment);
            else
                self.desired_location = self.brood.assure_location(nearest_parakeet.location);
            end
        end
        function [i_am_near, closest_food_source, closest_food_point] = in_food_source(self)
            global parameters
            %% Find the nearest food source to the parakeets
            [i_am_near, closest_food_source, closest_food_point] = self.brood.closest_food_source(self); 
            if i_am_near ~= true
                distance_to_food_source = self.find_distance_to(closest_food_point);
                if distance_to_food_source <= parameters.needs.min_distances.food_min_distance / 2 % they are less happy with food
                   i_am_near = true; 
                end
            end
        end
        function fly(self)
            %% Fly towards your desired location
            global parameters
            
            init_loc = self.location;
            
            des_loc_dist = self.find_distance_to(self.desired_location);
            if des_loc_dist <= parameters.predators.min_distances.flight_distance_per_day
                self.location = self.desired_location;
            else
                travel_vector = [0, 0];
                travel_vector(1) = self.desired_location.x - self.location.x;
                travel_vector(2) = self.desired_location.y - self.location.y;
                u_trvl_vector = travel_vector./norm(travel_vector);
                loc_vector = self.brood.assure_location(...
                    u_trvl_vector .* parameters.predators.min_distances.flight_distance_per_day...
                );
                self.location.x = loc_vector.x + self.location.x;
                self.location.y = loc_vector.y + self.location.y;
            end
            
            %% Reduce nourishment due to flight
            travel_distance = self.find_distance_to(init_loc);
            self.needs.nourishment = self.needs.nourishment - (travel_distance * parameters.needs.hunger_per_m);
            
        end
        function die(self)
            %% remove yourself from the brood list
            self.brood.remove_predator(self)
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
    end
end
