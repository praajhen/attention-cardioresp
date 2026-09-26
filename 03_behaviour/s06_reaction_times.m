%% s06_reaction_times
% Reaction time (target onset to correct button press) for every correct
% trial, plus per-participant summaries used in SPSS:
%   - mean raw RT per condition and per cue x flanker cell
%   - relative RT (% of the participant's mean RT over all correct trials)
%   - alerting effect (%) = (NC - DC) / NC * 100
%   - conflict effect (%) = (INCON - CON) / CON * 100
% Incorrect and missed responses are excluded.
% Input : raw .edf (events)
% Output: <work_dir>/05_rt/rt_trials.csv, <work_dir>/05_rt/rt_summary.csv

clear; clc;
C = ant_config();

target_codes = {'8Bit 21', '8Bit 22', '8Bit 23', '8Bit 24'};
cells        = {'NC_CON', 'NC_INCON', 'DC_CON', 'DC_INCON'}; % codes 21-24
keep_codes   = [target_codes, {'8Bit 31', '8Bit 32', '8Bit 33'}];

trials = {};
for file_idx = 1:numel(C.files)
    dataset = fullfile(C.raw_dir, C.files(file_idx).name);
    [id, group, excluded] = participant_info(C.files(file_idx), C);
    if excluded, continue; end

    hdr = ft_read_header(dataset);
    ev  = ft_read_event(dataset);
    ev(arrayfun(@(x) isempty(x.value), ev)) = [];
    ev  = ev(ismember({ev.value}, keep_codes));

    % A correct response (31) directly after a target gives one RT
    for i = 2:numel(ev)
        k = find(strcmp(ev(i-1).value, target_codes));
        if strcmp(ev(i).value, '8Bit 31') && ~isempty(k)
            rt = (ev(i).sample - ev(i-1).sample) / hdr.Fs * 1000;
            trials(end+1, :) = {id, group, cells{k}, ev(i-1).sample, rt}; %#ok<SAGROW>
        end
    end
end

T = cell2table(trials, 'VariableNames', {'id', 'group', 'cell', 'target_sample', 'rt_ms'});
T.cue      = extractBefore(T.cell, '_');
T.flanker  = extractAfter(T.cell, '_'); % CON / INCON
T.rel_rt   = nan(height(T), 1);
ids = unique(T.id, 'stable');
for s = 1:numel(ids)
    r = strcmp(T.id, ids{s});
    T.rel_rt(r) = T.rt_ms(r) / mean(T.rt_ms(r)) * 100;
end

out_dir = fullfile(C.work_dir, '05_rt');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
writetable(T, fullfile(out_dir, 'rt_trials.csv'));

% Per-participant summary
S = table();
for s = 1:numel(ids)
    r   = strcmp(T.id, ids{s});
    row = table(ids(s), T.group(find(r, 1)), 'VariableNames', {'id', 'group'});
    sel = struct('NC', r & strcmp(T.cue, 'NC'), 'DC', r & strcmp(T.cue, 'DC'), ...
                 'CON', r & strcmp(T.flanker, 'CON'), 'INCON', r & strcmp(T.flanker, 'INCON'));
    for c = 1:numel(C.conditions)
        cond = C.conditions{c};
        row.(['rt_' cond])  = mean(T.rt_ms(sel.(cond)));
        row.(['rel_' cond]) = mean(T.rel_rt(sel.(cond)));
    end
    for k = 1:numel(cells)
        row.(['rt_' cells{k}])  = mean(T.rt_ms(r & strcmp(T.cell, cells{k})));
        row.(['rel_' cells{k}]) = mean(T.rel_rt(r & strcmp(T.cell, cells{k})));
    end
    row.alerting_pct = (row.rt_NC - row.rt_DC) / row.rt_NC * 100;
    row.conflict_pct = (row.rt_INCON - row.rt_CON) / row.rt_CON * 100;
    S = [S; row]; %#ok<AGROW>
end
writetable(S, fullfile(out_dir, 'rt_summary.csv'));
