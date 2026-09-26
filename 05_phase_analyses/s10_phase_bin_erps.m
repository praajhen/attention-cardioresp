%% s10_phase_bin_erps
% Sorts accepted trials by respiration phase (2 bins) and cardiac phase
% (3 bins) at target onset, and computes per-participant ERPs per bin and
% condition. Also computes the difference waves used for the between-group
% cluster tests in BESA Statistics:
%   respiration: inspiration - expiration
%   cardiac    : late diastole - systole
% Input : <work_dir>/04_epochs/<cond>/<id>.mat, raw .edf (Resp, ecg), edges.mat
% Output: <work_dir>/06_phase_erp/<resp|cardiac>/<cond>/<id>.mat
%         (erp_bin{1..nbins}, erp_diff, n_trials)
%         <work_dir>/06_phase_erp/phase_trial_counts.csv

clear; clc;
C = ant_config();
load(C.cardiac.edges_file, 'edge');

counts = {};
for file_idx = 1:numel(C.files)
    dataset = fullfile(C.raw_dir, C.files(file_idx).name);
    [id, ~, excluded] = participant_info(C.files(file_idx), C);
    if excluded, continue; end

    resp_phase = angle(hilbert(read_physio(dataset, 'Resp')));
    [~, rlocs] = findpeaks(read_physio(dataset, 'ecg'), ...
        'MinPeakProminence', C.rpeak.erp(1), 'MinPeakDistance', C.rpeak.erp(2));

    for c = 1:numel(C.conditions)
        cond = C.conditions{c};
        load(fullfile(C.work_dir, '04_epochs', cond, [id '.mat']), 'erp_trials');
        target = erp_trials.trialinfo(:, 1);

        bins.resp    = resp_phase_bins(resp_phase, target, C.resp.edges);
        bins.cardiac = cardiac_phase_bins(rlocs, target, edge(file_idx, :));

        % Respiration
        [erp_bin, n_trials] = bin_erps(erp_trials, bins.resp, 2);
        i_in  = strcmp(C.resp.labels, 'inspiration');
        i_ex  = strcmp(C.resp.labels, 'expiration');
        erp_diff = difference(erp_bin{i_in}, erp_bin{i_ex});
        save_bins(fullfile(C.work_dir, '06_phase_erp', 'resp', cond), id, erp_bin, erp_diff, n_trials);
        counts = [counts; row(id, cond, 'resp', C.resp.labels, n_trials)]; %#ok<AGROW>

        % Cardiac
        [erp_bin, n_trials] = bin_erps(erp_trials, bins.cardiac, 3);
        erp_diff = difference(erp_bin{3}, erp_bin{1}); % late diastole - systole
        save_bins(fullfile(C.work_dir, '06_phase_erp', 'cardiac', cond), id, erp_bin, erp_diff, n_trials);
        counts = [counts; row(id, cond, 'cardiac', C.cardiac.labels, n_trials)]; %#ok<AGROW>
    end
end

T = cell2table(counts, 'VariableNames', {'id', 'condition', 'phase_type', 'bin', 'n_trials'});
writetable(T, fullfile(C.work_dir, '06_phase_erp', 'phase_trial_counts.csv'));

%% Local functions
function [erp_bin, n] = bin_erps(data, bin, nbins)
erp_bin = cell(1, nbins);
n       = zeros(1, nbins);
for b = 1:nbins
    cfg        = [];
    cfg.trials = find(bin == b);
    n(b)       = numel(cfg.trials);
    if n(b) > 0
        erp_bin{b} = ft_timelockanalysis(cfg, data);
    end
end
end

function d = difference(a, b)
cfg           = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
d = ft_math(cfg, a, b);
end

function save_bins(folder, id, erp_bin, erp_diff, n_trials)
if ~exist(folder, 'dir'), mkdir(folder); end
save(fullfile(folder, [id '.mat']), 'erp_bin', 'erp_diff', 'n_trials', '-v7.3');
end

function r = row(id, cond, type, labels, n)
r = [repmat({id, cond, type}, numel(n), 1), labels(:), num2cell(n(:))];
end
