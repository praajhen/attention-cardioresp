function [target_start_time] = target_times(dataset_filename, cond, erp_trials)
% target_times
% Extract target onset times aligned to ERP trials
%
% cond:
% 1 = no cue
% 2 = double cue
%
% Author: praghajieeth raajhen santhana gopalan

%% ================= READ EVENTS =================
event = ft_read_event(dataset_filename);

event(arrayfun(@(x) isempty(x.value), event)) = [];

%% ================= EXTRACT TARGET EVENTS =================
target_samples = [];

idx = 1;

for j = 1:numel(event)-5

trg1 = event(j+1).value;
trg2 = event(j+3).value;
trg3 = event(j+5).value;

switch cond

    case 1
        cond_ok = strcmp(trg1,'8Bit 11') && ...
                 (strcmp(trg2,'8Bit 21') || strcmp(trg2,'8Bit 22')) && ...
                  strcmp(trg3,'8Bit 31');

    otherwise
        cond_ok = strcmp(trg1,'8Bit 12') && ...
                 (strcmp(trg2,'8Bit 23') || strcmp(trg2,'8Bit 24')) && ...
                  strcmp(trg3,'8Bit 31');

end

if cond_ok
target_samples(idx,1) = event(j+3).sample;
idx = idx + 1;
end

end

%% ================= MATCH TO ERP TRIALS =================
trial_starts = erp_trials.sampleinfo(:,1);

threshold = 220;

target_start_time = zeros(length(trial_starts),1);

for t = 1:length(trial_starts)

diffs = abs(target_samples - trial_starts(t));
valid = find(diffs <= threshold,1,'first');

if ~isempty(valid)
target_start_time(t) = target_samples(valid);
end

end