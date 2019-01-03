
function num_doses = cal_step(arduino,init_port,init_step)

num_doses = 0;
calibrated = 0;
how_many_doses = 1;

while calibrated == 0
    
    how_many_doses_input = input('press 0 when filled to 28 mL, type number to drain:');
    
    if isempty(how_many_doses_input)
        how_many_doses = how_many_doses;
        for i = 1:how_many_doses;arduino.dose_cal(init_port,init_step);pause(0.5);num_doses = num_doses+1;end;
    elseif how_many_doses_input == 0
        calibrated = 1;
    else
        how_many_doses = how_many_doses_input;
        for i = 1:how_many_doses;arduino.dose_cal(init_port,init_step);pause(0.5);num_doses = num_doses+1;end;
    end
 
end

end
