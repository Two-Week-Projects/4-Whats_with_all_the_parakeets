classdef p2_run_statistics
    %P2_RUN_STATISTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        total_deaths = []
        death_stats = struct(...
            "nourishment", [],...
            "environment", [],...
            "social", [],...
            "age", [],...
            "predators", [])
        life_stats = struct(...
            "parakeets_born", [])
        day_statistics % mutable day-wise statistics
    end
    
    
    methods
        function self = p2_run_statistics()
        end
        
        function summ_results = summarise(self)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            summ_results = struct(...
                "nourishment_deaths", sum(self.death_stats.nourishment),...
                "environment_deaths", sum(self.death_stats.environment),...
                "social_deaths", sum(self.death_stats.social),...
                "age_deaths", sum(self.death_stats.age),...
                "predator_deaths", sum(self.death_stats.predators));
        end
        function plot_time_history(self)
            
        end
    end
end

