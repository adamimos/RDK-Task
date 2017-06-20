initiated_trial = 0;
poked = 1;
corrSide = 1;
go = 1;
a = tic;
howManyDoses = 0;
    while go == 1
        if test.is_licking(2) && initiated_trial == 0
            initiated_trial = 1;
            fprintf('initiated \n');
        end
        
        if test.is_licking(1) && initiated_trial == 1
            initiated_trial = 0;
            test.dose(1);
            pause(1);
            howManyDoses = howManyDoses + 1;
            fprintf('gottem close\n');
        end
        
        if test.is_licking(3) && initiated_trial == 1
            initiated_trial = 0;
            test.dose(3);
            pause(1);
            howManyDoses = howManyDoses + 1;
            fprintf('gottem far\n');
        end
        if toc(a) > 15*60
            go = 0;
        end
        
        
    end
    
