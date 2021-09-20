function X_out = map_vars(X_in, range_in, range_out, force_integers)
    
    if nargin < 4
        force_integers = false;
    end
    x_in_min = range_in(1);
    x_in_max = range_in(2);
    x_out_min = range_out(1);
    x_out_max = range_out(2);
    
    X_out = (X_in-x_in_min)*(x_out_max-x_out_min)/(x_in_max-x_in_min) + x_out_min;
    if force_integers == true
        X_out = round(X_out);
    end
end