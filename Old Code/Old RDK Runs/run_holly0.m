%% emmy0 run code

sca
clear all
test = ForcedChoice2('COM10');

%% PARAMETERS
rat_name = 'holly0';
num_trials = 800;
coherence_difficulty = 0.01;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.15;
min_time_vis = 0.1;%0.1; % seconds of minimum time the stimulus is visible

timeout = 0.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center infinite';%'infinite play forgiveness';
priors_type = 'blocks';
coherence_type = 'testing';

close_priors_list = [0.75]; % list of the priors

dots_size = 60;
dots_nDots = 150;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type);



Day1.run_day()

%% NOTES

% 2017-03-27: did a close_prior of 75%, since there is an extreme bias
% towards the far side.
