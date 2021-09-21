# 4 - Whats with all the parakeets?

This repository is dedicated to the ["What's with all the parakeets?" Two Week Project on YouTube](https://www.youtube.com/watch?v=VHRAZUo0-i8) completed in January 2021.

This MatLab simulation aims to answer perhaps the most pressing question in modern Britain: How did the rose-ringed parakeet populate so prolifically over the late 20th and early 21st century?

## What is this?

Great question... I don't really know what to tell you. The entire project is open source (under GPL3.0 license) so you can download the source code, modifiy it, hack it, break it, steal it, I don't care. If, god forbid, you find a use for it, all I ask is that you attribute me (under GPL 3.0 license conditions).

Please note that you will of course need MatLab installed to run these scripts.

This MatLab simulation is broken down in to 4 stages:

### Stage 1 (p1)

Here we use statistical modelling to forecast and hindcast the parakeet population looking only at the population as a whole and extrapolating outwards. 

Each of the files are scripts that can be run independently.

### Stage 2 (p2)

This is the bulk of the forecasting simulation code whereby we are trying to predict the viability of specific conditions to enable a self-sustaining population. You can design your own theory based on placement and number of parakeets and run onwards from there.
The `p2_1_monte_carlo.m` holds the primary script to run everything, and you can modify various parameters of the parakeets themselves (like how long they can survive without food, their average life expectancy, etc.) within here. ***It is not a Monte Carlo simulation, but I couldn't be bothered to change the name once I realised I couldn't make an MC looping sim.**

### Stage 3 (p3)

Here we take things a bit further. We leverage a lot of the same functions, classes, and code generally from `p2` but we now introduce predators, competition, and mutable resources. The `p3_1_run_sim.m` script is what calls the entire simulation to run, and much like in `p2_1_...` it is within here that you can change the key simulation parameters.

### Stage 4 (p4)

Here is a complete re-write of p1 and p2, whereby rather than ticking forward each day we intead tick backwards each day. This also reverses the entropy and energy-transfer of any interactions, and so should be taken with a pinch of salt.

### ext_data

Use the functions within `ext_data` to create your own maps and environments, either entirely from hand (which is slow and ardious) or using some clever boundary-detection functions and some contrast-enhancements in Photoshop/Gimp.

Note that the more parks and food sources you have, the slower the simulations will take to run.
Likewise the more parakeets you have, the simulations will take O(n<sup>2</sup>) more time to run.
