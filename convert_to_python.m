clear all
date = '*';
rat_name = '*';

[list, dirs] = glob(strcat('/home/adam/Documents/DATA/RDK/Behavior_1/', '*.mat'));



objs = {};

num_files = size(list, 1);
num_files = num_files;

fprintf('%s \n', 'found the following files:')

for i = 1:num_files
    fname = list{i};
    [pathstr,filename,dum2] = fileparts(fname);
    load(fname);
    
    num_trials = obj.curr_trial-1;
    
    %temp_obj.num_trials = num_trials;
    temp_obj.stim_right = obj.behavior_params.correct_side(1:num_trials);
    temp_obj.response_right = obj.response.stim_response.response_side;
    temp_obj.prior_right = obj.prob_params.close_priors(1:num_trials);
    %temp_obj.block_length = obj.prob_params.block_length;
    temp_obj.coherence = obj.prob_params.coherence(1:num_trials);
    
    temp_obj.stim_right(temp_obj.stim_right==3)=0;
    temp_obj.response_right(temp_obj.response_right==3)=0;
    temp_obj.coherence(temp_obj.stim_right==0)=-temp_obj.coherence(temp_obj.stim_right==0);
    
    temp_obj.was_correct = (temp_obj.stim_right==temp_obj.response_right);
    temp_obj = struct(temp_obj);
    save([pathstr '/' filename '.spd'],'temp_obj','-v6')
    fprintf('%s \n', fname);
    %objs{i} = load(fname);
    clear temp_obj
end