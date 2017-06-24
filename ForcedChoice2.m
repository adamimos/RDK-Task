
classdef ForcedChoice2 < handle
    properties (SetAccess=private)
        params
    end
    
    properties (Hidden=true)
        a % Arduino object
    end
    
    methods
        function choice = ForcedChoice2(comPort,dose_durs)
            % Set up parameters
            %------------------------------------------------------------
                              
            % JP1
            p.corridor(1).step = 53;  % Dir is expected to be pin "step"-2
            p.corridor(1).dose = 27; %shai changed from 49 to 0
            p.corridor(1).dose_duration = dose_durs(1);%(150; % 40 
            p.corridor(1).lick = 26; %shai changed from 47 to 1
            p.corridor(1).miniScopeTTL = 12;
            p.corridor(1).miniScopeFrame = 18;
            
            % JP3
            % Callibration by Shai on 4/19/2016. dose_duration = 50 ms 
            %   gives 130 doses per 1 mL (7.7 uL)
            p.corridor(2).step = 29;
            p.corridor(2).dose = 37;
            p.corridor(2).dose_duration = dose_durs(2);%150; % ms
            p.corridor(2).lick = 36;
            p.corridor(2).miniScopeTTL = 22; % this is a dummy variable
            p.corridor(2).miniScopeFrame = 19;
            
            % JP3
            % Callibration by Shai on 4/19/2016. dose_duration = 50 ms 
            %   gives 130 doses per 1 mL (7.7 uL)
            p.corridor(3).step = 29;
            p.corridor(3).dose = 47;
            p.corridor(3).dose_duration = dose_durs(3);%150; % ms
            p.corridor(3).lick = 46;
            p.corridor(3).miniScopeTTL = 22; % this is a dummy variable
            p.corridor(3).miniScopeFrame = 19;
            
            p.trial_out = 22;
            p.response_window = 24;
            
            p.num_corridors = length(p.corridor);
            
            choice.params = p;
            
            % Establish access to Arduino
            %------------------------------------------------------------
            choice.a = arduino(comPort);

            % Set up digital pins
            for i = 1:length(choice.params.corridor)
                corridor = choice.params.corridor(i);
                %choice.a.pinMode(corridor.step, 'output');
                %choice.a.pinMode(corridor.step-2, 'output'); % dir
                choice.a.pinMode(corridor.dose, 'output');
                %choice.a.pinMode(corridor.lick, 'input');
                choice.a.pinMode(corridor.miniScopeTTL, 'output');
                choice.a.pinMode(corridor.miniScopeFrame,'input');
            end
            
            choice.a.pinMode(choice.params.trial_out, 'output');
            choice.a.pinMode(choice.params.response_window, 'output');
            choice.a.pinMode(5,'output');
            
           
        end        
        
        function dose(choice, corridor_ind)
            c = choice.params.corridor(corridor_ind); % Selected corridor
            choice.a.send_pulse(c.dose, c.dose_duration);
        end % dose
        
        function sendTTL(choice,corridor_ind,val)
            c = choice.params.corridor(corridor_ind);
            choice.a.set_pin(c.miniScopeTTL,val);
        end
        
        
        function frame = getFrame(choice,corridor_ind)
            frame = choice.a.roundTrip(corridor_ind);
        end
        
        function lick = is_licking(choice, corridor_ind)
            %lick_pin = choice.params.corridor(corridor_ind).lick;
            val = choice.a.roundTrip(corridor_ind);
            lick = (val == 0); % HW pin goes low for lick
        end % is_licking
        
        function lick_state = get_lick_state(choice)
            lick_state = zeros(1, choice.params.num_corridors);
            for i = 1:choice.params.num_corridors
                lick_state(i) = choice.is_licking(i);
            end
        end % get_lick_state
       
        function set_trial_out(choice, val)
            choice.a.digitalWrite(choice.params.trial_out, val);
        end
        function set_response_window(choice, val)
            choice.a.digitalWrite(choice.params.response_window, val);
        end
    end
end