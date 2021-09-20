classdef p1_reports < handle
    
    properties
        start_year % start year of study
        end_year % end year of study
        pop_start % starting population
        pop_end % ending population
%        syms_func % function to determine next population loop
        splits = [] % collection of split breedable values
        results = [] % collection of results (in order of splits)
    end
    
    
    
    methods
        function obj = p1_reports(year_span, pop)
            %% Constructor class
            obj.start_year = year_span(1);
            obj.end_year = year_span(2);
            obj.pop_start = pop(1);
            obj.pop_end = pop(2);
        end
        function results = run_sim(self, reproduction, splits)
            %% run simulation
            pop_current = self.pop_start;
            
            self.splits = [self.splits, splits];
            female_percentage = splits.female_percentage;
            breeding_percentage = splits.breeding_percentage;
            results.year = [];
            results.population = [];
            for i = self.start_year:self.end_year
                % cycle through each year
                females_breeding = floor(pop_current *...
                    female_percentage *...
                    breeding_percentage);
                % get number of females able to have young
                offspring = 0;
                if females_breeding >= 50 % skip the loop and use statistical average
                    offspring = floor(females_breeding * mean(reproduction.numbers));
                else
                    for j = 1:females_breeding
                        % get number of offspring
                        offspring = offspring + get_rand(reproduction.numbers);
                    end
                end
                pop_current = floor(pop_current * (1-splits.dieing_percentage));
                pop_current = pop_current+offspring;
                results.year = [results.year, i];
                results.population = [results.population, pop_current];
            end
            self.results = [self.results, pop_current];
        end
        function array = eval_valid(self, tolerance)
            %% evaluate which of the result sets are within a tolerance
            array = zeros(length(self.results), 1);
            for i = 1:length(self.results)
                result = self.results(i);
                if (result <= self.pop_end * (1 + tolerance)) && (result >= self.pop_end  * (1 - tolerance))
                    array(i) = result/self.results(i);
                end
            end
        end
    end
end

