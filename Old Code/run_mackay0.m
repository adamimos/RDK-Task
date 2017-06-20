%% emmy0 run code

clear all
test = ForcedChoice2('COM10');

%% PARAMETERS
rat_name = 'mackay0';
num_trials = 800;
coherence_difficulty = 0.15;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.0;
min_time_vis = 0.15;%0.1; % seconds of minimum time the stimulus is visible

timeout = 0.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center infinite';%'infinite play forgiveness';
priors_type = 'blocks';
coherence_type = 'testing';

close_priors_list = [0.5]; % list of the priors

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,timeout,...
    stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type);

Day1.run_day()

%% NOTES

% 2017-03-27: 

