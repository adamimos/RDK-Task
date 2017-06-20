
        %% compute_priors
        %
        function [close_priors far_priors]= compute_priors_blocks(close_priors_list,num_trials,block_length)
        
        
        
            % compute the number of trials of each prior
            num_each_prior = round(close_priors_list * num_trials);
            
            % make sure they add up to the right number of trials
            num_each_prior(end) = num_trials-sum(num_each_prior(1:end-1));
            
            close_priors = [];
            for i = 1:length(close_priors_list)
                 close_priors = [close_priors close_priors_list(i)*ones(1,block_length)];
            end 
            
            close_priors = repmat(close_priors,1,10000);
            close_priors = close_priors(1:num_trials);
            
            
            
            
%             % build up the priors for all trials
%             close_priors = [];
%             for i = 1:length(close_priors_list)
%                 close_priors = [close_priors close_priors_list(i)*ones(1,num_each_prior(i))];
%             end 
%             
%             % randomly shuffle the priors
%             close_priors = close_priors(randperm(num_trials));
            
            % compute far priors
            far_priors = 1 - close_priors;
        end
        