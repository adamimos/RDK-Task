function [dirs, dx, dy] = compute_dirs(num_trials, nDots, coherence,direction, speed, frameRate)
            % This function computes the direction of every dot on every
            % trials
            
            % initialize every dot to move in a random direction
            dirs = rand(num_trials,nDots).*360;
            
            % iterating through every trial, set the coherent dots to move
            % in the correct direction
            for i = 1:num_trials
                dirs(i,1:floor(coherence(i)*nDots))=direction(i);
            end

            % compute the amount to displace the dot on every frame
            dx = speed*sin(dirs.*pi/180)/frameRate;
            dy = -speed*cos(dirs.*pi/180)/frameRate;

end