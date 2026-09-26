%% s12_phase_bin_rt
% Mean relative RT (% of participant mean) per respiration bin and cardiac
% bin for each ANT condition, plus alerting and conflict effects per bin,
% for the phase x condition x age group ANOVAs (run in SPSS).
% Input : <work_dir>/05_rt/rt_trials.csv, raw .edf (Resp, ecg), edges.mat
% Output: <work_dir>/05_rt/rt_phase_trials.csv, <work_dir>/05_rt/rt_phase_summary.csv

clear; clc;
C = ant_config();
load(C.cardiac.edges_file, 'edge');
T = readtable(fullfile(C.work_dir, '05_rt', 'rt_trials.csv'), 'TextType', 'char');

T.resp_bin    = nan(height(T), 1);
T.cardiac_bin = nan(height(T), 1);
for file_idx = 1:numel(C.files)
    dataset = fullfile(C.raw_dir, C.files(file_idx).name);
    [id, ~, excluded] = participant_info(C.files(file_idx), C);
    if excluded, continue; end
    r = strcmp(T.id, id);

    resp_phase = angle(hilbert(read_physio(dataset, 'Resp')));
    [~, rlocs] = findpeaks(read_physio(dataset, 'ecg'), ...
        'MinPeakProminence', C.rpeak.rt(1), 'MinPeakDistance', C.rpeak.rt(2));

    T.resp_bin(r)    = resp_phase_bins(resp_phase, T.target_sample(r), C.resp.edges);
    T.cardiac_bin(r) = cardiac_phase_bins(rlocs, T.target_sample(r), edge(file_idx, :));
end
writetable(T, fullfile(C.work_dir, '05_rt', 'rt_phase_trials.csv'));

% Per participant: mean relative RT per condition x bin, and effects per bin
cond_sel = @(T, cond) (strcmp(cond, 'NC')    & strcmp(T.cue, 'NC'))  | ...
                      (strcmp(cond, 'DC')    & strcmp(T.cue, 'DC'))  | ...
                      (strcmp(cond, 'CON')   & strcmp(T.flanker, 'CON')) | ...
                      (strcmp(cond, 'INCON') & strcmp(T.flanker, 'INCON'));
types  = {'resp_bin', 'cardiac_bin'};
labels = {C.resp.labels, C.cardiac.labels};

ids = unique(T.id, 'stable');
S = table();
for s = 1:numel(ids)
    r   = strcmp(T.id, ids{s});
    row = table(ids(s), T.group(find(r, 1)), 'VariableNames', {'id', 'group'});
    for p = 1:numel(types)
        for b = 1:numel(labels{p})
            inbin = r & T.(types{p}) == b;
            m = struct();
            for c = 1:numel(C.conditions)
                cond = C.conditions{c};
                m.(cond) = mean(T.rel_rt(inbin & cond_sel(T, cond)));
                row.(sprintf('rel_%s_%s', cond, labels{p}{b})) = m.(cond);
            end
            raw_nc = mean(T.rt_ms(inbin & cond_sel(T, 'NC')));
            raw_dc = mean(T.rt_ms(inbin & cond_sel(T, 'DC')));
            raw_in = mean(T.rt_ms(inbin & cond_sel(T, 'INCON')));
            raw_co = mean(T.rt_ms(inbin & cond_sel(T, 'CON')));
            row.(sprintf('alerting_pct_%s', labels{p}{b})) = (raw_nc - raw_dc) / raw_nc * 100;
            row.(sprintf('conflict_pct_%s', labels{p}{b})) = (raw_in - raw_co) / raw_co * 100;
        end
    end
    S = [S; row]; %#ok<AGROW>
end
writetable(S, fullfile(C.work_dir, '05_rt', 'rt_phase_summary.csv'));
