%% ambrosia1 run code

sca
clear all
test = ForcedChoice2('COM3',[120 100 100]);


%% PARAMETERS
rat_name = 'ambrosia1';
num_trials = 800;
coherence_difficulty = 0.01;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.3;
min_time_vis = 0.1;%0.1; % seconds of minimum time the stimulus is visible

timeout = 4.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center'%'infinite play forgiveness';%
priors_type = 'blocks';
coherence_type = 'training'; %'one value';%

close_priors_list = [0.5 0.25 0.75]; % list of the priors
block_length = 50;

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length);



Day1.run_day()

%% NOTES

%2017-03-31: started on full task. this rat will be trained starting with
% priors changing trial to trial

%2017-4-07 switched to grow nose in center infinite

%2017-4-15: changed to testing coherence

%2017-04-19: increased time to .3, increased coherence difficulty

%need to add timeout

% 2017-05-11 added back prior sounds