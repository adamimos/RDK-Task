        %% compute_coherences
        function coherence = compute_coherence(num_trials,coherence_type)
            switch coherence_type
                case 'one value'
                    coherence = ones(1,num_trials);
                    
                case 'training'
                    
                    coherence_vals = [1.0 0.75 0.5 0.25];
                    coherence_probs = [0.3 0.3 0.25 .15];
                    coherence_nums = round(coherence_probs.*num_trials);
                    coherence_nums(end) = num_trials-sum(coherence_nums(1:end-1));
                    
                    coherence = [];
                    for i = 1:length(coherence_vals)
                        coherence = [coherence coherence_vals(i)*ones(1,coherence_nums(i))];
                    end
                    
                    % randomly permute
                    coherence = coherence(randperm(num_trials));                                       
                case 'testing'
                    coherence_vals = [0.7 0.45 0.25 .1];
                    coherence_probs = [0.3 0.3 0.25 .15];
                    coherence_nums = round(coherence_probs.*num_trials);
                    coherence_nums(end) = num_trials-sum(coherence_nums(1:end-1));
                    
                    coherence = [];
                    for i = 1:length(coherence_vals)
                        coherence = [coherence coherence_vals(i)*ones(1,coherence_nums(i))];
                    end
                    
                    % randomly permute
                    coherence = coherence(randperm(num_trials));
                    
            end
        end



% %% compute_coherences old version
%         function coherence = compute_coherence(coherence_diff,num_trials)
%             % choose coherences from an exponential distribution
%             coherence = exprnd(coherence_diff,[1,num_trials]); % increase this number to make it harder
%             
%             % take all trials with coherence > 1 and randomly distribute
%             coherence(coherence>1) = rand(1,length(coherence(coherence>1)));
%             
%             % flip the exponential distribution so that it is weighted
%             % toward coherence of 1
%             coherence = -coherence + 1;
%             
%       end