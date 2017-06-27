
        %% compute_priors
        %
        function [close_priors far_priors]= compute_priors(close_priors_list,num_trials)
            % compute the number of trials of each prior
            num_each_prior = ones(1,length(close_priors_list))*round(num_trials/length(close_priors_list));
            
            % make sure they add up to the right number of trials
            num_each_prior(end) = num_trials-sum(num_each_prior(1:end-1));
            
            % build up the priors for all trials
            close_priors = [];
            for i = 1:length(close_priors_list)
                close_priors = [close_priors close_priors_list(i)*ones(1,num_each_prior(i))];
            end 
            
            % randomly shuffle the priors
            close_priors = close_priors(randperm(num_trials));
            
            % compute far priors
            far_priors = 1 - close_priors;
        end
        