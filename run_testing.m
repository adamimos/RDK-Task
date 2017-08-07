%% cj0 run code

sca
clear all
test = ForcedChoice2('COM3',[142 150 145]);

%% PARAMETERS
rat_name = 'testing';
screen_num = 1;

num_trials = 800;
coherence_difficulty = 0.01;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.0;
min_time_vis = 1.0;%0.1; % seconds of minimum time the stimulus is visible

timeout = 0.0; % seconds of timeout for incorrect response
    
stim_response_type = 'center play trial history';%'grow nose in center';%'grow nose in center infinite';%'infinite play forgiveness';%'sound forgiveness';%%
priors_type = 'blocks';% 'random';%'random'
coherence_type = 'training';%'one value';%'testing';%'testing';%

close_priors_list = [0.5 0.25 0.75]; % list of the priors
block_length = 100;

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length,screen_num);



Day1.run_day()

%% NOTES

% Vanilla RDK for muscimol

% 2017-06-24: started on full task. this rat will be trained starting with
% infinite play forgiveness. no audio, no history