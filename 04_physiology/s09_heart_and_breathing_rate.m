%% s09_heart_and_breathing_rate
% Descriptive heart rate and breathing rate per participant over the whole
% recording. Respiration is band-pass filtered 0.1-0.5 Hz (2nd-order
% Butterworth) before peak detection.
% Output: <work_dir>/cardiac/rates.csv

clear; clc;
C = ant_config();

n  = numel(C.files);
id = cell(n, 1); hr_bpm = nan(n, 1); br_bpm = nan(n, 1);
for file_idx = 1:n
    dataset     = fullfile(C.raw_dir, C.files(file_idx).name);
    id{file_idx} = participant_info(C.files(file_idx), C);

    % Heart rate
    ecg = read_physio(dataset, 'ecg');
    [~, rlocs] = findpeaks(ecg, 'MinPeakProminence', 700, 'MinPeakDistance', 600);
    hr_bpm(file_idx) = 60 / mean(diff(rlocs) / C.fs);

    % Breathing rate
    cfg            = [];
    cfg.dataset    = dataset;
    cfg.channel    = 'Resp';
    cfg.bpfilter   = 'yes';
    cfg.bpfreq     = [0.1 0.5];
    cfg.bpfilttype = 'but';
    cfg.bpfiltord  = 2;
    resp = ft_preprocessing(cfg);
    [~, blocs] = findpeaks(resp.trial{1});
    br_bpm(file_idx) = 60 / mean(diff(blocs) / C.fs);
end

out_dir = fullfile(C.work_dir, 'cardiac');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
writetable(table(id, hr_bpm, br_bpm), fullfile(out_dir, 'rates.csv'));
