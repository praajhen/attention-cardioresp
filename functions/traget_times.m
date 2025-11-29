function [target_start_time] = target_times(dataset_filename, i, erp_trials)
% TARGET_TIMES  Extract target onset sample indices from EDF annotation events
%
% This function reads EDF annotations (FieldTrip events), finds cue and target
% sequences for two task variants, and then matches target onsets to ERP trial
% start samples within a given threshold.
%
% Inputs:
%   dataset_filename : string, path to the dataset (EDF) file
%   i                : integer, task index (1 = left/first condition, else second)
%   erp_trials       : FieldTrip data structure containing 'sampleinfo'
%
% Output:
%   target_start_time: column vector of target onset sample indices, aligned
%                      to erp_trials.sampleinfo
%
% Author: praghajieeth raajhen santhana gopalan

% -------------------------------------------------------------------------
% Read all events from the dataset
% -------------------------------------------------------------------------
event = ft_read_event(dataset_filename);

% -------------------------------------------------------------------------
% Remove events where the 'value' field is empty
% (these can cause issues when matching trigger codes)
% -------------------------------------------------------------------------
emptyValueIndices = find(arrayfun(@(x) isempty(x.value), event));
event(emptyValueIndices) = [];

% -------------------------------------------------------------------------
% Extract cue and target onset times depending on task index i
%   Pattern (for each sequence of events):
%   - j+1: cue (e.g., '8Bit 11' or '8Bit 12')
%   - j+3: target (various '8Bit 2x' codes)
%   - j+5: end/confirmation trigger '8Bit 31'
% -------------------------------------------------------------------------
if i == 1
    % ----- Task 1: use 8Bit 11 as cue, 8Bit 21/22 as targets -----
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
    % ----- Task 2 (or any non-1): use 8Bit 12 as cue, 8Bit 23/24 as targets -----
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
% Match target onsets to ERP trial start samples
%   - 'a' = trial start samples from erp_trials.sampleinfo(:,1)
%   - 'b' = all detected target onset samples (t_start_time)
%   For each trial start in 'a', find the closest target in 'b'
%   within a maximum distance of 'threshold' samples.
% -------------------------------------------------------------------------

threshold = 220; % maximum allowable difference (in samples)

a = erp_trials.sampleinfo(:, 1);  % trial start samples
b = t_start_time;                 % target onset samples

target_start_time = []; % initialize the accepted vector

% NOTE: this loop reuses the variable name 'i' locally (as in original code)
for i = 1:length(a)
    for j = 1:length(b)
        difference = abs(a(i) - b(j));

        % Check if the difference meets the threshold
        if difference <= threshold
            % save the first matching target onset for this trial
            target_start_time(i) = b(j);
            break; % exit the loop for this value of 'a'
        else
            % Check the next values in 'b' for a valid match
            next_b_indices   = (j + 1):length(b);
            next_differences = abs(a(i) - b(next_b_indices));
            valid_indices    = next_b_indices(next_differences <= threshold);
            
            if ~isempty(valid_indices)
                % save the first valid target onset within threshold
                target_start_time(i) = b(valid_indices(1));
                break; % exit the loop for this value of 'a'
            end
        end
    end
end

% ensure output is a column vector
target_start_time = target_start_time';
