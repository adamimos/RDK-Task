%% PARAMETERS
numTrials = 5;
closeBias = 0.5;
farBias = 1-closeBias;

trialSide = rand(1,numTrials)<closeBias; % 1 is close and 3 is far
trialSide = double(trialSide)
incorrectSide = abs(trialSide-1);
trialSide(trialSide==0)=3;
incorrectSide(trialSide==1)=3;

trialCoherence = rand(1,numTrials);



for trial = 1:numTrials
    
    %% POKE IN CENTER PORT
    
    
    didPokeCenter = 0;
    
    while didPokeCenter == 0
        
        if test.is_licking(2)
            didPokeCenter = 1;
            while test.is_licking(2)
                % show stim
                fprintf('stim\n')
            end
            fprintf('STIMOFF')
            
        end
    end
    
    
    
    
    %% RESPONSE
    
    didRespond = 0;
    while didRespond == 0
        
        if test.is_licking(trialSide(trial))
            didRespond = 1;
            fprintf('Correct')
        elseif test.is_licking(incorrectSide(trial))
            didRespond = 1;
            fprintf('WRONG')
        end
        
    end
    
    
    
end