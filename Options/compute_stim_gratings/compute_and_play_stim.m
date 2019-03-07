function [display, dots] = compute_and_play_stim(display,dots,curr_trial)
                % for gratings, all we need are dots.directions, and
                % curr_trial, we move by the same speed every time
                
                gratingid = CreateProceduralSineGrating(display.windowPtr, 3000, 3000,[0.5 0.5 0.5 0.0]);

                %dstRect = OffsetRect(gratingrect, 100, 100);
                % gratingsize = Size of 2D grating patch in pixels.
                % freq = Frequency of sine grating in cycles per pixel.
                % cyclespersecond = Drift speed in cycles per second.
                
                dots.gratings.phase(curr_trial) = dots.gratings.phase(curr_trial) + 3.44*360/30;
                phase = dots.gratings.phase(curr_trial);%i want 3.44 hz = 3.44 cycles/second
                freq = .08*142/1920; % cycles per pixel, i want .08 cycles per degree, and we have 1920/143 pixels per degree, so .08c/d*142/1920 d/p = c/p
                contrast = dots.gratings.contrast(curr_trial);
                %contrast = 0.2;
                Screen('DrawTexture', display.windowPtr, gratingid, [], [], dots.gratings.direction(curr_trial), [],[],[], [],[], [phase, freq, contrast, 0]);
                 display.vbl = Screen('Flip', display.windowPtr, display.vbl + (display.waitframes + 1.0) * display.ifi);
                dots.direction(curr_trial)
                
                % draw dots, note: this does not flip the screen
                %draw_dots(display,dots)
                
                %update the dot position
                %[dots.x,dots.y] = move_dots(dots.x,dots.y,dots.dx(curr_trial,:),dots.dy(curr_trial,:));
                
                % Deal with dots that move offscreen
                %[dots.x,dots.y] = compute_aperture(dots.x,dots.y,dots.center,dots.apertureSize);
                
                % Deal with dots that have died
                %[dots.x, dots.y, dots.life] = compute_life(dots);
                
                % flip the screen
                %display.vbl = Screen('Flip', display.windowPtr, display.vbl + (display.waitframes + 1.0) * display.ifi);
                
end