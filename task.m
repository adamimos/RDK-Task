classdef task
    % description of task
    % Adam Shai
    % March 2017
    
    properties
        curr_trial % iterator for current trial
        completed_trials
        num_trials % number of trials
        dots % holds all dot parameters
        response % holds all response parameters
        prob_params % probabalistic parameters
        behavior_params % behavior parameters
        RDK_arduino % arduino object
        display % display parameters
        file_params % filename parameters
        block_num
        is_trial_completed
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
            
            file_params.file_prepend = strcat('C:\DATA\',year,month,day,'\',file_params.mouse,'_session',{'1'});
            dumfile1 = strcat(file_params.file_prepend,'.mat');
            
            
            if ~exist(dumfile1{1}, 'file')
                file_params.session = {'1'};
            else
                file_params.session = inputdlg('Enter Session Number');
            end
            
            
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
            file_params.sound{1} = audioread('sound1.wav');
            file_params.sound{2} = audioread('sound2.wav');
            file_params.sound{3} = audioread('sound3.wav');
            file_params.sound{4} = audioread('sound4.wav');
            %             file_params.sound{1} = audioread('tone1.wav');
            %             file_params.sound{2} = audioread('warble.wav');
            %             file_params.sound{3} = audioread('white.wav');
            %             file_params.sound{4} = audioread('tone3.wav');
            
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
            prob_params.close_priors_vector = [];
            prob_params.far_priors_vector = [];
            
            % prior parameters
            prob_params.close_priors_list = close_priors_list;%[0.25 0.5 0.75]; % list of the priors
            prob_params.priors_type = priors_type;
            
            %% CHANGE TO NEW TYPES
            if strcmpi(stim_response_type, 'response prior infinite') || strcmpi(stim_response_type, 'response prior')
                [prob_params.close_priors, prob_params.far_priors] =...
                    compute_priors([0.5 0.5],num_trials);
                %% COMPUTE PRIORS FOR REWARDS HERE
                [prob_params.close_response_priors, prob_params.far_response_priors] =...
                    compute_priors(prob_params.close_priors_list,num_trials);
                
                if strcmpi(prob_params.priors_type, 'blocks')
                    [prob_params.close_response_priors, prob_params.far_response_priors] =...
                        compute_priors_blocks(prob_params.close_priors_list,num_trials,block_length);
                end
                
                
                
                
            else % DEFAULT MODE
                [prob_params.close_priors, prob_params.far_priors] =...
                    compute_priors(prob_params.close_priors_list,num_trials);
                
                
                if strcmpi(prob_params.priors_type, 'blocks')
                    [prob_params.close_priors, prob_params.far_priors] =...
                        compute_priors_blocks(prob_params.close_priors_list,num_trials,block_length);
                end
                
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
            
            %% COMPUTE LARGE REWARD SIDES
            if strcmpi(stim_response_type, 'response prior infinite') || strcmpi(stim_response_type, 'response prior')
                [behavior_params.large_reward_side, behavior_params.small_reward_side] =...
                    compute_trial_side(prob_params.close_response_priors, num_trials);
            end
            
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
            dots.duration = 1;    %seconds
            dots.lifetime = 10;  %lifetime of each dot (frames)
            dots.direction = compute_direction(behavior_params.correct_side); % correct direction for each trial, either 90 or 270
            [dots.dirs dots.dx dots.dy] =...
                compute_dirs(num_trials, dots.nDots, prob_params.coherence,...
                dots.direction, dots.speed, display.frameRate);
            
            %% response structure
            response.trial_start_time = [];
            response.trial_start_frame = [];
            
            % trial initiation responses
            response.trial_initiation.start_time = [];
            response.trial_initiation.start_poke_time = [];
            response.trial_initiation.end_poke_time = [];
            response.trial_initiation.end_time = [];
            
            response.trial_initiation.start_frame = [];
            response.trial_initiation.start_poke_frame = [];
            response.trial_initiation.end_poke_frame = [];
            response.trial_initiation.end_frame = [];           
            
            % stimulation and response parameters
            response.stim_response.type = stim_response_type;%'grow nose in center infinite';%'infinite play forgiveness';
            response.stim_response.stim_type = 'dots';
            %             if strcmpi(file_params.mouse,'mackay1')|strcmpi(file_params.mouse,'mackay0')|strcmpi(file_params.mouse,'adam')
            %                 response.stim_response.stim_type = 'gratings';
            %             end
            response.stim_response.time_between_aud_vis = time_between_aud_vis;
            response.stim_response.start_time = [];
            response.stim_response.end_time = [];
            response.stim_response.response_time = [];
            response.stim_response.response_side = [];
            response.stim_response.response_correct = [];
            
            response.stim_response.start_frame = [];
            response.stim_response.end_frame = [];
            
            if strcmpi(response.stim_response.type,'confidence')
                response.stim_response.response_time_end = [];
                response.stim_response.did_hold = [];
                response.stim_response.minimum_hold_times = .5 + exprnd(.7,1,num_trials);
                response.stim_response.probe_trial = zeros(1,num_trials);
                response.stim_response.probe_trial(datasample(1:num_trials,floor(0.15*num_trials),'Replace',false))=1;
            end
            
            if strcmpi(response.stim_response.type,'center play trial history finite')
                % generate a vector of priors that give you the prior as a
                % function of the block number you are in
                [prob_params.close_priors_vector prob_params.far_priors_vector] = compute_priors_blocks(close_priors_list,num_trials,1);
                obj.is_trial_completed = zeros(1,100000);
            end
            
            
            %% set all values to the object
            
            obj.curr_trial = curr_trial; % iterator for current trial
            obj.completed_trials = 0;
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
            obj.response.trial_start_frame(obj.curr_trial) = obj.RDK_arduino.a.roundTrip(4);
            
            if strcmpi(obj.response.stim_response.type,'grow nose in center')
                
                obj = obj.run_grow_nose_in_center();
                obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                
            elseif strcmpi(obj.response.stim_response.type,'grow nose in center infinite')
                
                obj = obj.run_grow_nose_in_center_infinite();
                obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                
            elseif strcmpi(obj.response.stim_response.type,'finite center')
                obj = obj.run_finite_center();
                obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                
            elseif strcmpi(obj.response.stim_response.type,'center trial history')
                obj = obj.run_center_trial_history();
                obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                
            elseif  strcmpi(obj.response.stim_response.type,'center play trial history')
                obj = obj.run_center_play_trial_history();
                obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                
            elseif  strcmpi(obj.response.stim_response.type,'center play trial history finite')
                
                % coherence for this trial
                obj.prob_params.coherence(obj.curr_trial) = compute_coherence(1,obj.prob_params.coherence_type);
                
                % compute prior if needed
                obj.block_num(obj.curr_trial) = mod(obj.completed_trials,obj.prob_params.block_length)+1;
                
                obj.prob_params.close_priors(obj.curr_trial) = obj.prob_params.close_priors_vector(obj.block_num(obj.curr_trial));
                obj.prob_params.far_priors(obj.curr_trial) = obj.prob_params.close_priors_vector(obj.block_num(obj.curr_trial));
                
                % correct_side
                % flip coin based on prior
                correct_side = double(rand<obj.prob_params.close_priors(obj.curr_trial));
                incorrect_side = abs(correct_side-1);
            
                 % change from 1==close,0==far to 1==close, 3==far
                correct_side(correct_side==0)=3;
                incorrect_side(correct_side==1)=3;
                
                % put side into object
                direction = compute_direction(correct_side);
                
            
                [dirs, dx, dy] = compute_dirs(1, obj.dots.nDots, obj.prob_params.coherence(obj.curr_trial),direction, obj.dots.speed, obj.display.frameRate);

                obj.dots.direction = direction;
                obj.dots.dirs(obj.curr_trial,:) = dirs;
                obj.dots.dx(obj.curr_trial,:) = dx;
                obj.dots.dy(obj.curr_trial,:) = dy;
                
                obj = obj.run_center_play_trial_history_finite();
                if obj.is_trial_completed(obj.curr_trial) == 1
                    obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                end
                
            elseif  strcmpi(obj.response.stim_response.type,'center play infinite trial history')
                obj = obj.run_center_play_infinite_trial_history();
                obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                %%% NEW STUFF
            elseif  strcmpi(obj.response.stim_response.type,'response prior')
                obj = obj.run_center_play_trial_history();
                obj = obj.run_reinforcement_response_prior(obj.response.stim_response.response_correct(obj.curr_trial));
                
            elseif  strcmpi(obj.response.stim_response.type,'response prior infinite')
                obj = obj.run_center_play_infinite_trial_history();
                obj = obj.run_reinforcement_response_prior(obj.response.stim_response.response_correct(obj.curr_trial));
                %%% NEW STUFF
                
            elseif strcmpi(obj.response.stim_response.type,'confidence')
                obj = obj.run_confidence();
            else
                
                % Initiation
                obj = obj.run_initiation();
                
                % Stimulus/Response
                obj = obj.run_stimulus_response();
                
                % Reinforcement
                obj = obj.run_reinforcement(obj.response.stim_response.response_correct(obj.curr_trial));
                
            end
            
            
            % Output current status
            fprintf('%d out of %d = %d percent \n',sum(obj.response.stim_response.response_correct),obj.curr_trial,round(sum(obj.response.stim_response.response_correct)/obj.curr_trial*100))
            
            % Advance current trial
            obj = obj.advance_trial();
            
            
            
        end
        
        %% advance_trial
        % call this function to advance the current trial pointer by 1
        function obj = advance_trial(obj)
            obj.curr_trial = obj.curr_trial + 1;
        end
        
        
        
        
        
        
        
        
        function obj = run_center_play_infinite_trial_history(obj)
            %% run center play infinite trial history
            
            
            
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
                                % play beep
                                
                            end
                            
                        else % trial was already initiated
                            
                            % if longer than initiation+sound to vis wait
                            %if GetSecs - start_poke_times(end) >...
                            %        obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis
                            
                            % play stim
                            [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                            
                            if GetSecs - start_poke_times(end) > ...
                                    obj.behavior_params.minCenterTime + obj.behavior_params.min_time_vis
                                trial_finished = 1;
                                fprintf('nose was held ');
                                
                                % PLAY SOUND
                                s = [obj.file_params.sound{1} obj.file_params.sound{1}];
                                PsychPortAudio('FillBuffer', obj.file_params.pahandle, s');
                                PsychPortAudio('Start', obj.file_params.pahandle);
                                
                                while obj.RDK_arduino.is_licking(2) == 1
                                    
                                    [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                    
                                end
                                
                                % flip screen to black after trial is
                                % finished and rat leaves nosepoke
                                obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                
                                break;
                            end
                            
                            %end
                            
                        end % trial inititated if
                    end
                    % if the rat starts a nosepoke but doesnt hold long
                    % enough record the time the rat leaves
                    end_poke_times = [end_poke_times GetSecs];
                    
                    
                    %timeout if timein > 0.1
                    if trial_finished == 0 && GetSecs - start_poke_times(end) > 0.1
                        if obj.behavior_params.timeout > 0
                            % draw white screen
                            Screen('FillRect', obj.display.windowPtr, [255 255 255], CenterRectOnPointd([0 0 10000 10000], 0, 0));
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                            pause(obj.behavior_params.timeout);
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                        end
                    end
                    
                    trial_initiated = 0;
                    %obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                    %fprintf('left nosepoke ');
                    
                    
                end
                
            end % end big while loop for nosepoke
            
            
            % get response
            did_respond = 0;
            while did_respond == 0
                
                
                
                
                
                [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
                [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                % obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                
                
            end
            
            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
            
            % move nose poke timings to response object
            obj.response.trial_initiation.start_poke_time{obj.curr_trial} = start_poke_times;
            obj.response.trial_initiation.end_poke_time{obj.curr_trial} = end_poke_times;
            
            
        end
        
        
        
        
        
        
        
        
        
         function obj = run_center_play_trial_history_finite(obj)
            %% run center play trial history
 
            % initialize the x and y position and life of the dots
            [obj.dots] = initialize_dots(obj.dots);
            
            % first the initiation phase
            obj.response.trial_initiation.start_time(obj.curr_trial) = GetSecs;
            obj.response.trial_initiation.start_frame(obj.curr_trial) =  obj.RDK_arduino.a.roundTrip(4);
           
            
            % arrays to hold poke times, to be put into the object later
            start_poke_times = []; end_poke_times = [];
            start_poke_frames = []; end_poke_frames = [];
            
            trial_initiated = 0;
            trial_finished = 0;
            
            % the while loop runs until they have stayed in the nosepoke
            % for initiation, sound, and vis stimulus
            while trial_finished == 0
                
                % if the rat center nose pokes
                if obj.RDK_arduino.is_licking(2)
                    
                    % record time of poke
                    start_poke_times = [start_poke_times GetSecs];
                    start_poke_frames = [start_poke_frames obj.RDK_arduino.a.roundTrip(4)];
                    
                    % while the rat continues to hold in center
                    while obj.RDK_arduino.is_licking(2) == 1
                        
                        if trial_initiated == 0
                            
                            % check minimum time, and if met, the trial is
                            % initiated and we move onto the next part
                            if GetSecs - start_poke_times(end) > obj.behavior_params.minCenterTime
                                obj.response.trial_initiation.end_time(obj.curr_trial) = GetSecs;
                                obj.response.stim_response.start_time(obj.curr_trial) = GetSecs;
                                
                                obj.response.trial_initiation.end_frame(obj.curr_trial) = obj.RDK_arduino.a.roundTrip(4);
                                obj.response.stim_response.start_frame(obj.curr_trial) = obj.RDK_arduino.a.roundTrip(4);
                                
                                trial_initiated = 1;
                                % trial is initiated
                                %fprintf('initiated ');
                                % play beep
                                
                            end
                            
                        else % trial was already initiated
                            
                            % if longer than initiation+sound to vis wait
                            %if GetSecs - start_poke_times(end) >...
                            %        obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis
                            
                            % play stim
                            [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                            
                            if GetSecs - start_poke_times(end) > ...
                                    obj.behavior_params.minCenterTime + obj.behavior_params.min_time_vis
                                trial_finished = 1;
                                fprintf('nose was held ');
                                
                                % PLAY SOUND
                                s = [obj.file_params.sound{1} obj.file_params.sound{1}];
                                PsychPortAudio('FillBuffer', obj.file_params.pahandle, s');
                                PsychPortAudio('Start', obj.file_params.pahandle);
                                
                                while obj.RDK_arduino.is_licking(2) == 1
                                    
                                    % change screen to black
                                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);

                                end
                                
                                % flip screen to black after trial is
                                % finished and rat leaves nosepoke
                                obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                
                                break;
                            end
                            
                            %end
                            
                        end % trial inititated if
                    end
                    % if the rat starts a nosepoke but doesnt hold long
                    % enough record the time the rat leaves
                    end_poke_times = [end_poke_times GetSecs];
                    end_poke_frames = [end_poke_frames obj.RDK_arduino.a.roundTrip(4)];
                    trial_initiated = 0;
                    
                    % timeout if theyve taken their nose out too early
                    if trial_finished == 0 && GetSecs - start_poke_times(end) > 0.1
                        if obj.behavior_params.timeout > 0
                            % draw white screen
                            Screen('FillRect', obj.display.windowPtr, [255 255 255], CenterRectOnPointd([0 0 10000 10000], 0, 0));
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                            pause(obj.behavior_params.timeout);
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                        end
                    end
                    
                    
                    
                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                    fprintf('left nosepoke ');
                    break;
                    % TO DOOOOOOOOOOOOOO
                    % ADD BREAK HERE TO RESTART TRIAL WITH NEW PARAMS
                    % CHOSEN FROM THE CORRECT PARAMETERS
                end
                
            end % end big while loop for nosepoke
            
            
            % get response
            if trial_finished == 1
                obj.is_trial_completed(obj.curr_trial) = 1;
                did_respond = 0;
                while did_respond == 0
                    [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
                end
                obj.response.stim_response.response_frame(obj.curr_trial) = obj.RDK_arduino.a.roundTrip(4);
                obj.completed_trials = obj.completed_trials + 1;
            end
            
            % move nose poke timings to response object
            obj.response.trial_initiation.start_poke_time{obj.curr_trial} = start_poke_times;
            obj.response.trial_initiation.end_poke_time{obj.curr_trial} = end_poke_times;
            
            obj.response.trial_initiation.start_poke_frame{obj.curr_trial} = start_poke_frames;
            obj.response.trial_initiation.end_poke_frame{obj.curr_trial} = end_poke_frames;
            
            
        end
        
        
        function obj = run_center_play_trial_history(obj)
            %% run center play trial history
            
            
            
            % initialize the x and y position and life of the dots
            [obj.dots] = initialize_dots(obj.dots);
            
            % first the initiation phase
            obj.response.trial_initiation.start_time(obj.curr_trial) = GetSecs;
            obj.response.trial_initiation.start_frame(obj.curr_trial) =  obj.RDK_arduino.a.roundTrip(4);
           
            
            % arrays to hold poke times, to be put into the object later
            start_poke_times = []; end_poke_times = [];
            start_poke_frames = []; end_poke_frames = [];
            
            trial_initiated = 0;
            trial_finished = 0;
            
            % the while loop runs until they have stayed in the nosepoke
            % for initiation, sound, and vis stimulus
            while trial_finished == 0
                
                % if the rat center nose pokes
                if obj.RDK_arduino.is_licking(2)
                    
                    % record time of poke
                    start_poke_times = [start_poke_times GetSecs];
                    start_poke_frames = [start_poke_frames obj.RDK_arduino.a.roundTrip(4)];
                    
                    % while the rat continues to hold in center
                    while obj.RDK_arduino.is_licking(2) == 1
                        
                        if trial_initiated == 0
                            
                            % check minimum time, and if met, the trial is
                            % initiated and we move onto the next part
                            if GetSecs - start_poke_times(end) > obj.behavior_params.minCenterTime
                                obj.response.trial_initiation.end_time(obj.curr_trial) = GetSecs;
                                obj.response.stim_response.start_time(obj.curr_trial) = GetSecs;
                                
                                obj.response.trial_initiation.end_frame(obj.curr_trial) = obj.RDK_arduino.a.roundTrip(4);
                                obj.response.stim_response.start_frame(obj.curr_trial) = obj.RDK_arduino.a.roundTrip(4);
                                
                                trial_initiated = 1;
                                % trial is initiated
                                %fprintf('initiated ');
                                % play beep
                                
                            end
                            
                        else % trial was already initiated
                            
                            % if longer than initiation+sound to vis wait
                            %if GetSecs - start_poke_times(end) >...
                            %        obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis
                            
                            % play stim
                            [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                            
                            if GetSecs - start_poke_times(end) > ...
                                    obj.behavior_params.minCenterTime + obj.behavior_params.min_time_vis
                                trial_finished = 1;
                                fprintf('nose was held ');
                                
                                % PLAY SOUND
                                s = [obj.file_params.sound{1} obj.file_params.sound{1}];
                                PsychPortAudio('FillBuffer', obj.file_params.pahandle, s');
                                PsychPortAudio('Start', obj.file_params.pahandle);
                                
                                while obj.RDK_arduino.is_licking(2) == 1
                                    
                                    [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                    
                                end
                                
                                % flip screen to black after trial is
                                % finished and rat leaves nosepoke
                                obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                
                                break;
                            end
                            
                            %end
                            
                        end % trial inititated if
                    end
                    % if the rat starts a nosepoke but doesnt hold long
                    % enough record the time the rat leaves
                    end_poke_times = [end_poke_times GetSecs];
                    end_poke_frames = [end_poke_frames obj.RDK_arduino.a.roundTrip(4)];
                    trial_initiated = 0;
                    
                    % timeout if theyve taken their nose out too early
                    if trial_finished == 0 && GetSecs - start_poke_times(end) > 0.1
                        if obj.behavior_params.timeout > 0
                            % draw white screen
                            Screen('FillRect', obj.display.windowPtr, [255 255 255], CenterRectOnPointd([0 0 10000 10000], 0, 0));
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                            pause(obj.behavior_params.timeout);
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                        end
                    end
                    
                    
                    
                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                    %fprintf('left nosepoke ');
                    
                    
                end
                
            end % end big while loop for nosepoke
            
            
            % get response
            did_respond = 0;
            while did_respond == 0
                [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
            end
            obj.response.stim_response.response_frame(obj.curr_trial) = obj.RDK_arduino.a.roundTrip(4);

            
            % move nose poke timings to response object
            obj.response.trial_initiation.start_poke_time{obj.curr_trial} = start_poke_times;
            obj.response.trial_initiation.end_poke_time{obj.curr_trial} = end_poke_times;
            
            obj.response.trial_initiation.start_poke_frame{obj.curr_trial} = start_poke_frames;
            obj.response.trial_initiation.end_poke_frame{obj.curr_trial} = end_poke_frames;
            
            
        end
        
        %% run confidence
        function obj = run_confidence(obj)
            
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
                                % play beep
                                
                            end
                            
                        else % trial was already initiated
                            
                            % if longer than initiation+sound to vis wait
                            %if GetSecs - start_poke_times(end) >...
                            %        obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis
                            
                            % play stim
                            [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                            
                            if GetSecs - start_poke_times(end) > ...
                                    obj.behavior_params.minCenterTime + obj.behavior_params.min_time_vis
                                trial_finished = 1;
                                fprintf('nose was held ');
                                
                                % PLAY SOUND
                                s = [obj.file_params.sound{1} obj.file_params.sound{1}];
                                PsychPortAudio('FillBuffer', obj.file_params.pahandle, s');
                                PsychPortAudio('Start', obj.file_params.pahandle);
                                
                                while obj.RDK_arduino.is_licking(2) == 1
                                    
                                    [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                    
                                end
                                
                                % flip screen to black after trial is
                                % finished and rat leaves nosepoke
                                obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                
                                break;
                            end
                            
                            %end
                            
                        end % trial inititated if
                    end
                    % if the rat starts a nosepoke but doesnt hold long
                    % enough record the time the rat leaves
                    end_poke_times = [end_poke_times GetSecs];
                    trial_initiated = 0;
                    
                    if trial_finished == 0 && GetSecs - start_poke_times(end) > 0.1
                        if obj.behavior_params.timeout > 0
                            % draw white screen
                            Screen('FillRect', obj.display.windowPtr, [255 255 255], CenterRectOnPointd([0 0 10000 10000], 0, 0));
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                            pause(obj.behavior_params.timeout);
                            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                        end
                    end
                    
                    
                    
                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                    %fprintf('left nosepoke ');
                    
                    
                end
                
            end % end big while loop for nosepoke
            
            
            % get response
            did_respond = 0;
            while did_respond == 0
                [obj.response, did_respond] = check_for_response_confidence(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
            end
            
            
            % move nose poke timings to response object
            obj.response.trial_initiation.start_poke_time{obj.curr_trial} = start_poke_times;
            obj.response.trial_initiation.end_poke_time{obj.curr_trial} = end_poke_times;
            
            
        end
        
        
        
        
        
        
        
        
        
        
        
        %% run center trial history
        
        function obj = run_center_trial_history(obj)
            
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
                                % play beep
                                
                            end
                            
                        else % trial was already initiated
                            
                            % if longer than initiation+sound to vis wait
                            %if GetSecs - start_poke_times(end) >...
                            %        obj.behavior_params.minCenterTime + obj.response.stim_response.time_between_aud_vis
                            
                            % play stim
                            [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                            
                            if GetSecs - start_poke_times(end) > ...
                                    obj.behavior_params.minCenterTime + obj.behavior_params.min_time_vis
                                trial_finished = 1;
                                fprintf('nose was held ');
                                
                                % PLAY SOUND
                                s = [obj.file_params.sound{1} obj.file_params.sound{1}];
                                PsychPortAudio('FillBuffer', obj.file_params.pahandle, s');
                                PsychPortAudio('Start', obj.file_params.pahandle);
                                
                                %                                     while obj.RDK_arduino.is_licking(2) == 1
                                %
                                %                                         [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                %
                                %                                     end
                                
                                % flip screen to black after trial is
                                % finished and rat leaves nosepoke
                                obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                
                                break;
                            end
                            
                            %end
                            
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
            
            
            
        end
        
        %% run finite center
        function obj = run_finite_center(obj)
            
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
                                    %                                     while obj.RDK_arduino.is_licking(2) == 1
                                    %
                                    %                                         [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                                    %
                                    %                                     end
                                    
                                    % flip screen to black after trial is
                                    % finished and rat leaves nosepoke
                                    obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
                                    
                                    break;
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
                    
                case 'sound forgiveness'
                    compute_and_play_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
                    pause(obj.response.stim_response.time_between_aud_vis);
                    response_recorded = 0;
                    while did_respond == 0
                        
                        %[obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                        [obj.response, did_respond, response_recorded] = check_for_response_infinite(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino, response_recorded);
                        
                    end
                    
                    
                    % in the infinite play case the stimulus will play until
                    % there is a response
                case 'infinite play'
                    %fprintf('hello')
                    compute_and_play_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
                    pause(obj.response.stim_response.time_between_aud_vis);
                    
                    while did_respond == 0
                        
                        [obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
                        [obj.response, did_respond] = check_for_response(obj.response,obj.behavior_params,obj.curr_trial,obj.RDK_arduino);
                    end
                    
                case 'sound'
                    %fprintf('hello')
                    compute_and_play_prior(obj.file_params,obj.prob_params.close_priors_list,obj.prob_params.close_priors(obj.curr_trial),obj.file_params.sound);
                    pause(obj.response.stim_response.time_between_aud_vis);
                    
                    while did_respond == 0
                        
                        %[obj.display, obj.dots] = compute_and_play_stim(obj.display,obj.dots,obj.curr_trial);
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
                
                if strcmpi(obj.response.stim_response.type,'infinite play forgiveness')||strcmpi(obj.response.stim_response.type,'sound forgiveness')
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
            
        end % end run reinforcment
        
        function obj = run_reinforcement_response_prior(obj,was_correct)
            
            % flip screen to blank
            obj.display.vbl = Screen('Flip', obj.display.windowPtr, obj.display.vbl + (obj.display.waitframes + 1.0) * obj.display.ifi);
            
            if was_correct == 1
                
                % give reward
                obj.RDK_arduino.dose(obj.behavior_params.correct_side(obj.curr_trial));
                
                if obj.behavior_params.large_reward_side(obj.curr_trial) == obj.behavior_params.correct_side(obj.curr_trial)
                    pause(0.5);
                    obj.RDK_arduino.dose(obj.behavior_params.correct_side(obj.curr_trial));
                end
                
            elseif was_correct == 0
                
                if strcmpi(obj.response.stim_response.type,'infinite play forgiveness')||strcmpi(obj.response.stim_response.type,'sound forgiveness')
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
            
        end % end run reinforcment
        
        
    end
    
    
end