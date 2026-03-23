%% resp_phase_binned_ERP_N1_P3.m
% Respiration phase binned ERP extraction (N1 & P3)
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
code_path      = 'PATH_TO_YOUR_MATLAB_CODE_FOLDER';
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_EDF_DATA_FOLDER';
label_file     = 'PATH_TO_LABEL_FILE/label.mat';

trials_folder  = 'PATH_TO_TRIALS_FOLDER';
save_folder    = 'PATH_TO_SAVE_ERP_FOLDER';

%% ================= SETUP =================
addpath(code_path)
addpath(fieldtrip_path)
ft_defaults

dataset_files = dir(fullfile(data_folder,'*.edf'));
num_subjects  = length(dataset_files);

load(label_file)

bins = {};

%% ================= LOOP SUBJECTS =================
for file_idx = 1:num_subjects

dataset_filename = fullfile(data_folder,dataset_files(file_idx).name);

%% ================= LOAD TRIALS =================
trials_files = dir(fullfile(trials_folder,'*.mat'));
load(fullfile(trials_folder,trials_files(file_idx).name))

%% ================= RECONSTRUCT TRIALS =================
reconstructed_trials = cell(size(trials{1,1},1),1);

for t = 1:size(trials{1,1},1)

trial_data = zeros(128,size(trials{1},2));

for e = 1:128
trial_data(e,:) = trials{e}(t,:);
end

reconstructed_trials{t} = trial_data;

end

%% ================= RESPIRATION =================
cfg = [];
cfg.dataset = dataset_filename;
cfg.channel = {'Resp'};
Resp = ft_preprocessing(cfg);

resp = Resp.trial{1,1};
respPhase = angle(hilbert(resp));

%% ================= ALIGN TO TARGET =================
phase_data = zeros(length(target_start_time),1);

for t = 1:length(target_start_time)
phase_data(t) = respPhase(target_start_time(t));
end

%% ================= BINNING =================
edges = linspace(-pi,pi,5);   % 4 bins

bin_indices = discretize(phase_data,edges);

numBins = max(bin_indices);

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

%% ================= ERP =================
for b = 1:numBins

bin.trial   = bins{file_idx,b};
bin.fsample = 1000;

timevec = -0.2:0.001:1;
bin.time = repmat({timevec},1,length(bin.trial));
bin.label = label;

cfg = [];
ga_erp = ft_timelockanalysis(cfg,bin);

[~,base_filename,~] = fileparts(dataset_files(file_idx).name);

save(fullfile(save_folder,...
    ['bin' num2str(b) '_' base_filename '.mat']),...
    'ga_erp')

end

end

save('resp_bins.mat','bins','-v7.3')

disp('Resp phase ERP finished')