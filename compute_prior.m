function [] = compute_prior(file_params,prior_list,close_prior,sound_list)

%figure out which prior to play, and then put it into the buffer.


%which_prior = find(prior_list == close_prior);

if close_prior == 0.5
    index = 2;
elseif close_prior == 0.25
    index = 1;
elseif close_prior == 0.75
    index = 3;   
end


switch file_params.mouse   
    
    case 'ambrosia1'
        mapping = [3 4 2]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        s = [sound_list{mapping(index)} zeros(5513,1)];
        %s = [zeros(5513,1) zeros(5513,1)];
    case 'ambrosia0'
        
        mapping = [4 2 3]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        %s = [zeros(5513,1) sound_list{mapping(index)}];
        s = [zeros(5513,1) zeros(5513,1)];
   case 'zandra0'
        mapping = [4 3 2]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        s = [zeros(5513,1) sound_list{mapping(index)}];
        %s = [zeros(5513,1) zeros(5513,1)];
    case 'zandra1'
        
        mapping = [2 3 4]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        %s = [sound_list{mapping(index)} zeros(5513,1) ];
        s = [zeros(5513,1) zeros(5513,1)];
    case 'emmy0'

        mapping = [2 3 1]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        %s = [zeros(5513,1) sound_list{mapping(index)}];
        s = [zeros(5513,1) zeros(5513,1)];
    case 'emmy1'
        
        mapping = [3 2 1]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        %s = [sound_list{mapping(index)} zeros(5513,1)];
        s = [zeros(5513,1) zeros(5513,1)];
    case 'miley0'

        mapping = [2 3 4]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        %s = [zeros(5513,1) sound_list{mapping(index)}];
        s = [zeros(5513,1) zeros(5513,1)];
    case 'miley1'
        
        mapping = [3 2 4]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        %s = [sound_list{mapping(index)} zeros(5513,1)];
        s = [zeros(5513,1) zeros(5513,1)];
   case 'adam'
        
        mapping = [3 2 1]; %sound 3 for 25%, 1 for 50% and 2 for 75%
        %s = [sound_list{mapping(index)} zeros(5513,1)];
         s = [zeros(5513,1) zeros(5513,1)];   
  case 'mackay0'
        
        s = [zeros(5513,1) zeros(5513,1)];
        
  case 'mackay1'
        
        s = [zeros(5513,1) zeros(5513,1)];
        
   case 'alien0'
        
        s = [zeros(5513,1) zeros(5513,1)];
        
    case 'alien1'
        
        s = [zeros(5513,1) zeros(5513,1)];
        
    end


        PsychPortAudio('FillBuffer', file_params.pahandle, s');

end