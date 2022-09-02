% Draw all images in this script
% Save as a structure (myimages)
% Draws an oval in the top left corner of the screen, and outputs a jpg image
% of that dot.

%try
PsychDebugWindowConfiguration

[window, windowRect] = Screen('OpenWindow', 0);
[xCenter, yCenter] = RectCenter(windowRect);

Screen('FillRect', window, 0);
Screen(window, 'Flip');
white = WhiteIndex(window);

% Draws the display to be turned into an image file
% draw_target(window, xCenter, yCenter, tgt_dist(trial), add_distract_tar, discrim_tar(trial), 0, stim_type(trial))
mm2pixel = 3.00;
% tgt_location = [45, 135, 225, 315];
imageArray = struct(); 
textureArray = struct(); 
tgt_location = [15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345];

%tgt_location = [15, 75];
discrim_tar = [15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345]; 

%% Baseline Case

draw_target(window, xCenter, yCenter, 80 * mm2pixel, tgt_location, discrim_tar, 0, 1)
Screen(window, 'Flip');
% get image 
imageArray.(sprintf('discrim_%d', 0)) = Screen('GetImage', window);
textureArray.(sprintf('texture_%d', 0)) = Screen('Maketexture', window, imageArray.(sprintf('discrim_%d', 0))); 
imwrite(imageArray.(sprintf('discrim_%d', 0)),'discrim_0.jpg' )

% pull out image
Screen('FillRect', window, 0);
Screen(window, 'Flip');
Screen('DrawTexture', window, 11, [], [])
Screen(window, 'Flip');

%Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
%textureIndex=Screen('MakeTexture', WindowIndex, imageMatrix [, optimizeForDrawAngle=0] [, specialFlags=0] [, floatprecision=0] [, textureOrientation=0] [, textureShader=0]);

%% B Case

for si = 1:length(discrim_tar)
        draw_target(window, xCenter, yCenter, 80 * mm2pixel, tgt_location(si), discrim_tar(si), 1, 1)
        Screen(window, 'Flip');
        % get image 
        imageArray.(sprintf('B_%d', discrim_tar(si))) = Screen('GetImage', window);
        textureArray.(sprintf('B_%d', si)) = Screen('Maketexture', window,  imageArray.(sprintf('B_%d', discrim_tar(si)))); 
        imwrite(imageArray.(sprintf('B_%d', discrim_tar(si))), sprintf('B_%d.jpg', si) )
end

% pull out image
Screen('FillRect', window, 0);
Screen('DrawTexture', window, textureArray.texture_0, []) % figure out how to pull out images in a sequence
Screen(window, 'Flip');

%% D Case 

for si = 1:length(discrim_tar)
        draw_target(window, xCenter, yCenter, 80 * mm2pixel, tgt_location(si), discrim_tar(si), 1, 2)
        Screen(window, 'Flip');
        % get image 
        imageArray.(sprintf('D_%d', discrim_tar(si))) = Screen('GetImage', window);
        textureArray.(sprintf('D_%d', si)) = Screen('Maketexture', window,  imageArray.(sprintf('D_%d', discrim_tar(si)))); 
        imwrite(imageArray.(sprintf('D_%d', discrim_tar(si))), sprintf('D_%d.jpg', si) )
end

% pull out image
Screen('FillRect', window, 0);
Screen('DrawTexture', window, 11, []) % figure out how to pull out images in a sequence
                                      % figure out how to distinguish
                                      % between different cases when
                                      % pulling out images.
Screen(window, 'Flip');


%% P Case 

for si = 1:length(discrim_tar)
        draw_target(window, xCenter, yCenter, 80 * mm2pixel, tgt_location(si), discrim_tar(si), 1, 3)
        Screen(window, 'Flip');
        % get image 
        imageArray.(sprintf('P_%d', discrim_tar(si))) = Screen('GetImage', window);
        textureArray.(sprintf('P_%d', si)) = Screen('Maketexture', window,  imageArray.(sprintf('P_%d', discrim_tar(si)))); 
        imwrite(imageArray.(sprintf('P_%d', discrim_tar(si))), sprintf('P_%d.jpg', si) )
end

% pull out image
Screen('FillRect', window, 0);
Screen('DrawTexture', window, 11, []) % figure out how to pull out images in a sequence
                                      % figure out how to distinguish
                                      % between different cases when
                                      % pulling out images.
Screen(window, 'Flip');

%% Q Case 

for si = 1:length(discrim_tar)
        draw_target(window, xCenter, yCenter, 80 * mm2pixel, tgt_location(si), discrim_tar(si), 1, 4)
        Screen(window, 'Flip');
        % get image 
        imageArray.(sprintf('Q_%d', discrim_tar(si))) = Screen('GetImage', window);
        textureArray.(sprintf('Q_%d', si)) = Screen('Maketexture', window,  imageArray.(sprintf('Q_%d', discrim_tar(si)))); 
        imwrite(imageArray.(sprintf('Q_%d', discrim_tar(si))), sprintf('Q_%d.jpg', si) )
end

% pull out image
Screen('FillRect', window, 0);
Screen('DrawTexture', window, 11, []) % figure out how to pull out images in a sequence
                                      % figure out how to distinguish
                                      % between different cases when
                                      % pulling out images.
Screen(window, 'Flip');

%% Loop through all textures, identify 
% which movement target they are associated to
% and then add the arrow on the texture
% save as a new texure 

my_fields = fieldnames(imageArray);
my_mttarget = [45, 135, 225, 315]; 
% for all textures 1 to num textures
for si = 1:size(my_fields, 1)
    for mi = 1:length(my_mttarget)
        % draw the si texture in imageArray. 
        % draw the arrow onto the si texture 
        % make texture using both of these draws 
        % save this texture with a certain index into imageArray indicating
        % that this is with an arrow 
        
        temp = Screen('MakeTexture', window, imageArray.(my_fields{si}));
        Screen('DrawTexture', window, temp, [], windowRect);
        draw_arrow(window, [xCenter, yCenter], - my_mttarget(mi) - 180, [255, 255, 255], [25, 10, 0, 0]); % 0 is pointing left, 180 is pointing right
        Screen(window, 'Flip');
        imageArray.(sprintf('arrow_%s_%d', my_fields{si}, my_mttarget(mi))) = Screen('GetImage', window);
    end
end

% 1 = place  holders only
% 2 = place holders + center circle 
% 3 = place holders 


%% Ending 


Screen(window, 'Flip');

WaitSecs(.5);
Screen('CloseAll');


% save the imageArray 

save('Deubel_imageArray', '-struct', 'imageArray')

%% Draw Targets

function draw_target(window, xCenter, yCenter, tgt_dist, tgt_location, discrim_tar, on_discrim, stim_type)

%distract_col = [1, 1, 1];

if on_discrim
    switch stim_type
        case 1 % B
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) + 15]);
            Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [-0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)]);
            
            tgt_location = [15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345];
            tgt_location(tgt_location == discrim_tar) = [];
            for s = 1:length(tgt_location)
                if mod(s,2) == 0
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);

                else
                  
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 16]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 16]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                end
            end
            
        case 2 % D
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) + 15]);
            Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)]);
            
            tgt_location = [15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345];
            tgt_location(tgt_location == discrim_tar) = [];
            for s = 1:length(tgt_location)
                if mod(s,2) == 0
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);

                else
                  
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 16]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 16]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                end
            end
            
        case 3 % P
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) - 15]);
            Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)]);
            
            tgt_location = [15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345];
            tgt_location(tgt_location == discrim_tar) = [];
            for s = 1:length(tgt_location)
                if mod(s,2) == 0
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);

                else
                  
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 16]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 16]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                end
            end
            
        case 4 % Q
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar), yCenter - tgt_dist * sind(discrim_tar) - 15]);
            Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) + 9, yCenter - tgt_dist * sind(discrim_tar)]);
            Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(discrim_tar) - 9, yCenter - tgt_dist * sind(discrim_tar)]);
            
            tgt_location = [15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345];
            tgt_location(tgt_location == discrim_tar) = [];
            for s = 1:length(tgt_location)
                if mod(s,2) == 0
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);

                else
                  
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 16]);
                    Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 16]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                    Screen('DrawLines', window, [0 0 0 0 ; 0 0  0, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);
                end
            end
            
    end
    
else
    tgt_location = [15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345];
    for s = 1:length(tgt_location)
        Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s))]);
        Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) + 15]);
        Screen('DrawLines', window, [-11 11 0 0 ; 0 0 0, 0], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)), yCenter - tgt_dist * sind(tgt_location(s)) - 15]);
        Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) + 9, yCenter - tgt_dist * sind(tgt_location(s))]);
        Screen('DrawLines', window, [0 0 0 0 ; 0 0 -15, 15], 4,  [255, 255, 255], [xCenter + tgt_dist * cosd(tgt_location(s)) - 9, yCenter - tgt_dist * sind(tgt_location(s))]);
    end
end

end

%% Draw Arrow

function draw_arrow(w, center_coords, arrow_rotation, arrow_color, dimension_array)
% DRAW_ARROW Draws an arrow using PsychToolbox commands
%
% draw_arrow(w, center_coords, arrow_rotation, arrow_color, dimension_array)

    horz_center = center_coords(1);
    vert_center = center_coords(2);
    
    head_width = dimension_array(1);
    head_height = dimension_array(2);
    body_width = dimension_array(3);
    body_height = dimension_array(4);

    head_slope = head_height / head_width;
    arrow_width = head_width + body_width;
    arrow_height = max(head_height, body_height);
    arrow_left = -(arrow_width/2);
    arrow_neck = arrow_left + head_width;
    arrow_right = (arrow_width/2);
    
    % draw a leftward facing arrow, translate and rotate later
    
    % draw arrow head first
    for x = 0:head_width
        line_half_height = x * head_slope / 2;
        dim_array = [arrow_left+x -line_half_height arrow_left+x +line_half_height];
        drawn_array = draw_rotated_line(dim_array);
    end
    
    % now draw arrow body
    for x = arrow_neck:1:arrow_right
        dim_array = [x (-body_height/2) x (body_height/2)];
        drawn_array = draw_rotated_line(dim_array);
    end
            
    function [cart_coords] = screen2cart(screen_coords, horizontal_center, vertical_center)
        cart_coords = screen_coords - [horizontal_center vertical_center horizontal_center vertical_center];
    end

    function [screen_coords] = cart2screen(cart_coords, horizontal_center, vertical_center)
        screen_coords = cart_coords + [horizontal_center vertical_center horizontal_center vertical_center];
    end
    
    function [rotated_array] = rotate_dim_array(dim_array, rotation_angle_in_degrees)
        rotate_radians = rotation_angle_in_degrees / 180 * pi;
        % rotate first point in dim array
        [original_angle, radius, ] = cart2pol(dim_array(1), dim_array(2));
        new_angle = original_angle + rotate_radians;
        [rotated_array(1), rotated_array(2)] = pol2cart(new_angle, radius);
        
        % rotate second point in dim array
        [original_angle, radius, ] = cart2pol(dim_array(3), dim_array(4));
        new_angle = original_angle + rotate_radians;
        [rotated_array(3), rotated_array(4)] = pol2cart(new_angle, radius);
    end        
    
    function [rotated_screen_array] = draw_rotated_line(cart_array)
        rotated_array = rotate_dim_array(cart_array, arrow_rotation);
        rotated_screen_array = cart2screen(rotated_array, horz_center, vert_center);
        Screen('DrawLine', w, arrow_color, rotated_screen_array(1), rotated_screen_array(2), rotated_screen_array(3), rotated_screen_array(4));
    end
end