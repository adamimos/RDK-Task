function [] = compute_and_play_prior(file_params,prior_list,close_prior,sound_list)

% which_prior = find(prior_list == close_prior);
% 
% switch file_params.mouse   
%     
%     case 'holly1'
%         sound([sound_list{1} zeros(5513,1)],44100);
%     case 'holly0'
%         sound([zeros(5513,1) sound_list{2}],44100);
%     case 'emmy0'
%         sound([zeros(5513,1) sound_list{3}],44100);
%     case 'emmy1'
%         sound([sound_list{2} zeros(5513,1)],44100);
% end

PsychPortAudio('Start', file_params.pahandle);

end