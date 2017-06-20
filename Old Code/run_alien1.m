%% alien1

sca
clear all
test = ForcedChoice2('COM3',[115 100 105]);

%% PARAMETERS
rat_name = 'alien1';
num_trials = 800;
coherence_difficulty = 0.01;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.1;
min_time_vis = 0.4;%0.1; % seconds of minimum time the stimulus is visible

timeout = 1.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center infinite';%'infinite play forgiveness';% 
priors_type = 'random';%'blocks';%
coherence_type = 'training';%'one value';%'testing';%

close_priors_list = [0.5]; % list of the priors
block_length = 1;

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length);



Day1.run_day()

%% NOTES

% 2017 04 27: started

% doing left right strategy, take away forgiveness

%2017-05-12: changed coherence to training