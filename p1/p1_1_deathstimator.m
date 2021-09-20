global die_eval
die_eval = @(set, x) set.m*x + set.c;
global brd_eval
brd_eval = @(set, y) (y - set.c)/set.m;

sets(1).m = 0.22;
sets(1).c = -0.00761;
sets(1).t = "Wraysbury GP";

sets(2).m = 0.398;
sets(2).c = -0.131;
sets(2).t = "London 83 to 02";

sets(3).m = 0.39;
sets(3).c = -0.098323;
sets(3).t = "London 94 to 06";

sets(4).m = 0.3870;
sets(4).c = -0.1607;
sets(4).t = "London 02 to 12";

life_exp = [10, 40];
return_brd_avg(25, sets)
return_brd_avg(30, sets)

function avg = return_brd_avg(le, sets)
    fprintf("Avg. Life Exp. = %i\n", le);
    sum_set = [];
    global brd_eval
    for set = sets
        fprintf("%s\n", set.t)
        rslt = brd_eval(set, 1 / le);
        fprintf("%.3f\n", rslt);
        sum_set = [sum_set, rslt];
    end 
    avg = mean(sum_set);
end