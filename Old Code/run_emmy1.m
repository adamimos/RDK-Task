%% emmy1 run code

sca
clear all
test = ForcedChoice2('COM10',[150 150 150]); % May 11, 2017 - moved emmy1 to box0, com10,
                                %so that she could run with ambrosia1

%% PARAMETERS
rat_name = 'emmy1';
num_trials = 2500;
coherence_difficulty = 0.1;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.3;
min_time_vis = 0.5;%0.1; % seconds of minimum time the stimulus is visible

timeout = 4.0; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center'; %'infinite play forgiveness'; ;
priors_type = 'blocks';
coherence_type = 'training';

close_priors_list = [0.5]; % list of the priors
block_length = 50;
dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,timeout,...
    stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length);

Day1.run_day()

%% NOTES

% 2017-03-27: 
%4-7-2016 back to infinite play forgiveness to correct extreme bias

% tried moving to testing, bias came back!

% 5-15-17: took away infinity
