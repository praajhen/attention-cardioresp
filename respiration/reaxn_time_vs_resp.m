%% reaxn_time_vs_resp.m
% Respiration phase vs reaction time (incongruent condition)
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
phase_file = 'PATH_TO_REACTION_TIME_FOLDER/phase_data.mat';
rxn_file   = 'PATH_TO_REACTION_TIME_FOLDER/incon.mat';
save_folder = 'PATH_TO_OUTPUT_FOLDER_FOR_RESP_RXN';

%% ================= LOAD =================
load(phase_file)
load(rxn_file)

num_subjects = size(phase_data,2);
num_bins = 2;

%% ================= BINNING =================
all_sub_binIndices = cell(1,num_subjects);

for file_idx = 1:num_subjects

cue_cond = 4; % incongruent

plot_phase = phase_data{cue_cond,file_idx};
plot_rxn   = incon_reaxn_time{1,file_idx};

edges = linspace(-pi,pi,num_bins+1);

bin_indices = discretize(plot_phase,edges);

all_sub_binIndices{file_idx} = bin_indices;

end

%% ================= SORT RXN =================
resp_vs_rxn = cell(num_bins,num_subjects);

for subject = 1:num_subjects

bin_indices = all_sub_binIndices{subject};
plot_rxn    = incon_reaxn_time{1,subject};

for bin = 1:num_bins
resp_vs_rxn{bin,subject} = plot_rxn(bin_indices==bin);
end

end

%% ================= CONCATENATE =================
bin_data = cell(1,num_bins);

for bin = 1:num_bins

tmp = [];

for subject = 1:num_subjects
tmp = [tmp; resp_vs_rxn{bin,subject}];
end

bin_data{bin} = tmp;

end

%% ================= STATS =================
mean_values = zeros(1,num_bins);
sem_values  = zeros(1,num_bins);

for b = 1:num_bins

data = bin_data{b};

mean_values(b) = mean(data);
sem_values(b)  = std(data)/sqrt(length(data));

end

%% ================= SAVE =================
save(fullfile(save_folder,'resp_phase_vs_rxn.mat'), ...
    'resp_vs_rxn','mean_values','sem_values')

%% ================= PLOT =================
figure

errorbar(1:num_bins,mean_values,sem_values,'o-','LineWidth',1.5)

xlabel('Respiration phase bin')
ylabel('Reaction time (ms)')
title('Respiration phase vs reaction time')

%% ================= BOX PLOT =================
max_len = max(cellfun(@length,bin_data));

padded = cellfun(@(x)[x;nan(max_len-length(x),1)], ...
                 bin_data,'UniformOutput',false);

combined = cell2mat(padded);

figure
boxplot(combined,'Labels',1:num_bins)

xlabel('Respiration phase bin')
ylabel('Reaction time (ms)')