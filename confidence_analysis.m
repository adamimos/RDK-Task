response_params = objs{end}.obj.response;
held = response_params.stim_response.did_hold;
correct = response_params.stim_response.response_correct;

n_trials = length(correct);
response_time = response_params.stim_response.response_time_end - response_params.stim_response.response_time;
probe = response_params.stim_response.probe_trial;
req_hold_times = response_params.stim_response.minimum_hold_times(1:n_trials);



probe = probe(1:n_trials);

no_reward_trials = probe | ~correct;
incorrect_trials = ~correct;
incorrect_responses = response_time(incorrect_trials);


no_reward_responses = response_time(no_reward_trials);

subplot(221);
hist(no_reward_responses, 0:.5:10, 'facecolor', 'y', 'facealpha', .5, 'edgecolor', 'none');
title('hold time, all unrewarded trials')

subplot(222);
scatter(abs(coherences(no_reward_trials)), no_reward_responses)
title('all unrewarded trials')

subplot(223);
scatter(abs(coherences(correct & probe)), response_time(correct & probe))