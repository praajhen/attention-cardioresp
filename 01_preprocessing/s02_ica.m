%% s02_ica
% ICA (runica, 30 components) on the interpolated continuous EEG, then
% removal of ocular and cardiac (heartbeat-evoked) components selected by
% topography and time course. Run in two steps per participant.
% Input : <work_dir>/01_interpolated/<id>.mat
% Output: <work_dir>/02_ica/<id>_ica.mat (ica), <work_dir>/02_ica/<id>.mat (data_clean)
%
% Note: runica starts from random weights, so a new run gives a different
% decomposition. Component numbers are only valid for the saved ica file.

clear; clc;
C = ant_config();

%--------------------------------------------------------------------------
file_idx = 1;  % participant to process
reject   = []; % components to remove, e.g. [3 7 12 16 22] (fill in at step 2)
%--------------------------------------------------------------------------

id      = participant_info(C.files(file_idx), C);
out_dir = fullfile(C.work_dir, '02_ica');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
load(fullfile(C.work_dir, '01_interpolated', [id '.mat']), 'data_fixed');

ica_file = fullfile(out_dir, [id '_ica.mat']);

%% Step 1: decompose and inspect
if ~exist(ica_file, 'file')
    cfg              = [];
    cfg.method       = 'runica';
    cfg.numcomponent = 30;
    ica = ft_componentanalysis(cfg, data_fixed);
    save(ica_file, 'ica');
else
    load(ica_file, 'ica');
end

cfg           = [];
cfg.component = 1:30;
cfg.layout    = C.layout;
cfg.comment   = 'no';
cfg.marker    = 'no';
ft_topoplotIC(cfg, ica);

cfg          = [];
cfg.viewmode = 'component';
cfg.layout   = C.layout;
ft_databrowser(cfg, ica);

%% Step 2: remove selected components (set 'reject' above, then run)
if ~isempty(reject)
    cfg           = [];
    cfg.component = reject;
    data_clean    = ft_rejectcomponent(cfg, ica, data_fixed);
    save(fullfile(out_dir, [id '.mat']), 'data_clean', 'reject', '-v7.3');
end
