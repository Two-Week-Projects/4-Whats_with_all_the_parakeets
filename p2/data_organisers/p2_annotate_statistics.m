function annotates = p2_annotate_statistics(statistics, prev_annotates)
    a = gca; % get the current axis;
    a.Position(3) = 0.7;
    a.Position(1) = 0.05;
    
    delete(prev_annotates);
    % put the textbox at 75% of the width and 
    % 10% of the height of the figure
    
    statistics_list = struct(...
        "deaths_by_lack_of_nourishment", sum(statistics.death_stats.nourishment),...
        "deaths_by_lack_of_environment", sum(statistics.death_stats.environment),...
        "deaths_by_lack_of_social", sum(statistics.death_stats.social),...
        "deaths_of_old_age", sum(statistics.death_stats.age),...
        "deaths_by_predators", sum(statistics.death_stats.predators),...
        "births", sum(statistics.life_stats.parakeets_born)...
        );
    
    position = [0.775, 0.1, 0.1, 0.1];
    k = fieldnames(statistics_list);
    for ii = 1:length(k)
        k_ii = string(k(ii));
        print_kii = replace(k_ii, "_", " ");
        annotates(ii) = annotation('textbox', position, 'String',...
            sprintf("%s = %s", print_kii, string(statistics_list.(k_ii))));
        position(2) = position(2) + 0.05;
    end
end