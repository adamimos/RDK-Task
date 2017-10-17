function plot_calibration(cals)
    N = length(cals.ports);
    port1 = [];
    port3 = [];
    date = [];
    for i = 1:N
        port1 = [port1 cals.cal_200{i}{1}];
        port3 = [port3 cals.cal_200{i}{2}];
        date = [date cals.date{i}];
    end
    
    plot(date,port1,date,port3);

end