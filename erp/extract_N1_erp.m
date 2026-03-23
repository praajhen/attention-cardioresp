%% extract_N1_erp.m
% EEG preprocessing, trial rejection, and ERP extraction pipeline
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
code_path        = 'Matlab code';
fieldtrip_path   = 'path_to_fieldtrip_folder';

data_folder      = 'Data/';
ica_folder       = 'Intermediate files/ICA_cleaned/';
filtered_folder  = 'Intermediate files/BP filtered/';

trials_nc_folder   = 'Intermediate files/trials/NC';
trials_dc_folder   = 'Intermediate files/trials/DC';

erp_nc_folder      = 'Intermediate files/ERP/NC';
erp_dc_folder      = 'Intermediate files/ERP/DC';

%% ================= SETUP =================
addpath(code_path)
addpath(fieldtrip_path)
ft_defaults

dataset_files     = dir(fullfile(data_folder,'*.edf'));
ica_cleaned_files = dir(fullfile(ica_folder,'*.mat'));

num_subjects = length(dataset_files);

%% ================= LOOP SUBJECTS =================
for file_idx = 1:num_subjects

dataset_filename = fullfile(data_folder,dataset_files(file_idx).name);
ica_filename     = fullfile(ica_folder,ica_cleaned_files(file_idx).name);

load(ica_filename) % loads data_clean

%% ================= BANDPASS =================
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq   = [1 30];

data_filtered = ft_preprocessing(cfg,data_clean);

[~,base_filename,~] = fileparts(dataset_files(file_idx).name);

save(fullfile(filtered_folder,[base_filename '.mat']), ...
     'data_filtered','-v7.3')

%% ================= CONDITIONS =================
for cond = 1:2

%% ================= DEFINE TRIALS =================
cfg = [];
cfg.dataset = dataset_filename;
cfg.nr      = cond;
cfg.trialfun = 'mytrialfun';
cfg.trialdef.eventtype = 'annotation';

cfg.channel = cellstr(string(1:128));
cfg.baselinewindow = [-0.2 0];
cfg.demean = 'yes';

cfg  = ft_definetrial(cfg);
data = ft_redefinetrial(cfg,data_filtered);

erp  = ft_preprocessing(cfg,data);

%% ================= TRIAL REJECTION =================
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

%% ================= REREFERENCE =================
cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'avg';
cfg.refchannel = 'all';

erp_trials = ft_preprocessing(cfg,erp);

%% ================= EXTRACT TRIAL MATRICES =================
trials = cell(128,1);

for e = 1:128

tmp = [];

for t = 1:length(erp_trials.trial)
tmp = [tmp; erp_trials.trial{t}(e,:)];
end

trials{e} = tmp;

end

%% ================= TIMINGS =================
if cond == 1
[target_start_time] = ...
target_times(dataset_filename,cond,erp_trials);
else
[cue_start_time,target_start_time] = ...
start_times(dataset_filename,cond,erp_trials);
end

%% ================= SAVE TRIALS =================
if cond == 1

save(fullfile(trials_nc_folder,[base_filename '.mat']), ...
     'trials','target_start_time')

else

save(fullfile(trials_dc_folder,[base_filename '.mat']), ...
     'trials','target_start_time','cue_start_time')

end

%% ================= ERP =================
cfg = [];
ga_erp = ft_timelockanalysis(cfg,erp_trials);

if cond == 1
save(fullfile(erp_nc_folder,[base_filename '.mat']), ...
     'ga_erp')
else
save(fullfile(erp_dc_folder,[base_filename '.mat']), ...
     'ga_erp')
end

end
end

disp('EEG preprocessing pipeline finished')