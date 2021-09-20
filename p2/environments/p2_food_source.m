classdef p2_food_source < handle
    %P2_FOOD_SOURCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X = []
        Y = []
        centre = struct("x", 0, "y", 0)
        contained_food
        plotting = struct("pl", false, "txt", "");
        suppress_msg = false
        max_food
    end
    
    methods
        function self = p2_food_source(X,Y)
            global parameters
            %P2_FOOD_SOURCE Construct an instance of this class
            %   Detailed explanation goes here
            self.X = X;
            self.Y = Y;
            shape = polyshape(X, Y);
            [self.centre.x, self.centre.y] = centroid(shape);
            self.max_food = area(shape) * parameters.scalers.nourishment_per_sq_m2;
            self.contained_food = self.max_food;
            clear shape
        end
        function tick(self)
            %% Like the "tick" in Unreal Engine, called every time step (which is every day)
            % Increase food by a rate of 0.5% per day + 2000 (somewhat size dependant).
            self.contained_food = min((self.contained_food*1.005) + 1500, self.max_food);
        end
        function result = has_food(self)
            global suppress_output
            result = true;
            pa = self.proportion_available();
            if pa < 0.1 % must have at least 15% of its normal amount of food
                result = false;
                if suppress_output ~= true && self.suppress_msg == false
                    fprintf("Food source at %i, %i has been depleted!\n", self.centre.x, self.centre.y);
                end
                self.suppress_msg = true;
            end
        end
        function [is_food, give_food] = available_food(self)
            %% Give food to a parakeet, and deplete the food store by an amount.
            global parameters
            is_food = false;
            give_food = 0;
            if self.has_food() == true
                is_food = true;
                self.suppress_msg = false;
                give_food = min(self.contained_food, parameters.needs.boosters.nourishment);
                self.contained_food = self.contained_food - give_food;                
            end
                
        end
        function proportion = proportion_available(self)
            %% Get the current proportion of food available compared to the norm
            proportion = self.contained_food / self.max_food;
        end
    end
end

