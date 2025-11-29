%% cardiac_phase_alignment_check.m
% Cardiac phase verification – visualize systole and diastole bins
% Author: praghajieeth raajhen santhana gopalan

close all;
clear; clc;

addpath('PATH_TO_FIELDTRIP_FOLDER');              % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder = 'PATH_TO_ECG_DATA_FOLDER';          % e.g. D:\AICR (2023-24)\Data\
save_folder = 'PATH_TO_SAVE_CARDIAC_PHASE_FIGS';  % e.g. C:\...\figures\cardiac_phase
if ~exist(save_folder, 'dir'); mkdir(save_folder); end

% Load your subject-specific phase boundaries
load('PATH_TO_EDGES_FILE/edges.mat');             % variable: edges

dataset_files = dir(fullfile(data_folder, '*.edf'));

for file_idx = 1:length(dataset_files)
    subj_name = erase(dataset_files(file_idx).name, '.edf');
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    % --- Load ECG data ---
    cfg = [];
    cfg.dataset = dataset_filename;
    cfg.channel = {'ecg'};
    data = ft_preprocessing(cfg);
    ecg = data.trial{1,1};
    fs  = data.fsample;

    % --- Detect R-peaks ---
    [~, Rlocs] = findpeaks(ecg, 'MinPeakProminence', std(ecg)/2, ...
        'MinPeakDistance', round(0.6*fs));
    RR       = diff(Rlocs) / fs;
    mean_IBI = mean(RR);
    seg_len  = round(mean_IBI * fs);

    % --- Extract ECG segments around R-peaks ---
    segments = zeros(length(Rlocs)-1, seg_len);
    for i = 1:length(Rlocs)-1
        start_idx = Rlocs(i);
        end_idx   = start_idx + seg_len - 1;
        if end_idx <= length(ecg)
            segments(i,:) = ecg(start_idx:end_idx);
        end
    end
    avg_ecg = mean(segments, 1);
    time    = (0:seg_len-1)/fs*1000;  % ms

    % --- Load participant-specific edges (samples/ms) ---
    subj_edges = edges(file_idx,:); % [0 systole_end earlyD_end lateD_end]
    if length(subj_edges) < 4
        warning('%s: edges missing or incomplete', subj_name);
        continue
    end

    % --- Plot average ECG with phase boundaries ---
    figure('Visible','off','Position',[100 100 900 500]);
    plot(time, avg_ecg, 'k', 'LineWidth',1.2); hold on;
    yl = ylim;
    fill([0 subj_edges(2) subj_edges(2) 0], ...
         [yl(1) yl(1) yl(2) yl(2)], 'r', 'FaceAlpha',0.2, 'EdgeColor','none');
    fill([subj_edges(2) subj_edges(3) subj_edges(3) subj_edges(2)], ...
         [yl(1) yl(1) yl(2) yl(2)], 'b', 'FaceAlpha',0.2, 'EdgeColor','none');
    fill([subj_edges(3) subj_edges(4) subj_edges(4) subj_edges(3)], ...
         [yl(1) yl(1) yl(2) yl(2)], 'g', 'FaceAlpha',0.2, 'EdgeColor','none');
    xlabel('Time from R-peak (ms)');
    ylabel('ECG amplitude');
    title(sprintf('%s: Cardiac phase bins', subj_name));
    legend({'ECG','Systole','Early Diastole','Late Diastole'}, 'Location','northeast');

    saveas(gcf, fullfile(save_folder, [subj_name '_cardiac_phase.png']));
    close(gcf);
end

disp('✅ All cardiac phase figures saved successfully!');
