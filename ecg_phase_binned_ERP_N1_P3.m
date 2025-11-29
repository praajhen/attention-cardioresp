%% ecg_phase_binned_ERP_N1_P3.m
% Bin trials by ECG phase (systole/diastole) for N1 and P3 ERPs
% Author: praghajieeth raajhen santhana gopalan

%% --------------------------------------N1------------------------------------------%%

clear; clc

addpath('PATH_TO_YOUR_MATLAB_CODE_FOLDER');    % e.g. C:\...\AICRM (2023-24)\Matlab code
addpath('PATH_TO_FIELDTRIP_FOLDER');           % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';     % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

load('PATH_TO_EDGES_FILE/edges.mat')           % e.g. ...\Intermediate files\edges.mat
bins = {};

%--------------------------------------------------------------------------------------------------
for file_idx = 2:50 % enter the file number
%--------------------------------------------------------------------------------------------------
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    trials_folder   = 'PATH_TO_TRIALS_CONG_FOLDER';  % e.g. ...\Intermediate files\trials\cong
    trials_files    = dir(fullfile(trials_folder, '*.mat'));
    trials_filename = fullfile(trials_folder, trials_files(file_idx).name); % segment only correctly responds trials
    load(trials_filename); % load accepted trials for averaging

    % Initialize a cell array to store the reconstructed trials
    reconstructed_trials = cell(size(trials{1,1},1),1);

    % Iterate over each trial
    for trial_idx = 1:size(trials{1,1},1)
        % Initialize a matrix to store data for all electrodes in the current trial
        trial_data = zeros(128, size(trials{1}, 2));

        % Iterate over each electrode
        for electrode_idx = 1:128
            % Extract the data for the current electrode and trial
            trial_data(electrode_idx, :) = trials{electrode_idx}(trial_idx, :);
        end

        % Store the reconstructed trial data
        reconstructed_trials{trial_idx} = trial_data;
    end

    %% ECG data
    cfg         = [];
    cfg.dataset = dataset_filename;
    cfg.channel = 'ecg';
    ecg         = ft_preprocessing(cfg);

    % find the r peaks and its location
    [rpeaks,locs] = findpeaks((ecg.trial{1,1}), 'MinPeakProminence',600, 'MinPeakDistance',500);

    % Define the start times and labels for the loop
    cue_start_time = [];
    start_times = {cue_start_time; target_start_time};
    labels      = {'cue onset', 'target onset'};

    for loop_idx = 2 % target_start_time

        differences = zeros(length(start_times{loop_idx}), 1); % initialize a matrix
        for t = 1:length(start_times{loop_idx})
            [~, index] = max(locs(locs <= start_times{loop_idx}(t))); % Find the nearest lower value from rpeaks location matrix
            differences(t) = start_times{loop_idx}(t) - locs(index);
        end
        all_sub_diff{file_idx} = differences;

        % Define the bin edges
        edges = edge(file_idx,:); % 3 bins; 1 systole and 2 diastole

        % Group data into bins
        bin_indices = discretize(differences, edges);

        % Replace NaN values with a specific bin index
        nan_indices = isnan(bin_indices);
        bin_indices(nan_indices) = 3; % Assign NaN values to the last bin

        all_sub_binIndices{file_idx} = bin_indices;

    end

    % Extracting bin indices and initializing cell arrays
    binIndices  = all_sub_binIndices{1, file_idx};
    numBins     = 3;
    binMatrices = cell(1, numBins);

    % Initialize each bin in binMatrices as an empty cell array
    for binIdx = 1:numBins
        binMatrices{binIdx} = {};
    end

    % Loop through trials and assign them to the respective bin cell arrays
    for trialIdx = 1:length(binIndices)
        binIndex = binIndices(trialIdx);

        % Extract the trial data from reconstructed_trials
        trialData = reconstructed_trials{trialIdx};

        % Append the trial data to the respective bin cell array
        binMatrices{binIndex}{1, end + 1} = trialData; % to get horizontally
        % binMatrices{binIndex} = [binMatrices{binIndex}; {trialData}]; % to get vertically
    end

    bins = [bins; binMatrices];

    %%
    load('PATH_TO_LABEL_FILE/label.mat')   % e.g. ...\Matlab code\label.mat

    bin1.trial   = bins{file_idx, 1};
    bin1.fsample = 1000;
    bin1.time    = {};
    bin1.time{1, 1} = -0.2:0.001:1;
    for i = 1:length(bin1.trial)
        bin1.time{1, i} = bin1.time{1, 1};
    end
    bin1.label = label;

    cfg       = [];
    ga_erp_1  = ft_timelockanalysis(cfg, bin1);

    trials_folder = 'PATH_TO_ERP_BINS_ECG_NC1200_BIN1_FOLDER'; % e.g. ...\ERP_bins\ecg\archieved\nc_1200ms\bin1
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_1');

    bin2.trial   = bins{file_idx, 2};
    bin2.fsample = 1000;
    bin2.time    = {};
    bin2.time{1, 1} = -0.2:0.001:1;
    for i = 1:length(bin2.trial)
        bin2.time{1, i} = bin2.time{1, 1};
    end
    bin2.label = label;

    cfg       = [];
    ga_erp_2  = ft_timelockanalysis(cfg, bin2);

    trials_folder = 'PATH_TO_ERP_BINS_ECG_NC1200_BIN2_FOLDER'; % e.g. ...\ERP_bins\ecg\archieved\nc_1200ms\bin2
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_2');

    bin3.trial   = bins{file_idx, 3};
    bin3.fsample = 1000;
    bin3.time    = {};
    bin3.time{1, 1} = -0.2:0.001:1;
    for i = 1:length(bin3.trial)
        bin3.time{1, i} = bin3.time{1, 1};
    end
    bin3.label = label;

    cfg       = [];
    ga_erp_3  = ft_timelockanalysis(cfg, bin3);

    trials_folder = 'PATH_TO_ERP_BINS_ECG_NC1200_BIN3_FOLDER'; % e.g. ...\ERP_bins\ecg\archieved\nc_1200ms\bin3
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_3');

end

save("bins.mat", 'bins','-v7.3');


%% --------------------------------------P3------------------------------------------%%

clear

addpath('PATH_TO_YOUR_MATLAB_CODE_FOLDER');    % e.g. C:\...\AICRM (2023-24)\Matlab code
addpath('PATH_TO_FIELDTRIP_FOLDER');           % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';     % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

load('PATH_TO_EDGES_FILE/edges.mat')
bins = {};

%--------------------------------------------------------------------------------------------------
for file_idx = 1:50 %enter the file number
%--------------------------------------------------------------------------------------------------
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    for i = 4 % 3 congruent, 4 incongruent
        if i == 3
            trials_folder = 'PATH_TO_TRIALS_CONG_FOLDER';   % e.g. ...\Intermediate files\trials\cong
        elseif i == 4
            trials_folder = 'PATH_TO_TRIALS_INCON_FOLDER';  % e.g. ...\Intermediate files\trials\incon
        end

        trials_files    = dir(fullfile(trials_folder, '*.mat'));
        trials_filename = fullfile(trials_folder, trials_files(file_idx).name); % segment only correctly responds trials

        load(trials_filename); % load accepted trials for averaging

        % Initialize a cell array to store the reconstructed trials
        reconstructed_trials = cell(size(trials{1,1},1),1);

        % Iterate over each trial
        for trial_idx = 1:size(trials{1,1},1)
            % Initialize a matrix to store data for all electrodes in the current trial
            trial_data = zeros(128, size(trials{1}, 2));

            % Iterate over each electrode
            for electrode_idx = 1:128
                % Extract the data for the current electrode and trial
                trial_data(electrode_idx, :) = trials{electrode_idx}(trial_idx, :);
            end

            % Store the reconstructed trial data
            reconstructed_trials{trial_idx} = trial_data;
        end

        %% ECG data
        cfg         = [];
        cfg.dataset = dataset_filename;
        cfg.channel = 'ecg';
        ecg         = ft_preprocessing(cfg);

        % Extraction ECG data
        [rpeaks,locs] = findpeaks((ecg.trial{1,1}), 'MinPeakProminence',600, 'MinPeakDistance',500);

        % Define the start times and labels for the loop
        cue_start_time = []; 
        start_times = {cue_start_time; target_start_time};
        labels      = {'cue onset', 'target onset'};

        if file_idx == 5 && i == 2
            load('PATH_TO_START_TIMES_SPECIAL_FILE/start_times(A005)_dc.mat');
        end

        for loop_idx = 2 % target_start_time

            differences = zeros(length(start_times{loop_idx}), 1); % initialize a matrix
            for t = 1:length(start_times{loop_idx})
                [~, index] = max(locs(locs <= start_times{loop_idx}(t))); % Find the nearest lower value from rpeaks location matrix
                differences(t) = start_times{loop_idx}(t) - locs(index);
            end
            all_sub_diff{file_idx} = differences;

            % Define the bin edges
            edges = edge(file_idx,:); % 3 bins; 1 systole and 2 diastole

            % Group data into bins
            bin_indices = discretize(differences, edges);

            % Replace NaN values with a specific bin index
            nan_indices = isnan(bin_indices);
            bin_indices(nan_indices) = 3; % Assign NaN values to the last bin

            all_sub_binIndices{file_idx} = bin_indices;
        end
    end

    % Extracting bin indices and initializing cell arrays
    binIndices  = all_sub_binIndices{1, file_idx};
    numBins     = 3;
    binMatrices = cell(1, numBins);

    % Initialize each bin in binMatrices as an empty cell array
    for binIdx = 1:numBins
        binMatrices{binIdx} = {};
    end

    % Loop through trials and assign them to the respective bin cell arrays
    for trialIdx = 1:length(binIndices)
        binIndex = binIndices(trialIdx);

        % Extract the trial data from reconstructed_trials
        trialData = reconstructed_trials{trialIdx};

        % Append the trial data to the respective bin cell array
        binMatrices{binIndex}{1, end + 1} = trialData; % to get horizontally
        % binMatrices{binIndex} = [binMatrices{binIndex}; {trialData}]; % to get vertically
    end

    bins = [bins; binMatrices];

    %%
    load('PATH_TO_LABEL_FILE/label.mat')

    bin1.trial   = bins{file_idx, 1};
    bin1.fsample = 1000;
    bin1.time    = {};
    bin1.time{1, 1} = -0.2:0.001:1;
    for i = 1:length(bin1.trial)
        bin1.time{1, i} = bin1.time{1, 1};
    end
    bin1.label = label;

    cfg       = [];
    ga_erp_1  = ft_timelockanalysis(cfg, bin1);

    trials_folder = 'PATH_TO_ERP_BINS_ECG_INCON_BIN1_FOLDER'; % e.g. ...\ERP_bins\ECG\incon\bin1
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_1');

    bin2.trial   = bins{file_idx, 2};
    bin2.fsample = 1000;
    bin2.time    = {};
    bin2.time{1, 1} = -0.2:0.001:1;
    for i = 1:length(bin2.trial)
        bin2.time{1, i} = bin2.time{1, 1};
    end
    bin2.label = label;

    cfg       = [];
    ga_erp_2  = ft_timelockanalysis(cfg, bin2);

    trials_folder = 'PATH_TO_ERP_BINS_ECG_INCON_BIN2_FOLDER'; % e.g. ...\ERP_bins\ECG\incon\bin2
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_2');

    bin3.trial   = bins{file_idx, 3};
    bin3.fsample = 1000;
    bin3.time    = {};
    bin3.time{1, 1} = -0.2:0.001:1;
    for i = 1:length(bin3.trial)
        bin3.time{1, i} = bin3.time{1, 1};
    end
    bin3.label = label;

    cfg       = [];
    ga_erp_3  = ft_timelockanalysis(cfg, bin3);

    trials_folder = 'PATH_TO_ERP_BINS_ECG_INCON_BIN3_FOLDER'; % e.g. ...\ERP_bins\ECG\incon\bin3
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_3');

end

save("bins.mat", 'bins','-v7.3');
