%% ------------------------------------------------------------------------
% Author: Praghajieeth Raajhen Santhana Gopalan
% Description:
% ICA cleaning pipeline for EEG using FieldTrip
%% ------------------------------------------------------------------------

clear; clc;

%% ================= USER PATHS =================
fieldtrip_path = 'path_to_fieldtrip_folder';
data_folder    = 'data/clean_channels/';
ica_folder     = 'data/ica_components/';
output_folder  = 'data/ica_cleaned/';
layout_file    = 'resources/GSN-HydroCel-128.sfp';

%% ----------------------------- Setup -----------------------------------
addpath(fieldtrip_path);
ft_defaults;

dataset_files = dir(fullfile(data_folder, '*.mat'));

%% --------------------------- loop files --------------------------------
for file_idx = 1:length(dataset_files)

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

%% --------------------- Load cleaned EEG -------------------
load(dataset_filename);  % loads data_fixed

%% --------------------- Line noise removal -----------------
cfg = [];
cfg.dftfreq = [50 100 150];
data = ft_preprocessing(cfg, data_fixed);

%% ----------------------------- ICA -------------------------------------
cfg = [];
cfg.continuous  = 'yes';
cfg.channel     = cellstr(string(1:128));
cfg.method      = 'runica';
cfg.numcomponent = 30;

ica = ft_componentanalysis(cfg, data);

%% ------------------------- Save ICA components --------------------------
[~, base_filename, ~] = fileparts(dataset_files(file_idx).name);

ica_filename = fullfile(ica_folder, ...
    [base_filename '_ICA.mat']);

save(ica_filename,'ica')

%% ------------------------- Plot ICA topoplots ---------------------------
cfg = [];
cfg.component = 1:30;
cfg.layout    = layout_file;
cfg.comment   = 'no';

ft_topoplotIC(cfg, ica);

%% ------------------------- Inspect components --------------------------
cfg = [];
cfg.viewmode = 'component';
cfg.layout   = layout_file;

ft_databrowser(cfg, ica);

%% ------------------- Reject components (edit manually) -----------------
cfg = [];
cfg.component = [3 7 12 16 22];  % edit per subject

data_clean = ft_rejectcomponent(cfg, ica, data);

%% ---------------------- Save cleaned data -------------------------------
ica_cleaned_filename = fullfile(output_folder, ...
    [base_filename '_ICAcleaned.mat']);

save(ica_cleaned_filename,'data_clean','-v7.3')

end

disp('ICA cleaning finished')