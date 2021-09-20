function correct = is_int(number)
    if mod(number, 1) == 0
        correct = true;
    else
        correct = false;
    end
end