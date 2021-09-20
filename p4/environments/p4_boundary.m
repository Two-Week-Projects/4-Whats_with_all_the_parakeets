classdef p4_boundary
    %P4_BOUNDARY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X
        Y
        bounding = struct(...
            "minX", 0,...
            "minY", 0,...
            "maxX", 0,...
            "maxY", 0)
        shape
    end
    methods
        function self = p4_boundary(X, Y)
            %% Initialise the boundary
            self.X = X;
            self.Y = Y;
            self.bounding.minX = min(X);
            self.bounding.maxX = max(X);
            self.bounding.minY = min(Y);
            self.bounding.maxY = max(Y);
            self.shape = polyshape(self.X, self.Y);
        end
    end
end

