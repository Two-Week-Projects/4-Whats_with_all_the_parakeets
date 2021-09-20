function annotates = p2_annotate_parameters(parameters, prev_annotates)
    a = gca; % get the current axis;
    a.Position(3) = 0.65;
    a.Position(1) = 0.05;
    
    delete(prev_annotates);
    % put the textbox at 75% of the width and 
    % 10% of the height of the figure
    
    parameter_list = p2_organise_parameters(parameters);
    
    position = [0.75, 0.1, 0.1, 0.1];
    k = fieldnames(parameter_list);
    for ii = 1:length(k)
        k_ii = string(k(ii));
        print_kii = replace(k_ii, "_", " ");
        annotates(ii) = annotation('textbox', position, 'String',...
            sprintf("%s = %s", print_kii, string(parameter_list.(k_ii))));
        position(2) = position(2) + 0.05;
    end
end