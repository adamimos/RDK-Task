%% miley0 run code

sca
clear all
test = ForcedChoice2('COM3',[150 150 150]);

%% PARAMETERS
rat_name = 'testing';
box = 0;

num_trials = 800;
coherence_difficulty = 0.01;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.3;
min_time_vis = 0.1;%0.1; % seconds of minimum time the stimulus is visible

timeout = 4.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center';%'infinite play forgiveness';%
priors_type = 'blocks';%'random'
coherence_type = 'testing';%'one value';%

close_priors_list = [0.5 0.25 0.75]; % list of the priors
block_length = 50;

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,...
    timeout,stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length,box);



Day1.run_day()

%% NOTES

% 2017-03-31: started on full task. this rat will be trained starting with
% blocks of 50 prior

% 2017-04-07: switched to grow nose in center infinite, with 4 second
% timeout

% 2017-04-11: should move to testing coherence levels next time

% 2017-04-12: moved coherence levels to 'testing'

% 2017-04-15: changed block length to 40c

% 2017-04-16: changed coherence schedule to .45, .35, .2, times to .25

% 2017-04-19:
%                    coherence_vals = [0.8 0.6 0.25 .1];
%                    coherence_probs = [0.4 0.3 0.2, .1];
%                    time_between_aud_vis = 0.35;
%                    min_time_vis = 0.35;%0.1; % seconds of minimum time the stimulus is visible

% 2017-04-20: shifted coherene values to 0.75 0.45 0.25 0.1

% 2017-05-12: took away infinite, to grow nose in center

