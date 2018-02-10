function [response, did_respond] = check_for_response(response,behavior_params,curr_trial,RDK_arduino)
    
    did_respond = 0;
    
    % check if stimulus on for minimum time
    if GetSecs - response.stim_response.start_time(curr_trial) > behavior_params.min_time_vis

        % check if rat has responded on the correct side
        if RDK_arduino.is_licking(behavior_params.correct_side(curr_trial))

            % record response
            response.stim_response.response_time(curr_trial) = GetSecs;
            %response.stim_response.response_frame(curr_trial) = RDK_arduino.a.roundTrip(4);
            
            response.stim_response.response_side(curr_trial) = behavior_params.correct_side(curr_trial);
            response.stim_response.response_correct(curr_trial) = 1;
            did_respond = 1;
            fprintf(' CORRECT ');

            % check if rat has responded on the incorrect side
        elseif RDK_arduino.is_licking(behavior_params.incorrect_side(curr_trial))

            % record response
            response.stim_response.response_time(curr_trial) = GetSecs;
            %response.stim_response.response_frame(curr_trial) = RDK_arduino.a.roundTrip(4);
            response.stim_response.response_side(curr_trial) = behavior_params.incorrect_side(curr_trial);
            response.stim_response.response_correct(curr_trial) = 0;
            did_respond = 1;
            fprintf(' INCORRECT ');
        end

    end
end
