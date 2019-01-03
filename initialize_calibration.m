
%%%
function [] = initialize_calibration(arduino,init_port,init_step)

initialized = 0;
how_many_doses = 1;

while initialized == 0
        how_many_doses_input = input('please fill to 30 mL, press 0 to start,type number to drain:');
    
    if isempty(how_many_doses_input)
        how_many_doses = how_many_doses;
        for i = 1:how_many_doses;arduino.dose_cal(init_port,init_step);pause(0.5);end;
    elseif how_many_doses_input == 0
        initialized = 1;
    else
        how_many_doses = how_many_doses_input;
        for i = 1:how_many_doses;arduino.dose_cal(init_port,init_step);pause(0.5);end;
    end
 
end

end