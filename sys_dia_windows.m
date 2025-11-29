%% sys_dia_windows.m
% Derive ECG cycle edges (systole/diastole bins) from R-peak locked segments
% Author: praghajieeth raajhen santhana gopalan

clear; clc;
addpath('PATH_TO_YOUR_MATLAB_CODE_FOLDER');   % e.g. C:\...\AICRM (2023-24)\Matlab code
addpath('PATH_TO_FIELDTRIP_FOLDER');          % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';    % e.g. C:\...\AICRM (2023-24)\Data\
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

%--------------------------------------------------------------------------------------------------
for file_idx = 1:50 % enter the file number
%--------------------------------------------------------------------------------------------------
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    cfg         = [];
    cfg.dataset = dataset_filename;
    cfg.channel = 'ecg';
    ecg         = ft_preprocessing(cfg);

    fs = 1000;  % sampling frequency

    % Find R-peaks based on threshold crossing
    [~, R_peak_indices] = findpeaks((ecg.trial{1,1}), ...
                                    'MinPeakProminence',700, ...
                                    'MinPeakDistance', fs * 0.6);

    % Calculate RR Intervals
    RR_intervals   = diff(R_peak_indices) / fs;  % RR intervals in seconds
    segment_length = round(mean(RR_intervals) * 1000);

    filtered_ecg        = ecg.trial{1,1};
    [Rpeak, Rlocs]      = findpeaks(filtered_ecg, 'MinPeakProminence',700, 'MinPeakDistance',700);
    num_segments        = length(Rlocs);
    ecg_segments        = zeros(num_segments, segment_length);   % segments matrix

    % Iterate through each R peak location
    for i = 1:num_segments
        r_peak_loc   = Rlocs(i);
        segment_start = max(1, r_peak_loc);
        segment_end   = min(length(filtered_ecg), r_peak_loc + segment_length - 1);

        % Extract the segment from the ECG data
        segment = filtered_ecg(segment_start:segment_end);

        % If the segment is shorter than segment_length, pad with zeros
        if length(segment) < segment_length
            num_zeros = segment_length - length(segment);
            segment   = [segment, zeros(1, num_zeros)];
        end

        % Store the segment in the matrix
        ecg_segments(i, :) = segment;
    end

    seg_len(file_idx) = segment_length;

    figure;
    plot(mean(ecg_segments))

    [rpeak, rlocs] = findpeaks(mean(ecg_segments), 'MinPeakDistance',300);

    a = 0;
    b = rlocs(1) - 50;
    c = rlocs(2) - 100;
    d = length(mean(ecg_segments));

    edges(file_idx,:) = [a, b, c, d];

    [~, data_filename, ~] = fileparts(dataset_filename);
    figure_filename = fullfile('PATH_TO_ECG_FIG_OUTPUT_FOLDER', [data_filename '.jpg']); 
    % e.g. ...\Intermediate files\Figures\ecg\

    % Save the figure as JPEG
    findpeaks(mean(ecg_segments), 'MinPeakDistance',300)
    saveas(gcf, figure_filename, 'jpg');
    close(gcf); % Close the figure

end
