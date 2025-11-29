%% ------------------------------------------------------------------------
%  Author: Praghajieeth Raajhen Santhana Gopalan
%  Description:
%  Script for loading EDF EEG data, visually inspecting channels,
%  identifying bad channels, repairing them using neighbour interpolation,
%  and saving the cleaned dataset using FieldTrip.
%% ------------------------------------------------------------------------

clear; clc;

%% ------------------------- FieldTrip setup -----------------------------
% Add FieldTrip to MATLAB path (modify to your installation path)
addpath('path_to_fieldtrip_folder');  
ft_defaults;  % Initialize FieldTrip defaults

% Folder containing raw .edf datasets (use relative or placeholder path)
data_folder = 'path_to_raw_edf_files/';

% List all .edf files in the data folder
dataset_files = dir(fullfile(data_folder, '*.edf'));

%% --------------------- Select the file to process ----------------------
file_idx = 1;  % Select EDF file by index (adjust as needed)

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

%% ------------------------- Load EEG data ------------------------------
cfg            = [];
cfg.dataset    = dataset_filename;     % EDF file to read
cfg.channel    = cellstr(string(1:128));  % Channels '1' to '128'
data           = ft_preprocessing(cfg);   % Read continuous EEG

%% ------------------------- EEG data browser ---------------------------
cfg = [];
cfg.ylim           = [-82 82];     % Scale for visualization
cfg.channel        = cellstr(string(1:128));
cfg.layout         = 'path_to_layout_file/GSN-HydroCel-128.sfp'; % Electrode layout
cfg.viewmode       = 'vertical';
cfg.blocksize      = 5;
cfg.artifactalpha  = 0.8;

% Launch the FieldTrip browser for inspection
artifInfo = ft_databrowser(cfg, data);

%% ------------------------- EEG locations ------------------------------
% Load electrode positions (sfp file)
elec = ft_read_sens('path_to_layout_file/GSN-HydroCel-128.sfp','senstype','eeg');

% Load neighbour structure for interpolation
load('path_to_neighbour_file/neighbours.mat');

% Load layout file (used for plotting inside FieldTrip)
load('path_to_layout_file/layout.mat');

%% ------------------------- Mark bad channels ---------------------------
% Manually specify bad channels (example)
artifInfo.badchannel = {'55','90','65','54','123'};

%% ------------------------- Interpolate bad channels --------------------
cfg = [];
cfg.badchannel = artifInfo.badchannel;   % Channels to fix
cfg.method     = 'average';              % Interpolation method
cfg.neighbours = neighbours;             % Neighbour structure
cfg.elec       = elec;                   % Electrode coordinates

data_fixed = ft_channelrepair(cfg, data);

%% ------------------------- Save cleaned data ---------------------------
clean_channels_data_folder = 'path_to_output_folder/clean_channels/';

% Extract EDF filename without extension
[~, base_filename, ~] = fileparts(dataset_files(file_idx).name);

% Save the cleaned EEG data
clean_channels_filename = fullfile(clean_channels_data_folder, [base_filename '.mat']);
save(clean_channels_filename, 'data_fixed','-v7.3');

%% ------------------------- Additional reference code -------------------
% (Kept for reproducibility)

% % To create layout file:
% cfg = [];
% cfg.layout = 'path_to_layout_file/GSN-HydroCel-128.sfp';
% layout = ft_prepare_layout(cfg);
% save('layout.mat','layout')

% % To create neighbours file:
% cfg = [];
% cfg.method = 'triangulation';
% cfg.layout = layout;
% cfg.feedback = 'yes';
% neighbours = ft_prepare_neighbours(cfg, layout);
% save('neighbours.mat', 'neighbours');

%% ------------------------- Plot raw vs repaired data -------------------
% Visual check of interpolation
plot(data.trial{1,1}(2000:5000));  % Raw data
hold on;
plot(data_fixed.trial{1,1}(2000:5000));  % Repaired data
title('Raw vs. Interpolated EEG Segment');
legend('Raw','Interpolated');
