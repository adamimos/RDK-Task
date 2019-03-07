
        %% compute_priors
        %
        function [close_priors far_priors]= compute_priors_sequence(close_priors_list,num_trials)
                close_priors = repmat(close_priors_list, 1, 9999);
                close_priors = close_priors(1:num_trials);

            
            % compute far priors
            far_priors = 1 - close_priors;
        end
        