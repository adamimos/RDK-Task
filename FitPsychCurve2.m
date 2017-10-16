function [coeffs, curve, threshold] = FitPsychCurve2(xAxis, yData)

    
    
    F = @(x,xdata) x(1) + x(2)./( 1+exp(  -1*(xdata-x(3))./ x(4)  )  );
    x0 = [0.0 1.0 0.0 -0.5];
    [x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,xAxis,yData);
    
    coeffs = x;
    curve = x
    threshold = x(3);




end