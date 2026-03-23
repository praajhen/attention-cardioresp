%% respiration_rate.m
% Estimate respiration rate from Resp channel
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
code_path      = 'PATH_TO_YOUR_MATLAB_CODE_FOLDER';
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_EDF_DATA_FOLDER';
output_file    = 'RespirationRates.xlsx';

%% ================= SETUP =================
addpath(code_path)
addpath(fieldtrip_path)
ft_defaults

dataset_files = dir(fullfile(data_folder,'*.edf'));
num_subjects  = length(dataset_files);

respiration_rate_bpm = zeros(num_subjects,1);
respiration_frequency = zeros(num_subjects,1);

%% ================= LOOP SUBJECTS =================
for file_idx = 1:num_subjects

dataset_filename = fullfile(data_folder,dataset_files(file_idx).name);

cfg = [];
cfg.dataset    = dataset_filename;
cfg.channel    = 'Resp';
cfg.bpfilter   = 'yes';
cfg.bpfreq     = [0.1 0.5];
cfg.bpfilttype = 'but';
cfg.bpfiltord  = 2;

Resp = ft_preprocessing(cfg);

resp = Resp.trial{1,1};
fs   = Resp.fsample;

%% ================= PEAK DETECTION =================
[~,locs] = findpeaks(resp);

time_intervals = diff(locs) / fs;
avg_interval   = mean(time_intervals);

respiration_rate_bpm(file_idx) = 60 / avg_interval;
respiration_frequency(file_idx) = 1 / avg_interval;

[~,subject_name,~] = fileparts(dataset_files(file_idx).name);

results{file_idx,1} = subject_name;
results{file_idx,2} = respiration_rate_bpm(file_idx);

end

%% ================= SAVE =================
headers = {'Subject','Respiration Rate (bpm)'};
xlswrite(output_file,[headers; results])

disp('Respiration rate calculation finished')