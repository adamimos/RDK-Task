% dirty first attempt at calibration

function out = calibrate(arduino, port,pause_length)

doses = 0;
calibrated = 0;
how_many_doses = 1;
while calibrated == 0
    how_many_doses_input = input('how many doses?');
    
    if isempty(how_many_doses_input)
        how_many_doses = how_many_doses;
    else
        how_many_doses = how_many_doses_input;
    end
    
    for i = 1:how_many_doses
        arduino.dose(port);
        pause(pause_length);
        fprintf('doses: %d\n',doses+i);
    end
    doses = doses+how_many_doses;
    doses
end

end
