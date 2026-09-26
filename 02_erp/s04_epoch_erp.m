%% s04_epoch_erp
% Epoching, baseline correction, artifact rejection, average re-reference
% and per-participant ERPs for the four ANT conditions (NC, DC, CON, INCON).
% Only correctly answered trials are epoched (see ant_trialfun).
% Input : raw .edf (events), <work_dir>/03_filtered/<id>.mat
% Output: <work_dir>/04_epochs/<cond>/<id>.mat (erp_trials; trialinfo = target sample)
%         <work_dir>/04_erp/<cond>/<id>.mat    (erp, ft_timelockanalysis)
%         <work_dir>/04_trial_counts.csv

clear; clc;
C = ant_config();

counts = {};
for file_idx = 1:numel(C.files)
    dataset = fullfile(C.raw_dir, C.files(file_idx).name);
    id      = participant_info(C.files(file_idx), C);
    load(fullfile(C.work_dir, '03_filtered', [id '.mat']), 'data_filtered');

    for c = 1:numel(C.conditions)
        cond = C.conditions{c};

        % Define cue-locked epochs (-0.2 to 1.0 s from cue)
        cfg           = [];
        cfg.dataset   = dataset;
        cfg.trialfun  = 'ant_trialfun';
        cfg.condition = cond;
        cfg           = ft_definetrial(cfg);

        cfgr     = [];
        cfgr.trl = cfg.trl;
        data     = ft_redefinetrial(cfgr, data_filtered);

        % Baseline: 200 ms before (possible) cue
        cfgb                = [];
        cfgb.demean         = 'yes';
        cfgb.baselinewindow = [-0.2 0];
        erp_trials          = ft_preprocessing(cfgb, data);
        n_before            = numel(erp_trials.trial);

        % Peak-to-peak rejection
        keep       = reject_trials_amplitude(erp_trials, C.reject);
        cfgs       = [];
        cfgs.trials = find(keep);
        erp_trials = ft_selectdata(cfgs, erp_trials);

        % Average reference
        cfgr            = [];
        cfgr.reref      = 'yes';
        cfgr.refmethod  = 'avg';
        cfgr.refchannel = 'all';
        erp_trials      = ft_preprocessing(cfgr, erp_trials);

        erp = ft_timelockanalysis([], erp_trials);

        save_to(fullfile(C.work_dir, '04_epochs', cond), id, 'erp_trials', erp_trials);
        save_to(fullfile(C.work_dir, '04_erp', cond), id, 'erp', erp);

        counts(end+1, :) = {id, cond, n_before, numel(erp_trials.trial)}; %#ok<SAGROW>
    end
end

T = cell2table(counts, 'VariableNames', {'id', 'condition', 'n_epochs', 'n_accepted'});
writetable(T, fullfile(C.work_dir, '04_trial_counts.csv'));

function save_to(folder, id, name, value)
if ~exist(folder, 'dir'), mkdir(folder); end
S.(name) = value; %#ok<STRNU>
save(fullfile(folder, [id '.mat']), '-struct', 'S', '-v7.3');
end
