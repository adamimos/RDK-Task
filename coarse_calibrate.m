%% coarse calibrate


% port 1

pause_length = 0.5; % ms between doses
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
ports = [1 3];
step_size = [200]; % ms
p = 1;


% run calibration for 200ms step size
initialize_calibration(test, ports(p),step_size(1));
num_dose = cal_step(test,ports(p),step_size(1));

index = 1;
cont = 1;
while cont == 1
    index = index+1;
    fprintf('The previous calibration was %d setps at %d ms.\n',num_dose(index-1),step_size(index-1));
    next_step_size = input('What would you like the next calibration time to be (ms)?');
    step_size = [step_size next_step_size];
    num_doses = cal_step(test,ports(p),step_size(index));
    num_dose = [num_dose num_doses];
    
    cont = input('would you like to continue?');
    
end


scatter(num_dose,step_size); xlabel('number of doses'); ylabel('step length (ms)');
P1 = polyfit(num_dose,step_size,1); P = P1; x = num_dose(1):1:num_dose(end);yfit = P(1)*x+P(2);
hold on; plot(x,yfit);

% we want 80 doses for every 2 mL so
fprintf('The 25 uL does is given by %f ms step dose',P(1)*80+P(2));

port1_cal25 = P(1)*80+P(2);


%%

p = 2;


% run calibration for 200ms step size
initialize_calibration(test, ports(p),step_size(1));
num_dose = cal_step(test,ports(p),step_size(1));
step_size = [200]; % ms
index = 1;
cont = 1;
while cont == 1
    index = index+1;
    fprintf('The previous calibration was %d setps at %d ms.\n',num_dose(index-1),step_size(index-1));
    next_step_size = input('What would you like the next calibration time to be (ms)?');
    step_size = [step_size next_step_size];
    num_doses = cal_step(test,ports(p),step_size(index));
    num_dose = [num_dose num_doses];
    
    cont = input('would you like to continue?');
    
end


scatter(num_dose,step_size); xlabel('number of doses'); ylabel('step length (ms)');
P3 = polyfit(num_dose,step_size,1); x = num_dose(1):1:num_dose(end);P=P3;yfit = P(1)*x+P(2);
hold on; plot(x,yfit);

% we want 80 doses for every 2 mL so
fprintf('The 25 uL does is given by %f ms step dose',P(1)*80+P(2));

port3_cal25 = P(1)*80+P(2);










%%%

    load(['C:\DATA\calibration_' hostname '.mat']);
    cals.date{end+1} = datetime;
    cals.ports{end+1} = ports;
    cals.fits{end+1} = cell(1,length(ports));
    cals.cal_200{end+1} = cell(1,length(ports));
    
    fit_temp{1} = P1; fit_temp{2} = P3;
    good_temp{1} = port1_cal25; good_temp{2} = port3_cal25;
    cals.fits{end} = fit_temp;
    cals.cal_200{end} = good_temp;
    save(['C:\DATA\calibration_' hostname '.mat'],'cals')


