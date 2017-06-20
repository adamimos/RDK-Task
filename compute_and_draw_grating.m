function output = compute_and_draw_grating(display, i, angle, contrast)

% First we compute pixels per cycle, rounded up to full pixels, as we
% need this to create a grating of proper size below:
gratingsize = 400;
f=0.1;
cyclespersecond=3.0;
texsize=gratingsize / 2;
p=ceil(1/f);

% Also need frequency in radians:
fr=f*2*pi;

% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visiblesize=2*texsize+1;

% Create one single static grating image:
%
% We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
% define the whole grating! If the 'srcRect' in the 'Drawtexture' call
% below is "higher" than that (i.e. visibleSize >> 1), the GPU will
% automatically replicate pixel rows. This 1 pixel height saves memory
% and memory bandwith, ie. it is potentially faster on some GPUs.
%
% However it does need 2 * texsize + p columns, i.e. the visible size
% of the grating extended by the length of 1 period (repetition) of the
% sine-wave in pixels 'p':
x = meshgrid(-texsize:texsize + p, 1);

white=WhiteIndex(display.screenNum);
	black=BlackIndex(display.screenNum);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
	gray=round((white+black)/2);

    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
		gray=white / 2;
    end
    
    % Contrast 'inc'rement range for given white and gray values:
	inc=white-gray;


% Compute actual cosine grating:
grating=gray + inc*cos(fr*x);

% Store 1-D single row grating in texture:
gratingtex=Screen('MakeTexture', display.windowPtr, grating);

% Create a single gaussian transparency mask and store it to a texture:
% The mask must have the same size as the visible size of the grating
% to fully cover it. Here we must define it in 2 dimensions and can't
% get easily away with one single row of pixels.
%
% We create a  two-layer texture: One unused luminance channel which we
% just fill with the same color as the background color of the screen
% 'gray'. The transparency (aka alpha) channel is filled with a
% gaussian (exp()) aperture mask:
% mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
% [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
% mask(:, :, 2)=white * (1 - exp(-((x/90).^2)-((y/90).^2)));
% masktex=Screen('MakeTexture', display.windowPtr, mask);

% Query maximum useable priorityLevel on this system:
%priorityLevel=MaxPriority(w); %#ok<NASGU>

% We don't use Priority() in order to not accidentally overload older
% machines that can't handle a redraw every 40 ms. If your machine is
% fast enough, uncomment this to get more accurate timing.
%Priority(priorityLevel);

% Definition of the drawn rectangle on the screen:
% Compute it to  be the visible size of the grating, centered on the
% screen:
dstRect=CenterRectOnPointd([0 0 10000 10000], 0, 0);%[0 0 visiblesize visiblesize];
%dstRect=CenterRect(dstRect, screenRect);

% Query duration of one monitor refresh interval:
%ifi=Screen('GetFlipInterval', w);

% Translate that into the amount of seconds to wait between screen
% redraws/updates:

% waitframes = 1 means: Redraw every monitor refresh. If your GPU is
% not fast enough to do this, you can increment this to only redraw
% every n'th refresh. All animation paramters will adapt to still
% provide the proper grating. However, if you have a fine grating
% drifting at a high speed, the refresh rate must exceed that
% "effective" grating speed to avoid aliasing artifacts in time, i.e.,
% to make sure to satisfy the constraints of the sampling theorem
% (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
% you don't know what this means):
%waitframes = 1;

% Translate frames into seconds for screen update interval:
waitduration = display.waitframes * display.ifi;

% Recompute p, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding errors!
p=1/f;  % pixels/cycle

% Translate requested speed of the grating (in cycles per second) into
% a shift value in "pixels per frame", for given waitduration: This is
% the amount of pixels to shift our srcRect "aperture" in horizontal
% directionat each redraw:
shiftperframe= cyclespersecond * p * waitduration;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp as timing baseline for our redraw loop:
%display.vbl=Screen('Flip', display.windowPtr);

% We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
%vblendtime = vbl + movieDurationSecs;


xoffset = mod(i*shiftperframe,p);
%i=i+1;

% Define shifted srcRect that cuts out the properly shifted rectangular
% area from the texture: We cut out the range 0 to visiblesize in
% the vertical direction although the texture is only 1 pixel in
% height! This works because the hardware will automatically
% replicate pixels in one dimension if we exceed the real borders
% of the stored texture. This allows us to save storage space here,
% as our 2-D grating is essentially only defined in 1-D:
srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

% Draw grating texture, rotated by "angle":
Screen('DrawTexture', display.windowPtr, gratingtex, srcRect, dstRect, angle+90);



% Flip 'waitframes' monitor refresh intervals after last redraw.
% Providing this 'when' timestamp allows for optimal timing
% precision in stimulus onset, a stable animation framerate and at
% the same time allows the built-in "skipped frames" detector to
% work optimally and report skipped frames due to hardware
% overload:
display.vbl = Screen('Flip', display.windowPtr, display.vbl + (display.waitframes - 0.5) * display.ifi);


Screen('Close',gratingtex);