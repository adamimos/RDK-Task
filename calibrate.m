% dirty first attempt at calibration

function out = calibrate(arduino)

pause_length = 0.5; % ms between doses
steps = [120 140 160]; % ms to calibrate at
ports = [1 3];
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );

if ~exist(['C:\DATA\calibration_' hostname '.mat'], 'file')
    cals.date = {datetime};
    cals.steps = {steps};
    cals.ports = {ports};
    cals.cal_vals =  {cell(1,length(ports))};
    cals.fits = {cell(1,length(ports))};
    cals.cal_200 = {cell(1,length(ports))};
else
    load(['C:\DATA\calibration_' hostname '.mat']);
    pcals = cals.cal_vals{end};
    cals.date{end+1} = datetime;
    cals.steps{end+1} = steps;
    cals.ports{end+1} = ports;
    cals.cal_vals{end+1}= cell(1,length(ports));
    cals.fits{end+1} = cell(1,length(ports));
    cals.cal_200{end+1} = cell(1,length(ports));
end


cal_vals_temp = cals.cal_vals{end};
for p = 1:length(ports)
    port_pcal = pcals{p};
    for s = 1:length(steps)
        
 

        fprintf('Calibrating port %d at %d ms. Previous Calibration was %d steps!\n',ports(p),steps(s),port_pcal(s));
        initialize_calibration(arduino,ports(p),steps(s));

        cal_val = cal_step(arduino,ports(p),steps(s));
        cal_vals_temp{p} = [cal_vals_temp{p} cal_val];
        fprintf('Calibration of port %d at %d ms is %d steps\n\n',ports(p),steps(s),cal_val);
    end

end

cals.cal_vals{end} = cal_vals_temp;

% plot and fit and find correct dosage
fit_temp = cals.fits{end};
good_temp = cals.cal_200{end};
figure;
subplot(1,2,1);hold on; x = steps(1):1:steps(end);
scatter(steps,cal_vals_temp{1});
P = polyfit(steps,cal_vals_temp{1},1); yfit = P(1)*x+P(2);    fit_temp{1}=P;
good_val =(200-P(2))/P(1); title(['Port ' num2str(ports(1)) ' Calibration = ' num2str(good_val) 'steps']); good_temp{1} = good_val;
plot(x,yfit);


subplot(1,2,2);hold on; x = steps(1):1:steps(end);
scatter(steps,cal_vals_temp{2});
P = polyfit(steps,cal_vals_temp{2},1); yfit = P(1)*x+P(2); fit_temp{2}=P;
good_val = (200-P(2))/P(1); title(['Port ' num2str(ports(2)) ' Calibration = ' num2str(good_val) 'steps']); good_temp{2} = good_val;
plot(x,yfit);


cals.fits{end} = fit_temp;
cals.cal_200{end} = good_temp;
save(['C:\DATA\calibration_' hostname '.mat'],'cals')



end


function [] = initialize_calibration(arduino,init_port,init_step)

initialized = 0;
how_many_doses = 1;

while initialized == 0
        how_many_doses_input = input('please fill to 20 mL, press 0 to start,type number to drain:');
    
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


function num_doses = cal_step(arduino,init_port,init_step)

num_doses = 0;
calibrated = 0;
how_many_doses = 1;

while calibrated == 0
    
    how_many_doses_input = input('press 0 when filled to 15mL, type number to drain:');
    
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


