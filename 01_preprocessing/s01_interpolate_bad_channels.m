%% s01_interpolate_bad_channels
% Visual inspection of raw EEG and interpolation of bad channels
% (FieldTrip 'average' method). Run once per participant.
% Input : raw .edf
% Output: <work_dir>/01_interpolated/<id>.mat (data_fixed)

clear; clc;
C = ant_config();

%--------------------------------------------------------------------------
file_idx   = 1;   % participant to process
badchannel = {};  % e.g. {'55','90','65','54','123'}, chosen after browsing
%--------------------------------------------------------------------------

dataset = fullfile(C.raw_dir, C.files(file_idx).name);
[id]    = participant_info(C.files(file_idx), C);

% Read EEG
cfg         = [];
cfg.dataset = dataset;
cfg.channel = C.channels;
data        = ft_preprocessing(cfg);

% Browse the data to identify bad channels
cfg           = [];
cfg.ylim      = [-82 82];
cfg.layout    = C.layout;
cfg.viewmode  = 'vertical';
cfg.blocksize = 5;
ft_databrowser(cfg, data);

% Sensors and neighbours (triangulation on the 2D layout)
elec = ft_read_sens(C.layout, 'senstype', 'eeg');

cfg        = [];
cfg.layout = C.layout;
layout     = ft_prepare_layout(cfg);

cfg          = [];
cfg.method   = 'triangulation';
cfg.layout   = layout;
neighbours   = ft_prepare_neighbours(cfg, layout);

% Interpolate
cfg            = [];
cfg.badchannel = badchannel;
cfg.method     = 'average';
cfg.neighbours = neighbours;
cfg.elec       = elec;
data_fixed     = ft_channelrepair(cfg, data);

out_dir = fullfile(C.work_dir, '01_interpolated');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
save(fullfile(out_dir, [id '.mat']), 'data_fixed', 'badchannel', '-v7.3');
