%% ------------------------------------------------------------------------
% Author: Praghajieeth Raajhen Santhana Gopalan
%
% Description:
% This script:
%   - Loops over multiple EDF datasets
%   - Loads corresponding ICA-cleaned EEG data
%   - Applies band-pass filtering (1–30 Hz)
%   - Defines trials using a custom trial function (mytrialfun)
%   - Performs amplitude-based trial rejection
%   - Re-references the data
%   - Extracts per-electrode trial matrices and timing info
%   - Saves single-trial data and averaged ERPs for different conditions
%
% Dependencies:
%   - FieldTrip toolbox
%   - Custom functions: mytrialfun, target_times, start_times
%   - Matching EDF, ICA-cleaned, and output folders already created
%% ------------------------------------------------------------------------

clear; clc;

%% ----------------------------- Paths ------------------------------------
% Add paths to your own MATLAB code and FieldTrip
addpath('Matlab code');              % Folder with your custom scripts (e.g., mytrialfun)
addpath('path_to_fieldtrip_folder'); % Replace with actual FieldTrip path
ft_defaults;

% Folder containing raw EDF datasets
data_folder = 'Data/';

% Folder containing ICA-cleaned data (output from previous step)
ica_cleaned_folder = 'Intermediate files/ICA_cleaned/';

% List all EDF and ICA-cleaned MAT files
dataset_files      = dir(fullfile(data_folder, '*.edf'));
ica_cleaned_files  = dir(fullfile(ica_cleaned_folder, '*.mat'));

%% ------------------------ Main loop over files --------------------------
% Process multiple subjects/files
for file_idx = 1:50   % Adjust upper limit to the number of available files

    % Full paths to EDF and corresponding ICA-cleaned data
    dataset_filename      = fullfile(data_folder, dataset_files(file_idx).name);
    ica_cleaned_filename  = fullfile(ica_cleaned_folder, ica_cleaned_files(file_idx).name);

    % Load ICA-cleaned data (variable data_clean is expected)
    load(ica_cleaned_filename);

    %% ------------------ Band-pass filter (1–30 Hz) ---------------------
    cfg = [];
    cfg.dataset  = dataset_filename;   % NOTE: hard-coded dataset name, adjust if needed
    cfg.bpfilter = 'yes';
    cfg.bpfreq   = [1 30];               % Band-pass range (Hz)
    data_filtered = ft_preprocessing(cfg, data_clean);

    % Save band-pass filtered data
    filtered_folder = 'Intermediate files/BP filtered/';  % Folder for BP-filtered data
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    filtered_data_filename = fullfile(filtered_folder, [base_filename '.mat']);
    save(filtered_data_filename, 'data_filtered', '-v7.3');

    %% ---------------- Loop over conditions (1 = NC, 2 = DC) ------------
    for i = 1:2  % 1 no cue, 2 double cue (3 & 4 mentioned below but not looped here)

        % Change directory depending on condition (as in original code)
        if i == 2
            cd('Matlab code/archieved matlab codes');
        else
            cd('Matlab code');
        end

        %% --------- Define trials using custom trial function ------------
        cfg                         = [];
        cfg.dataset                 = dataset_filename;
        cfg.nr                      = i;             % 1 NC, 2 DC, 3 congruent, 4 incongruent target
        cfg.trialfun                = 'mytrialfun';  % Custom trial function
        cfg.trialdef.eventtype      = 'annotation';
        cfg.channel                 = cellstr(string(1:128)); % Channels 1–128
        cfg.baselinewindow          = [-0.2 0];      % Baseline period (s)
        cfg.demean                  = 'yes';

        % Define trials
        cfg  = ft_definetrial(cfg);

        % Apply trial definition to filtered data
        data = ft_redefinetrial(cfg, data_filtered);

        % Preprocessing step to create ERP structure
        erp  = ft_preprocessing(cfg, data);

        % Store number of trials before rejection
        trial_no_b4(file_idx) = length(erp.trial);

        %% ----------------- Amplitude thresholding ----------------------
        numTrials    = length(erp.trial);
        difftrial    = cell(1, numTrials);
        btrial       = cell(1, numTrials);
        clean_trials = [];
        reject_trial = false(1, numTrials);

        % Threshold limits
        threshold_low      = 175;
        threshold_high     = 300;
        max_zero_columns   = 25;

        % Calculate peak-to-peak differences per trial
        for tr = 1:numTrials
            % Max - min across samples from index 150 onward (per channel)
            difftrial{tr} = max(erp.trial{tr}(:, 150:end), [], 2) - ...
                            min(erp.trial{tr}(:, 150:end), [], 2);
        end

        % Decide which trials to reject based on thresholds
        for tr = 1:numTrials
            % Reject if any channel exceeds high threshold
            if any(difftrial{tr} > threshold_high)
                reject_trial(tr) = true;
            else
                % Count how many channels exceed low threshold
                btrial{tr}    = difftrial{tr} <= threshold_low;
                zeroCount(tr) = sum(btrial{tr} == 0);

                if zeroCount(tr) > max_zero_columns
                    reject_trial(tr) = true;  % Too many channels above low threshold
                else
                    reject_trial(tr) = false; % Accept trial
                end
            end
        end

        % Keep only trials that are not rejected
        clean_trials = find(~reject_trial);

        % Number of trials after rejection
        trial_no_after(file_idx) = length(clean_trials);

        % Keep only the clean trials in ERP structure
        erp.sampleinfo = erp.sampleinfo(clean_trials, :);
        erp.trial      = erp.trial(:, clean_trials);
        erp.time       = erp.time(:, clean_trials);

        %% ----------------- Re-referencing (average) --------------------
        cfg          = [];
        cfg.reref    = 'yes';
        cfg.refmethod = 'avg';
        cfg.refchannel = 'all';
        erp_trials   = ft_preprocessing(cfg, erp);

        %% ---- Extract per-electrode concatenated trial matrices --------
        % trials{e} will contain [nTrials x nTimeSamples] for electrode e
        trials = cell(128, 1);

        for electrode_idx = 1:128
            electrode_trials = [];

            for trial_idx = 1:length(erp_trials.trial)
                trial_data       = erp_trials.trial{trial_idx}(electrode_idx, :);
                electrode_trials = [electrode_trials; trial_data];
            end

            trials{electrode_idx} = electrode_trials;
        end

        %% ----------- Get cue/target timing information -----------------
        if i == 1
            % No cue condition: only target times
            [target_start_time] = target_times(dataset_filename, i, erp_trials);
        else
            % Double cue (or other cue conditions): cue + target times
            [cue_start_time, target_start_time] = start_times(dataset_filename, i, erp_trials);
        end

        %% ---------------- Save single-trial data -----------------------
        % Count trials based on first electrode (same for all electrodes)
        if i == 1
            no_of_trials_nc(file_idx, 1) = size(trials{1, 1}, 1);
            trials_folder = 'Intermediate files/trials/NC';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials', 'target_start_time');

        elseif i == 2
            no_of_trials_dc(file_idx, 1) = size(trials{1, 1}, 1);
            trials_folder = 'Intermediate files/trials/DC';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials', 'target_start_time', 'cue_start_time');

        elseif i == 3
            no_of_trials_dc(file_idx, 1) = size(trials{1, 1}, 1);
            trials_folder = 'Intermediate files/trials/cong';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials', 'target_start_time');

        else
            no_of_trials_dc(file_idx, 1) = size(trials{1, 1}, 1);
            trials_folder = 'Intermediate files/trials/incon';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials', 'target_start_time');
        end

        %% ----------------- Average ERP per condition -------------------
        cfg    = [];
        ga_erp = ft_timelockanalysis(cfg, erp_trials);

        % Save ERP results (ga_erp) with subject-specific name
        if i == 1
            erp_folder = 'Intermediate files/ERP/NC';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);

        elseif i == 2
            erp_folder = 'Intermediate files/ERP/DC';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);

        elseif i == 3
            erp_folder = 'Intermediate files/ERP/cong';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);

        else
            erp_folder = 'Intermediate files/ERP/incon';
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);
        end

        % Save ERP structure to file
        erp_filename = fullfile(erp_folder, [base_filename '.mat']);
        save(erp_filename, base_filename);

    end % end of condition loop (i)

end % end of file loop (file_idx)
