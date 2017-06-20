%% miley0 run code

sca
clear all
test = ForcedChoice2('COM10');

%% PARAMETERS
rat_name = 'ambrosia0';
num_trials = 800;
coherence_difficulty = 0.01;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.1;
min_time_vis = 0.15;%0.1; % seconds of minimum time the stimulus is visible

timeout = 4.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center infinite'; %'infinite play forgiveness'
priors_type = 'random';%'blocks';%
coherence_type = 'testing';%'one value';%

close_priors_list = [0.25, 0.5, 0.75]; % list of the priors
block_length = 1;

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length);



Day1.run_day()

%% NOTES

% 2017-03-31: started on full task. this rat will be trained starting with
% only 50-50 prior

% 2017-04-06: switched to grow nose in center infinite 

%2017-04-07: increased time to .15, .151

%2017-04-12: switched to testing coherence

%2017-04-16: increased time to .25, .25

%2017-04-19: changed to full task, increased difficulty distribution,
%increased time to .3

%should add timeout

% 2017-04-21: added timeout

%she's fucking up make it easier

% 2017-04-25: block size = 50


% did terribly, change coherence type to one value

% 2017 04 27: vhanged back to testing coherence
