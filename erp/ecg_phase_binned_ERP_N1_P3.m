%% ecg_phase_binned_ERP_N1_P3.m
% Bin trials by ECG phase (systole/diastole) for N1 and P3 ERPs
% Author: praghajieeth raajhen santhana gopalan

clear; clc

%% ================= USER PATHS =================
code_path      = 'PATH_TO_YOUR_MATLAB_CODE_FOLDER';
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_EDF_DATA_FOLDER';

edges_file     = 'PATH_TO_EDGES_FILE/edges.mat';
label_file     = 'PATH_TO_LABEL_FILE/label.mat';

trials_cong_folder  = 'PATH_TO_TRIALS_CONG_FOLDER';
trials_incon_folder = 'PATH_TO_TRIALS_INCON_FOLDER';

erp_bin1_folder = 'PATH_TO_ERP_BIN1_FOLDER';
erp_bin2_folder = 'PATH_TO_ERP_BIN2_FOLDER';
erp_bin3_folder = 'PATH_TO_ERP_BIN3_FOLDER';

%% ================= SETUP =================
addpath(code_path)
addpath(fieldtrip_path)
ft_defaults

dataset_files = dir(fullfile(data_folder, '*.edf'));
num_subjects  = length(dataset_files);

load(edges_file)
load(label_file)

bins = {};

%% ================= LOOP SUBJECTS =================
for file_idx = 1:num_subjects

dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

%% ================= LOAD TRIALS =================
trials_files = dir(fullfile(trials_cong_folder,'*.mat'));
trials_filename = fullfile(trials_cong_folder,trials_files(file_idx).name);
load(trials_filename)

%% ================= RECONSTRUCT TRIALS =================
reconstructed_trials = cell(size(trials{1,1},1),1);

for trial_idx = 1:size(trials{1,1},1)

    trial_data = zeros(128,size(trials{1},2));

    for electrode_idx = 1:128
        trial_data(electrode_idx,:) = ...
            trials{electrode_idx}(trial_idx,:);
    end

    reconstructed_trials{trial_idx} = trial_data;

end

%% ================= ECG =================
cfg = [];
cfg.dataset = dataset_filename;
cfg.channel = 'ecg';
ecg = ft_preprocessing(cfg);

[~,locs] = findpeaks(ecg.trial{1,1}, ...
    'MinPeakProminence',600, ...
    'MinPeakDistance',500);

%% ================= ALIGN TO R PEAK =================
differences = zeros(length(target_start_time),1);

for t = 1:length(target_start_time)

    [~,index] = max(locs(locs <= target_start_time(t)));
    differences(t) = target_start_time(t) - locs(index);

end

%% ================= BINNING =================
subj_edges = edges(file_idx,:);

bin_indices = discretize(differences,subj_edges);

nan_indices = isnan(bin_indices);
bin_indices(nan_indices) = 3;

%% ================= SORT TRIALS =================
numBins = 3;
binMatrices = cell(1,numBins);

for b = 1:numBins
    binMatrices{b} = {};
end

for trialIdx = 1:length(bin_indices)

    binIndex = bin_indices(trialIdx);
    trialData = reconstructed_trials{trialIdx};

    binMatrices{binIndex}{end+1} = trialData;

end

bins = [bins; binMatrices];

%% ================= BIN 1 ERP =================
bin1.trial   = bins{file_idx,1};
bin1.fsample = 1000;

timevec = -0.2:0.001:1;
bin1.time = repmat({timevec},1,length(bin1.trial));
bin1.label = label;

cfg = [];
ga_erp_1 = ft_timelockanalysis(cfg,bin1);

[~,base_filename,~] = fileparts(dataset_files(file_idx).name);
save(fullfile(erp_bin1_folder,[base_filename '.mat']),'ga_erp_1')

%% ================= BIN 2 ERP =================
bin2.trial   = bins{file_idx,2};
bin2.fsample = 1000;

bin2.time = repmat({timevec},1,length(bin2.trial));
bin2.label = label;

cfg = [];
ga_erp_2 = ft_timelockanalysis(cfg,bin2);

save(fullfile(erp_bin2_folder,[base_filename '.mat']),'ga_erp_2')

%% ================= BIN 3 ERP =================
bin3.trial   = bins{file_idx,3};
bin3.fsample = 1000;

bin3.time = repmat({timevec},1,length(bin3.trial));
bin3.label = label;

cfg = [];
ga_erp_3 = ft_timelockanalysis(cfg,bin3);

save(fullfile(erp_bin3_folder,[base_filename '.mat']),'ga_erp_3')

end

save('bins.mat','bins','-v7.3')

disp('ECG phase binned ERP finished')