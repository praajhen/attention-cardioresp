%% s07_cardiac_bin_edges
% Proposes per-participant cardiac bin edges from the R-peak-locked mean ECG
% waveform (segment length = mean inter-beat interval, IBI):
%   systole        : 0 ms to (first peak after R, T wave) - 50 ms
%   early diastole : to (second peak) - 100 ms
%   late diastole  : to mean IBI
% The proposed edges and saved waveform figures were then inspected and
% adjusted by hand for each participant. The final edges used in the paper
% are stored in <work_dir>/cardiac/edges.mat (variable 'edge', 50 x 4, ms).
% Group means of the final edges: young 0-202-593-907 ms, older 0-206-545-946 ms.
% Output: <work_dir>/cardiac/edges_auto.mat, waveform figures

clear; clc;
C = ant_config();

out_dir = fullfile(C.work_dir, 'cardiac');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

edges_auto = zeros(numel(C.files), 4);
for file_idx = 1:numel(C.files)
    dataset = fullfile(C.raw_dir, C.files(file_idx).name);
    id      = participant_info(C.files(file_idx), C);
    ecg     = read_physio(dataset, 'ecg');

    % Mean IBI sets the segment length
    [~, r_ibi] = findpeaks(ecg, 'MinPeakProminence', 700, 'MinPeakDistance', 600);
    seg_len    = round(mean(diff(r_ibi)) / C.fs * 1000);

    % R-peak-locked segments
    [~, rlocs] = findpeaks(ecg, 'MinPeakProminence', 700, 'MinPeakDistance', 700);
    segs = zeros(numel(rlocs), seg_len);
    for i = 1:numel(rlocs)
        seg = ecg(rlocs(i):min(numel(ecg), rlocs(i) + seg_len - 1));
        segs(i, 1:numel(seg)) = seg; % zero-padded at the end of the recording
    end
    mean_seg = mean(segs, 1);

    [~, plocs] = findpeaks(mean_seg, 'MinPeakDistance', 300);
    edges_auto(file_idx, :) = [0, plocs(1) - 50, plocs(2) - 100, numel(mean_seg)];

    figure('Visible', 'off');
    findpeaks(mean_seg, 'MinPeakDistance', 300);
    xline(edges_auto(file_idx, 2:3), 'r--');
    title(id);
    saveas(gcf, fullfile(out_dir, [id '_mean_ecg.png']));
    close(gcf);
end

save(fullfile(out_dir, 'edges_auto.mat'), 'edges_auto');
