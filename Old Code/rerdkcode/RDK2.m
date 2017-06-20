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
params = struct('mouse', inputdlg('Enter Mouse Name'));
params.session = inputdlg('Enter Session Number');
file_prepend = strcat('C:\Users\Adam\Documents\MATLAB\DATA\Adam',year,month,day,'\',params.mouse,'s',params.session);
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


%% PARAMETERS
params.nTrials = 500; % number of trials

% set prior probablities
params.closeBias = 0.5; % set the prior probability for the close direction
params.farBias = 1-params.closeBias; % set prior for far direction

% set the correct trialsides
params.trialSide = rand(1,params.nTrials)<params.closeBias; % 1 is close and 3 is far
params.trialSide = double(params.trialSide);
params.incorrectSide = abs(params.trialSide-1);
params.trialSide(params.trialSide==0)=3;
params.incorrectSide(params.trialSide==1)=3;

params.coherence = rand(1,params.nTrials);
params.coherence = ones(1,params.nTrials);

% dot parameters
dots.nDots = 300;                % number of dots
dots.color = [255,255,255];      % color of the dots
dots.size = 20;                   % size of dots (pixels)
dots.center = [0,0];           % center of the field of dots (x,y)
dots.apertureSize = [205,140];     % size of rectangular aperture [w,h] in degrees.
dots.speed = 60;       %degrees/second
dots.duration = 10;    %seconds
dots.direction = rand(1,params.nTrials);  %degrees (clockwise from straight up)
dots.direction = dots.direction<params.closeBias;
dots.direction = double(dots.direction).*180+90;
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);
dots.lifetime = 10;  %lifetime of each dot (frames)

display.dist = 10.2;  %cm
display.width = 50.8; %cm
display.frameRate = 30;
display.screenNum = 2;
tmp = Screen('Resolution',2);
display.resolution = [tmp.width,tmp.height];
pixpos.x = angle2pix(display,dots.x);
pixpos.y = angle2pix(display,dots.y);
display = OpenWindow(display);

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
for trial = 1:params.nTrials
    fprintf('\nTrial %d',trial);
    
    
    
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
    
    
    %% POKE IN CENTER PORt
    didPokeCenter = 0;
    response.trialStart(trial) = GetSecs;
    while didPokeCenter == 0
        
        if test.is_licking(2)
            fprintf('hit center');
            response.centerPokeTime(trial) = GetSecs;
            didPokeCenter = 1;
            timeCenterPoke = GetSecs;
            while didRespond == 0%test.is_licking(2) || (GetSecs-timeCenterPoke) < 1.5;
                %% show stim
                
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
                
                %fprintf('\nC: %d, W: %d',test.is_licking(corrSide), test.is_licking(incorrSide));
                if (GetSecs-timeCenterPoke) > 1.5
                    if test.is_licking(corrSide)
                        response.trialRespondTime(trial) = GetSecs;
                        didRespond = 1;
                        fprintf('Correct');
                        response.nCorrect = response.nCorrect + 1;
                        test.dose(corrSide);
                        response.res(trial) = 1;
                    elseif test.is_licking(incorrSide)
                        response.trialRespondTime(trial) = GetSecs;
                        didRespond = 1;
                        fprintf('WRONG');
                        response.nWrong = response.nWrong + 1;
                        getRight = 0;
                        while getRight == 0;
                            
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
                            
                            
                            
                            Screen('Flip',display.windowPtr);
                            
                            
                            
                            if test.is_licking(corrSide)==1;
                                getRight = 1;
                                %test.dose(corrSide);
                            end
                        end
                    end
                end
                % END RESPONSE
                
                Screen('Flip',display.windowPtr);

                
            end
            %fprintf('STIMOFF')
            Screen('DrawText',display.windowPtr,'STIMOFF');
            Screen('Flip',display.windowPtr);
        end
        
    end
    
    
    
    % save all data
    filename = strcat(file_prepend,'_response.mat');
    save(filename{1},'response')
    
    fprintf('%d out of %d',response.nCorrect,trial);
    
end



sca
