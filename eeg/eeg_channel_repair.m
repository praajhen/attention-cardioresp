%% ------------------------------------------------------------------------
%  Author: Praghajieeth Raajhen Santhana Gopalan
%  Description:
%  Load EDF EEG data, identify bad channels, repair using interpolation,
%  and save cleaned dataset (FieldTrip)
%% ------------------------------------------------------------------------

clear; clc;

%% ================= USER PATHS =================
fieldtrip_path  = 'path_to_fieldtrip_folder';
data_folder     = 'path_to_raw_edf_files/';
layout_file     = 'path_to_layout_file/GSN-HydroCel-128.sfp';
neighbour_file  = 'path_to_neighbour_file/neighbours.mat';
output_folder   = 'path_to_output_folder/clean_channels/';

%% ------------------------- FieldTrip setup -----------------------------
addpath(fieldtrip_path);
ft_defaults;

dataset_files = dir(fullfile(data_folder, '*.edf'));

%% --------------------- loop through files ------------------------------
for file_idx = 1:length(dataset_files)

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

%% ------------------------- Load EEG data ------------------------------
cfg = [];
cfg.dataset = dataset_filename;
cfg.channel = cellstr(string(1:128));
data = ft_preprocessing(cfg);

%% ------------------------- Visual inspection --------------------------
cfg = [];
cfg.ylim = [-82 82];
cfg.channel = cellstr(string(1:128));
cfg.layout = layout_file;
cfg.viewmode = 'vertical';
cfg.blocksize = 5;

artifInfo = ft_databrowser(cfg, data);

%% ------------------------- EEG locations ------------------------------
elec = ft_read_sens(layout_file,'senstype','eeg');
load(neighbour_file);

%% ------------------------- Mark bad channels ---------------------------
% example (edit per subject)
artifInfo.badchannel = {'55','90','65','54','123'};

%% ------------------------- Interpolate bad channels --------------------
cfg = [];
cfg.badchannel = artifInfo.badchannel;
cfg.method     = 'average';
cfg.neighbours = neighbours;
cfg.elec       = elec;

data_fixed = ft_channelrepair(cfg, data);

%% ------------------------- Save cleaned data ---------------------------
[~, base_filename, ~] = fileparts(dataset_files(file_idx).name);

clean_filename = fullfile(output_folder,[base_filename '.mat']);

save(clean_filename,'data_fixed','-v7.3');

end

disp('EEG channel repair completed')