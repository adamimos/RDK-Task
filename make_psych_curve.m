function [axis, curve, coeffs, curve_fit, threshold, weight] = make_psych_curve(coherence, correct, direction)
%this is just the first stupid version of this function, we will make it
%much more official later


    direction(direction == 270) = 1;
    direction(direction == 90) = -1;

    coherence = coherence.*direction;
    
    bins = unique(coherence);

    curve = [];
    weight = [];
    for i= 1:length(bins)
        
        choices = correct(coherence == bins(i));
        weight(i) = length(choices); %/ length(correct);
        
        curve(i) = sum(choices == 1)/ length(choices);
    end

    axis = bins;
    
    %fit psych curve:
    
    %[coeffs, curve_fit, threshold] = FitPsycheCurveLogit(bins, curve, weight, [.25, .5, .75]);  
    
    [coeffs, curve_fit, threshold] = FitPsycheCurveLogit(bins, curve, ones(1,length(bins)), [.25, .5, .75]);  
    
    
end