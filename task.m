classdef task
    % description of task
    % Adam Shai
    % March 2017
    
    properties
        curr_trial % iterator for current trial
        num_trials % number of trials
        dots % holds all dot parameters
        response % holds all response parameters
        prob_params % probabalistic parameters
        behavior_params % behavior parameters
        RDK_arduino % arduino object
        display % display parameters
        file_params % filename parameters
    end
    
    methods
        
        %% constructor
        function obj = task(RDK_arduino,num_trials,coherence_difficulty,...
                minCenterTime,time_between_aud_vis,min_time_vis,timeout,...
                stim_response_type, close_priors_list,mouse_name,priors_type,...
                dots_size,dots_nDots,coherence_type,block_length,screen_num)
            
            %% save file structure REDO THIS AND MAKE IT CLEAN
            c = clock;
            year = num2str(c(1));
            month = num2str(c(2));
            day = num2str(c(3));
            if length(month)==1;month = ['0' month];end
            if length(day)==1;day = ['0' day];end
            
            
            if ~exist(strcat('C:\DATA\',year,month,day), 'dir')
                mkdir(strcat('C:\DATA\',year,month,day));
            end
            
            % Savefile Structure, initializations
            file_params = struct('mouse', mouse_name);
            file_params.session = inputdlg('Enter Session Number');
            % CHANGE THE PREPEND OBJECT AWAY FROM RESPONSE
            file_params.file_prepend = strcat('C:\DATA\',year,month,day,'\',file_params.mouse,'_session',file_params.session);
            dumfile1 = strcat(file_params.file_prepend,'.mat');
            if exist(dumfile1{1}, 'file')
                % Construct a questdlg with three options
                answer = questdlg('The rat and session already exist, would you like to overwrite?', ...
                    'Overwrite?', ...
                    'Yes, continue','No, exit','No, exit');
                % Handle response
                switch answer
                    case 'Yes, continue'
                        delete(dumfile1{1});
                    case 'No, exit'
                        return;
                end
            end
            
            
            %% set the sounds
            file_params.sound{1} = audioread('tone1.wav');
            file_params.sound{2} = audioread('warble.wav');
            file_params.sound{3} = audioread('white.wav');
            file_params.sound{4} = audioread('tone3.wav');
            
            InitializePsychSound(1);
            file_params.pahandle = PsychPortAudio('Open', [], 1, [], 44100, 2, [], 0.025);
       
            %% display parameters and setup
            Screen('Preference', 'SkipSyncTests', 1);
            display.dist = 8.0;  % cm
            display.width = 50.8/2; % cm
            
            display.screenNum = screen_num;

            tmp = Screen('Resolution',1);
            display.resolution = [tmp.width,tmp.height];
            display = OpenWindow(display);
            
            % Measure the vertical refresh rate of the monitor
            display.ifi = Screen('GetFlipInterval', display.windowPtr);
            
            % Retreive and set the maximum priority number
            topPriorityLevel = MaxPriority(display.windowPtr);
            Priority(topPriorityLevel);
            
            % Numer of frames to wait when specifying good timing
            display.waitframes = 1;
            
            % flip screen
            display.vbl = Screen('Flip',display.windowPtr);
            
            %% meta parameters
            curr_trial = 1;
            
            
            
            %% probabalistic parameters
            % coherence parameter
            prob_params.coherence_diff = coherence_difficulty; % k of exponential distribution to determine coherence distribution
           % prob_params.coherence = compute_coherence(prob_params.coherence_diff,num_trials);
            prob_params.coherence = compute_coherence(num_trials,coherence_type);
            prob_params.coherence_type = coherence_type;
            
            % prior parameters
            prob_params.close_priors_list = close_priors_list;%[0.25 0.5 0.75]; % list of the priors
            prob_params.priors_type = priors_type;
            
            [prob_params.close_priors, prob_params.far_priors] =...
                compute_priors(prob_params.close_priors_list,num_trials);
            
            if strcmpi(prob_params.priors_type, 'blocks')
                [prob_params.close_priors, prob_params.far_priors] =...
                    compute_priors_blocks(prob_params.close_priors_list,num_trials,block_length);
            end
            
            prob_params.block_length = block_length;
            
            %% HARDCODE FOR EMMY0 OVERNIGHT
%             prob_params.close_priors = [0.75*ones(1,250) prob_params.close_priors];
%             prob_params.close_priors = prob_params.close_priors(1:num_trials);
%             prob_params.far_priors = 1 - prob_params.close_priors;
%             
            
            %% behavior parameters
            [behavior_params.correct_side, behavior_params.incorrect_side] =...
                compute_trial_side(prob_params.close_priors, num_trials);
            behavior_params.minCenterTime = minCenterTime;%0.0; % minimum time in center before a response is allowed
            behavior_params.timeout = timeout; % seconds of timeout for incorrect response
            behavior_params.min_time_vis = min_time_vis;%0.1; % seconds of minimum time the stimulus is visible
            
            %% stimulus parameters
            dots.nDots = dots_nDots;                % number of dots
            dots.color = [255,255,255];      % color of the dots
            dots.size = dots_size;                   % size of dots (pixels)
            dots.center = [0,0];           % center of the field of dots (x,y)
            dots.apertureSize = [145.03,122.5];     % size of rectangular aperture [w,h] in degrees.
            dots.speed = 60*2;       %degrees/second, we must multiply by 2 because we are halving the framerate
            dots.duration = 10;    %seconds
            dots.lifetime = 10;  %lifetime of each dot (frames)
            dots.direction = compute_direction(behavior_params.correct_side); % correct direction for each trial, either 90 or 270
            [dots.dirs dots.dx dots.dy] =...
                compute_dirs(num_trials, dots.nDots, prob_params.coherence,...
                dots.direction, dots.speed, display.frameRate);
            
            %% response structure
            response.trial_start_time = [];
            
            % trial initiation responses
            response.trial_initiation.start_time = [];
            response.trial_initiation.start_poke_time = [];
            response.trial_initiation.end_poke_time = [];
            response.trial_initiation.end_time = [];
            
            % stimulation and response parameters
            response.stim_response.type = stim_response_type;%'grow nose in center infinite';%'infinite play forgiveness';
            response.stim_response.stim_type = 'dots';
            if strcmpi(file_params.mouse,'mackay1')|strcmpi(file_params.mouse,'mackay0')|strcmpi(file_params.mouse,'adam')
                response.stim_response.stim_type = 'gratings';
            end
            response.stim_response.time_between_aud_vis = time_between_aud_vis;
            response.stim_response.start_time = [];
            response.stim_response.end_time = [];
            response.stim_response.response_time = [];
            response.stim_response.response_side = [];
            response.stim_response.response_correct = [];
            
            
            %% set all values to the object
            obj.curr_trial = curr_trial; % iterator for current trial
            obj.num_trials = num_trials; % number of trials
            obj.dots = dots; % holds all dot parameters
            obj.response = response; % holds all response parameters
            obj.prob_params = prob_params; % probabalistic parameters
            obj.behavior_params = behavior_params; % behavior parameters
            obj.RDK_arduino = RDK_arduino;
            obj.display = display;
            obj.file_params = file_params;
        end
        
        function name = objName(self)
            name = inputname(1);
        end
        
        %% run_day
        function obj = run_day(obj)
            
            for i = 1:obj.num_trials
                
                % run the trial
                obj = obj.run_trial();
                
                % save trial object
                % save all data
                filename = strcat(obj.file_params.file_prepend,'.mat');
                save(filename{1},obj.objName())
            end
            
        end
        
        %% run_trial
        function obj = run_trial(obj)
            
            compute_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
 
            fprintf('Trial %d, coher: %d, port: %d, prior: %d .',obj.curr_trial,100*obj.prob_params.coherence(obj.curr_trial),obj.behavior_params.correct_side(obj.curr_trial),obj.prob_params.close_priors(obj.curr_trial)*100);
            
            % record trial start time
            obj.response.trial_start_time(obj.curr_trial) = GetSecs;
            
            if strcmpi(obj.response.stim_response.type,'grow nose in center')
                
                obj = obj.run_grow_nose_in_center();
                
            elseif strcmpi(obj.response.stim_response.type,'grow nose in center infinite')
                
                 obj = obj.run_grow_nose_in_center_infinite();
                 
            else
                
                % Initiation
                obj = obj.run_initiation();
                
                % Stimulus/Response
                obj = obj.run_stimulus_response();
                
            end
            
            % Reinforcement
            obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
            
            % Output current status
            fprintf('%d out of %d \n',sum(obj.response.stim_response.response_correct),obj.curr_trial)
            
            % Advance current trial
            obj = obj.advance_trial();
            
            
            
        end        
        
        %% advance_trial
        % call this function to advance the current trial pointer by 1
        function obj = advance_trial(obj)
            obj.curr_trial = obj.curr_trial + 1;
        end
        
        %% run grow nose in center
        function obj = run_grow_nose_in_center(obj)
            
            % initialize the x and y position and life of the dots
            [obj.dots] = initialize_dots(obj.dots);
            
            % first the initiation phase
            obj.response.trial_initiation.start_time(obj.curr_trial) = GetSecs;
            
            % arrays to hold poke times, to be put into the object later
            start_poke_times = []; end_poke_times = [];
            
            trial_initiated = 0;
            trial_finished = 0;
            
            % the while loop runs until they have stayed in the nosepoke
            % for initiation, sound, and vis stimulus
            while trial_finished == 0
                
                % if the rat center nose pokes
                if obj.RDK_arduino.is_licking(2)
                    
                    % record time of poke
                    start_poke_times = [start_poke_times GetSecs];
                    
                    % while the rat continues to hold in center
                    while obj.RDK_arduino.is_licking(2) == 1
                        
                        if trial_initiated == 0
                            
                            % check minimum time, and if met, the trial is
                            % initiated and we move onto the next part
                            if GetSecs - start_poke_times(end) > obj.behavior_params.minCenterTime
                                obj.response.trial_initiation.end_time(obj.curr_trial) = GetSecs;
                                obj.response.stim_response.start_time(obj.curr_trial) = GetSecs;
                                trial_initiated = 1;
                                % trial is initiated
                                %fprintf('initiated ');
                                % play sound
                                compute_and_play_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
                                
                            end
                            
                        else % trial was already initiated
                            
                            % if longer than initiation+sound to vis wait
                            if GetSecs - start_poke_times(end) >...
                                    obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis
                                
                                % play stim
                                [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                
                                if GetSecs - start_poke_times(end) > ...
                                        obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis + obj.behavior_params.min_time_vis
                                    trial_finished = 1;
                                    fprintf('nose was held ');
                                    while obj.RDK_arduino.is_licking(2) == 1
                                        
                                        [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                        
                                    end
                                    
                                    % flip screen to black after trial is
                                    % finished and rat leaves nosepoke
                                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                    
                                    
                                end
                                
                            end
                            
                        end % trial inititated if
                    end
                    % if the rat starts a nosepoke but doesnt hold long
                    % enough record the time the rat leaves
                    end_poke_times = [end_poke_times GetSecs];
                    trial_initiated = 0;
                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                    %fprintf('left nosepoke ');
                    
                    
                end
                
            end % end big while loop for nosepoke
            
            
            % get response
            did_respond = 0;
            while did_respond == 0
                [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
            end
            
            
            % move nose poke timings to response object
            obj.response.trial_initiation.start_poke_time{obj.curr_trial} = start_poke_times;
            obj.response.trial_initiation.end_poke_time{obj.curr_trial} = end_poke_times;
            
            
            
        end % end function
                
        %% run grow nose in center infinite
        function obj = run_grow_nose_in_center_infinite(obj)
            
            % initialize the x and y position and life of the dots
            [obj.dots] = initialize_dots(obj.dots);
            
            % first the initiation phase
            obj.response.trial_initiation.start_time(obj.curr_trial) = GetSecs;
            
            % arrays to hold poke times, to be put into the object later
            start_poke_times = []; end_poke_times = [];
            
            iter_grating = 0;
            trial_initiated = 0;
            trial_finished = 0;
            did_respond = 0;
            
            % the while loop runs until they have stayed in the nosepoke
            % for initiation, sound, and vis stimulus
            while trial_finished == 0
                
                % if the rat center nose pokes
                if obj.RDK_arduino.is_licking(2)
                    
                    % record time of poke
                    start_poke_times = [start_poke_times GetSecs];
                    
                    % while the rat continues to hold in center
                    while obj.RDK_arduino.is_licking(2) == 1
                        
                        if trial_initiated == 0
                            
                            % check minimum time, and if met, the trial is
                            % initiated and we move onto the next part
                            if GetSecs - start_poke_times(end) > obj.behavior_params.minCenterTime
                                obj.response.trial_initiation.end_time(obj.curr_trial) = GetSecs;
                                obj.response.stim_response.start_time(obj.curr_trial) = GetSecs;
                                trial_initiated = 1;
                                % trial is initiated
                                %fprintf('initiated ');
                                % play sound
                                compute_and_play_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
                                
                            end
                            
                        else % trial was already initiated
                            
                            % if longer than initiation+sound to vis wait
                            if GetSecs - start_poke_times(end) >...
                                    obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis
                                
                                % play stim
                                if strcmpi(obj.response.stim_response.stim_type,'gratings')
                                    iter_grating = iter_grating+1;
                                    compute_and_draw_grating(obj.display,iter_grating,obj.dots.direction(obj.curr_trial),1);
                                else
                                    [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                end
                                
                                if GetSecs - start_poke_times(end) > ...
                                        obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis + obj.behavior_params.min_time_vis
                                    trial_finished = 1;
                                    %fprintf('nose was held ');
                                    while did_respond == 0
                                        
                                        if strcmpi(obj.response.stim_response.stim_type,'gratings')
                                            iter_grating = iter_grating+1;
                                            compute_and_draw_grating(obj.display,iter_grating,obj.dots.direction(obj.curr_trial),1);
                                        else
                                            [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                        end
                                        
                                        [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
                                        
                                    end
                                    
                                    % flip screen to black after trial is
                                    % finished and rat leaves nosepoke
                                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                    
                                    
                                end
                                
                            end
                            
                        end % trial inititated if
                    end
                    % if the rat starts a nosepoke but doesnt hold long
                    % enough record the time the rat leaves
                    end_poke_times = [end_poke_times GetSecs];
                    trial_initiated = 0;
                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                    %fprintf('responded ');
                    
                    
                end
                
            end % end big while loop for nosepoke
            
            
            
            
            % move nose poke timings to response object
            obj.response.trial_initiation.start_poke_time{obj.curr_trial} = start_poke_times;
            obj.response.trial_initiation.end_poke_time{obj.curr_trial} = end_poke_times;
            
            
            
        end % end function
        
        %% run_initiation
        function obj = run_initiation(obj)
            
            obj.response.trial_initiation.start_time(obj.curr_trial) = GetSecs;
            
            % arrays to hold poke times, to be put into the object later
            start_poke_times = []; end_poke_times = [];
            
            trial_initiated = 0;
            % while the rat has not initiated the trial
            while trial_initiated == 0
                
                % if the rat center nose pokes
                if obj.RDK_arduino.is_licking(2)
                    
                    % record time of poke
                    start_poke_times = [start_poke_times GetSecs];
                    
                    % if the rat continues to hold in center
                    while obj.RDK_arduino.is_licking(2) == 1
                        
                        % check minimum time, and if met, the trial is
                        % initiated and we move onto the next part
                        if GetSecs - start_poke_times(end) > obj.behavior_params.minCenterTime
                            obj.response.trial_initiation.end_time(obj.curr_trial) = GetSecs;
                            trial_initiated = 1;
                            break;
                        end
                        
                    end
                    
                    % if the rat starts a nosepoke but doesnt hold long
                    % enough record the time the rat leaves
                    end_poke_times = [end_poke_times GetSecs];
                    
                end
            end
            
            % trial is initiated
            %fprintf('initiated ');
            
            % move nose poke timings to response object
            obj.response.trial_initiation.start_poke_time{obj.curr_trial} = start_poke_times;
            obj.response.trial_initiation.end_poke_time{obj.curr_trial} = end_poke_times;
        end
        
        %% run_stimulus_response
        function obj = run_stimulus_response(obj)
            
            % initialize the x and y position and life of the dots
            [obj.dots] = initialize_dots(obj.dots);
            did_respond = 0;
            
            % record trial start time
            obj.response.stim_response.start_time(obj.curr_trial) = GetSecs;
            
            % perform actions based on the type of stimulus/response
            switch obj.response.stim_response.type
                
                case 'infinite play forgiveness'
                    compute_and_play_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
                    pause(obj.response.stim_response.time_between_aud_vis);
                    response_recorded = 0;
                    while did_respond == 0
                        
                        [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                        [obj.response, did_respond, response_recorded] = check_for_response_infinite(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino, response_recorded);
                        
                    end
                    
                    
                    % in the infinite play case the stimulus will play until
                    % there is a response
                case 'infinite play'
                    
                    compute_and_play_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
                    pause(obj.response.stim_response.time_between_aud_vis);
                    
                    while did_respond == 0
                        
                        [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                        [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
                        
                    end
                    
                case 'whilecenter'
                    
                    
                case 'fixed time'
                    
                    % play stim for fixed duration
                    while GetSecs - obj.response.stim_response.start_time(obj.curr_trial) < obj.dots.duration
                        [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                    end
                    
                    % get response
                    while did_respond == 0
                        [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
                    end
            end
            
            
        end
        
        %% run reinforcmement
        function obj = run_reinforcement(obj,was_correct)
            
            % flip screen to blank
            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
            
            if was_correct == 1
                
                % give reward
                obj.RDK_arduino.dose(obj.behavior_params.correct_side(obj.curr_trial));
                
            elseif was_correct == 0
                
                if strcmpi(obj.response.stim_response.type,'infinite play forgiveness')
                    obj.RDK_arduino.dose(obj.behavior_params.correct_side(obj.curr_trial));
                end
                
                if obj.behavior_params.timeout > 0
                    % draw white screen
                    Screen('FillRect', obj.display.windowPtr, [255 255 255], CenterRectOnPointd([0 0 10000 10000], 0, 0));
                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                    pause(obj.behavior_params.timeout);
                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                end
            end
            
        end
        
        
    end
    
    
end