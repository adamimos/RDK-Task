
clear all; close all; clc;



%date format should be yyyymmdd or * for all dates
date = '201*';

[list, dirs] = glob(strcat('C:/DATA/', date , '/*.mat'));
%[list, dirs] = glob(strcat('C:/OLD_DATA/DATA/Adam', date , '/', rat_name, '*.mat'));
%[list, dirs] = glob(strcat('C:/OLD_DATA/DATA20170930_LSRF/', date , '/', rat_name, '*.mat'));
%[list, dirs] = glob(strcat('C:/OLD_DATA/DATA20170930_LSRF/Box2/', date , '/', rat_name, '*.mat'));

objs = {};
rnames = {};dnames = {};
num_files = size(list, 1);
num_files = num_files;

fprintf('%s \n', 'found the following files:')

inds = [];
for i = 1: num_files
     %fprintf('%s \n', fname);
     try
             fname = list{i};
             obj = load(fname);
    if strcmp(obj.obj.response.stim_response.type,'center play trial history finite');
        inds = [inds i];
        objs{end+1} = obj;
        i1 = strfind(fname,'\'); i1 = i1(3);
        i2 = strfind(fname,'_'); i2 = i2(1);        
        rnames{end+1} = fname(i1+1:i2-1);
        i1 = strfind(fname,'\'); i1 = i1(2); i2 = strfind(fname,'\'); i2 = i2(3);
        dnames{end+1} = fname(i1+1:i2-1);
    end
     catch
     end
end




for i=unique(rnames)
    
    
    index = find(cellfun(@(x) strcmp(x,i), rnames, 'UniformOutput', 1));
    rat_struct = [];
    for ii = index
        
        name = i; obj = objs{ii}.obj; temp_obj.date = dnames{ii};
           
        trials = find(obj.is_trial_completed);
        %temp_obj.num_trials = num_trials;
        temp_obj.stim_right = obj.behavior_params.correct_side(trials);
        temp_obj.response_right = obj.response.stim_response.response_side(trials);
        temp_obj.prior_right = obj.prob_params.close_priors(trials);
        temp_obj.coherence = obj.prob_params.coherence(trials);

        temp_obj.stim_right(temp_obj.stim_right==3)=0;
        temp_obj.response_right(temp_obj.response_right==3)=0;
        temp_obj.coherence(temp_obj.stim_right==0)=-temp_obj.coherence(temp_obj.stim_right==0);

        temp_obj.was_correct = (temp_obj.stim_right==temp_obj.response_right);
        temp_obj = struct(temp_obj);
        rat_struct = [rat_struct temp_obj];
        %save([pathstr '/' filename '.spd'],'temp_obj','-v6')
        fprintf('%s \n', fname);
        %objs{i} = load(fname);
        %clear temp_obj
        
        
    end
    batch_data.(name{1}) = rat_struct;

end



