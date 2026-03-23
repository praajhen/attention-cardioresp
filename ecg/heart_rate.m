%% compute_heart_rate.m
% Estimate heart rate from ECG and save to Excel
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
code_path      = 'PATH_TO_YOUR_MATLAB_CODE_FOLDER';
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_EDF_DATA_FOLDER';

%% ================= SETUP =================
addpath(code_path);
addpath(fieldtrip_path);
ft_defaults;

dataset_files = dir(fullfile(data_folder, '*.edf'));

heart_rate_bpm = [];

for file_idx = 1:length(dataset_files)

    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    %% Load ECG
    cfg         = [];
    cfg.dataset = dataset_filename;
    cfg.channel = 'ecg';
    ecg         = ft_preprocessing(cfg);

    sampling_frequency = ecg.fsample;

    %% R-peak detection
    [~, locs] = findpeaks(ecg.trial{1,1}, ...
        'MinPeakProminence', 700, ...
        'MinPeakDistance', round(0.6 * sampling_frequency));

    %% RR intervals
    time_intervals = diff(locs) / sampling_frequency;

    %% Heart rate
    avg_time_interval = mean(time_intervals);
    heart_rate_bpm(file_idx) = 60 / avg_time_interval;

    %% Subject name
    [~, subject_name, ~] = fileparts(dataset_files(file_idx).name);

    %% Save to Excel
    excel_filename = 'HeartRate.xlsx';

    if file_idx == 1
        headers = {'Subject', 'Heart Rate (bpm)'};
        writecell(headers, excel_filename, 'Sheet', 'Sheet1', 'Range', 'A1');
    end

    data_to_write = {subject_name, heart_rate_bpm(file_idx)};
    range = ['A' num2str(file_idx + 1)];

    writecell(data_to_write, excel_filename, ...
        'Sheet','Sheet1', ...
        'Range',range);

end

disp('Heart rate computation completed')