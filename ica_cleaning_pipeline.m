%% ------------------------------------------------------------------------
% Author: Praghajieeth Raajhen Santhana Gopalan
% Description:
% This script loads cleaned EEG data (after bad channel repair), applies
% line-noise removal, performs ICA decomposition, visualizes components,
% allows manual inspection, rejects selected ICA components, and saves the
% final ICA-cleaned data using FieldTrip.
%% ------------------------------------------------------------------------

clear; clc;

%% ----------------------------- Setup -----------------------------------
% Add FieldTrip to the MATLAB path (modify according to your installation)
addpath('path_to_fieldtrip_folder');
ft_defaults;

% Folder containing cleaned EEG datasets (after channel repair)
data_folder = 'data/clean_channels/';

% List all .mat cleaned EEG files
dataset_files = dir(fullfile(data_folder, '*.mat'));

% ------------------------------------------------------------------------
file_idx = 1;   % Select the file index to process
% ------------------------------------------------------------------------

% Full path to the selected file
dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

%% --------------------- Load cleaned EEG (before ICA) -------------------
load(dataset_filename);  % Loads variable: data_fixed

% Apply DFT filter to remove line noise (50 Hz, 100 Hz, 150 Hz)
cfg = [];
cfg.dftfreq = [50 100 150];
data = ft_preprocessing(cfg, data_fixed);

%% ----------------------------- ICA -------------------------------------
cfg = [];
cfg.continuous  = 'yes';              % Continuous data
cfg.channel     = cellstr(string(1:128));   % Channels 1–128
cfg.method      = 'runica';           % ICA method (EEGLAB runica)
cfg.numcomponent = 30;                % Number of components to extract
cfg.blc         = 'no';

ica = ft_componentanalysis(cfg, data_fixed);

%% ------------------------- Save ICA components --------------------------
ica_folder = 'data/ica_components/';   % Output folder for ICA results

[~, base_filename, ~] = fileparts(dataset_files(file_idx).name);
ica_filename = fullfile(ica_folder, [base_filename '_ICA.mat']);

save(ica_filename, 'ica');

%% ------------------------- Plot ICA topoplots ---------------------------
cfg = [];
cfg.component = 1:30;                     % Components to plot
cfg.layout    = 'resources/GSN-HydroCel-128.sfp';  % EEG sensor layout file
cfg.comment   = 'no';
cfg.marker    = 'no';

ft_topoplotIC(cfg, ica);

%% ----------- Plot ICA time course + topoplots for inspection -----------
cfg = [];
cfg.channel  = [1 2];                     % Components to inspect interactively
cfg.viewmode = 'component';
cfg.layout   = 'resources/GSN-HydroCel-128.sfp';

ft_databrowser(cfg, ica);

%% ------------------ Reload EEG (for component rejection) ----------------
cfg = [];
cfg.dataset  = dataset_filename;          % Original cleaned-channel dataset
cfg.channel  = cellstr(string(1:128));
data = ft_preprocessing(cfg);

%% ------------------- Reject selected ICA components ---------------------
cfg = [];
cfg.component = [3 7 12 16 22];   % Components selected for removal (example)

data_clean = ft_rejectcomponent(cfg, ica, data);

%% ---------------------- Save ICA-cleaned EEG data -----------------------
ica_cleaned_folder = 'data/ica_cleaned/';

ica_cleaned_data_filename = ...
    fullfile(ica_cleaned_folder, [base_filename '_ICAcleaned.mat']);

save(ica_cleaned_data_filename, 'data_clean', '-v7.3');
