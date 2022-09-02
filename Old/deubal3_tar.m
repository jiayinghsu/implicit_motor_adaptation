% Author: Jonathan Tsay
% Purpose: Make Target files
% 2 SOA x 4 Targets (spaced 30 deg apart) x 2 conditions (reach / covert)
% 1680 trials total (60 / 40 valid invalid split)


clear; clc; close all

%% ---------------
% COVERT / VERIDICAL / GRADUAL / ABRUPT
% ----------------

exp_param = struct();
exp_param.sub = 5; 
exp_param.type = 'exp1';
exp_param.ver = 2; % version 1 is covert first then reach. version 2 is reach then covert
exp_param.rotation = 'none'; % if covert block then this does not matter

exp_param.namefile = ['EXP1_V', int2str(exp_param.ver), '_SUB', int2str(exp_param.sub ),'.tgt']; % 3rd pilot, covert, no rotation
exp_param.rot_size = 0;

exp_param.num_target = 4;
exp_param.target_dist = 60;

% dist is not actual distance but just 
% an index 

exp_param.discrim_dist = [0, 1, 2, 3];
exp_param.target_location = [45, 75, 105, 135];
exp_param.discrim_onset = [250, 300] / 1000;
exp_param.tgt_reps = [150, 20, 20, 20]

%% ---------------
% ALL PERMUTATIONS
% ----------------

% each one corresponds to each DT location
% every field corresponds to one distance 

dist_trials = struct();

% make container to divide all trials into two equal halves.
first_half = [];

for m = 1:length(exp_param.tgt_reps) % just take half the trials
    
    dist_trials.(char(96 + m)) = repmat(CombVec(exp_param.discrim_onset, exp_param.target_location, exp_param.discrim_dist(m))', [exp_param.tgt_reps(m), 1]); % zero distance
    
    half_len = length(dist_trials.(char(96 + m))) / 2; % row length
    
    first_half = [first_half; dist_trials.(char(96 + m))(1: half_len , :) ];
end

dist_trials

%% ---------------
% MAKE SAME NUM OF DT STIMULI
% ----------------

first_half = [first_half, repmat(1:4, 1, length (first_half) / 4)'];

%% ---------------
% RANDOMIZE SEQUENCE
% ----------------

exp_param.half_discrim_len = length(first_half);
first_half = first_half(randperm(exp_param.half_discrim_len), :);

%% ---------------
% COUNTERBALANCE MOVEMENT TARGET 
% ----------------

discrim_trials = []; 
cycle_counter = 0; 

% for Discrim trials

for i = 1: ( exp_param.half_discrim_len / exp_param.num_target ) 
    
    cycle_counter = cycle_counter + 1; 
    
    rand_tgt = exp_param.target_location(randperm( exp_param.num_target ) ); 
    
    for m = 1 : exp_param.num_target
        
        row_list = find ( first_half(:, 2) == rand_tgt(m) ); 
        row_list = row_list(randperm(length(row_list))); 
        
        discrim_trials( (cycle_counter - 1 ) * exp_param.num_target + m, :) = first_half(row_list(1), :); 
        first_half(row_list(1), :) = []; 
        
    end 
end

%% ---------------
% DUPLICATE
% ----------------

discrim_trials = [discrim_trials; discrim_trials]

%% ---------------
% CREATE REACH CYCLES
% ----------------

nC_FB = 5; % practice reaching

nC_Discrim = length(discrim_trials) / exp_param.num_target;

nT_total = (nC_FB + nC_Discrim) * exp_param.num_target;

%% ---------------
% CREATE TRIAL INDEX
% ----------------

% index start, finish

Trial = struct();

Trial.FB(1) = 1;
Trial.FB(2) = nC_FB * exp_param.num_target;

Trial.Discrim(1) = 1 + Trial.FB(2);
Trial.Discrim(2) = Trial.FB(2) + nC_Discrim * exp_param.num_target;

%% ---------------
% CREATE TARGET TABLE
% ----------------

T = table();

T.trialnum = (1:nT_total)';

T.tgt_dist = ones(nT_total, 1) * exp_param.target_dist;

% is it a discrim trial
T.discrim = zeros(nT_total, 1); T.discrim(Trial.Discrim(1):Trial.Discrim(2)) = 1;

% is it a covert trial
T.covert = zeros(nT_total, 1);

% counterbalanced
switch exp_param.ver
    case 1
        T.covert(Trial.Discrim(1):Trial.Discrim(1) + exp_param.half_discrim_len - 1) = 1;
    case 2
        T.covert(Trial.Discrim(1) + exp_param.half_discrim_len:Trial.Discrim(2)) = 1;
end

% when discrimination beings
T.discrim_onset = zeros(nT_total, 1); T.discrim_onset(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 1);

% Movement target.
T.tgt_location = ones(nT_total, 1); T.tgt_location(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 2);
% short cut 
T.tgt_location(Trial.FB(1):Trial.FB(2)) = discrim_trials(Trial.FB(1):Trial.FB(2), 2);

% index for which target is being discriminated
T.discrim_dist = zeros(nT_total, 1); T.discrim_dist(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 3);

% P, B, Q, B discrimination
T.stim_type = zeros(nT_total, 1); T.stim_type(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 4);

% Place holder for actual target to discriminate
T.discrim_tar = zeros(nT_total, 1);

% Place holder rotation angle
T.rotation = zeros(nT_total, 1);

% It it a clamp trial: we are doing gradual rotation so no
T.clamp = zeros(nT_total, 1);

% online Feedback
T.online_fb = ones(nT_total, 1);

% endpoint Feedback
T.endpoint_fb = ones(nT_total, 1);

% Between block messages

T.between_blocks = zeros(nT_total, 1);

T.calibrate_eye = zeros(nT_total, 1);

raw_events = repmat(1:250, 1, 8)';

T.event_code = raw_events(1:nT_total, 1);

header = {'trialnum','tgt_distance', 'discrim', 'covert', 'discrim_onset', 'tgt_location', ...
    'discrim_dist', 'stim_type', 'discrim_tar', 'rotation', 'clamp', 'online_fb', 'endpoint_fb',...
    'between_block', 'calibrate_eye', 'event_code'};


%% ---------------
% FILL IN ROTATION SIZES
% ----------------

switch exp_param.type
    case 'covert'
        T.rotation(1:end) = 0;
    case 'veridical'
        T.rotation(1:end) = 0;
    case 'gradual'
        
        increment = exp_param.rot_size / (nC_Rot - 10);
        tot_increments = 0:increment:exp_param.rot_size;
        
        for m = 1:nC_Rot
            
            T.rotation(Trial.Rot(1) - 1 + m) = tot_increments(m);
        end
        
        T.rotation(Trial.Discrim(1):Trial.Discrim(2)) = exp_param.rot_size;
        
    case 'abrupt'
        T.rotation(Trial.Rot(1):Trial.Discrim(2)) = exp_param.rot_size;
end


%% ---------------
% DETERMINE DISCRIM TARGET
% ----------------

for ti = Trial.Discrim(1):Trial.Discrim(2)
    
    switch T.tgt_location(ti)
        case 45
            switch T.discrim_dist(ti)
                case 0
                    T.discrim_tar(ti) = 45; 
                case 1
                    T.discrim_tar(ti) = 75; 
                case 2
                    T.discrim_tar(ti) = 105; 
                case 3
                    T.discrim_tar(ti) = 135; 
            end
        case 75
            switch T.discrim_dist(ti)
                case 0
                     T.discrim_tar(ti) = 75; 
                case 1
                     T.discrim_tar(ti) = 45; 
                case 2
                     T.discrim_tar(ti) = 135; 
                case 3
                    T.discrim_tar(ti) =  105; 
            end
        case 105
            switch T.discrim_dist(ti)
                case 0
                     T.discrim_tar(ti) = 105; 
                case 1
                     T.discrim_tar(ti) = 75; 
                case 2
                     T.discrim_tar(ti) = 45; 
                case 3
                     T.discrim_tar(ti) = 135; 
            end
        case 135
            switch T.discrim_dist(ti)
                case 0
                     T.discrim_tar(ti) = 135; 
                case 1
                     T.discrim_tar(ti) = 105; 
                case 2
                     T.discrim_tar(ti) = 75; 
                case 3
                     T.discrim_tar(ti) = 45; 
            end
            
            
    end
end


%% ---------------
% SET BETWEEN BLOCK MESSAGES
% ----------------

T.between_blocks(Trial.FB(2)) = 1; % Begin discrimination
T.between_blocks(Trial.Discrim(1) + exp_param.half_discrim_len - 1 ) = 2; % Switch Reach or Covert
T.between_blocks(Trial.Discrim(2)) = 3; % Experiments over

%% ---------------
% SET WHEN TO RE-DO EYE CALIBRATION
% ----------------

T.calibrate_eye(1:250:Trial.Discrim(2)) = 1;

%% ---------------
% SAVE TARGET FILE
% ----------------

% dummy = table2dataset(T);
dummy = table2array(T);
set = double(dummy);
%If you ever need strings in here use this way

set(:,1) = 1:size(set,1);
%Add in last Betweenblocks
%set(end,15) = 1;
%Variables header file

%If you ever need strings in here use this way
fid = fopen(exp_param.namefile,'wt');
[rows,cols] = size(set);
fprintf(fid,'%s\t',header{:});
for i = 1:rows
    fprintf(fid,'\n');
    for j = 1:cols
        fprintf(fid,'%3.2f\t',set(i,j));
    end
end
fclose(fid);
