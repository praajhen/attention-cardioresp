%% sys_dia_windows.m
% Derive ECG cycle edges (systole/diastole bins) from R-peak locked segments
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
code_path      = 'PATH_TO_YOUR_MATLAB_CODE_FOLDER';
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_EDF_DATA_FOLDER';
figure_folder  = 'PATH_TO_ECG_FIG_OUTPUT_FOLDER';

%% ================= SETUP =================
addpath(code_path);
addpath(fieldtrip_path);
ft_defaults;

dataset_files = dir(fullfile(data_folder, '*.edf'));
num_subjects  = length(dataset_files);

for file_idx = 1:num_subjects

    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    cfg = [];
    cfg.dataset = dataset_filename;
    cfg.channel = 'ecg';
    ecg = ft_preprocessing(cfg);

    fs = ecg.fsample;

    %% R peaks
    [~, Rlocs] = findpeaks(ecg.trial{1,1}, ...
        'MinPeakProminence',700, ...
        'MinPeakDistance',round(0.6*fs));

    %% RR interval
    RR_intervals   = diff(Rlocs) / fs;
    segment_length = round(mean(RR_intervals) * fs);

    filtered_ecg = ecg.trial{1,1};
    num_segments = length(Rlocs);

    ecg_segments = zeros(num_segments, segment_length);

    %% segment extraction
    for i = 1:num_segments

        start_idx = Rlocs(i);
        end_idx   = start_idx + segment_length - 1;

        if end_idx <= length(filtered_ecg)
            ecg_segments(i,:) = filtered_ecg(start_idx:end_idx);
        end

    end

    seg_len(file_idx) = segment_length;

    %% mean ECG
    mean_ecg = mean(ecg_segments);

    figure
    plot(mean_ecg)

    %% find systole / diastole boundaries
    [~, rlocs] = findpeaks(mean_ecg,'MinPeakDistance',round(0.3*fs));

    a = 0;
    b = rlocs(1) - 50;
    c = rlocs(2) - 100;
    d = length(mean_ecg);

    edges(file_idx,:) = [a b c d];

    %% save figure
    [~, data_filename, ~] = fileparts(dataset_filename);

    figure_filename = fullfile(figure_folder, ...
        [data_filename '.jpg']);

    saveas(gcf, figure_filename)
    close(gcf)

end

disp('Cardiac phase windows computed')