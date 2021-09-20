classdef p4_environment < handle
    %P4_ENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        grid = [] % a grid of all the possible (int) coordinates within the allocated boundaries.
        boundary % a polygon definition of the outer perimeter of the environment
        food_sources % a vector set of coordinates
        parks % a collection of polyshapes
        plotting = false
        background_img = false;
    end
    
    methods
        function self = p4_environment(boundary, food_sources, parks, background_img)
            %% Initialise the environmet
            self.boundary = boundary;
            self.food_sources = food_sources;
            self.parks = parks;
            if nargin >= 4
                self.background_img = background_img;
            end
            for each_park = parks
               each_park.set_nearest_parks(parks)                
            end
        end
        function location = get_random_location(self)
            %% Get a random location that is within the poly bounds
            tmp_location = [...
                randi([self.boundary.bounding.minX, self.boundary.bounding.maxX]),...
                randi([self.boundary.bounding.minY, self.boundary.bounding.maxY])];
            location.x = tmp_location(1);
            location.y = tmp_location(2);
            while 1
                [in_boundaries, ~, ~] = p_poly_dist(location.x, location.y, self.boundary.X, self.boundary.Y);
                if in_boundaries >= 0
                    location.x = randi([self.boundary.bounding.minX, self.boundary.bounding.maxX]);
                    location.y = randi([self.boundary.bounding.minY, self.boundary.bounding.maxY]);
                else
                    break
                end
            end
        end
        function plotting = plot_env(self, fig_num)
            %% Display the environment (for debugging)
            global render_figure
            if nargin < 2 % self and fig_num
                fig_num = 1;
            end
            render_figure = figure(fig_num);
            global parameters
            ax = axes('Parent', render_figure);
            ax.XLim = [min(self.boundary.X), max(self.boundary.X)];
            ax.YLim = [min(self.boundary.Y), max(self.boundary.Y)];
            hold on
            title(sprintf(parameters.graph.tit, 0, 0));
            pl = plot(ax, self.boundary.shape);
            pl.FaceColor = "black";
            pl.FaceAlpha = 0.2;
            for each_p = self.parks
                each_p.plotting.pl = plot(ax, each_p.shape);
                each_p.plotting.pl.FaceColor = each_p.colour();
                each_p.plotting.pl.FaceAlpha = 0.5;
            end
            for each_fs = self.food_sources
                each_fs.plotting.pl = plot(ax, each_fs.centre.x, each_fs.centre.y, '.r');
                each_fs.plotting.txt = text(each_fs.centre.x + 5, each_fs.centre.y + 5, "");
            end
            
            if self.background_img ~= false
                I = imread(self.background_img); 
                h = image(xlim,-ylim,I); 
                uistack(h,'bottom')
            end
            
            set(gcf, 'Position', [300, 200, 1067, 600]);
            hold off
            self.plotting = true;
            plotting = true;
        end
    end
end

