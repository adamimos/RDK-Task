function [x,y] = compute_aperture(x,y,center,apertureSize);
    % this function computes the boundaries for the aperture and then
    % moves dots to the other edge

    % compute boundaries
    l = center(1)-apertureSize(1)/2;
    r = center(1)+apertureSize(1)/2;
    b = center(2)-apertureSize(2)/2;
    t = center(2)+apertureSize(2)/2;

    % move dots as needed
    x(x<l) = x(x<l) + apertureSize(1);
    x(x>r) = x(x>r) - apertureSize(1);
    y(y<b) = y(y<b) + apertureSize(2);
    y(y>t) = y(y>t) - apertureSize(2);
end