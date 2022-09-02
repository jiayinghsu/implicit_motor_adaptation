Screen('DrawTexture', window, 11, [])
% Draw all images in this script
% Save as a structure (myimages)
% Draws an oval in the top left corner of the screen, and outputs a jpg image
% of that dot.

%try

[window, windowRect] = Screen('OpenWindow', 0);
[xCenter, yCenter] = RectCenter(windowRect);

Screen('FillRect', window, 0);
Screen(window, 'Flip');
white = WhiteIndex(window);

% Draws the display to be turned into an image file
% draw_target(window, xCenter, yCenter, tgt_dist(trial), add_distract_tar, discrim_tar(trial), 0, stim_type(trial))
mm2pixel = 3.00;
tgt_location = [45, 135, 225, 315];
myimages = struct(); 
mytexture = struct(); 

for si = 1:4
    
    draw_target(window, xCenter, yCenter, 80 * mm2pixel, tgt_location(si), 45, 0, 1)
    Screen(window, 'Flip');
    % get 
    myimages.(sprintf('Image_%d', si)) = Screen('GetImage', window);
    mytexture.(sprintf('Texture_%d', si)) = Screen('Maketexture', window,  myimages.(sprintf('Image_%d', si))); 
    %imwrite(imageArray, sprintf('test%d.jpg', si) )
end

Screen('FillRect', window, 0);
Screen('DrawTexture', window, 11, [])

Screen(window, 'Flip');

% pull out the third one. 

%Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
%textureIndex=Screen('MakeTexture', WindowIndex, imageMatrix [, optimizeForDrawAngle=0] [, specialFlags=0] [, floatprecision=0] [, textureOrientation=0] [, textureShader=0]);



Screen(window, 'Flip');

WaitSecs(.5);
Screen('CloseAll');



function draw_target(window, xCenter, yCenter, tgt_dist, tgt_location, discrim_tar, on_discrim, stim_type)

distract_col = [1, 1, 1];

if on_discrim
    switch stim_type
        case 1 % B
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)] , 2);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) + 15], 2);
            %Screen('DrawLines', window, [-15 15 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) - 32], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0  0, 15], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 15], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
        case 2 % D
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)] , 2);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) + 15], 2);
            %Screen('DrawLines', window, [-15 15 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) - 32], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 15], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0  0, 15], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
        case 3 % P
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)] , 2);
            %Screen('DrawLines', window, [-15 15 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) + 32], 2);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) - 15], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 0], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 15], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
        case 4 % Q
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)] , 2);
            %Screen('DrawLines', window, [-15 15 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) + 32], 2);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) - 15], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 15], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
            Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 0], 4, [1, 1, 1], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)], 2);
    end
    
    tgt_location(tgt_location == discrim_tar) = [];
    
    for s = 1:4
        switch s
            case {2, 4, 6, 8, 10}
                Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))] , 2);
                Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15], 2);
                Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15], 2);
                Screen('DrawLines', window, [ 0 0 0 0 ; 0 0  0, 15], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))], 2);
                Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))], 2);
            case {1, 3, 5, 7, 9, 11}
                Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))] , 2);
                Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 16], 2);
                Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 16], 2);
                Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))], 2);
                Screen('DrawLines', window, [ 0 0 0 0 ; 0 0  0, 15], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))], 2);
        end
    end
else
    
    for s = 1:length(tgt_location)
        Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
        Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15]);
        Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15]);
        Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
        Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);
        %Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15], 2);
        %Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15], 2);
        %Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 15], 4, distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))], 2);
        %Screen('DrawLines', window, [ 0 0 0 0 ; 0 0 -15, 15], 4, distract_col, [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))], 2);
    end
end

end
