classdef p4_park < handle
    %P4_PARKS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X = []
        Y = []
        shape
        centre = struct("x", 0, "y", 0)
        nearest_parks = [];
        plotting = struct("pl", false, "colour", "");
        competition
    end
    
    methods
        function self = p4_park(X,Y, food_source)
            %P4_PARKS Construct an instance of this class
            %   Detailed explanation goes here
            self.X = X;
            self.Y = Y;
            self.shape = polyshape(X, Y);
            [self.centre.x, self.centre.y] = centroid(self.shape);
            self.competition = p4_competition(self, food_source);
        end
        function return_colour = colour(self)
            ptn = self.competition.population_density;
            if ptn > 1
                g = max((1 - (ptn-1)*3), 0);
                b = max((1 - (ptn-1)*3), 0);
                r = min(1, (ptn-1)*5);
            elseif 0.5 < ptn && ptn <= 1
                g = 1;
                b = 1;
                r = 0;
            else
                g = max(0.3, ptn*2);
                b = max(0.3, ptn*2);
                r = 0;
            end
            return_colour = [r, g, b];
        end
        function set_nearest_parks(self, all_parks)
            all_parks = all_parks(all_parks~=self);
            %% Set the parks that are nearest to this park in an array (speeds up computation later)
            for i = 1:6 % find the 6 nearest parks
                check_parks = all_parks;
                for each_ignore = self.nearest_parks
                    check_parks(check_parks==each_ignore) = [];
                end
                park = check_parks(1);
                cp_X = park.X;
                cp_Y = park.Y;
                p_x = self.centre.x;
                p_y = self.centre.y;
                [distance_to_cp, ~, ~] = p_poly_dist(p_x, p_y, cp_X, cp_Y);
                for each_park = check_parks(2:end) % go through all but first park
                    cp_X = each_park.X;
                    cp_Y = each_park.Y;
                    [distance_to_each_park, ~, ~] = p_poly_dist(p_x, p_y, cp_X, cp_Y);
                    if distance_to_each_park < distance_to_cp
                        % if this park is the new closest..
                        distance_to_cp = distance_to_each_park;
                        park = each_park;
                    end
                end
                self.nearest_parks = [self.nearest_parks, park];
            end
            self.set_nearest_competitions();
        end
        function set_nearest_competitions(self)
            %% Tell the competition where its nearest competition is
            for each_park = self.nearest_parks
                self.competition.nearest_competitions = [self.competition.nearest_competitions, ...
                    each_park.competition];
            end
        end
    end
end

