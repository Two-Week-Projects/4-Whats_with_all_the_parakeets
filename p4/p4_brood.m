classdef p4_brood < handle
    %P4_BROOD This is a backwards-in-time brood
    %   Detailed explanation goes here
    
    properties
        environment
        parakeets
        dead_parakeets
        predators
        plotting = struct(...
            "init", false,...
            "ax", false,...
            "X", [], "Y", [], "healths", struct("X", [], "Y", []),...
            "death_location", struct(...
                "X", [],...
                "Y", []...
            ), ...
            "predators", struct("X", [], "Y", []),...
            "plot_var", false, ...
            "plot_death", false, ...
            "plot_health", false, ...
            "plot_predators", false ...
            ) % variable to access the plot data
        time_history = struct("day", [0], "para_count", [0])
        statistics
    end
    
    methods
        function self = p4_brood(environment)
            %% Initialise brood
            self.environment = environment;
            self.parakeets = [];
            self.plotting.plot_var = false;
            if self.environment.plotting == true
                self.plot()
            end
            self.statistics = p4_run_statistics();
        end
        function remove_parakeet(self, parakeet)
            %% Remove a given parakeet from my list of parakeets
%             self.statistics.day_statistics.birth = self.statistics.day_statistics.total_deaths + 1;
            self.parakeets = self.parakeets(self.parakeets~=parakeet);
        end
        function remove_predator(self, predator)
           self.predators = self.predators(self.predators ~= predator); 
        end
        function spawn_parakeet(self, age, gender, location)
            %% Create a new parakeet and add to my list of parakeets - Used only for initialisiation.
            if nargin < 4 % location not set 
                location = self.assure_location(...
                    self.environment.get_random_location());
            end
            % Make me a parakeet!
            new_parakeet = p4_parakeet(age, gender, self, self.assure_location(location));
            self.parakeets = [self.parakeets, new_parakeet];      
        end
        function remove_dead_parakeet(self, dead_parakeet)
            self.dead_parakeets = self.dead_parakeets(self.dead_parakeets ~= dead_parakeet);
        end
        function spawn_dead_parakeet(self, location, days, age)
            %% Spawn a dead parakeet in to your brood
            % Days is the number of days until the parakeet will rise from the dead
            % Age is the age of the parakeet at death
            % Location is obviously the location of the parakeet
            new_dead_parakeet = p4_dead_parakeet(location, days, age, self);
            self.dead_parakeets = [self.dead_parakeets, new_dead_parakeet];
        end
        function spawn_predator(self, age, gender, location)
            %% Create a new predator and add to my list of predators
            if nargin < 4 % location not set 
                location = self.assure_location(...
                    self.environment.get_random_location());
            end
            % Make me a predator!
            new_predator = p4_predators(age, gender, self, self.assure_location(location));
            self.predators = [self.predators, new_predator];
        end
        function run_days(self, num_days, run_name)
            global parameters
            
            start_date = self.time_history.day(end);
            filename = sprintf('exports/hindcasting/%s/im_%s.gif', run_name, run_name);
            prev_annotates = [];
            %% Run the simulation for a specified number of days
            for each_day = start_date:-1:start_date-num_days % Run t
                self.statistics.day_statistics = struct(...
                    "total_deaths", 0,...
                    "death_stats", struct(...
                        "nourishment", 0,...
                        "environment", 0,...
                        "social", 0,...
                        "age", 0,...
                        "predators", 0),...
                    "life_stats", struct(...
                        "parakeets_born", 0)...
                );
                self.plotting.X = [];
                self.plotting.Y = [];
                self.plotting.healths.X = [];
                self.plotting.healths.Y = [];
                self.plotting.death_location.X = [];
                self.plotting.death_location.Y = [];
                self.plotting.predators.X = [];
                self.plotting.predators.Y = [];
                for each_parakeet = self.parakeets
                    % Populate the list of locations for the parakeets
                    self.plotting.X = [self.plotting.X, each_parakeet.location.x];
                    self.plotting.Y = [self.plotting.Y, each_parakeet.location.y];
                end
                for each_dead_parakeet = self.dead_parakeets
                    % Populate the list of locations for the parakeets
                    self.plotting.death_location.X = [self.plotting.death_location.X, each_dead_parakeet.location.x];
                    self.plotting.death_location.Y = [self.plotting.death_location.Y, each_dead_parakeet.location.y];
                end
                for each_predator = self.predators
                    % Populate the list of locations for the parakeets
                    self.plotting.predators.X = [self.plotting.predators.X, each_predator.location.x];
                    self.plotting.predators.Y = [self.plotting.predators.Y, each_predator.location.y];
                end
                for each_food_source = self.environment.food_sources
                    % Simulate the food sources available
                    each_food_source.tick();
                end
                for each_park = self.environment.parks
                    % Simulate the competition in the parks
                    each_park.competition.tick();
                end
                for each_parakeet = self.parakeets
                    % Simulate the parakeets in their lovely lives
                    each_parakeet.tick();
                    if mod(each_day, 365) == parameters.life.breeding_season(2)
                        each_parakeet.mating = struct("paired_with", false, "successful", true, "shut_up_im_mating", false);
                    elseif mod(each_day, 365) == parameters.life.breeding_season(1)
                        each_parakeet.mating = struct("paired_with", false, "successful", false, "shut_up_im_mating", false);
                    end
                end
                for each_dead_parakeet = self.dead_parakeets
                   each_dead_parakeet.tick(); 
                end
                for each_predator = self.predators
                    each_predator.tick();
                end
                if self.plotting.init ~= false
                    % Plot the parakeets and lines
                    global await_key
                    if is_int(await_key)
                        while true % wait for "Enter" to be pressed.
                            w = waitforbuttonpress; 
                            key = get(gcf,'currentcharacter'); 
                            switch key
                                case await_key
                                    break
                                otherwise 
                                  Wait for a different command. 
                            end
                        end
                    else
                        pause(await_key);
                    end
                    
%                     Parakeet death locations
                    warning("off")
                    set(self.plotting.plot_death, "XData", self.plotting.death_location.X);
                    set(self.plotting.plot_death, "YData", self.plotting.death_location.Y);
                    set(self.plotting.plot_healths, "XData", self.plotting.healths.X);
                    set(self.plotting.plot_healths, "YData", self.plotting.healths.Y);
                    warning("on")
%                     Parakeet locations
                    set(self.plotting.plot_var, "XData", self.plotting.X);
                    set(self.plotting.plot_var, "YData", self.plotting.Y);
%                     Predator locations
                    set(self.plotting.plot_predators, "XData", self.plotting.predators.X);
                    set(self.plotting.plot_predators, "YData", self.plotting.predators.Y);
%                     Title changing
                    set(gca, "Title", title(...
                        sprintf(parameters.graph.tit, length(self.parakeets), each_day)));
%                     Food sources
                    for each_fs = self.environment.food_sources
                        if each_fs.contained_food >= 5000000 || each_fs.contained_food <= 0
                            set(each_fs.plotting.txt, "String", sprintf("%2.2e", int64(each_fs.contained_food)));
                        else
                           set(each_fs.plotting.txt, "String", ""); 
                        end
                    end
                    for each_p = self.environment.parks
                        set(each_p.plotting.pl, "FaceColor", each_p.colour());
                    end
                    refreshdata(self.plotting.ax, "caller");
                    drawnow
                    prev_annotates = p4_annotate_parameters(parameters, prev_annotates);
                    prev_annotates = p4_annotate_statistics(self.statistics, prev_annotates);
                    frame = getframe(gcf);
                    im = frame2im(frame);
                    [imind,cm] = rgb2ind(im,256); 
                    if each_day == start_date
                        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
                    else 
                        imwrite(imind,cm,filename,'gif','WriteMode','append'); 
                    end 

                end
                self.time_history.day = [self.time_history.day, each_day];
                self.time_history.para_count = [self.time_history.para_count, length(self.parakeets)];
                if mod(each_day, 366) == 0
                    year = (each_day - mod(each_day, 366)) / 366;
                    fprintf("Year %i\n", year);
                end
                if mod(each_day, 30) == 0
                    fprintf("Day %i, with %i parakeets.\n", each_day, length(self.parakeets));
                end
                
                
                self.statistics.total_deaths = [self.statistics.total_deaths, self.statistics.day_statistics.total_deaths];
                self.statistics.death_stats.nourishment = [self.statistics.death_stats.nourishment,...
                    self.statistics.day_statistics.death_stats.nourishment];
                self.statistics.death_stats.environment = [self.statistics.death_stats.environment,...
                    self.statistics.day_statistics.death_stats.environment];
                self.statistics.death_stats.social = [self.statistics.death_stats.social,...
                    self.statistics.day_statistics.death_stats.social];
                self.statistics.death_stats.age = [self.statistics.death_stats.age,...
                    self.statistics.day_statistics.death_stats.age];
                self.statistics.death_stats.predators = [self.statistics.death_stats.predators,...
                    self.statistics.day_statistics.death_stats.predators];
                self.statistics.life_stats.parakeets_born = [self.statistics.life_stats.parakeets_born,...
                    self.statistics.day_statistics.life_stats.parakeets_born];
            
                if (isempty(self.parakeets) && isempty(self.dead_parakeets)) && each_day ~= 0
                    return
                end
            end
        end
        function plot(self)
            %% Plot the parakeets on the graph
            ax = gca;
            hold on
            self.plotting.X = [0];
            self.plotting.Y = [0];
            self.plotting.death_location.X = [0];
            self.plotting.death_location.Y = [0];
            self.plotting.healths.X = [0];
            self.plotting.healths.Y = [0];
            self.plotting.predators.X = [0];
            self.plotting.predators.Y = [0];
            self.plotting.plot_death = plot(ax, self.plotting.death_location.X, self.plotting.death_location.Y, "xr");
            self.plotting.plot_var = plot(ax, self.plotting.X, self.plotting.Y, 'ob', 'MarkerFaceColor', 'g');
            self.plotting.plot_healths = plot(ax, self.plotting.healths.X, self.plotting.healths.Y, 'ob',...
                'MarkerFaceColor', 'r', 'MarkerSize', 4);
            self.plotting.plot_predators = plot(ax, self.plotting.predators.X, self.plotting.predators.Y,...
                'ow', 'MarkerFaceColor', 'b');
            self.plotting.ax = ax;
            self.plotting.init = true;
            self.plotting.X = [];
            self.plotting.Y = [];
            self.plotting.death_location.X = [];
            self.plotting.death_location.Y = [];
            self.plotting.healths.X = [];
            self.plotting.healths.Y = [];
            self.plotting.predators.X = [];
            self.plotting.predators.Y = [];
            set(self.plotting.plot_death, "XData", self.plotting.death_location.X)
            set(self.plotting.plot_death, "YData", self.plotting.death_location.Y)
            set(self.plotting.plot_var, "XData", self.plotting.X)
            set(self.plotting.plot_var, "YData", self.plotting.Y)
            set(self.plotting.plot_healths, "XData", self.plotting.healths.X)
            set(self.plotting.plot_healths, "YData", self.plotting.healths.Y)
            set(self.plotting.plot_predators, "XData", self.plotting.predators.X)
            set(self.plotting.plot_predators, "YData", self.plotting.predators.Y)
            hold off            
        end
        function location = assure_location(~, checked_location)
            %% Assure that the location you have given can be used
            raised_error = "You have not given me a viable location";
            new_location = struct("x", 0, "y", 0);
            if isstruct(checked_location)
                failed = [true, true];
                if isfield(checked_location, "x")
                    new_location.x = checked_location.x;
                    failed(1) = false;
                end
                if isfield(checked_location, "y")
                    new_location.y = checked_location.y;
                    failed(2) = false;
                end
                if or(failed(1), failed(2))
                    error(raised_error);
                end
            elseif length(checked_location)>=2
                new_location.x = checked_location(1);
                new_location.y = checked_location(2);
            else
                error(raised_error);
            end
            
            location = new_location;
        end
        function [in_food, food_source, cfs_return] = closest_food_source(self, parakeet)
            %% Find the nearest food source to a given parakeet
            in_food = false;
            food_sources = self.environment.food_sources; % returns a set of coordinates
            food_source = food_sources(1);
            cfs_X = food_source.X;
            cfs_Y = food_source.Y;
            p_x = parakeet.location.x;
            p_y = parakeet.location.y;
            [distance_to_cfs, x_cfs, y_cfs] = p_poly_dist(p_x, p_y, cfs_X, cfs_Y);
            for each_fs = food_sources(2:end) % skip the first one
                has_food = each_fs.has_food();
                if has_food == true
                    cfs_X = each_fs.X;
                    cfs_Y = each_fs.Y;
                    [distance_to_each_food_source, te_X, te_Y] = p_poly_dist(p_x, p_y, cfs_X, cfs_Y);
                    if distance_to_each_food_source < distance_to_cfs
                        % if this food source is the new closest...
                        distance_to_cfs = distance_to_each_food_source;
                        x_cfs = te_X;
                        y_cfs = te_Y;
                        food_source = each_fs;
                    end
                end
            end
            cfs_return = [x_cfs, y_cfs];
            if distance_to_cfs <= 0
                in_food = true;
            end
        end
        function [in_park, park, cp_return] = closest_park(self, parakeet)
            %% Find the nearest park to a given parakeet
            in_park = false;
            parks = self.environment.parks;
            park = parks(1);
            cp_X = park.X;
            cp_Y = park.Y;
            p_x = parakeet.location.x;
            p_y = parakeet.location.y;
            [distance_to_cp, x_cp, y_cp] = p_poly_dist(p_x, p_y, cp_X, cp_Y);
            for each_park = parks(2:end) % go through all but first park
                cp_X = each_park.X;
                cp_Y = each_park.Y;
                [distance_to_each_park, te_X, te_Y] = p_poly_dist(p_x, p_y, cp_X, cp_Y);
                if distance_to_each_park < distance_to_cp
                    % if this park is the new closest..
                    distance_to_cp = distance_to_each_park;
                    x_cp = te_X;
                    y_cp = te_Y;
                    park = each_park;
                end
                
            end
            cp_return = [x_cp, y_cp] ;
            if distance_to_cp <= 0
                in_park = true;
            end
        end
    end
    
end

