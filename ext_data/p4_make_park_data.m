%% Generate the plot
figure(2)
I = imread("ext_data/gimping/london_small_scale_nice_docks.png");
BW = im2bw(I);
imshow(BW)
boundaries = bwboundaries(BW);
hold on

%% Generate the parks
park_boundaries = {};
boundaries(2) = [];
ignore_these_ones = [];
for k=1:length(boundaries)
   b = boundaries{k};
   mod_b = b;
   if length(mod_b) >= 50
       mod_b = DouglasPeucker(mod_b, 0.9);
%        fprintf("Reduced %i to %i\n", length(z), length(mod_b));
   end
   switcher = mod_b(:,2);
   mod_b(:, 2) = mod_b(:, 1);
   mod_b(:, 1) = switcher;
    %% Remove the big empty space (it's not a park!)
    add_me = true;
    for j = 1:length(mod_b)
        if mod_b(j, :) == [1, 1]
            fprintf("%i is not a park!\n", j);
            add_me = false;
            ignore_these_ones = [ignore_these_ones, k];
            break
        end
        if (length(mod_b) < 3) || all(mod_b(:, 1)==mod_b(1, 1)) || all(mod_b(:, 2)==mod_b(1, 2))
            add_me = false;
            ignore_these_ones = [ignore_these_ones, k];
            break
        end
    end
    if add_me
       park_boundaries(k) = {mod_b};
       plot(mod_b(:,1),mod_b(:,2),'g','LineWidth',3);
    end
end

if isempty(ignore_these_ones) == false
   park_boundaries(ignore_these_ones) = [];  
end
hold off
