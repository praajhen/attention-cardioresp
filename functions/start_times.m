function [cue_start_time, target_start_time] = start_times(dataset_filename, i, erp_trials)
% START_TIMES  Get cue and target onset sample indices aligned to ERP trials
%
% This function:
%   1) Reads EDF events (FieldTrip format).
%   2) Finds cue and target events for two task variants (i == 1 or not).
%   3) Matches:
%        - cue onsets to ERP trial start samples
%        - target onsets to those cue onsets
%      within given sample thresholds.
%
% Inputs:
%   dataset_filename : string, path to the dataset (EDF) file
%   i                : integer, task index (1 = first task, else second task)
%   erp_trials       : FieldTrip data structure with field 'sampleinfo'
%
% Outputs:
%   cue_start_time    : column vector of cue onset samples aligned to trials
%   target_start_time : column vector of target onset samples aligned to cues
%
% Author: praghajieeth raajhen santhana gopalan

% -------------------------------------------------------------------------
% Read all events from the dataset
% -------------------------------------------------------------------------
event = ft_read_event(dataset_filename);

% -------------------------------------------------------------------------
% Remove events where the 'value' field is empty
% (these can be non-annotation entries that we don't want to process)
% -------------------------------------------------------------------------
emptyValueIndices = find(arrayfun(@(x) isempty(x.value), event));
event(emptyValueIndices) = [];

% -------------------------------------------------------------------------
% Extract cue and target sample indices based on task index i
%
% Pattern in events for each valid trial sequence:
%   j+1 : cue   (e.g., '8Bit 11' or '8Bit 12')
%   j+3 : target (e.g., '8Bit 21/22' or '8Bit 23/24')
%   j+5 : end/confirmation '8Bit 31'
% -------------------------------------------------------------------------
if i == 1
    % ----- Task 1:  cue = 8Bit 11, targets = 8Bit 21 or 8Bit 22 -----
    idx = 1; 
    c_start_time = []; 
    t_start_time = [];
    
    for j = 1:numel(event)-5
        if strcmp(event(j+1).value, '8Bit 11') && ...
           (strcmp(event(j+3).value, '8Bit 21') || strcmp(event(j+3).value, '8Bit 22')) && ...
            strcmp(event(j+5).value, '8Bit 31')
        
            % store cue and target onset sample indices
            c_start_time(idx,1) = event(j+1).sample;
            t_start_time(idx,1) = event(j+3).sample;
            idx = idx + 1;
        end
    end

else
    % ----- Task 2 (or any non-1): cue = 8Bit 12, targets = 8Bit 23 or 8Bit 24 -----
    idx = 1;
    c_start_time = []; 
    t_start_time = [];
    
    for j = 1:numel(event)-5
        if strcmp(event(j+1).value, '8Bit 12') && ...
           (strcmp(event(j+3).value, '8Bit 23') || strcmp(event(j+3).value, '8Bit 24')) && ...
            strcmp(event(j+5).value, '8Bit 31')
        
            % store cue and target onset sample indices
            c_start_time(idx,1) = event(j+1).sample;
            t_start_time(idx,1) = event(j+3).sample;
            idx = idx + 1;
        end
    end

end

% -------------------------------------------------------------------------
% STEP 1: Match cue onsets to ERP trial start samples
%   a = trial start samples from erp_trials.sampleinfo(:,1)
%   b = all cue onset samples (c_start_time)
%   For each trial start in 'a', find the first cue in 'b' within threshold.
% -------------------------------------------------------------------------
a = erp_trials.sampleinfo(:, 1);  % trial start samples
b = c_start_time;                 % cue onset samples

threshold = 250; % maximum allowable difference (in samples) for cue alignment

cue_start_time = []; % will hold one cue onset per trial

% NOTE: loop reuses variable name 'i' locally (kept as in your original code)
for i = 1:length(a)
    for j = 1:length(b)
        difference = abs(a(i) - b(j));

        % Check if the difference meets the threshold
        if difference <= threshold
            cue_start_time(i) = b(j); % save the cue sample closest to this trial
            break; % exit the loop for this trial
        else
            % Check the next values in 'b' for a valid match
            next_b_indices   = (j + 1):length(b);
            next_differences = abs(a(i) - b(next_b_indices));
            valid_indices    = next_b_indices(next_differences <= threshold);
            
            if ~isempty(valid_indices)
                cue_start_time(i) = b(valid_indices(1)); % first acceptable cue
                break; % exit the loop for this trial
            end
        end
    end
end

% -------------------------------------------------------------------------
% STEP 2: Match target onsets to the aligned cue onsets
%   a = cue_start_time (aligned to trials above)
%   b = all target onset samples (t_start_time)
%   For each cue in 'a', find the first target in 'b' within threshold.
% -------------------------------------------------------------------------
threshold = 520; % maximum allowable difference (in samples) for target alignment

a = cue_start_time; % cue onsets aligned to ERP trials
b = t_start_time;   % all target onsets

target_start_time = []; % will hold one target onset per trial

for i = 1:length(a)
    for j = 1:length(b)
        difference = abs(a(i) - b(j));

        % Check if the difference meets the threshold
        if difference <= threshold
            target_start_time(i) = b(j); % save matching target sample
            break; % exit the loop for this cue
        else
            % Check the next values in 'b' for a valid match
            next_b_indices   = (j + 1):length(b);
            next_differences = abs(a(i) - b(next_b_indices));
            valid_indices    = next_b_indices(next_differences <= threshold);
            
            if ~isempty(valid_indices)
                target_start_time(i) = b(valid_indices(1)); % first acceptable target
                break; % exit the loop for this cue
            end
        end
    end
end

% -------------------------------------------------------------------------
% Ensure outputs are column vectors
% -------------------------------------------------------------------------
cue_start_time    = cue_start_time';
target_start_time = target_start_time';
``
