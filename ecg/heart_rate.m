%% compute_heart_rate.m
% Estimate heart rate from ECG and save to Excel
% Author: praghajieeth raajhen santhana gopalan

clear; clc;
addpath('PATH_TO_YOUR_MATLAB_CODE_FOLDER');   % e.g. C:\...\AICRM (2023-24)\Matlab code
addpath('PATH_TO_FIELDTRIP_FOLDER');          % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';    % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

for file_idx = 50
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    cfg         = [];
    cfg.dataset = dataset_filename;
    cfg.channel = 'ecg';
    ecg         = ft_preprocessing(cfg);

    % Given sampling frequency
    sampling_frequency = 1000; % Hz

    % Extraction ECG data
    [rpeaks,locs] = findpeaks((ecg.trial{1,1}), ...
                              'MinPeakProminence',700, ...
                              'MinPeakDistance',600);

    % Calculate time intervals between consecutive R-peaks (in seconds)
    time_intervals = diff(locs) / sampling_frequency;

    % Calculate average time interval (in seconds)
    avg_time_interval = mean(time_intervals);

    % Convert average time interval to heart rate (beats per minute, bpm)
    heart_rate_bpm(file_idx) = 60 / avg_time_interval;

    % Extract the subject name from the file name (assuming the file name format is consistent)
    [~, subject_name, ~] = fileparts(dataset_files(file_idx).name);
    
    % Create or append to an Excel file
    excel_filename = 'RespirationRates.xlsx';  % (kept your original filename)
    if exist(excel_filename, 'file') == 0
        headers = {'Subject', 'Heart Rate (bpm)'};
        xlswrite(excel_filename, headers, 'Sheet2', 'A1');
    end
    
    % small fix: write only this subject's heart rate, not whole vector
    data_to_write = {subject_name, heart_rate_bpm(file_idx)};
    range = ['A' num2str(file_idx + 1)]; % Start writing from the second row
    xlswrite(excel_filename, data_to_write, 'Sheet2', range);
end
