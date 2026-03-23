%% extract_P3_erp.m
% ERP extraction and trial segmentation script
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
code_path        = 'PATH_TO_YOUR_CODE_FOLDER';
fieldtrip_path   = 'PATH_TO_FIELDTRIP_FOLDER';

data_folder      = 'PATH_TO_RAW_DATA_FOLDER';
filtered_folder  = 'PATH_TO_FILTERED_DATA_FOLDER';

trialfun_path    = 'PATH_TO_TRIAL_FUNCTION_FOLDER';

trials_cong_folder  = 'PATH_TO_SAVE_TRIALS_CONGRUENT';
trials_incon_folder = 'PATH_TO_SAVE_TRIALS_INCONGRUENT';

erp_cong_folder     = 'PATH_TO_SAVE_ERP_CONGRUENT';
erp_incon_folder    = 'PATH_TO_SAVE_ERP_INCONGRUENT';

%% ================= SETUP =================
addpath(code_path)
addpath(fieldtrip_path)
addpath(trialfun_path)

ft_defaults

dataset_files  = dir(fullfile(data_folder,'*.edf'));
filtered_files = dir(fullfile(filtered_folder,'*.mat'));

num_subjects = length(dataset_files);

%% ================= LOOP SUBJECTS =================
for file_idx = 1:num_subjects

dataset_filename  = fullfile(data_folder,dataset_files(file_idx).name);
filtered_filename = fullfile(filtered_folder,filtered_files(file_idx).name);

load(filtered_filename) % loads data_filtered

%% ================= CONDITIONS =================
for cond = 3:4

%% ---------------- Define trials ----------------
cfg = [];
cfg.dataset = dataset_filename;
cfg.nr      = cond;
cfg.trialfun = 'erp_1500ms';
cfg.trialdef.eventtype = 'annotation';

cfg.channel = arrayfun(@num2str,1:128,'UniformOutput',false);
cfg.baselinewindow = [-0.2 0];
cfg.demean = 'yes';

cfg  = ft_definetrial(cfg);
data = ft_redefinetrial(cfg,data_filtered);
erp  = ft_preprocessing(cfg,data);

%% ---------------- Trial rejection ----------------
numTrials = length(erp.trial);

threshold_low  = 175;
threshold_high = 300;
max_zero_columns = 25;

reject_trial = false(1,numTrials);

for tr = 1:numTrials

difftrial = max(erp.trial{tr}(:,150:end),[],2) - ...
            min(erp.trial{tr}(:,150:end),[],2);

if any(difftrial > threshold_high)
    reject_trial(tr) = true;
else
    zeroCount = sum(difftrial > threshold_low);
    if zeroCount > max_zero_columns
        reject_trial(tr) = true;
    end
end

end

clean_trials = find(~reject_trial);

erp.sampleinfo = erp.sampleinfo(clean_trials,:);
erp.trial      = erp.trial(clean_trials);
erp.time       = erp.time(clean_trials);

%% ---------------- Rereference ----------------
cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'avg';
cfg.refchannel = 'all';

erp_trials = ft_preprocessing(cfg,erp);

%% ---------------- Extract trials ----------------
trials = cell(128,1);

for e = 1:128

tmp = [];

for t = 1:length(erp_trials.trial)
tmp = [tmp; erp_trials.trial{t}(e,:)];
end

trials{e} = tmp;

end

%% ---------------- Timing ----------------
[target_start_time] = ...
target_start_times_inhibition(dataset_filename,cond,erp_trials);

[~,base_filename,~] = fileparts(dataset_files(file_idx).name);

%% ---------------- Save trials ----------------
if cond == 3
save(fullfile(trials_cong_folder,[base_filename '.mat']), ...
     'trials','target_start_time')
else
save(fullfile(trials_incon_folder,[base_filename '.mat']), ...
     'trials','target_start_time')
end

%% ---------------- ERP ----------------
cfg = [];
ga_erp = ft_timelockanalysis(cfg,erp_trials);

%% ---------------- Save ERP ----------------
if cond == 3
save(fullfile(erp_cong_folder,[base_filename '.mat']),'ga_erp')
else
save(fullfile(erp_incon_folder,[base_filename '.mat']),'ga_erp')
end

end
end

disp('ERP pipeline finished')