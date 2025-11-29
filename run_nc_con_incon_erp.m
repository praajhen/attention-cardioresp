%% run_nc_con_incon_erp.m
% ERP extraction and trial segmentation: nc-con / nc-incon
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

addpath('PATH_TO_YOUR_MATLAB_CODE_FOLDER');   % e.g. ..\Matlab code
addpath('PATH_TO_YOUR_FIELDTRIP_FOLDER');     % e.g. ..\fieldtrip
ft_defaults;

data_folder = 'PATH_TO_RAW_EDF_DATA_FOLDER';          % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

BP_filtered_folder = 'PATH_TO_BP_FILTERED_DATA_FOLDER';   % Folder containing BP-filtered .mat files
BP_filtered_files = dir(fullfile(BP_filtered_folder, '*.mat'));

%--------------------------------------------------------------------------------------------------
for file_idx = 1:50 %enter the file number
%--------------------------------------------------------------------------------------------------

    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);
    BP_files = fullfile(BP_filtered_folder, BP_filtered_files(file_idx).name); % segment only correctly responds trials
    load(BP_files); %load ICA cleaned data

    for i = 1:2 %1 nc_con, 2 nc_incon, 3 dc_con, 4 dc_incon
        % Preprocessing EEG data for ERP analysis
        cfg                         = [];
        cfg.dataset                 = dataset_filename;
        %--------------------------------------------------------------------------------------------------
        cfg.nr = i; % 1 nc_con, 2 nc_incon, 3 dc_con, 4 dc_incon
        %--------------------------------------------------------------------------------------------------
        cfg.trialfun                = 'con_incon_fn';
        cfg.trialdef.eventtype      = 'annotation';
        cfg.channel = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60','61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '100','101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '120', '121', '122', '123', '124', '125', '126', '127', '128'};
        cfg.baselinewindow = [-0.2 0];
        cfg.demean ='yes';
        cfg = ft_definetrial(cfg);
        data = ft_redefinetrial(cfg,data_filtered);
        erp = ft_preprocessing(cfg,data);
        trial_no_b4(file_idx) = length(erp.trial);


        %% Amplitude thresholding
        % Preallocate memory
        numTrials = length(erp.trial);
        difftrial = cell(1, numTrials);
        btrial = cell(1, numTrials);
        clean_trials = [];
        reject_trial = false(1, numTrials);

        %threshold limits
        threshold_low = 175;
        threshold_high = 300;
        max_zero_columns = 25;

        % Calculate differences
        for tr = 1:numTrials
            difftrial{tr} = max(erp.trial{tr}(:, 150:end), [], 2) - min(erp.trial{tr}(:, 150:end), [], 2);
        end

        for tr = 1:numTrials
            % Check if any value exceeds the high threshold
            if any(difftrial{tr} > threshold_high)
                % Reject the trial if any value exceeds the high threshold
                reject_trial(tr) = true;
            else
                % Otherwise, check the number of zero columns with respect to low threshold
                btrial{tr} = difftrial{tr} <= threshold_low;
                zeroCount(tr) = sum(btrial{tr} == 0);
                if zeroCount(tr) > max_zero_columns
                    reject_trial(tr) = true; % Reject the trial if zero columns exceed the limit
                else
                    reject_trial(tr) = false; % Accept the trial otherwise
                end
            end
        end

        % Keep only the trials that are not rejected
        clean_trials = find(~reject_trial);
        trial_no_after(file_idx) = length(clean_trials);

        % Create the cleantrials matrix
        erp.sampleinfo = erp.sampleinfo(clean_trials,:);
        erp.trial = erp.trial(:, clean_trials);
        erp.time = erp.time(:, clean_trials);

        cfg = [];
        cfg.reref = 'yes';
        cfg.refmethod = 'avg';
        cfg.refchannel = 'all';
        erp_trials = ft_preprocessing(cfg,erp);

        %Extracting each electrodes and their trial data into one individual cell
        trials = cell(128, 1);
        for electrode_idx = 1:128
            electrode_name = {electrode_idx};  % Assuming ch is a cell array of electrode labels
            electrode_trials = [];
            for trial_idx = 1:length(erp_trials.trial)
                trial_data = erp_trials.trial{trial_idx}(electrode_idx, :);  % Extract trial data for the current electrode
                electrode_trials = [electrode_trials; trial_data];
            end
            trials{electrode_idx} = electrode_trials;  % Save trials for the current electrode
        end

        [target_start_time] = target_times_con_incon(dataset_filename, i,erp_trials); %target start time as function

        if i==1
            no_of_trials_nc(file_idx,1)= length(trials{1, 1}(:,1));
            trials_folder = 'PATH_TO_SAVE_TRIALS_NC_CON_1200ms';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials','target_start_time');
        elseif i==2
            no_of_trials_dc(file_idx,1)= length(trials{1, 1}(:,1));
            trials_folder = 'PATH_TO_SAVE_TRIALS_NC_INCON_1200ms';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials','target_start_time');
        elseif i==3
            no_of_trials_dc(file_idx,1)= length(trials{1, 1}(:,1));
            trials_folder = 'PATH_TO_SAVE_TRIALS_DC_CON';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials','target_start_time');
        else
            no_of_trials_dc(file_idx,1)= length(trials{1, 1}(:,1));
            trials_folder = 'PATH_TO_SAVE_TRIALS_DC_INCON';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            erp_filename = fullfile(trials_folder, [base_filename '.mat']);
            save(erp_filename, 'trials','target_start_time');
        end

        %average of ERPs
        cfg= [];
        ga_erp=ft_timelockanalysis(cfg,erp_trials);

        % Save ERP results
        if i == 1
            erp_folder = 'PATH_TO_SAVE_ERP_NC_CON_1200ms';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);
        elseif i ==2
            erp_folder = 'PATH_TO_SAVE_ERP_NC_INCON_1200ms';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);
        elseif i ==3
            erp_folder = 'PATH_TO_SAVE_ERP_DC_CON';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);
        else
            erp_folder = 'PATH_TO_SAVE_ERP_DC_INCON';  % Folder to save ERP results
            [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
            eval([base_filename ' = ga_erp;']);
        end

        erp_filename = fullfile(erp_folder, [base_filename '.mat']);
        save(erp_filename, base_filename);
    end
end
