initiated_trial = 1;
poked = 1;
corrSide = 1;
go = 1;
a = tic;
howManyDoses = 0;
    while go == 1
        if test.is_licking(2) && initiated_trial == 1
            test.dose(2);
            pause(1);
            howManyDoses = howManyDoses + 1;
            fprintf('gottem center \n');
        end
        
        if test.is_licking(1) && initiated_trial == 1
            test.dose(1);
            pause(1);
            howManyDoses = howManyDoses + 1;

            fprintf('gottem close\n');
        end
        
        if test.is_licking(3) && initiated_trial == 1

            test.dose(3);
            pause(1);
            howManyDoses = howManyDoses + 1;
            fprintf('gottem far\n');
        end
        if toc(a) > 30*60
            go = 0;
        end
        
        
    end
    
