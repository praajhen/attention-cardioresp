%% reaxn_time.m
% Reaction time and respiration phase extraction
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_EDF_DATA_FOLDER';
save_folder    = 'PATH_TO_REACTION_TIME_OUTPUT_FOLDER';

addpath(fieldtrip_path)
ft_defaults

dataset_files = dir(fullfile(data_folder,'*.edf'));
num_subjects  = length(dataset_files);

phase_data = {};
targetMt   = {};

%% ================= CONDITION DEFINITIONS =================
cond_codes = {
    {'23','24'}   % 1 DC
    {'21','22'}   % 2 NC
    {'21','23'}   % 3 congruent
    {'22','24'}   % 4 incongruent
    {'21'}        % 5 nc_con
    {'22'}        % 6 nc_incon
    {'23'}        % 7 dc_con
    {'24'}        % 8 dc_incon
};

%% ================= LOOP SUBJECTS =================
for file_idx = 1:num_subjects

dataset_filename = fullfile(data_folder,dataset_files(file_idx).name);

events = ft_read_event(dataset_filename);

events(arrayfun(@(x) isempty(x.value),events)) = [];

%% extract respiration
cfg = [];
cfg.dataset = dataset_filename;
cfg.channel = 'Resp';
Resp = ft_preprocessing(cfg);

resp = Resp.trial{1,1};
respPhase = angle(hilbert(resp));

%% loop conditions
for cond = 1:8

reactionTime = [];
t_Mt = [];

idx = 1;

for e = 2:length(events)

if strcmp(events(e).value,'8Bit 31')

prev = events(e-1).value;

valid_codes = cond_codes{cond};

for k = 1:length(valid_codes)

if strcmp(prev,['8Bit ' valid_codes{k}])

reactionTime(idx,1) = ...
events(e).sample - events(e-1).sample;

t_Mt(idx,1) = events(e-1).sample;

idx = idx + 1;

end
end
end
end

targetMt{cond,file_idx} = t_Mt;

%% respiration phase
for t = 1:length(t_Mt)
phase_data{cond,file_idx}(t,1) = respPhase(t_Mt(t));
end

%% store reaction time
rxn{cond,file_idx} = reactionTime;

end
end

%% ================= SAVE =================
names = {'dc','nc','cong','incon',...
         'nc_con','nc_incon','dc_con','dc_incon'};

for i = 1:8
tmp = cellfun(@(x) x, rxn(i,:), 'UniformOutput', false);
save(fullfile(save_folder,names{i}), 'tmp','-v7.3')
end

save(fullfile(save_folder,'phase_data'),'phase_data','-v7.3')
save(fullfile(save_folder,'targetMt'),'targetMt','-v7.3')