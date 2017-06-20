%% emmy0 run code - straight up RDK, imaging GRINS in FOF and PPC

sca
clear all
test = ForcedChoice2('COM10');

%% PARAMETER11S
rat_name = 'emmy0';
num_trials = 2500;
coherence_difficulty = 0.15;

minCenterTime = 0.0;%0.0; % minimum time in center before a response is allowed
time_between_aud_vis = 0.3;
min_time_vis = 0.5;%0.1; % seconds of minimum time the stimulus is visible
block_length = 50;
timeout = 4; % seconds of timeout for incorrect response

stim_response_type = 'grow nose in center infinite';
priors_type = 'blocks';
coherence_type = 'testing';

close_priors_list = [.25, 0.5, .75]; % list of the priors

dots_size = 30;
dots_nDots = 300;

%% SETUP AND RUN
Day1 = task(test,num_trials,coherence_difficulty,minCenterTime,time_between_aud_vis,min_time_vis,timeout,...
    stim_response_type, close_priors_list,rat_name,priors_type,dots_size,dots_nDots,coherence_type,block_length);

Day1.run_day()

%% NOTES

% 2017-4-1: Starting back on all priors after (we think) we've fixed her bias

%2017-4-2: t_b_av = .35, m_t_v = .35, coherence = [.8, .5, .2], distrib =
%[.5, .4, 1]

%2017-4-6: decrease block length to 40

%2017-4-7: increased both times to .45, coherence = [.8, .6, .25], distrib
%= [.6, .3. .1]

%2017-4-14: changed block length to 40

%2017-4-16: increased time, now at .5, .55

%2017-4-19: harder coherences

%adam I have time between aud and vis and min time vis uneven on purpose,
%doesn't seem like more than a half a second on the visual stimulus is
%really necessary before we move to the other task version, but I think we
%still want probably a second between the prior and visual stimulus?

%took out sounds

%taking out other prior values than 50%

%added back other priors, added back blocks!