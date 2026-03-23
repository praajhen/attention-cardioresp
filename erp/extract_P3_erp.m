%% run_erp_pipeline.m
% ERP extraction and trial segmentation script
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ------------------------------------------------------------------------
%  ADD REQUIRED PATHS (replace with your own paths when running)
% -------------------------------------------------------------------------
addpath('PATH_TO_YOUR_CODE_FOLDER');          % e.g., ...\Matlab code
addpath('PATH_TO_FIELDTRIP_FOLDER');          % e.g., ...\fieldtrip
ft_defaults;

%% ------------------------------------------------------------------------
%  DEFINE DATA FOLDERS (user must fill in)
% -------------------------------------------------------------------------
data_folder     = 'PATH_TO_RAW_DATA_FOLDER';      % contains *.edf files
filtered_folder = 'PATH_TO_FILTERED_DATA_FOLDER'; % contains filtered *.mat files

dataset_files   = dir(fullfile(data_folder, '*.edf'));
filtered_files  = dir(fullfile(filtered_folder, '*.mat'));

%% ------------------------------------------------------------------------
% Loop through subjects
% -------------------------------------------------------------------------
for file_idx = 1:50

    dataset_filename  = fullfile(data_folder, dataset_files(file_idx).name);
    filtered_filename = fullfile(filtered_folder, filtered_files(file_idx).name);

    load(filtered_filename); % loads data_filtered

    cd('PATH_TO_TRIAL_FUNCTION_FOLDER'); % folder where erp_1500ms.m exists

    %% Loop through conditions 3–4 (congruent / incongruent)
    for i = 3:4

        %% ---------------- Define trials ----------------
        cfg = [];
        cfg.dataset = dataset_filename;
        cfg.nr      = i;  % 3 = congruent, 4 = incongruent
        cfg.trialfun = 'erp_1500ms';
        cfg.trialdef.eventtype = 'annotation';

        % Use channels 1–128
        cfg.channel = arrayfun(@num2str, 1:128, 'UniformOutput', false);

        cfg.baselinewindow = [-0.2 0];
        cfg.demean = 'yes';

        cfg = ft_definetrial(cfg);
        data = ft_redefinetrial(cfg, data_filtered);
        erp  = ft_preprocessing(cfg, data);

        trial_no_b4(file_idx) = length(erp.trial);

        %% ---------------- Amplitude thresholding ----------------
        numTrials = length(erp.trial);
        difftrial = cell(1, numTrials);
        btrial    = cell(1, numTrials);
        clean_trials = [];
        reject_trial = false(1, numTrials);

        threshold_low  = 175;
        threshold_high = 300;
        max_zero_columns = 25;

        for tr = 1:numTrials
            difftrial{tr} = max(erp.trial{tr}(:, 150:end), [], 2) - ...
                            min(erp.trial{tr}(:, 150:end), [], 2);
        end

        for tr = 1:numTrials
            if any(difftrial{tr} > threshold_high)
                reject_trial(tr) = true;
            else
                btrial{tr} = difftrial{tr} <= threshold_low;
                zeroCount = sum(btrial{tr} == 0);
                reject_trial(tr) = (zeroCount > max_zero_columns);
            end
        end

        clean_trials = find(~reject_trial);
        trial_no_after(file_idx) = length(clean_trials);

        erp.sampleinfo = erp.sampleinfo(clean_trials, :);
        erp.trial      = erp.trial(:, clean_trials);
        erp.time       = erp.time(:, clean_trials);

        %% ---------------- Average reference ----------------
        cfg = [];
        cfg.reref = 'yes';
        cfg.refmethod = 'avg';
        cfg.refchannel = 'all';
        erp_trials = ft_preprocessing(cfg, erp);

        %% ---------------- Extract trials per electrode ----------------
        trials = cell(128, 1);

        for electrode_idx = 1:128
            electrode_trials = [];

            for trial_idx = 1:length(erp_trials.trial)
                trial_data = erp_trials.trial{trial_idx}(electrode_idx, :);
                electrode_trials = [electrode_trials; trial_data];
            end

            trials{electrode_idx} = electrode_trials;
        end

        %% ---------------- Target start times ----------------
        [target_start_time] = target_start_times_inhibition(dataset_filename, i, erp_trials);

        %% ---------------- SAVE TRIALS PER CONDITION ----------------
        [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);

        if i == 3
            trials_folder = 'PATH_TO_SAVE_TRIALS_CONGRUENT';
        else
            trials_folder = 'PATH_TO_SAVE_TRIALS_INCONGRUENT';
        end

        save(fullfile(trials_folder, [base_filename '.mat']), ...
             'trials', 'target_start_time');

        %% ---------------- Compute ERP average ----------------
        cfg = [];
        ga_erp = ft_timelockanalysis(cfg, erp_trials);

        %% ---------------- Save ERP ----------------
        if i == 3
            erp_folder = 'PATH_TO_SAVE_ERP_CONGRUENT';
        else
            erp_folder = 'PATH_TO_SAVE_ERP_INCONGRUENT';
        end

        eval([base_filename ' = ga_erp;']);
        save(fullfile(erp_folder, [base_filename '.mat']), base_filename);

    end  % condition loop

end  % file loop
