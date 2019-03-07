
response_params = objs{num_files}.obj.response;


lll = length(response_params.stim_response.did_hold);
wc = objs{num_files}.obj.is_trial_completed(1:lll);


held = response_params.stim_response.did_hold;
held = held(wc == 1);

correct = response_params.stim_response.response_correct;
correct = correct(wc == 1);

response_time = response_params.stim_response.response_time_end - response_params.stim_response.response_time;
response_time = response_time(wc == 1);

probe = response_params.stim_response.probe_trial(1:lll);
probe = probe(wc == 1);





probe = (probe | ~held);

no_reward_trials = probe | ~correct;
incorrect_trials = ~correct;
incorrect_responses = response_time(incorrect_trials);


no_reward_responses = response_time(no_reward_trials);
no_reward_accuracy = correct(no_reward_trials);

figure(3)

subplot(221);
hist(no_reward_responses, 0:.5:10, 'facecolor', 'y', 'facealpha', .5, 'edgecolor', 'none');
title('hold time, all unrewarded trials')

subplot(222);
scatter(abs(coherence(incorrect_trials)),response_time(incorrect_trials))
title('incorrect trials')

subplot(223);

coh_prob = [];
resp_prob = [];

for i = 1:num_files
    response_params = objs{i}.obj.response;
    correct = response_params.stim_response.response_correct;
    n_trials = length(correct);
    
    coh = objs{i}.obj.prob_params.coherence;
    response_time = response_params.stim_response.response_time_end - response_params.stim_response.response_time;
    
    probe = response_params.stim_response.probe_trial; 
    probe = probe(1:n_trials);
    
    c_prob = abs(coh(correct & probe));
    r_prob = response_time(correct & probe);
    
    coh_prob = [coh_prob, c_prob];
    resp_prob = [resp_prob, r_prob];
end

scatter(coh_prob, resp_prob)
hold on

x = unique(coh_prob);

times = [];
time_std = [];
for c = x
    inds = find( coh_prob == c);
    val = mean(resp_prob(inds));
    stds = std(resp_prob(inds)) / sqrt(length(resp_prob(inds)));
    times = [times, val];
    time_std = [time_std, stds];
end

errorbar(x, times, time_std, '--k')
title('only correct unrewarded probe trials')



subplot(224)
%no_reward_responses
%no_reward_accuracy

temp_x = uint8(no_reward_responses);
x = [];
y = [];
err = [];
for i = unique(temp_x)
    inds = find(temp_x == i);
    x = [x, i];
    y = [y,  mean(no_reward_accuracy(inds))];  
    err = [err, std(no_reward_accuracy(inds))];
end

errorbar(x, y, err)
title('accuracy vs. wait time')