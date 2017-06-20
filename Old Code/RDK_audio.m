sca

 g1 = onlineAnalysis;
 handles = guidata(g1);
    Screen('Preference', 'SkipSyncTests', 1);


c = clock;
year = num2str(c(1));
month = num2str(c(2));
day = num2str(c(3));
if length(month)==1;month = ['0' month];end
if length(day)==1;day = ['0' day];end


if ~exist(strcat('./DATA/Adam',year,month,day), 'dir')
    mkdir(strcat('./DATA/Adam',year,month,day));
end

% Savefile Structure, initializations
params = struct('mouse', inputdlg('Enter RAT Name'));
params.session = inputdlg('Enter Session Number');
file_prepend = strcat('C:\MATLAB\RDK\DATA\Adam',year,month,day,'\',params.mouse,'s',params.session);
dumfile1 = strcat(file_prepend,'_params.mat');
dumfile2 = strcat(file_prepend,'_data.mat');
if exist(dumfile1{1}, 'file')
    % Construct a questdlg with three options
    answer = questdlg('The rat and session already exist, would you like to overwrite?', ...
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


handles.name.String = params.mouse;
handles.session.String = params.session;
guidata(g1, handles);
%dum = findobj(g1,'tag','name'); dum.String = params.mouse;
%dum = findobj(g1,'tag','session'); dum.String = params.session;

%% PARAMETERS
params.nTrials = 1500; % number of trials
params.coherenceDifficulty = 0.3; % k of the exponential distribution
params.minTimeVis = 0.1; % in seconds
params.timeout = 2.0; % in seconds
params.minPokeTime = 0.1;
params.stimTime = 0.75;
%params.timeInCenter = 0.4; % time in ms that rat has to stay in center
%(this parameter is not operable at the moment)



% set prior probablities
% params.closeBias = rand(1,params.nTrials) > 0.5; % 0 for no bias, 1 for 0.7 to far side
% params.closeBias = params.closeBias*0.25 + 0.25;
percentFlat = 0.5;
percentRand = 1-percentFlat;
numFlat = floor(percentFlat*params.nTrials);
numRand = params.nTrials - numFlat;
params.closeBias = [0.5*ones(1,numRand) 0.25*ones(1,floor(numFlat/2)) 0.75*ones(1,numRand-floor(numFlat/2))];
params.closeBias = params.closeBias(randperm(params.nTrials));

params.blocklength = 50;
params.closeBias = [0.5*ones(1,params.blocklength) 0.25*ones(1,params.blocklength) 0.75*ones(1,params.blocklength)];
params.closeBias = repmat(params.closeBias,1,50);
params.closeBias = params.closeBias(1:params.nTrials);
params.farBias = 1-params.closeBias; % set prior for far direction


% set the correct trialsides
params.trialSide = rand(1,params.nTrials)<params.closeBias; % 1 is close and 3 is far
params.trialSide = double(params.trialSide);
params.incorrectSide = abs(params.trialSide-1);
params.trialSide(params.trialSide==0)=3;
params.incorrectSide(params.trialSide==1)=3;


params.coherence = rand(1,params.nTrials);
params.coherence = ones(1,params.nTrials);
params.coherence = exprnd(params.coherenceDifficulty,[1,params.nTrials]); % increase this number to make it harder
params.coherence(params.coherence>1) = rand(1,length(params.coherence(params.coherence>1)));
params.coherence = -params.coherence + 1;
hist(params.coherence);



% dot parameters
dots.nDots = 300;                % number of dots
dots.color = [255,255,255];      % color of the dots
dots.size = 30;                   % size of dots (pixels)
dots.center = [0,0];           % center of the field of dots (x,y)
dots.apertureSize = [145.03,122.5];     % size of rectangular aperture [w,h] in degrees.
dots.speed = 60*2;       %degrees/second, we must multiply by 2 because we are halving the framerate
dots.duration = 10;    %seconds
dots.direction = rand(1,params.nTrials);  %degrees (clockwise from straight up)
dots.direction = dots.direction<params.closeBias;
dots.direction = double(dots.direction).*180+90;
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);
dots.lifetime = 10;  %lifetime of each dot (frames)

display.dist = 8.0;  %cm
display.width = 50.8/2; %cm
%display.frameRate = 30;
display.screenNum = 4;
tmp = Screen('Resolution',1);
display.resolution = [tmp.width,tmp.height];
pixpos.x = angle2pix(display,dots.x);
pixpos.y = angle2pix(display,dots.y);
display = OpenWindow(display);


% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', display.windowPtr);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(display.windowPtr);
Priority(topPriorityLevel);
% Length of time and number of frames we will use for each drawing test
numSecs = 1;
numFrames = round(numSecs / ifi);

% Numer of frames to wait when specifying good timing
waitframes = 1;


% This generates pixel positions, but they're centered at [0,0].  The last
% step for this conversion is to add in the offset for the center of the
% screen:
%

pixpos.x = pixpos.x + display.resolution(1)/2;
pixpos.y = pixpos.y + display.resolution(2)/2;
dirs = rand(params.nTrials,dots.nDots).*360;

for i = 1:params.nTrials
    dirs(i,1:floor(params.coherence(i)*dots.nDots))=dots.direction(i);
end

dx = dots.speed*sin(dirs.*pi/180)/display.frameRate;
dy = -dots.speed*cos(dirs.*pi/180)/display.frameRate;

nFrames = secs2frames(display,dots.duration);

% First we'll calculate the left, right top and bottom of the aperture (in
% degrees)
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

% New random starting positions
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

% Each dot will have a integer value 'life' which is how many frames the
% dot has been going.  The starting 'life' of each dot will be a random
% number between 0 and dots.lifetime-1 so that they don't all 'die' on the
% same frame:
dots.life =    ceil(rand(1,dots.nDots)*dots.lifetime);




%% print parameters to datafile
filename = strcat(file_prepend,'_params.mat');
save(filename{1},'params')

%% print parameters to datafile
filename = strcat(file_prepend,'_dots.mat');
save(filename{1},'dots')
%% response object
response.nCorrect = 0;
response.nWrong = 0;
response.trialStart = zeros(1,params.nTrials);
response.centerPokeTime = zeros(1,params.nTrials);
response.trialRespondTime = zeros(1,params.nTrials);
response.res = zeros(1,params.nTrials);
response.timeVis = zeros(1,params.nTrials);















sss = GetSecs;
handles.startTime.String = num2str(datestr(now,'HH:MM:SS'));%dum = findobj(g1,'tag','startTime'); dum.String = 
for trial = 1:params.nTrials
    
    fprintf('\n%s: Trial %d',datestr(now,'HH:MM:SS'),trial);
    %dum = findobj(g1,'tag','trial'); dum.String = num2str(trial);
    %dum = findobj(g1,'tag','elapsedTime'); dum.String = [num2str((GetSecs-sss)./60) ' min'];
    handles.trial.String = num2str(trial);
    handles.elapsedTime.String = [num2str((GetSecs-sss)./60) ' min'];
    guidata(g1, handles);
    drawnow;
    
    didRespond = 0;
    
    if dots.direction(trial) == 270
        %far
        corrSide = 3;
        incorrSide = 1;
    elseif dots.direction(trial) == 90
        %close
        corrSide = 1;
        incorrSide = 3;
    end
    
    
    %% POKE IN CENTER PORT
    didPokeCenter = 0;
    response.trialStart(trial) = GetSecs;
   
    
    while didPokeCenter == 0
        if test.is_licking(2)
            startLick = GetSecs;

            while test.is_licking(2) == 1
                if GetSecs - startLick > params.minPokeTime
                    response.centerPokeTime(trial) = GetSecs;
                    timeCenterPoke = GetSecs;
                    didPokeCenter = 1;
                    break;
                end
            end

        end
    end
    
    
    
                    fprintf(' initiated ');    
    
            if params.farBias(trial) == 0.75
                test.a.play_tones(5,250);
            elseif params.farBias(trial) == 0.25
                test.a.play_tones(3,250)
            end
    
  pause(0.25)  
    
    
%     while didPokeCenter == 0
%         if test.is_licking(2)
%             lickedCenterTime = GetSecs;
%             while test.is_licking(2)
%                 if GetSecs - lickedCenterTime > params.timeInCenter
%                     fprintf(' initiated ');
%                     response.centerPokeTime(trial) = GetSecs;
%                     didPokeCenter = 1;
%                     timeCenterPoke = GetSecs;
%                     break;
%                 end
%             end
%         end
%     end

    
    %% MOVE ONTO STIM
    vbl = Screen('Flip',display.windowPtr);
    a = GetSecs;
    while didRespond == 0
        %% show stim
               
        
            %if GetSecs-a < params.stimTime %test.is_licking(2)
                %convert from degrees to screen pixels
                pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
                pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
                
                Screen('DrawDots',display.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);
                

                %update the dot position
                dots.x = dots.x + dx(trial,:);
                dots.y = dots.y + dy(trial,:);
                
                %move the dots that are outside the aperture back one aperture
                %width.
                dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
                dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
                dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
                dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);
                
                %increment the 'life' of each dot
                dots.life = dots.life+1;
                
                %find the 'dead' dots
                deadDots = mod(dots.life,dots.lifetime)==0;
                
                %replace the positions of the dead dots to a random location
                dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
                dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);
                %vbl = Screen('Flip',display.windowPtr);
                vbl = Screen('Flip', display.windowPtr, vbl + (waitframes + 1.0) * ifi);
                response.timeVis(trial) = response.timeVis(trial) + 1/30;
                
%             else
%                 vbl = Screen('Flip', display.windowPtr, vbl + (waitframes + 1.0) * ifi);
%             end
                
                
                
                
                %if (GetSecs-timeCenterPoke) > 1.0
                if response.timeVis(trial)>params.minTimeVis
                    if test.is_licking(corrSide)
                        response.trialRespondTime(trial) = GetSecs;
                        didRespond = 1;
                        fprintf(' CORRECT ');
                        response.nCorrect = response.nCorrect + 1;
                        test.dose(corrSide);
                        response.res(trial) = 1;
                        getRight = 1;
                        vbl = Screen('Flip', display.windowPtr, vbl + (waitframes + 1.0) * ifi);

                    elseif test.is_licking(incorrSide)
                        response.trialRespondTime(trial) = GetSecs;
                        didRespond = 1;
                        fprintf(' WRONG   ');
                        response.nWrong = response.nWrong + 1;
                        getRight = 0;
                        rectColor = [255 255 255];
                        centeredRect = CenterRectOnPointd([0 0 10000 10000], 0, 0);
                        Screen('FillRect', display.windowPtr, rectColor, centeredRect);
                        vbl = Screen('Flip', display.windowPtr, vbl + (waitframes + 1.0) * ifi);
                        pause(params.timeout);
                        vbl = Screen('Flip', display.windowPtr, vbl + (waitframes + 1.0) * ifi);
                    end
                end
                    
              
        
    end


    
    %% RESPONDED
%    if getRight == 0;
%        while getRight == 0   
%             if test.is_licking(2) == 1
%                             %convert from degrees to screen pixels
%                             pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
%                             pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
%                             
%                             Screen('DrawDots',display.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);
%                             
%                             %update the dot position
%                             dots.x = dots.x + dx(trial,:);
%                             dots.y = dots.y + dy(trial,:);
%                             
%                             %move the dots that are outside the aperture back one aperture
%                             %width.
%                             dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
%                             dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
%                             dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
%                             dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);
%                             
%                             %increment the 'life' of each dot
%                             dots.life = dots.life+1;
%                             
%                             %find the 'dead' dots
%                             deadDots = mod(dots.life,dots.lifetime)==0;
%                             
%                             %replace the positions of the dead dots to a random location
%                             dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
%                             dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);
%                             
%                             
%                             
%                             %Screen('Flip',display.windowPtr);
%                             vbl = Screen('Flip', display.windowPtr, vbl + (waitframes + 1.0) * ifi);
%             else
%                 vbl = Screen('Flip', display.windowPtr, vbl + (waitframes + 1.0) * ifi);
%             end
%                             
%                             if test.is_licking(corrSide)==1;
%                                 getRight = 1;
%                                 %test.dose(corrSide);
%                             end
%         end
%     end
    
   %% 
    %Screen('Flip',display.windowPtr);
    
    
    % save all data
    filename = strcat(file_prepend,'_response.mat');
    save(filename{1},'response')
    
    if GetSecs - response.trialStart(trial) < 60
     fprintf('%d out of %d. Trial Time = %f seconds. %f percent correct',response.nCorrect,trial, GetSecs - response.trialStart(trial), response.nCorrect./trial);
    else
     fprintf('%d out of %d. Trial Time = %f minutes. %f percent correct',response.nCorrect,trial, (GetSecs - response.trialStart(trial))./60, response.nCorrect./trial);
    end
    

    
    
    
    
    %% PLOTS
    ttt = params.trialSide(1:trial);
    rrr = response.res(1:trial);
    
    %fprintf('percent correct close = %f\n',100*sum(rrr(trialType == 1)./length(rrr(trialType==1))));
    %fprintf('percent correct far = %f\n',100*sum(rrr(trialType == 3)./length(rrr(trialType==3))));
    
    
    responseTimes = response.trialRespondTime(1:trial) - response.centerPokeTime(1:trial);
    sRT = sort(responseTimes);
    minRT = sRT(1);
    maxRT = 4;%sRT(ceil(0.95.*length(sRT)));
    
    

    bar([100*response.nCorrect./trial 100-100*response.nCorrect./trial],'parent',handles.barCorrect);
    bar([100*sum(rrr(ttt == 1)./length(rrr(ttt==1))) 100-100*sum(rrr(ttt == 1)./length(rrr(ttt==1)))],'parent',handles.barCorrectClose);
    bar([100*sum(rrr(ttt == 3)./length(rrr(ttt==3))) 100-100*sum(rrr(ttt == 3)./length(rrr(ttt==3)))],'parent',handles.barCorrectFar);
    handles.barCorrect.Title.String = ['Overall ' num2str(100*response.nCorrect./trial) '%'];
    handles.barCorrectClose.Title.String = ['Close ' num2str(100*sum(rrr(ttt == 1)./length(rrr(ttt==1)))) '%'];
    handles.barCorrectFar.Title.String = ['Far ' num2str(100*sum(rrr(ttt == 3)./length(rrr(ttt==3)))) '%'];
    
    
try
%plot(linspace(minRT,maxRT,40),histc(responseTimes,linspace(minRT,maxRT,40)),'parent',handles.RTAll);
tVis = response.timeVis(1:trial);
mintVis = min(tVis);
maxtVis = max(tVis);
plot(linspace(mintVis,maxtVis,10),histc(tVis(rrr==0),linspace(mintVis,maxtVis,10))./sum(histc(tVis(rrr==0),linspace(mintVis,maxtVis,10))),...
     linspace(mintVis,maxtVis,10),histc(tVis(rrr==1),linspace(mintVis,maxtVis,10))./sum(histc(tVis(rrr==1),linspace(mintVis,maxtVis,10))),'parent',handles.RTAll);
%legend(handles.RTALL,'incorrect','correct');
handles.RTAll.Title.String = 'Time in Center Correct vs. Incorrect';
catch
end

try
 plot(linspace(minRT,maxRT,40),histc(responseTimes(ttt == 1),linspace(minRT,maxRT,40)),...
     linspace(minRT,maxRT,40),histc(responseTimes(ttt == 3),linspace(minRT,maxRT,40)),'parent',handles.RTCloseFar);
legend(handles.RTCloseFar,'close','far');
handles.RTCloseFar.Title.String = 'Response Times Close vs. Far';
catch
end

try
plot(linspace(minRT,maxRT,40),histc(responseTimes(rrr == 0),linspace(minRT,maxRT,40)),...
    linspace(minRT,maxRT,40),histc(responseTimes(rrr == 1),linspace(minRT,maxRT,40)),'parent',handles.RTCorrIncorr);
legend(handles.RTCorrIncorr,'incorrect','correct');
handles.RTCorrIncorr.Title.String = 'Response Times Correct vs. Incorrect';
catch
end
    
    
    
    
    
    
    
    
    
    guidata(g1, handles);
    drawnow;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end



sca
 %cleanupObj = onCleanup(@cleanMeUp);
 
 
 
