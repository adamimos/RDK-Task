function [response, did_respond] = check_for_response_confidence(response,behavior_params,curr_trial,RDK_arduino)
    
    did_respond = 0;
    held_max = 0;
    % check if stimulus on for minimum time
    if GetSecs - response.stim_response.start_time(curr_trial) > behavior_params.min_time_vis

        while did_respond == 0
            
            %% Answer on correct side
            if  RDK_arduino.is_licking(behavior_params.correct_side(curr_trial))
                response_hold_start = GetSecs;
                did_respond = 1;
                fprintf('CORRECT- ')
                
                
                while RDK_arduino.is_licking(behavior_params.correct_side(curr_trial)) && held_max == 0
                    
                    if (GetSecs - response_hold_start) > response.stim_response.minimum_hold_times(curr_trial)
                        held_max = 1;
                        response_hold_end = GetSecs;
                        fprintf('H ')
                        fprintf(num2str(response.stim_response.minimum_hold_times(curr_trial)))
                        if response.stim_response.probe_trial(curr_trial)
                            % don't reward
                            fprintf('PROBE');
                            
                            
                            while RDK_arduino.is_licking(behavior_params.correct_side(curr_trial))
                                
                            end
                            
                            response_hold_end = GetSecs;
                            
                        else
                            %%REWARD
                            RDK_arduino.dose(behavior_params.correct_side(curr_trial));
                        end
                        break;
                    end
                end
                

               if held_max == 0
                    response_hold_end = GetSecs;
                    
                    % left correct port before reward
                end
                
                response.stim_response.response_correct(curr_trial) = 1;
                response.stim_response.response_side(curr_trial) = behavior_params.correct_side(curr_trial);
                
                
            %% Answer on incorrect side    
            elseif RDK_arduino.is_licking(behavior_params.incorrect_side(curr_trial))
                response_hold_start = GetSecs;
                did_respond = 1;
                
                fprintf('INCORRECT')
                
                while RDK_arduino.is_licking(behavior_params.incorrect_side(curr_trial))
                    % holding the response poke
                end

                response_hold_end = GetSecs;
                 
                response.stim_response.response_side(curr_trial) = behavior_params.incorrect_side(curr_trial);
                response.stim_response.response_correct(curr_trial) = 0;
                end
        end
    
            
        
        response.stim_response.response_time(curr_trial) = response_hold_start;
        response.stim_response.response_time_end(curr_trial) = response_hold_end;
        response.stim_response.did_hold(curr_trial) = held_max;
        
    end
        
    
    
        
        
        
        
        

   end

