function mRespMat = self_moving_bar_2(choice)

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
    
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

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
    month = sprintf('%02i', month);
    day = sprintf('%02i', day);
    
    if ~exist(strcat('./DATA/',year,month,day), 'dir')
       mkdir(strcat('./DATA/',year,month,day));
    end
    
    numTrials = 120;

    % Savefile Structure, initializations
    data = struct('mouse', inputdlg('Enter Mouse Name'));
    data.session = inputdlg('Enter Session Number');
    file_prepend = strcat('C:\Users\Adam\Documents\MATLAB\IF-Code-master\DATA\',year,month,day,'\',data.mouse,data.session);
    dumfile1 = strcat(file_prepend,'_params.txt');
    dumfile2 = strcat(file_prepend,'_data.txt');
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
    
    data.responseTime = zeros(1,numTrials);
    data.startX = zeros(1,numTrials);
    data.timeouttime = zeros(1,numTrials);
    data.targetPosX = zeros(1,numTrials);
    data.targetTime = zeros(1,numTrials);
    data.targetAlpha = rand(1,numTrials);

    % Set Paramters
    data.targetwidth = 600;
    data.ballwidth = 400;
    data.targetPosX = ones(1,numTrials).*xCenter;
    data.startX = ones(1,numTrials).*rand(1,numTrials).*screenXpixels;
    data.maxTrialTime = 60; % seconds
    data.targetTime = 1.75; %seconds
    %data.targetPosX = data.targetwidth/2 + ones(1,numTrials).*rand(1,numTrials).*(screenXpixels - data.targetwidth);
   %data.timeouttime = ones(1,numTrials).*1.0;

    %% print parameters to datafile
    filename = strcat(file_prepend,'_params.txt');
    fileID = fopen(filename{1},'a');
    fprintf(fileID,'mouseName = %s\n',data.mouse);
    fprintf(fileID,'targetTime = %f\n',data.targetTime);
    fprintf(fileID,'targetwidth = %f\n',data.targetwidth);
    fprintf(fileID,'ballwidth = %f\n',data.ballwidth);
    
    fprintf(fileID,'targetPosX = ');
    fprintf(fileID,'%f\t',data.targetPosX);
    
    fprintf(fileID,'\nstartX = ');
    fprintf(fileID,'%f\t',data.startX);
    
    fprintf(fileID,'\nmaxTrialTime = %f\n',data.maxTrialTime);
    fclose(fileID);

    %% initialization of ball and target
    ballRect = [0 0 data.ballwidth screenYpixels];
    targetRect = [0 0 data.targetwidth screenYpixels];

    % Wait for user input to continue
    DrawFormattedText(window, 'Press Any Key to Begin', 'center','center', black );
    vbl = Screen('Flip', window);
    KbStrokeWait;

    Priority(topPriorityLevel)
    
    
    
    
    %%
    
    % Make a base Rect of 200 by 200 pixels
    dim = data.targetwidth/5;
    baseRect = [0 0 dim dim];

    % Make the coordinates for our grid of squares
    [xPos, yPos] = meshgrid(-2:1:2, -6:1:6);

    % Calculate the number of squares and reshape the matrices of coordinates
    % into a vector
    [s1, s2] = size(xPos);
    numSquares = s1 * s2;
    xPos = reshape(xPos, 1, numSquares);
    yPos = reshape(yPos, 1, numSquares);

    % Scale the grid spacing to the size of our squares and centre
    xPosLeft = xPos .* dim + screenXpixels * 0.25;
    yPosLeft = yPos .* dim + yCenter;

    xPosRight = xPos .* dim;
    yPosRight = yPos .* dim + yCenter;

    % Set the colors of each of our squares
    bwColors = repmat(eye(2), 14, 14);
    bwColors = bwColors(1:s1, 1:s2);
     bwColors = reshape(bwColors, 1, numSquares);
    bwColors = repmat(bwColors, 3, 1);

    % Make our rectangle coordinates
    allRectsLeft = nan(4, 3);
    allRectsRight = nan(4, 3);
    for i = 1:numSquares
        allRectsLeft(:, i) = CenterRectOnPointd(baseRect,...
            xPosLeft(i), yPosLeft(i));
        allRectsRight(:, i) = CenterRectOnPointd(baseRect,...
            xPosRight(i), yPosRight(i));
    end


%%  %----------------------------------------------------------------------
    %                       Run Trials
    %----------------------------------------------------------------------


    nCorrect = 0;
    for trial = 1:numTrials
        
        tic;
        while toc<1.0
            while toc<0.25
                 ballX = mod(data.startX(trial),screenXpixels);
                centeredBall = CenterRectOnPointd(ballRect, ballX, yCenter);
                Screen('FillRect', window, [0 0 0 1], centeredBall);
                 vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);
            end
            while toc>0.25 && toc<0.75
                 vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);
            end
            while toc>0.75 && toc<1.0
                Screen('FillRect', window, [0 0 0 1], centeredBall);   
                 vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);
            end
        end
        
        fprintf('\n\nTrial %d of %d:\n', trial, numTrials); 
        centeredTarget = CenterRectOnPointd(targetRect,data.targetPosX(trial), yCenter);
        choice.a.set_rotary(); % reset rotary encoder to 0
        startTime = GetSecs;
        hitTimer = 0;
        onTarget = 0;
        v_ballPos = [];
        v_time = [];
        v_rotState = [];
        success = 0;
            for i = 1:numSquares
                 allRectsRight(:, i) = CenterRectOnPointd(baseRect,...
                 xPosRight(i)+data.targetPosX(trial), yPosRight(i));
            end

        
        while 1
            rot_state = choice.a.roundTrip(2);
            ballX = mod(data.startX(trial) - 3.*rot_state,screenXpixels);
            centeredBall = CenterRectOnPointd(ballRect, ballX, yCenter);
            tt = data.targetAlpha(trial).*screenXpixels;%data.targetPosX(trial);
            ballDist = min([abs(screenXpixels + ballX - tt),abs(screenXpixels + tt - ballX),abs(ballX - tt)]);
              
            %Screen('FillRect', window, [0.6 0.6 0.6], centeredTarget);
            Screen('FillRect', window, [bwColors],[allRectsRight]);
            
            if ballDist < 800
                Screen('FillRect', window, [0 0 0 heaviside(ballDist./500.0-0.25).*(ballDist./500.0-0.25)], centeredBall);
            else
                Screen('FillRect', window, [0 0 0 1], centeredBall);
            end
            %Screen('DrawingFinished', window);
            vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);

            totalTrialTime = GetSecs-startTime;
            v_ballPos = [v_ballPos ballX];
            v_time = [v_time totalTrialTime];
            v_rotState = [v_rotState rot_state];
            
            
            % if inside target
            if (ballX > data.targetPosX(trial) - data.targetwidth/2 && ballX < data.targetPosX(trial) +data.targetwidth/2)
                if onTarget == 0 % if moving in to target
                    hitStart = GetSecs;
                    onTarget = 1;
                elseif onTarget == 1 % if staying in target
                    hitTimer = GetSecs - hitStart;
                end
                
                if hitTimer > data.targetTime
                    nCorrect = nCorrect+1;
                    fprintf('\nMission Accomplished in %d seconds! %d correct. \n',totalTrialTime,nCorrect);
                    success = 1;
                    choice.dose(1);
                    break;
                end
            else % if outside target
                onTarget = 0;
                hitTimer = 0;
                hitStart = 0;
                if totalTrialTime > data.maxTrialTime
                  fprintf('\nMission Failed, max time of %d seconds reached!\n',data.maxTrialTime);
                  break; 
                end
            end

    
        WaitSecs(0.001);
        end % while

%%
        filename = strcat(file_prepend,'_data.txt');
        fileID = fopen(filename{1},'a');
        fprintf(fileID,'trial = %f\n',trial);
        fprintf(fileID,'success = %f\n',success);
    
        fprintf(fileID,'totalTrialTime = %f\n',totalTrialTime);

        fprintf(fileID,'time = ');
        fprintf(fileID,'%f\t',v_time);
    
        fprintf(fileID,'\nrotState = ');
        fprintf(fileID,'%f\t',v_rotState);
        
        fprintf(fileID,'\nballPos = ');
        fprintf(fileID,'%f\t',v_ballPos);
    
        fprintf(fileID,'\nmaxTrialTime = %f\n',data.maxTrialTime);
        fprintf(fileID,'\n\n');
        fclose(fileID);
        
        %data.responseTime(trial) = totalTrialTime;

        %Screen('FillRect', window, [0.75 0.75 0.75], centeredTarget);
        vbl = Screen('Flip',window,vbl + (waitframes - 0.5) * ifi);
        WaitSecs(3);
%         %% adaptive timeout
%         fprintf('Starting timeout of %.2f seconds. ', timing.timeout(trial));
%         %fprintf('Lick times (seconds): ');
%         tic;
%         totalATO = tic;
%         while (toc < timing.timeout(trial))
%             if (choice.is_licking(1)) % lick
%                 tic;  % reset clock
%                 %choice.dose(1); % Air puff
%                 %fprintf('%s,: ', datestr(now,'SS'));
%             end
%         end
%         totalATO = toc(totalATO);
%         fprintf('Done. It took %.2f seconds!\n\n',totalATO);
%         data.timeouttime(trial) = totalATO;

    end



%     [file,path] = uiputfile([data.mouse 'data.mat'],'Save file name');
%     save([path file], '-struct', 'data');

    sca;