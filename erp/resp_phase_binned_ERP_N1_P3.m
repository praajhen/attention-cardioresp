%% --------------------------------------N1------------------------------------------%%
clear; clc;

addpath('PATH_TO_YOUR_MATLAB_CODE_FOLDER');   % e.g. C:\...\AICRM (2023-24)\Matlab code
addpath('PATH_TO_FIELDTRIP_FOLDER');          % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';    % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder
bins = {};

%--------------------------------------------------------------------------------------------------
for file_idx = 1:5 % enter the file number
%--------------------------------------------------------------------------------------------------
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    trials_folder   = 'PATH_TO_TRIALS_NC_FOLDER';   % e.g. ...\Intermediate files\trials\NC
    trials_files    = dir(fullfile(trials_folder, '*.mat'));
    trials_filename = fullfile(trials_folder, trials_files(file_idx).name);
    load(trials_filename); % load accepted trials for averaging

    % Initialize a cell array to store the reconstructed trials
    reconstructed_trials = cell(size(trials{1,1},1), 1);

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

    %%
    cfg            = [];
    cfg.trialfun   = 'mytrialfun';
    cfg.dataset    = dataset_filename;
    cfg.channel    = {'Resp'};
    Resp           = ft_preprocessing(cfg);

    resp      = Resp.trial{1,1};               % complete resp data
    respPhase = angle(hilbert(resp));          % Angle and Hilbert transform of respiration data

    % Define the start times and labels for the loop
    cue_start_time = []; % as we dont have cue_start_time CAUTIOUS
    start_times = {cue_start_time; target_start_time};
    labels      = {'cue onset', 'target onset'};

    for loop_idx = 2 % target onset

        % Extract respiration phase
        phase_data = zeros(length(start_times{loop_idx}), 1);
        for t = 1:length(start_times{loop_idx})
            phase_data(t) = respPhase(1, start_times{loop_idx}(t));
        end
        phase_data = round(phase_data, 2); % rounded to ignore values like 3.1408 -> NaN in bins
        all_sub_phase_data{file_idx} = phase_data;

        % Define the bin edges
        edges = linspace(-3.14, 3.14, 3); % 2 bins total

        % Group data into bins
        bin_indices = discretize(phase_data, edges);
        all_sub_binIndices{file_idx} = bin_indices;
    end

    % Extracting bin indices and initializing cell arrays
    binIndices = all_sub_binIndices{1, file_idx};
    numBins    = 2;
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
    load('PATH_TO_LABEL_FILE/label.mat');  % e.g. ...\Matlab code\label.mat

    bin1.trial   = bins{file_idx, 1};
    bin1.fsample = 1000;
    bin1.time    = {};
    bin1.time{1, 1} = linspace(-0.2, 1, 1200);
    for k = 1:length(bin1.trial)
        bin1.time{1, k} = bin1.time{1, 1};
    end
    bin1.label = label;

    cfg       = [];
    ga_erp_1  = ft_timelockanalysis(cfg, bin1);

    trials_folder = 'PATH_TO_ERP_BINS_RESP_INCON_BIN1_FOLDER'; % e.g. ...\ERP_bins\resp\incon\bin1
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_1');

    bin2.trial   = bins{file_idx, 2};
    bin2.fsample = 1000;
    bin2.time    = {};
    bin2.time{1, 1} = linspace(-0.2, 1, 1200);
    for k = 1:length(bin2.trial)
        bin2.time{1, k} = bin2.time{1, 1};
    end
    bin2.label = label;

    cfg      = [];
    ga_erp_2 = ft_timelockanalysis(cfg, bin2);

    trials_folder = 'PATH_TO_ERP_BINS_RESP_INCON_BIN2_FOLDER'; % e.g. ...\ERP_bins\resp\incon\bin2
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_2');

end

save('bins.mat', 'bins','-v7.3');



%% --------------------------------------P3------------------------------------------%%

clear; clc;

addpath('PATH_TO_YOUR_MATLAB_CODE_FOLDER');   % e.g. C:\...\AICRM (2023-24)\Matlab code
addpath('PATH_TO_FIELDTRIP_FOLDER');          % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';    % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

bins = {};
%--------------------------------------------------------------------------------------------------
for file_idx = 1:50  % enter the file number
%--------------------------------------------------------------------------------------------------
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    for i = 4 % 3 congruent, 4 incongruent target

        if i == 3
            trials_folder = 'PATH_TO_TRIALS_CONG_FOLDER';   % e.g. ...\Intermediate files\trials\cong
        else % i == 4
            trials_folder = 'PATH_TO_TRIALS_INCON_FOLDER';  % e.g. ...\Intermediate files\trials\incon
        end

        trials_files    = dir(fullfile(trials_folder, '*.mat'));
        trials_filename = fullfile(trials_folder, trials_files(file_idx).name);

        load(trials_filename); % load accepted trials for averaging

        % Initialize a cell array to store the reconstructed trials
        reconstructed_trials = cell(size(trials{1,1},1), 1);

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

        % -----------------------------------------------------------------
        % Respiration phase extraction
        % -----------------------------------------------------------------
        channel = {'Resp','ecg','55'};
        for j = 1
            cfg            = [];
            cfg.trialfun   = 'mytrialfun';
            cfg.dataset    = dataset_filename;
            cfg.channel    = channel(j);
            Resp(j)        = ft_preprocessing(cfg);
        end

        resp      = Resp.trial{1,1};            % complete resp data
        respPhase = angle(hilbert(resp));       % Angle and Hilbert transform of respiration data

        % Define the start times and labels for the loop
        cue_start_time = []; % as we dont have cue_start_time CAUTIOUS
        start_times = {cue_start_time; target_start_time};
        labels      = {'cue onset', 'target onset'};

        for loop_idx = 2 % target onset

            % Extract respiration phase
            phase_data = zeros(length(start_times{loop_idx}), 1);
            for t = 1:length(start_times{loop_idx})
                phase_data(t) = respPhase(1, start_times{loop_idx}(t));
            end
            phase_data = round(phase_data, 2); % rounded to ignore values like 3.1408 -> NaN in bins
            all_sub_phase_data{file_idx} = phase_data;

            % Define the bin edges
            edges = linspace(-3.14, 3.14, 5); % 4 bins total

            % Group data into bins
            bin_indices = discretize(phase_data, edges);
            all_sub_binIndices{file_idx} = bin_indices;
        end
    end

    % Extracting bin indices and initializing cell arrays
    binIndices = all_sub_binIndices{1, file_idx};
    numBins    = 4;
    binMatrices = cell(1, numBins);

    % Initialize each bin in binMatrices as an empty cell array
    for binIdx = 1:numBins
        binMatrices[binIdx] = {};
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
    load('PATH_TO_LABEL_FILE/label.mat');  % e.g. ...\Matlab code\label.mat

    bin1.trial   = bins{file_idx, 1};
    bin1.fsample = 1000;
    bin1.time    = {};
    bin1.time{1, 1} = -0.2:0.001:1;
    for k = 1:length(bin1.trial)
        bin1.time{1, k} = bin1.time{1, 1};
    end
    bin1.label = label;

    cfg       = [];
    ga_erp_1  = ft_timelockanalysis(cfg, bin1);

    trials_folder = 'PATH_TO_ERP_BINS_RESP_INCON_BIN1_FOLDER';  % e.g. ...\ERP_bins\resp\incon\bin1
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_1');

    bin2.trial   = bins{file_idx, 2};
    bin2.fsample = 1000;
    bin2.time    = {};
    bin2.time{1, 1} = -0.2:0.001:1;
    for k = 1:length(bin2.trial)
        bin2.time{1, k} = bin2.time{1, 1};
    end
    bin2.label = label;

    cfg       = [];
    ga_erp_2  = ft_timelockanalysis(cfg, bin2);

    trials_folder = 'PATH_TO_ERP_BINS_RESP_INCON_BIN2_FOLDER';  % e.g. ...\ERP_bins\resp\incon\bin2
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_2');

    bin3.trial   = bins{file_idx, 3};
    bin3.fsample = 1000;
    bin3.time    = {};
    bin3.time{1, 1} = -0.2:0.001:1;
    for k = 1:length(bin3.trial)
        bin3.time{1, k} = bin3.time{1, 1};
    end
    bin3.label = label;

    cfg       = [];
    ga_erp_3  = ft_timelockanalysis(cfg, bin3);

    trials_folder = 'PATH_TO_ERP_BINS_RESP_INCON_BIN3_FOLDER';  % e.g. ...\ERP_bins\resp\incon\bin3
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_3');

    bin4.trial   = bins{file_idx, 4};
    bin4.fsample = 1000;
    bin4.time    = {};
    bin4.time{1, 1} = -0.2:0.001:1;
    for k = 1:length(bin4.trial)
        bin4.time{1, k} = bin4.time{1, 1};
    end
    bin4.label = label;

    cfg       = [];
    ga_erp_4  = ft_timelockanalysis(cfg, bin4);

    trials_folder = 'PATH_TO_ERP_BINS_RESP_INCON_BIN4_FOLDER';  % e.g. ...\ERP_bins\resp\incon\bin4
    [~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
    erp_filename = fullfile(trials_folder, [base_filename '.mat']);
    save(erp_filename, 'ga_erp_4');

end

save('bins.mat', 'bins','-v7.3');
