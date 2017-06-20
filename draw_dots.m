function [] = draw_dots(display,dots)

    %convert from degrees to screen pixels
    pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
    pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;

    % draw the dots on the screen
    Screen('DrawDots',display.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);

end