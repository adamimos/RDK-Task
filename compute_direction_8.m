        %% compute_direction
        % this function calculates the the direction, in degrees, of the
        % dots for each trials based on the previously computed correct
        % sides
        function direction = compute_direction_8(correct_side)
            direction = correct_side;
            for i = 1:length(direction)
                if direction(i) == 1
                    direction(i) = randsample([90 135 45 0],1,1);
                elseif direction(i) == 3
                    direction(i) = randsample([315 225 270 180],1,1);
                end
                
            end

        end
     