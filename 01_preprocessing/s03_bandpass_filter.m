%% s03_bandpass_filter
% 1-30 Hz band-pass filter of the ICA-cleaned continuous EEG.
% FieldTrip's default filter (two-pass Butterworth) was used.
% Input : <work_dir>/02_ica/<id>.mat
% Output: <work_dir>/03_filtered/<id>.mat (data_filtered)

clear; clc;
C = ant_config();

out_dir = fullfile(C.work_dir, '03_filtered');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

for file_idx = 1:numel(C.files)
    id = participant_info(C.files(file_idx), C);
    load(fullfile(C.work_dir, '02_ica', [id '.mat']), 'data_clean');

    cfg            = [];
    cfg.bpfilter   = 'yes';
    cfg.bpfreq     = [1 30];
    cfg.bpfilttype = 'but'; % FieldTrip default
    data_filtered  = ft_preprocessing(cfg, data_clean);

    save(fullfile(out_dir, [id '.mat']), 'data_filtered', '-v7.3');
end
