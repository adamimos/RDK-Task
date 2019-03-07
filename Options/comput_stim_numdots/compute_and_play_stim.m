function [display, dots] = compute_and_play_stim(display,dots,curr_trial)
                % for dots
                
                % draw dots, note: this does not flip the screen
                draw_dots(display,dots)
                
                %update the dot position
                [dots.x,dots.y] = move_dots(dots.x,dots.y,dots.dx,dots.dy);
                
                % Deal with dots that move offscreen
                [dots.x,dots.y] = compute_aperture(dots.x,dots.y,dots.center,dots.apertureSize);
                
                % Deal with dots that have died
                [dots.x, dots.y, dots.life] = compute_life(dots);
                
                % flip the screen
                display.vbl = Screen('Flip', display.windowPtr, display.vbl + (display.waitframes + 1.0) * display.ifi);
                
end