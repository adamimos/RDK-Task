function [x, y, life] = compute_life(dots)
    % increment the life of each dot by 1
    life = dots.life+1;

    % figure out if the dot is dead
    deadDots = mod(dots.life,dots.lifetime)==0;

    % find new position for the dead dots
    dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
    dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);

    % send back to function
    x = dots.x; y = dots.y;
end