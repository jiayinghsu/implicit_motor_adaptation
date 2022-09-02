% Purpose: Make Target files
% 4 MTs x 3 DTs x 3 SOAs


clear; clc; close all

%% ---------------
% Baseline
% ----------------

exp_param = struct();
exp_param.sub = 8000; 
exp_param.ver = 0;

exp_param.namefile = ['EXP1_V', int2str(exp_param.ver), '_SUB', int2str(exp_param.sub ),'.tgt']; 
exp_param.rot_size = 30; % changed

exp_param.num_target = 4;
exp_param.target_dist = 60;

% dist is not actual distance but just 
% an index 

exp_param.discrim_dist = [-2, -1, 0, 1, 2]; % changed
exp_param.target_location = [45, 135, 225, 315]; % changed into 30, 120, 210, 300
exp_param.discrim_onset = [300, 400, 500] / 1000; % need 2 before movement and 2 after. 
exp_param.tgt_reps = 5;

%% ---------------
% ALL PERMUTATIONS
% ----------------

unique_conditions = CombVec(exp_param.discrim_onset, exp_param.target_location, exp_param.discrim_dist)';
con_size = length(unique_conditions);

%% ---------------
% REPETITIONS, PSEUDORANDOMIZED
% ----------------

all_trials = []; 

for ri = 1:exp_param.tgt_reps
    
    all_trials = [all_trials; unique_conditions(randperm(con_size), :)];
    
    
end

%% ---------------
% TRANSLATE DT DISTANCE -> DTs
% ----------------

exp_param.discrim_len = length(all_trials);

%% ---------------
% COUNTERBALANCE MOVEMENT TARGET 
% ----------------

discrim_trials = []; 
cycle_counter = 0; 

% for Discrim trials ? unique conditions for delay between MT and DT,
% MT (3) x DT dist (Number -1, 0, +1, +2) X SOA (consider randomizing)
% after you determine situations. multiply by number of trials. 20 trials
% per bin, but may be enough to have 15?

for i = 1:( exp_param.discrim_len / exp_param.num_target ) 
    
    cycle_counter = cycle_counter + 1; 
    
    rand_tgt = exp_param.target_location(randperm( exp_param.num_target ) ); 
    
    for m = 1 : exp_param.num_target
        
        row_list = find ( all_trials(:, 2) == rand_tgt(m) ); 
        row_list = row_list(randperm(length(row_list))); 
        
        discrim_trials( (cycle_counter - 1 ) * exp_param.num_target + m, :) = all_trials(row_list(1), :); 
        all_trials(row_list(1), :) = []; 
        
    end 
end

temporal=[];
for cir=1:length(discrim_trials)./20
    temporal=[temporal; Shuffle(repmat([1,2,3,4]',5,1))];
end
discrim_trials(:,4) =  temporal;
%% ---------------
% CREATE REACH CYCLES
% ----------------

nC_nFB = 10; % FB trials

nC_FB = 10; % no FB trials 

nC_Discrim = length(discrim_trials) / exp_param.num_target; 

nT_total = (nC_nFB + nC_FB + nC_Discrim) * exp_param.num_target; % Total number of trials


%% ---------------
% CREATE TRIAL INDEX
% ----------------

% index start, finish

Trial = struct();

Trial.nFB(1) = 1;
Trial.nFB(2) = nC_nFB * exp_param.num_target; % block 1

Trial.FB(1) = Trial.nFB(2) + 1;
Trial.FB(2) = Trial.nFB(2) + nC_FB * exp_param.num_target; % block 2

Trial.Discrim(1) = Trial.FB(2) + 1;
Trial.Discrim(2) = Trial.FB(2) + nC_Discrim * exp_param.num_target; % block 3

%% ---------------
% CREATE TARGET TABLE
% ----------------
header = {'trial_num','tgt_dist', 'discrim', 'discrim_onset', 'tgt_location',... 
    'discrim_dist', 'stim_type', 'discrim_tar', 'rotation', 'clamp', 'online_fb',... 
    'endpoint_fb', 'between_blocks', 'event_code', 'calibrate_fin'};

T = table();

T.trial_num = (1:nT_total)';

T.tgt_dist = ones(nT_total, 1) * exp_param.target_dist;

%Is it a discrim trial
T.discrim = zeros(nT_total, 1); T.discrim(Trial.Discrim(1):Trial.Discrim(2)) = 1;

% when pre discrimination beings
T.discrim_onset = zeros(nT_total, 1); T.discrim_onset(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 1);

% Movement target.
T.tgt_location = ones(nT_total, 1); T.tgt_location(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 2);

% short cut 
T.tgt_location(Trial.nFB(1):Trial.nFB(2)) = discrim_trials(Trial.nFB(1):Trial.nFB(2), 2);
T.tgt_location(Trial.FB(1):Trial.FB(2)) = discrim_trials(Trial.FB(1):Trial.FB(2), 2);

% index for which target is being discriminated
T.discrim_dist = zeros(nT_total, 1); T.discrim_dist(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 3);

% P, B, Q, B discrimination
T.stim_type = zeros(nT_total, 1); T.stim_type(Trial.Discrim(1):Trial.Discrim(2)) = discrim_trials(:, 4);

% Place holder for actual target to discriminate
T.discrim_tar = zeros(nT_total, 1);

% Place holder rotation angle
T.rotation = zeros(nT_total, 1);

% Is it a clamp trial: we are doing abrupt so yes ??
T.clamp = zeros(nT_total, 1);

% online Feedback
T.online_fb = ones(nT_total, 1); T.online_fb(Trial.nFB(1):Trial.nFB(2)) = 0;

% endpoint Feedback
T.endpoint_fb = ones(nT_total, 1); T.endpoint_fb(Trial.nFB(1):Trial.nFB(2)) = 0;

% Between block messages

T.between_blocks = zeros(nT_total, 1);

T.event_code = repmat(1:nT_total, 1)';

T.calibrate_fin = ones(nT_total, 1); T.calibrate_fin(1) = 0; T.calibrate_fin(81) = 0; T.calibrate_fin(191) = 0;


%% ---------------
% DETERMINE DISCRIM TARGET
% ----------------

for ti = Trial.Discrim(1):Trial.Discrim(2)
    
    switch T.tgt_location(ti)
        case 45
            switch T.discrim_dist(ti)
                case 0
                    T.discrim_tar(ti) = 45; 
                case -1
                    T.discrim_tar(ti) = 15; 
                case 1
                    T.discrim_tar(ti) = 75; 
                case -2
                    T.discrim_tar(ti) = 345; 
                case 2
                    T.discrim_tar(ti) = 105; 
            end
        case 135
            switch T.discrim_dist(ti)
                case 0
                     T.discrim_tar(ti) = 135; 
                case -1
                     T.discrim_tar(ti) = 105; 
                case 1
                     T.discrim_tar(ti) = 165; 
                case -2
                     T.discrim_tar(ti) = 75; 
                case 2
                     T.discrim_tar(ti) = 195; 
            end
        case 225
            switch T.discrim_dist(ti)
                case 0
                     T.discrim_tar(ti) = 225; 
                case -1
                     T.discrim_tar(ti) = 195; 
                case 1
                     T.discrim_tar(ti) = 255; 
                case -2
                     T.discrim_tar(ti) = 165; 
                case 2
                     T.discrim_tar(ti) = 285; 
            end
        case 315
            switch T.discrim_dist(ti)
                case 0
                     T.discrim_tar(ti) = 315; 
                case -1
                     T.discrim_tar(ti) = 285; 
                case 1
                     T.discrim_tar(ti) = 345; 
                case -2
                     T.discrim_tar(ti) = 255; 
                case 2
                     T.discrim_tar(ti) = 15; 
            end    
    end
end

%% ---------------
% SET BETWEEN BLOCK MESSAGES
% ----------------

T.between_blocks(Trial.nFB(2)) = 1;
T.between_blocks(Trial.FB(2)) = 2;
T.between_blocks(Trial.Discrim(2)) = 3; 


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
