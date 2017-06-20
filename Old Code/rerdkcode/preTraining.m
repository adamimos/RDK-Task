 
poked = 1;
corrSide = 1;
go = 1;
a = tic;
howManyDoses = 0;
    while go == 1
        
        if test.is_licking(corrSide)
           
            test.dose(corrSide);
            corrSide = mod(corrSide + 2,4);
            poked = 1;
            pause(1);
            howManyDoses = howManyDoses + 1;
            fprintf('gottem \n');
        end
        if toc(a) > 15*60
            go = 0;
        end
        
        
    end
    
