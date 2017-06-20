
     
        %% compute_coherences
        function coherence = compute_coherence(coherence_diff,num_trials)
            % choose coherences from an exponential distribution
            coherence = exprnd(coherence_diff,[1,num_trials]); % increase this number to make it harder
            
            % take all trials with coherence > 1 and randomly distribute
            coherence(coherence>1) = rand(1,length(coherence(coherence>1)));
            
            % flip the exponential distribution so that it is weighted
            % toward coherence of 1
            coherence = -coherence + 1;
        end
        