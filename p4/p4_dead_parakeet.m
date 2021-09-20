classdef p4_dead_parakeet < handle
    
    properties
        location = struct("x", 0, "y", 0)
        days
        age
        brood
    end
    
    methods
        function self = p4_dead_parakeet(location, days, age, brood)
            %% Dead parakeets are more than just points now, they have a countdown timer
             % until they are reborn
            self.location = location;
            self.days = days;
            self.age = age;
            self.brood = brood;
        end
        function tick(self)
            %% Like the "tick" in Unreal Engine, called every time step (which is every day)
            self.days = self.days - 1; % get one day closer to undieing
            if self.days <= 0
                self.undie()
            end
        end
        function undie(self)
            %% Spawn a new parakeet of your age
            self.brood.spawn_parakeet(self.age, get_rand(["female", "male"]), self.location);
            self.brood.remove_dead_parakeet(self);
        end
    end
end
            