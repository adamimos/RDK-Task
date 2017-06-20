        %% compute_trial_side
        function [correct_side incorrect_side] = compute_trial_side(close_priors, num_trials)
            % use priors to randomly select trial sides, here 1 is close
            % and 0 is far
            correct_side = double(rand(1,num_trials)<close_priors);
            
            % calculate the incorrect side
            incorrect_side = abs(correct_side-1);
            
            % change from 1==close,0==far to 1==close, 3==far
            correct_side(correct_side==0)=3;
            incorrect_side(correct_side==1)=3;
        end
        