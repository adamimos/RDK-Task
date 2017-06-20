prior = objs{num_files}.obj.prob_params.close_priors;

%direction = objs{num_files}.obj.dots.direction;

coherence = objs{num_files}.obj.prob_params.coherence;
correct = objs{num_files}.obj.response.stim_response.response_side;

prior = prior(1:length(correct));
coherence = coherence(1:length(correct));

n_trials = length(correct);

p30 = (coherence == .5);

corr_side =  objs{num_files}.obj.behavior_params.correct_side;
corr_side = corr_side(1:n_trials);

resp_side = objs{num_files}.obj.response.stim_response.response_side;
resp_side = resp_side(1:n_trials);

prior = prior(p30);
coherence = coherence(p30);
corr_side = corr_side(p30);

%plot side bias over time 

close_acc_vec = [];
far_acc_vec = [];
bias_vec = [];
coher_vec = [];

j = 1;
for i = 6:1:(length(prior) - 5)
    bias_vec(j) = prior(i);
    coher_vec(j) = coherence(i);
    
    trial_mask = zeros(1, length(prior) );
    trial_mask(i-5:i+5) = 1;
    
    temp_corr_side = trial_mask.*corr_side;
    
    one_corr = (temp_corr_side == 1);
    
    three_corr = (temp_corr_side == 3);

    
    resp_given_close = resp_side(one_corr);
    resp_given_far = resp_side(three_corr);

   
    close_acc = sum(resp_given_close == 1) / length(resp_given_close);
    far_acc = sum(resp_given_far == 3) / length(resp_given_far);

    close_acc_vec(j) = close_acc;
    far_acc_vec(j) = far_acc;
    
    j = j + 1;
end


figure(2);
plot(close_acc_vec, 'b');

hold on;
plot(far_acc_vec, 'r');

plot(bias_vec, 'k');

scatter(1:length(coher_vec), coher_vec, 'm');

legend('close accuracy', 'far accuracy', 'prior', 'coherence')
