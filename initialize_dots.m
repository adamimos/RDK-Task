function [dots] = initialize_dots(dots)
            dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
            dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);
            dots.life = ceil(rand(1,dots.nDots)*dots.lifetime);
end