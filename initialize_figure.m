function obj = initialize_figure(obj)

handles = obj.handles;
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
load(['C:\DATA\calibration_' hostname '.mat']);

cellfun(@(x) x{1},cals.cal_200)
cellfun(@(x) x{2},cals.cal_200)
dates = {cat(1, cals.date{:})}; dates = dates{1};
plot(dates,cellfun(@(x) x{1},cals.cal_200),dates,cellfun(@(x) x{2},cals.cal_200),'parent',handles.calibration)


date = '2017*';
rat_name = obj.file_params.mouse;
[list, dirs] = glob(strcat('C:/DATA/', date , '/', rat_name, '*.mat'));
%[list, dirs] = glob(strcat('C:/OLD_DATA/DATA/Adam', date , '/', rat_name, '*.mat'));
objs = {};

num_files = size(list, 1);
num_files = num_files;

fprintf('%s \n', 'found the following files:')

for i = 1: num_files
    fname = list{i};
    
    fprintf('%s \n', fname);
    objs{i} = load(fname);
end

%%

%first simple plot: how has the requested rat performed over time?

learning_curve_z0 = [];
for i = 1:num_files
    corr_resp = objs{i}.obj.response.stim_response.response_correct;
    learning_curve_z0(i) = sum(corr_resp) / size(corr_resp, 2);
end

plot(1: num_files, learning_curve_z0, '.-r','parent',handles.learning_curve);
handles.learning_curve.Title.String = 'Learning Curve';
box off;

%%
%todo once there is data: split psych curve out into blocks of different
%priors
prior = objs{num_files}.obj.prob_params.close_priors;

direction = objs{num_files}.obj.dots.direction;

coherence = objs{num_files}.obj.prob_params.coherence;
correct = objs{num_files}.obj.response.stim_response.response_side;

prior = prior(1:length(correct));
coherence = coherence(1:length(correct));
direction = direction(1:length(correct));

%50-50 prior

p5 = (prior == .5);

[bins, curve, coeffs, curve_fit, threshold, weight] = make_psych_curve(coherence(p5), correct(p5), direction(p5));


scatter(bins, curve, '.r','parent',handles.prev_psych)
set(handles.prev_psych, 'NextPlot', 'add')
plot(curve_fit(:, 1), curve_fit(:, 2), '-r','parent',handles.prev_psych)
plot([threshold(2), threshold(2)], [0, 1], '--r','parent',handles.prev_psych)

try
    p75 = (prior == .75);
    [bins, curve, coeff, curve_fit, threshold] = make_psych_curve(coherence(p75), correct(p75), direction(p75));
    
    scatter(bins, curve, '.b','parent',handles.prev_psych)
    plot(curve_fit(:, 1), curve_fit(:, 2), '-b','parent',handles.prev_psych)
    plot([threshold(2), threshold(2)], [0, 1], '--b','parent',handles.prev_psych)
    
    p25 = (prior == .25);
    [bins, curve, coeff, curve_fit, threshold] = make_psych_curve(coherence(p25), correct(p25), direction(p25));
    
    scatter(bins, curve, '.g','parent',handles.prev_psych)
    plot(curve_fit(:, 1), curve_fit(:, 2),'parent', '-g',handles.prev_psych)
    plot([threshold(2), threshold(2)], [0, 1],'parent', '--g',handles.prev_psych)
    
    legend('50-50 prior', 'fit', 'bias point', 'close prior', 'fit', 'bias point', 'far prior', 'fit', 'bias point')
    
    title(strcat('todays psych curve')); ylabel('probability to chose port 1'); xlabel('coherence');
    xlim([-1 1]);ylim([0 1]);
catch
end


%%
%now make a psychophysical curve that's averaged over some days, e.g. last
%5 behavioral sessions

prior = [];
coherence = [];
correct = [];
direction = [];

if num_files > 6
    lag = 5;
else
    lag = num_files - 1;
end

for i = (num_files - lag):num_files
    dir = objs{i}.obj.dots.direction;
    coh = objs{i}.obj.prob_params.coherence;
    cor = objs{i}.obj.response.stim_response.response_side;
    pri = objs{i}.obj.prob_params.close_priors;
    
    prior = [prior pri(1:length(cor))];
    correct = [correct cor];
    coherence = [coherence coh(1:length(cor))];
    direction = [direction dir(1:length(cor))];
end

%50-50 prior

p5 = (prior == .5);

[bins, curve, coeffs, curve_fit, threshold] = make_psych_curve(coherence(p5), correct(p5), direction(p5));


%subplot(323);
scatter(bins, curve, '.r','parent',handles.av_psych)

plot(curve_fit(:, 1), curve_fit(:, 2), '-r','parent',handles.av_psych)
plot([threshold(2), threshold(2)], [0, 1], '--r','parent',handles.av_psych)
xlim([-1 1]);ylim([0 1]);
set(handles.av_psych, 'NextPlot', 'add')

try
    p75 = (prior == .75);
    [bins, curve, coeff, curve_fit, threshold] = make_psych_curve(coherence(p75), correct(p75), direction(p75));
    
    scatter(bins, curve, '.b','parent',handles.av_psych)
    plot(curve_fit(:, 1), curve_fit(:, 2), '-b','parent',handles.av_psych)
    plot([threshold(2), threshold(2)], [0, 1], '--b','parent',handles.av_psych)
    
    p25 = (prior == .25);
    [bins, curve, coeff, curve_fit, threshold] = make_psych_curve(coherence(p25), correct(p25), direction(p25));
    
    scatter(bins, curve, '.g','parent',handles.av_psych)
    plot(curve_fit(:, 1), curve_fit(:, 2), '-g','parent',handles.av_psych)
    plot([threshold(2), threshold(2)], [0, 1], '--g','parent',handles.av_psych)
    
    title('average psych curve')
    legend('50-50 prior', 'fit', 'bias point', 'close prior', 'fit', 'bias point', 'far prior', 'fit', 'bias point')
catch
end
%%
%is there a bias?

close_acc_vec = [];
far_acc_vec = [];

for i = 1:num_files
    n_trials = objs{i}.obj.curr_trial - 1;
    
    corr_side =  objs{i}.obj.behavior_params.correct_side;
    corr_side = corr_side(1:n_trials);
    
    resp_side = objs{i}.obj.response.stim_response.response_side;
    resp_side = resp_side(1:n_trials);
    
    resp_given_close = resp_side(corr_side == 1);
    resp_given_far = resp_side(corr_side == 3);
    
    close_acc = sum(resp_given_close == 1) / length(resp_given_close);
    far_acc = sum(resp_given_far == 3) / length(resp_given_far);
    
    close_acc_vec(i) = close_acc;
    far_acc_vec(i) = far_acc;
    
    
end

scatter(1:num_files, close_acc_vec, 'm','.','parent',handles.bias);
set(handles.bias, 'NextPlot', 'add')
scatter(1:num_files, far_acc_vec, 'c','.','parent',handles.bias);
%legend('close','far')
%title(strcat('side bias')); ylabel('frac chose port 1'); xlabel('day'); ylim([0 1]);


% %% timing information
% 
% % get viewing time
% 
% subplot(325);
% nose_poke_times = cellfun(@(x,y) sum(y-x),objs{end}.obj.response.trial_initiation.start_poke_time,objs{end}.obj.response.trial_initiation.end_poke_time);
% nose_poke_times = nose_poke_times - objs{end}.obj.response.stim_response.time_between_aud_vis;
% 
% %end_poke_times = cellfun(@(x) x(end),objs{end}.obj.response.trial_initiation.end_poke_time);
% %nose_poke_times = end_poke_times - start_poke_times;
% quants = quantile(nose_poke_times,0:0.1:0.95);
% quants = [0 quants];
% was_correct = objs{end}.obj.response.stim_response.response_correct;
% [n,bin] = histc(nose_poke_times,quants);
% data_dummy = [];
% for i = 1:length(quants)
%     data_dummy(i) = sum(was_correct( find(bin==i)) )./n(i);
% end
% plot(quants,data_dummy,'.-')
% xlabel('time in center')
% ylabel('probability correct')
% 
% subplot(326);
% coherences = objs{end}.obj.prob_params.coherence;
% coherences = coherences(1:length(nose_poke_times));
% dirs = direction(1:length(nose_poke_times)); dirs(dirs==90)=-1; dirs(dirs==270)=1;
% %scatter(coherences,nose_poke_times)
% coherences = dirs.*coherences;
% cohs = unique(coherences);
% data_dummy = [];
% for i = 1:length(cohs)
%     
%     data_dummy(i) = mean(nose_poke_times(coherences==cohs(i)));
%     
% end
% 
% plot(cohs,data_dummy,'.-');
% xlabel('coherence');
% ylabel('nose poke time');
% 
% 
% for i = 1:length(objs)
%     fprintf('%s\n',objs{i}.obj.response.stim_response.type)
% end

% 
% 
% moving_average_param = 5;
% 
% corr_resp = objs{end}.obj.response.stim_response.response_correct;
% accuracy_over_time = movingmean(corr_resp,10,2)
% 
% figure(2); subplot(321);
% plot(accuracy_over_time, '-r');
% title(strcat('moving average')); ylabel('accuracy'); xlabel('trial number');
% 
% 
% 








end