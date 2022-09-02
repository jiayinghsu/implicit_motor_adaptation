function run_baseline_pl_12March2020()

%------------------------
% INPUT TARGET FILE
%------------------------

subject_num = input('Enter Subject #:', 's'); % number from 1:N
subj_ver = input('Enter Version #:', 's'); % number from 1:N

trial = 85;
gamephase = -1;
discrim_duration = 0.133; 

%------------------------
% PSYCHTOOLBOX INITIATLIZE
%------------------------

InExpSystem = 0; % 0= not in the system; 1 = in the system (during exp)
PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 1);
Priority(1)
PsychDefaultSetup(2);
InitializePsychSound(1)
freq = 22500;
nrchannels = 2; % for stereo, I think
pamaster = PsychPortAudio('Open', [], 1+8, 0, freq, nrchannels, [], 0.022); % last arg is for delay in sound onset
PsychPortAudio('Start', pamaster, 0, 0, 1);
pasound1 = PsychPortAudio('OpenSlave', pamaster, 1);
pasound2 = PsychPortAudio('OpenSlave', pamaster, 1);
pasound3 = PsychPortAudio('OpenSlave', pamaster, 1);

% Get the screen numbers
screens = Screen('Screens');

if InExpSystem
    screenNumber = max(screens);
    dir='C:\Dropbox\VICE\JT\DEUBAL\';
    addpath(genpath('C:\Users\ivrylab\Dropbox\'))
    mm2pixel = 3.6137;
    start_tolerance = 20*mm2pixel;
else
    screenNumber = max(screens);
    dir='/Users/newxjy/Dropbox/VICE/JT/DEUBAL/';
    addpath(genpath('/Users/newxjy/Dropbox/VICE/JT/DEUBAL/'))
    mm2pixel = 3.00;
    start_tolerance = 60*mm2pixel
end

% Load sounds
cd([dir 'Sounds'])
load 'ding'
load 'tooslow'
load 'knock_short_quiet'

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pasound1, ding);
PsychPortAudio('FillBuffer', pasound2, tooslow);
PsychPortAudio('FillBuffer', pasound3, knock_short_quiet);

% Clean PTB's pipes by emitting sound
PsychPortAudio('Volume', pasound1, 0.1)
PsychPortAudio('Start', pasound1, 1, 0, 0);
PsychPortAudio('Volume', pasound1, 1.0)

%------------------------
% MODIFY/INITIALIZE VARIABLES
%------------------------

startcirclewidth = 6*mm2pixel;
rt_dist_thresh = 5*mm2pixel;
targetsize = 15*mm2pixel;
force_RT = 0.450; % need to change?
searchring_tolerance = 10*mm2pixel;
endptfbtime = 0.5; % need to change?
wait_time = 0.5; % need to change?
insidetime = 0; % what is this?
curtime = 0; % what is this?
rt = 0;
mt = 0;
searchtime = 0;
fb_time = 0;
hits = 0;
tgtstart = 0;
fix_start = 0;
discrim_start = 0;
report_time = 0;
visible = 0;
start_event = 1; 
end_event = 1; 

MTs = [];
SearchTimes = [];

RTs = 1000; % place holder

data = [];
cursor = [];
problem_report = {};
textureArray = struct(); 

% See Matlab for Behavioral Scientists by David A. Rosenbaum.
desiredSampleRate = 500;
k = 0;

% Define the ESC key
KbName('UnifyKeynames');
esc = KbName('ESCAPE');
space = KbName('SPACE');

% Variables that store data -all copied from Ryan's code
MAX_SAMPLES=6e6; %about 1 hour @ 1.6kHz = 60*60*1600
gamephase_move=nan(MAX_SAMPLES,1);
tablet_queue_length=nan(MAX_SAMPLES,1);
thePoints=nan(MAX_SAMPLES,2);
cursorPoints=nan(MAX_SAMPLES,2);
tabletPoints=uint16(nan(MAX_SAMPLES/8,2)); %reduce # of samples since the tablet is sampled @ 200Hz
tabletTime=nan(MAX_SAMPLES/8,1);
dt_all = nan(MAX_SAMPLES,1);
t = nan(MAX_SAMPLES,1);
trial_time = nan(MAX_SAMPLES,1);
trial_move = nan(MAX_SAMPLES,1);
start_x_move = nan(MAX_SAMPLES,1);
start_y_move = nan(MAX_SAMPLES,1);
rotation_move = nan(MAX_SAMPLES,1);

%------------------------
% DRAW ALL TARGET IMAGES
%------------------------

imageArray = load('Deubel_imageArray.mat');
imageArrow = load('Deubel_imageArrow.mat');

%------------------------
% INITIALIZE SCREEN/FONT
%------------------------

HideCursor;

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
if InExpSystem
    WinTabMex(0, window); %Initialize tablet driver, connect it to 'win'
    tab_k = 15;
end

[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 28);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

if InExpSystem
    % I think there are 2540 lines per inch (lpi) on tablet
    % tablet active area is 19.2 in x 12.0 in
    tablet_x_scale = 1/27.625;
    tablet_x_offset = -1.1969*2540;
    tablet_y_scale = -1/27.625;
    tablet_y_offset = 11.724*2540;
    WinTabMex(2); %Empties the packet queue in preparation for collecting actual data
end

%------------------------
% LOAD IN IMAGES AND TGT FILE
%------------------------

cd([dir 'Images'])
[cursor_img, ~, cursor_alpha] = imread('cursor.png');
cursor_img(:,:,4) = cursor_alpha(:,:);
cursortext=Screen('MakeTexture', window, cursor_img);
cursor_r = 1.00 * mm2pixel; %1.75*mm2pixel;
resx = windowRect(3);
resy = windowRect(4);

% Load target file
cd([dir 'TargetFiles'])

if subj_ver == '0'
    tgt_file = dlmread(strcat('EXP1_V0_SUB', subject_num,'.tgt'), '\t', 1, 0); % start reading in from 2nd row (1), 1st column (0)
else
    tgt_file = dlmread(strcat('EXP1_V1_SUB', subject_num,'.tgt'), '\t', 1, 0); % start reading in from 2nd row (1), 1st column (0)
end

numtrials = size(tgt_file, 1);
trial_num = tgt_file(:,1);
tgt_dist = tgt_file(:,2).*mm2pixel;
discrim = tgt_file(:, 3);
discrim_onset = tgt_file(:, 4);
tgt_location = tgt_file(:,5);
discrim_dist = tgt_file(:,6);
stim_type =tgt_file(:,7);
discrim_tar = tgt_file(:,8);
rotation = tgt_file(:,9);
clamp = tgt_file(:, 10);
online_fb = tgt_file(:,11);
endpoint_fb = tgt_file(:,12);
between_blocks = tgt_file(:,13);
event_code = tgt_file(:,14);
calibrate_fin = tgt_file(:, 15); 

add_distract_tar = [15:30:345]';
maxtrialnum = max(numtrials);
hand_angle = nan(maxtrialnum,1);

% hit will be any part of cursor touching target
hit_tolerance = targetsize./2 + cursor_r;

%------------------------
% GAME LOOP
%------------------------
textureArray.placeholder = Screen('MakeTexture', window, imageArray.('discrim_0'));  % figure out how to pull out images in a sequence
% needto draw surface markers with place holders and dts. 

tic;
begintime = GetSecs;
nextsampletime = begintime;

% Loop game until over or ESC key press
while trial <= maxtrialnum   %
    % Exits experiment when ESC key is pressed.
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(esc)
            %             Screen('CloseAll')
            break
        end
    end
    
    k = k+1;    % just to stay consistent with Ryan's code
    t(k) = GetSecs - begintime;
    dt = toc-curtime;
    dt_all(k) = dt;
    
    if k == 1
        trial_time(k) = dt;
    else
        trial_time(k) = trial_time(k-1) + dt;
    end
    curtime = toc;
    
    % Flip to the screen
    % last argument - 1: synchronous screen flipping, 2:asynchronous screen flipping
    
    % draw textures to window
    Screen('DrawTexture',window,imageWindow(i),[],theseDims);
    Screen('Flip', window, 0, 0, 2);
    
    % Record trial number
    trial_move(k) = trial;
    rotation_move(k) = rotation(trial,1);
    
    % Read information from the tablet
    if InExpSystem
        pkt = WinTabMex(5); % reads the latest data point out of a tablet's event queue
        tablet_queue_length(k) = 0;
        while ~isempty(pkt) % makes sure data are in packet; once pkt is 'grabbed,' then rest of code executes
            tabletPoints(tab_k,1:2) = pkt(1:2)';    % placing x and y (pkt rows 1,2) into tabletPoints variable
            tabletTime(tab_k) = (pkt(6)-tabletTime(16))/1000;   % tab_k initialized to 15; giving a little buffer at start of game?
            tab_k = tab_k+1;    % now tab_k is just another iterating variable
            tablet_queue_length(k) = tablet_queue_length(k)+1;  % adding each loop through
            pkt = WinTabMex(5); % reads the latest data point out of a tablet's event queue
        end
        % HAND COORDINATES
        % x,y coordinates from WinTabMex pkt
        hX = (double(tabletPoints(tab_k-1,1))-tablet_x_offset)*tablet_x_scale;
        hY = (double(tabletPoints(tab_k-1,2))-tablet_y_offset)*tablet_y_scale;
    else
        tablet_queue_length(k) = 0;
        % HAND COORDINATES
        [hX, hY] = GetMouse(window);
    end
    
    thePoints(k,:) = [hX hY]; % record full precision points
    
    hand_dist = sqrt((hX-xCenter)^2 + (hY-yCenter)^2);
    
    % ROTATED CURSOR (including clamp)
    if clamp(trial,1) == 1  % check variable?
        % Clamped fb location:
        rcX = xCenter + hand_dist.*cosd(tgt_location(trial,1) + rotation(trial,1)); % may need to subtract rotation in order to make (+) clamp CCW
        rcY = yCenter - hand_dist.*sind(tgt_location(trial,1) + rotation(trial,1));
        
    else
        
        [rcX_rotated, rcY_rotated] = rotatexy(round(hX)-xCenter, (round(hY)-yCenter),rotation(trial,1),1);
        rcX = rcX_rotated + xCenter;
        rcY = rcY_rotated + yCenter;
    end
    
    tgtx = xCenter + tgt_dist(trial).* cosd(tgt_location(trial));
    tgty = yCenter - tgt_dist(trial).* sind(tgt_location(trial));
    tgtloc = [tgtx tgty];
    
%     if InExpSystem
%         display_markers('C:\Dropbox\VICE\JT\DEUBAL\Functions\pupil_middleman-master\surfaceMarkers', window, screenXpixels, screenYpixels, xCenter, yCenter)
%     else
%         display_markers('/Users/newxjy/Dropbox/VICE/JT/DEUBAL/Functions/pupil_middleman-master/surfaceMarkers', window, screenXpixels, screenYpixels, xCenter, yCenter)
%     end
%     
    if gamephase == -1 % creating textures 
        
        Screen('DrawTexture', window, textureArray.placeholder, [], windowRect)
        textureArray.discrimination = Screen('MakeTexture', window, imageArray.(mt_dist_dt( tgt_location(trial), discrim_dist(trial), stim_type(trial), 1))); 
        textureArray.arrowplaceholder = Screen('MakeTexture', window, imageArray.(mt_dist_dt( tgt_location(trial), discrim_dist(trial), stim_type(trial), 0))); 
        % draw placeholder
        gamephase = 0; 
        
    elseif gamephase == 0   % Searching for start location
        
%         if calibrate_fin(trial) == 0 % calibrate eye tracker
%             calibrate_fin(trial) = Pupil_Manual_Markers_Calibration(hUDP, xCenter, yCenter, screenXpixels, screenYpixels, window, InExpSystem);
%         end
        
        searchtime = searchtime + dt;
        SearchTimes(trial) = searchtime;
        %draw_target(window, xCenter, yCenter, tgt_dist(trial), add_distract_tar, discrim_tar(trial), 0, stim_type(trial))
        
        % get placeholder image 
        %Screen('FillRect', window, 0);
        %Screen(window, 'Flip');
        
        % Draw start position
        Screen('DrawTexture', window, textureArray.placeholder, [], windowRect)
        Screen('FrameOval', window, [1, 1, 1], [xCenter - startcirclewidth/2, yCenter - startcirclewidth/2, xCenter + startcirclewidth/2, yCenter + startcirclewidth/2], 2);
        
        if hand_dist < startcirclewidth/2
            % Hand inside % fill up start position
            Screen('DrawDots', window, [xCenter yCenter], startcirclewidth, [1 1 0], [], 2);
            visible = 1;
        elseif hand_dist < start_tolerance
            % Hand close to start position
            visible = 1;
        elseif hand_dist < searchring_tolerance && hand_dist >= startcirclewidth/2
            % Hand within search ring
            visible = 1;
            Screen('FrameOval', window, [1 1 1], [xCenter - hand_dist, yCenter - hand_dist, xCenter + hand_dist, yCenter + hand_dist], 1);
        else
            % Hand outside search ring
            visible = 0;
        end
        
        % calculate distance of cursor from start position
        if hand_dist < startcirclewidth/2
            %   Screen('DrawDots', window, [xCenter yCenter], startcirclewidth, white, [], 2);
            inside = 1;
            insidetime = insidetime + dt;
        else
            inside = 0;
            insidetime = 0;
        end
        
        % Starting to use idea of game phases to signify different phases of
        % the game. Similar to use of flags in Pygame scripts.
        if inside ==  1 && insidetime > wait_time
            
            gamephase = 0.5;
            insidetime = 0;
        end
        
    elseif gamephase == 0.5 % jitter start time
        
        fix_start = fix_start + dt;
        HideCursor;
        %draw_target(window, xCenter, yCenter, tgt_dist(trial), add_distract_tar, discrim_tar(trial), 0, stim_type(trial))
     
        % get placeholder image
        Screen('DrawTexture', window, textureArray.placeholder, [], windowRect)
        
        if fix_start < 1.2
            Screen('DrawDots', window, [xCenter yCenter], startcirclewidth, [1 1 0], [], 2);
            visible = 1;
        else
            gamephase = 1;
            visible = 0;
        end
        
    elseif gamephase == 1
        
        tgtstart = tgtstart + dt;
        visible = online_fb(trial);
       
        % start event 
        if discrim(trial) == 1 && start_event == 1
            % talk to pupil labs to start trial
%             fwrite(hUDP, int2str( event_code(trial) ));
%             event_code(trial)
            start_event = 0; 
        end
        
        if hand_dist >  rt_dist_thresh % comment if you want to increase radial distance before feedback disappears, 50 seems good
            mt = mt + dt;
            RTs(trial) = rt;
        else
            rt = rt + dt;
        end
        
        if  tgtstart > discrim_onset(trial) && tgtstart < (discrim_onset(trial) + discrim_duration) && discrim(trial) == 1
            %draw_target(window, xCenter, yCenter, tgt_dist(trial), add_distract_tar, discrim_tar(trial), 1, stim_type(trial))
            Screen('DrawTexture', window, textureArray.discrimination, [], windowRect)
        else
            %draw_target(window, xCenter, yCenter, tgt_dist(trial), add_distract_tar, discrim_tar(trial), 0, stim_type(trial))
            Screen('DrawTexture', window, textureArray.discrimination, [], windowRect)
        end
        
        if hand_dist >= tgt_dist(trial,1)
            
            fb_angle = atan2d(rcY-yCenter, rcX-xCenter);
            fb_x = tgt_dist(trial,1)*cosd(fb_angle) + xCenter;
            fb_y = tgt_dist(trial,1)*sind(fb_angle) + yCenter ;
            
            hand_angle(trial,1) = atan2d((hY-yCenter)*(-1), hX-xCenter);
            
            if RTs(trial) <= force_RT
                PsychPortAudio('Start', pasound3, 1, 0, 0); % the last input argument '0' instructs Matlab to execute code immediately
            elseif RTs(trial) > force_RT
                PsychPortAudio('Start', pasound2, 1, 0, 0);
            end
            
            gamephase = 2;
            
        end
        
    elseif gamephase == 2  % Endpoint Feedback

        fb_time = fb_time + dt;
        tgtstart = tgtstart + dt;
        
        visible = endpoint_fb(trial,1);

        if  tgtstart > discrim_onset(trial) && tgtstart < (discrim_onset(trial) + discrim_duration) && discrim(trial) == 1
            Screen('DrawTexture', window, textureArray.discrimination, [], windowRect)
        else
            Screen('DrawTexture', window, textureArray.arrowplaceholder, [], windowRect)
        end
        
        if discrim(trial) == 1 && end_event == 1 && fb_time > endptfbtime
            visible = 0;
            % talk to pupil labs to end trial
%             fwrite(hUDP, int2str( event_code(trial) ));
%             event_code(trial)
            end_event = 0; 
            gamephase = 3;
        elseif fb_time > endptfbtime
            visible = 0;
            problem_report{trial} = 'No_Discrim';
            gamephase = 4;
            
        end
        
        
    elseif gamephase == 3 % Report Time
        
        report_time = report_time + dt;
        
        Screen('DrawTexture', window, textureArray.placeholder, [], windowRect)
        
        visible = 0;
        
        [keyIsDown, secs, keyCode] = KbCheck;
        
        if keyIsDown == 1 & report_time <= 5
            PTs(trial) = report_time;
            char1 = KbName(keyCode);
            problem_report{trial} = char1;
            char1 = '';
            keyIsDown = 0;
            gamephase = 4;
        elseif report_time > 5
            problem_report{trial} = 'Late';
            gamephase = 4;
        else
        end
        
    elseif gamephase == 4  % Between Blocks Message
        
        trial_time(k) = 0;
        if between_blocks(trial) == 0
            Screen('DrawTexture', window, textureArray.placeholder, [], windowRect)
        end
        
        %------------------------
        % SAVE DATA
        %------------------------
        
        if mod(trial, 100) == 0
            cd([dir 'Data'])
            name_prefix_all = strcat('EXP1_V1_SUB', subject_num, '_DATA');
            disp('Saving...')
            datafile_name = [name_prefix_all,'.mat'];
            
            save(datafile_name);
            disp(['Saved ', datafile_name]);
            cd(dir)
            
        end
        
        
        if between_blocks(trial) ~= 0
            if between_blocks(trial) == 1
                Screen('DrawText', window, 'Continue to move AS QUICKLY and AS ACCURATELY to the target.' , xCenter-550, yCenter, white);
                
            elseif between_blocks(trial) == 2
                Screen('DrawText', window, 'Continue to move AS QUICKLY and AS ACCURATELY to the target.' , xCenter-550, yCenter, white);
                
            elseif between_blocks(trial) == 3
                Screen('DrawText', window, 'Continue to move AS QUICKLY and AS ACCURATELY to the target.' , xCenter-430, yCenter, white);
                Screen('DrawText', window, 'b [UP] d [DOWN] P [LEFT] q [RIGHT].' , xCenter-550, yCenter + 100, white);
            end
            
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(space)
                    gamephase = -1;
                    fb_time = 0;
                    searchtime = 0;
                    MTs(trial) = mt;
                    rt = 0;
                    mt = 0;
                    trial_time(k) = 0;
                    trial = trial + 1;
                    tgtstart = 0;
                    fix_start = 0;
                    discrim_start = 0;
                    report_time = 0;
                    start_event = 1; 
                    end_event = 1; 
                end
            end
            
        else
            gamephase = -1;
            fb_time = 0;
            searchtime = 0;
            MTs(trial) = mt;
            rt = 0;
            mt = 0;
            trial_time(k) = 0;
            trial = trial + 1;
            tgtstart = 0;
            fix_start = 0;
            discrim_start = 0;
            report_time = 0;
            start_event = 1; 
            end_event = 1; 
        end
    end
    
    if (visible)
        if (gamephase == 0 | gamephase == 0.5)
            cursor = [(hX - cursor_r) (hY - cursor_r) (hX + cursor_r) (hY + cursor_r)];
            cursorPoints(k,:) = [hX hY]; % record full precision points
            cursortext=Screen('MakeTexture', window, cursor_img);
            Screen('DrawTexture', window, cursortext, [], cursor, [], [], [],[1 1 1]);
        elseif (gamephase == 1)
            cursor = [(rcX - cursor_r) (rcY - cursor_r) (rcX + cursor_r) (rcY + cursor_r)];
            cursorPoints(k,:) = [hX hY]; % record full precision points
            Screen('DrawTexture', window, cursortext, [], cursor, [], [], [],[1 1 1]);
        elseif  (gamephase == 2 | gamephase == 3)
            cursor = [(fb_x - cursor_r) (fb_y - cursor_r) (fb_x + cursor_r) (fb_y + cursor_r)];
            cursorPoints(k,:) = [fb_x fb_y]; % record full precision points
            Screen('DrawTexture', window, cursortext, [], cursor, [], [], [],[1 1 1]);
        end
    else
        cursorPoints(k,:) = [NaN NaN];
    end
    
    gamephase_move(k) = gamephase;
    
    sampletime(k) = GetSecs;
    nextsampletime = nextsampletime + 1/desiredSampleRate;
    
    while GetSecs < nextsampletime
    end
    
end

endtime = GetSecs;
elapsedTime = endtime - begintime;
numberOfSamples = k;
actualSampleRate = 1/(elapsedTime / numberOfSamples);
thePoints(1:k,:);


ShowCursor;
% Clear the screen
sca;
if InExpSystem
    WinTabMex(3); % Stop/Pause data acquisition.
    WinTabMex(1); % Shutdown driver.
end
ListenChar(0);

% Stop playback:
PsychPortAudio('Stop', pasound1);
PsychPortAudio('Stop', pasound2);

% Close the audio device:
PsychPortAudio('Close')

% Game file
hand_angle = hand_angle;

% Movement file
trial_move = trial_move;
gamephase_move = gamephase_move;
t = t;
dt_all = dt_all;
rotation_move = rotation_move;
start_x_move = ones(k,1).*xCenter;
start_y_move = ones(k,1).*yCenter;
hand_x(:,1) = thePoints(:,1)-xCenter;
hand_y(:,1) = (thePoints(:,2)-yCenter)*(-1); % adjust for other monitor points
cursor_x(:,1) = cursorPoints(:,1) - xCenter;
cursor_y(:,1) = (cursorPoints(:,2) - yCenter)*(-1); % adjust for other monitor points

% clear sounds
clear ding tooslow aim_img

cd([dir 'Data'])
name_prefix_all = strcat('EXP1_V0_SUB', subject_num, '_DATA');
disp('Saving...')
datafile_name = [name_prefix_all,'.mat'];

save(datafile_name);
disp(['Saved ', datafile_name]);
cd(dir)




%------------------------
% HELPER FUNCTIONS
%------------------------

function [rx, ry] = rotatexy(x,y,phi,gain)
% phi is in degrees
phi=phi*pi/180;
[theta r]=cart2pol(x,y);
[rx ry]=pol2cart(theta-phi,gain*r);
return

return

return
