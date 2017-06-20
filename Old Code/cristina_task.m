function mRespMat = cristina_task(choice)

%%  %----------------------------------------------------------------------
    %                       Visual Setup
    %----------------------------------------------------------------------
    % Here we call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    contrast = 1;

    % Get color codes for black white and gray
    % try different screen numbers if not working.
    %screenNumber = max(screens);
    screenNumber = 1;
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    gray=round((white+black)/2);
    if gray == white
        gray=white / 3;
    end
    inc=contrast*(white-gray);

%%  %----------------------------------------------------------------------
    %                       Window Setup
    %----------------------------------------------------------------------
    % Open an on screen window using PsychImaging
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
    %[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [],...
    %    [0 0 600 600]);
    [xCenter, yCenter] = RectCenter(windowRect);
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    % Measure the vertical refresh rate of the monitor
    ifi = Screen('GetFlipInterval', window);
    numSecs = 0.2;
    numFrames = round(numSecs/ifi);
    waitframes = 1;
    vbl = Screen('Flip', window);

    % Retreive the maximum priority number
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);



%%  %----------------------------------------------------------------------
    %                       Parameters and Data
    %----------------------------------------------------------------------
    c = clock;
    year = num2str(c(1));
    month = num2str(c(2));
    day = num2str(c(3));
    if length(month)==1;month = ['0' month];end
    if length(day)==1;day = ['0' day];end
    
    
    if ~exist(strcat('./DATA/Cristina',year,month,day), 'dir')
       mkdir(strcat('./DATA/Cristina',year,month,day));
    end

    % Savefile Structure, initializations
    params = struct('mouse', inputdlg('Enter Mouse Name'));
    params.session = inputdlg('Enter Session Number');
    file_prepend = strcat('C:\Users\Adam\Documents\MATLAB\IF-Code-master\DATA\Cristina',year,month,day,'\',params.mouse,params.session);
    dumfile1 = strcat(file_prepend,'_params.mat');
    dumfile2 = strcat(file_prepend,'_data.mat');
    if exist(dumfile1{1}, 'file')
            % Construct a questdlg with three options
        answer = questdlg('The mouse and session already exist, would you like to overwrite?', ...
        'Overwrite?', ...
        'Yes, continue','No, exit','No, exit');
        % Handle response
        switch answer
            case 'Yes, continue'
                delete(dumfile1{1}, dumfile2{1});
            case 'No, exit'
                return;
           end
    end
    
  

    % Set Paramters
    params.exp_type = 'ori'; % ori for orientation, loc for location
    params.ori_go_nogo = [0 90]; % go is the 1st element, no-go is the 2nd
    params.loc_go_nogo = [xCenter-400 xCenter+400];
    params.num_trials = 10;
    params.stim_time = 2.0; %seconds
    params.response_time = 2.0; %seconds
    params.ITI = 2.0; %seconds
    params.punish = 8.0; %seconds
    
    % sound paramaters
    SamplingFreqSound=44.1*10^3; % kHz
    WaveFreq=3400; % kHz
    Duration=0.1; % s
    TimeVector=0:1/SamplingFreqSound:Duration;
    SoundWave=sin(TimeVector*2*pi*WaveFreq);
    InitializePsychSound;
    wavedata = [SoundWave ; SoundWave];
    nrchannels = 2;
    handleSound = PsychPortAudio('Open', 4, 1, 1, SamplingFreqSound, nrchannels);
    PsychPortAudio('FillBuffer', handleSound, wavedata);
    
    if strcmp(params.exp_type,'ori')
        params.go_nogo = params.ori_go_nogo; % first element is go, second is no go 
    elseif strcmp(params.exp_type,'loc')
        params.go_nogo = params.loc_go_nogo; % first element is go, second is no go 
    else
        error('invalid experiment type')
    end  

    params.gabor_orientation = randsample(params.ori_go_nogo,params.num_trials,...
        true,[0.5 0.5]);
    %params.x_loc = ones(params.num_trials).*xCenter;
    params.x_loc =  randsample(params.loc_go_nogo,params.num_trials,...
        true,[0.5 0.5]);
    
    
    % spatial = 0.04 cpd
    % temporal = 2 Hz
    % contrast = 100
    params.gabor_dim_pix = 1400;
    params.gabor_contrast = 1.0;
    params.gabor_phase = 0;
    params.gabor_freq = 5/params.gabor_dim_pix; % cycles per pixel
    
    gaborRect = [0 0 params.gabor_dim_pix params.gabor_dim_pix];
    
    
    
    % set up gabor
    backgroundOffset = [0.5 0.5 0.5 1.0];
    backgroundOffset = [gray gray gray 1.0];
    disableNorm = 1;
    preContrastMultiplier = 0.5;
    gabortex = CreateProceduralGabor(window, params.gabor_dim_pix, params.gabor_dim_pix, [],...
        backgroundOffset, disableNorm, preContrastMultiplier);
    
    propertiesMat = [params.gabor_phase, params.gabor_freq, params.gabor_dim_pix/6, params.gabor_contrast, 1.0, 0, 0, 0];
    
    % output vectors
    data.responseTime = zeros(1,params.num_trials);
    data.hits = zeros(1,params.num_trials);
    data.correctrejs = zeros(1,params.num_trials);
    data.miss = zeros(1,params.num_trials);
    data.falsealarms = zeros(1,params.num_trials);
    data.data.did_lick(trial) = zeros(1,params.num_trials);
    data.time = cell(1,params.num_trials);
    data.rot_state = cell(1,params.num_trials);
    data.scope_frame = cell(1,params.num_trials);
    data.licks = cell(1,params.num_trials);
    

    %% print parameters to datafile
      filename = strcat(file_prepend,'_params.mat');
      save(filename{1},'params')

    %% Wait for user input to continue
    DrawFormattedText(window, 'Press Any Key to Begin', 'center','center', black );
    vbl = Screen('Flip', window);
    KbStrokeWait;

    Priority(topPriorityLevel)
      
%%  %----------------------------------------------------------------------
    %                       Run Trials
    %----------------------------------------------------------------------


    nCorrect = 0;
    for trial = 1:params.num_trials
        
        trial_type = 'NO GO';
        if strcmp(params.exp_type,'ori')
            if params.gabor_orientation(trial) == params.ori_go_nogo(1)
                trial_type = 'GO';
            end
        elseif strcmp(params.exp_type,'loc')
            if params.x_loc(trial) == params.loc_go_nogo(1)
                trial_type = 'GO';
            end
        end
        
        fprintf('\n %s trial (%d of %d) ', trial_type, trial, params.num_trials); 
        %centeredTarget = CenterRectOnPointd(targetRect,data.targetPosX(trial), yCenter);
        choice.a.set_rotary(); % reset rotary encoder to 0
        startTime = GetSecs;
        hitTimer = 0;
        v_scope_frame = [];
        v_time = [];
        v_rotState = [];
        v_licks = [];
        c = onCleanup(@() choice.sendTTL(1,0));
        
        success = 0;
        totalTrialTime = 0;
        choice.sendTTL(1,1); % start miniscope

        % STIMULATION
        
        centeredGabor = CenterRectOnPointd(gaborRect, params.x_loc(trial), yCenter);
        fprintf('--> stimulus %d degrees', params.gabor_orientation(trial)); 
        while totalTrialTime < params.stim_time
                    
            rot_state = choice.a.roundTrip(2);
            
            
            % draw stimulus
            
            
            propertiesMat(1) = 0;%dont move!!  totalTrialTime*360*2;
            
            Screen('DrawTextures', window, gabortex, [], centeredGabor, params.gabor_orientation(trial), [], [], [], [],...
                kPsychDontDoRotation, propertiesMat');
            
            
            vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);
            
            miniscope_frame = choice.a.roundTrip(4);
            totalTrialTime = GetSecs-startTime;
            v_time = [v_time totalTrialTime];
            v_rotState = [v_rotState rot_state];
            v_scope_frame = [v_scope_frame miniscope_frame];
            v_licks = [v_licks choice.is_licking(1)];
            
        end % while
        
        
        % RESPONSE WINDOW
        vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);
        fprintf('--> response '); 
        
        
        % BEEP
        PsychPortAudio('Start', handleSound, 1,0);
        
        
        data.did_lick(trial) = 0;
        punish = 0;
        


        if strcmp(params.exp_type,'ori') % orientation trial
            while(totalTrialTime - params.stim_time) < params.response_time
               rot_state = choice.a.roundTrip(2);
            
                
               if choice.is_licking(1) && data.did_lick(trial) == 0; %check if first lick
                   fprintf('LICKED')
                   data.did_lick(trial) = 1;
                   data.response_time(trial) = totalTrialTime-params.stim_time;
                   
                   
                   %CHECK IF GO OR NO GO
                   if params.gabor_orientation(trial) == params.ori_go_nogo(1) % correct trial
                       fprintf('CORRECT')
                       choice.dose(1);
                       data.hits(trial) = 1;
                   else % false alarm
                       fprintf('FALSE ALARM')
                       data.falsealarms(trial) = 1;
                       punish = 1;
                   end 
                   
               end

                miniscope_frame = choice.a.roundTrip(4);
                totalTrialTime = GetSecs-startTime;
                v_time = [v_time totalTrialTime];
                v_rotState = [v_rotState rot_state]; 
                v_scope_frame = [v_scope_frame miniscope_frame];
                v_licks = [v_licks choice.is_licking(1)];
            end
            
            if data.did_lick(trial) == 0 % didn't lick whole time
                 if params.gabor_orientation(trial) == params.ori_go_nogo(1) % miss trial
                       fprintf('MISS')
                       data.miss(trial)=1;
                 else
                       fprintf('CORRECT REJECTION')
                       data.correctrejs(trial)=1;
                 end  
            end
            

        elseif strcmp(params.exp_type,'loc') %location trial
            while(totalTrialTime - params.stim_time) < params.response_time
                rot_state = choice.a.roundTrip(2);
            
                 if choice.is_licking(1) && data.did_lick(trial) == 0; %check if first lick
                   fprintf('LICKED')
                   data.response_time(trial) = totalTrialTime-params.stim_time;
                   data.did_lick(trial) = 1;
                   
                   %CHECK IF GO OR NO GO
                   if params.gabor_orientation(trial) == params.loc_go_nogo(1) % correct trial
                       fprintf('CORRECT')
                       data.hits(trial) = 1;
                       choice.dose(1);
                   else % false alarm
                       fprintf('FALSE ALARM')
                       data.falsealarms(trial) = 1;
                       punish = 1;
                   end 
                   
               end
            
            
                miniscope_frame = choice.a.roundTrip(4);
                totalTrialTime = GetSecs-startTime;
                v_time = [v_time totalTrialTime];
                v_rotState = [v_rotState rot_state]; 
                v_scope_frame = [v_scope_frame miniscope_frame];
                v_licks = [v_licks choice.is_licking(1)];
            end
            
             if data.did_lick(trial) == 0 % didn't lick whole time
                 if params.gabor_orientation(trial) == params.loc_go_nogo(1) % miss trial
                       fprintf('MISS')
                       data.miss(trial)=1;
                 else
                       fprintf('CORRECT REJECTION')
                       data.correctrejs(trial)=1;
                 end  
             end
            
        end
        

        
        
    %% print parameters to datafile
    

        data.time{trial} = v_time;
        data.rot_state{trial} = v_rotState;
        data.scope_frame{trial} = v_scope_frame;
        data.licks{trial} = v_licks;
        filename = strcat(file_prepend,'_data.mat');
        save(filename{1},'data')

      %%

        %Screen('FillRect', window, [0.75 0.75 0.75], centeredTarget);
        vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);
        
        fprintf('--> ITI of %d seconds \n', params.ITI + punish.*params.punish);
        while(totalTrialTime - params.stim_time - params.response_time) < (params.ITI + punish.*params.punish)
               
            rot_state = choice.a.roundTrip(2);
            
            
            
            
            miniscope_frame = choice.a.roundTrip(4);
            totalTrialTime = GetSecs-startTime;
            v_time = [v_time totalTrialTime];
            v_rotState = [v_rotState rot_state]; 
            v_scope_frame = [v_scope_frame miniscope_frame];
            v_licks = [v_licks choice.is_licking(1)];
            
            
        end
        
        
        choice.sendTTL(1,0); %end miniscope
        
        fprintf('H = %d, M = %d, CR = %d, FA = %d\n',sum(data.hits),sum(data.miss),sum(data.correctrejs),sum(data.falsealarms)); 
        pause(.1)

    end


    sca;