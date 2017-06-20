%% zandra0 run code

sca
clear all
test = ForcedChoice2('COM10',[150 150 150]);

%% PARAMETERS
rat_name = 'zandra0';
num_trials = 800;
coherence_difficulty = 0.01;
minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.3;
min_time_vis = 0.1;%0.1; % seconds of minimum time the stimulus is visible

timeout = 3.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center';% 'grow nose in center infinite';%'infinite play forgiveness';
priors_type = 'blocks';%'random';%
coherence_type = 'training';%

close_priors_list = [0.25, 0.5, 0.75]; % list of the priors
block_length = 50;

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length);



Day1.run_day()

%% NOTES

% 2017-03-31: started on full task. this rat will be trained starting with
% only 50-50 prior

% 2017-04-06: changed to grow nose in center infinite

% 2017-04-07: changed coherence structure to testing, [.8, .6, .25]
% 2017-4-12: increased time to .2

%2017-4-15: changed blocks to 40

%2017-4-19: made longer time (.4), increased coherence difficulty, added
%timeout, moved to all priors

% 2017-05-11 - added back sounds for priors

% 2017-05-11 - took away infinity for grow nose in center
