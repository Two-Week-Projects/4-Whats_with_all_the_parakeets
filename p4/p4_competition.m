classdef p4_competition < handle
    %P4_COMPETITION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        population_density = 1
        food_source
        park
        nearest_competitions = []
        leeching = false
    end
    
    methods
        function self = p4_competition(park, food_source)
            self.food_source = food_source;
            self.park = park;            
        end
        function tick(self)
            %% Like the "tick" in Unreal Engine, called every time step (which is every day)
            proportion_to_norm = self.food_source.proportion_available();
            self.leeching = false;
            if proportion_to_norm >= 0.7
                %% If the food source has 70% or more as much food as normal
                being_leached_to = false;
                for each_c = self.nearest_competitions
                    if each_c.leeching == true
                        being_leached_to = each_c;
                        break
                    end
                end
                if being_leached_to ~= false
                    %% When another park is leaching from this park
                    proportion_of_leaching = area(being_leached_to.park.shape) / area(self.park.shape);
                    self.population_density = self.population_density - self.population_density *...
                        proportion_of_leaching * 0.005; % increase by 0.2% per day
                else
                    if self.population_density >= 1
                        %% when your population density is above 1 (overpopulated) but you're not being leached to
                        self.population_density = min(1, self.population_density * 1.005);
                    else
                        %% when your population density is less than 1 but you're not being leached to
                        self.population_density = max(1, self.population_density / 1.005);
                    end
                end
            elseif proportion_to_norm < 0.1
                %% If the food has less than 10% of the food it normally has (population starts leaching on nearby parks).
                self.population_density = min(0.05, self.population_density / (proportion_to_norm / 0.1));
                self.leeching = true;
            end
            %% reduce the amount of food at the food source proportional to the population density
            self.food_source.contained_food = self.food_source.contained_food + (1000*self.population_density);
        end
    end
end

