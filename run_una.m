%% una run code

sca
clear all
%% get latest calibration
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
load(['C:\DATA\calibration_' hostname '.mat']);
load(['C:\DATA\box_' hostname '.mat']);
fprintf('Recognized box %s.\n',hostname);
fprintf('Using calibration from %s\n',datestr(cals.date{end}));
cals = cals.cal_200{end};
test = ForcedChoice2(box.com_port,[cals{1} 150 cals{2}]);


%% PARAMETERS
rat_name = 'una';
screen_num = box.screen_num;

num_trials = 800;
coherence_difficulty = 0.01;

minCenterTime = 0.3;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.0;
min_time_vis = 1.0;%0.1; % seconds of minimum time the stimulus is visible

timeout = 2.0; % seconds of timeout for incorrect response
    
stim_response_type = 'center play trial history';%'response prior infinite';%'infinite play forgiveness';%'grow nose in center';%'grow nose in center infinite';%'infinite play forgiveness';%'sound forgiveness';%%
priors_type = 'blocks';%'blocks';% 'random'
coherence_type = 'one value';%'testing';%'training';%%'testing';%
    
close_priors_list = [0.5, .5]; % list of the priors
block_length = 100;

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length,screen_num);



Day1.run_day()

%% NOTES
