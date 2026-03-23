%% ecg_phase_vs_rxn_time_dc_incon.m
% ECG phase (systole/diastole bins) vs DC incongruent reaction time
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_EDF_DATA_FOLDER';
reaction_path  = 'PATH_TO_REACTION_TIME_FOLDER';
edges_file     = 'PATH_TO_EDGES_FILE/edges.mat';

%% ================= SETUP =================
addpath(fieldtrip_path);
ft_defaults;

load(fullfile(reaction_path,'targetMt.mat'));
load(fullfile(reaction_path,'dc_incon.mat'));
load(edges_file);

dataset_files = dir(fullfile(data_folder, '*.edf'));
num_subjects  = length(dataset_files);

%% ================= ECG phase extraction =================

for file_idx = 1:num_subjects

    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    cfg = [];
    cfg.dataset = dataset_filename;
    cfg.channel = 'ecg';
    ecg = ft_preprocessing(cfg);

    %% R peaks
    [~, locs] = findpeaks(ecg.trial{1,1}, ...
        'MinPeakProminence',700, ...
        'MinPeakDistance',700);

    cond = 8; % dc incon

    for t = 1:length(targetMt{cond,file_idx})

        [~, index] = max(locs(locs <= targetMt{cond,file_idx}(t)));

        differences{file_idx}(t,1) = ...
            targetMt{cond,file_idx}(t) - locs(index);

    end

    plot_ecg = differences{file_idx};
    plot_rxn = dc_incon_reaxn_time{1,file_idx};

    %% bins
    subj_edges = edges(file_idx,:);
    bin_indices = discretize(plot_ecg, subj_edges);

    all_sub_binIndices{file_idx} = bin_indices;

end

%% ================= sort rxn by bin =================

num_bins = 3;

for subject = 1:num_subjects

    bin_indices = all_sub_binIndices{subject};
    plot_rxn    = dc_incon_reaxn_time{1,subject};

    for bin = 1:num_bins
        rxn_by_bin{bin, subject} = ...
            plot_rxn(bin_indices == bin);
    end

end

%% ================= mean per subject =================

for subj = 1:num_subjects
    for bin = 1:num_bins

        if subj ~= 16 % remove subject 16
            mean_rxn{subj,bin} = ...
                mean(rxn_by_bin{bin,subj});
        end

    end
end

%% ================= concatenate bins =================

for bin = 1:num_bins

    current_bin = [];

    for subject = 1:num_subjects

        current_bin = [current_bin; rxn_by_bin{bin,subject}];

    end

    bin_data{bin} = current_bin;

end

%% ================= mean + SEM =================

for i = 1:num_bins

    data = bin_data{i};

    mean_values(i) = mean(data);
    sem_values(i)  = std(data)/sqrt(length(data));

end

%% ================= plot =================

figure;
errorbar(1:3, mean_values, sem_values,'o-','LineWidth',1.5)

xlabel('Cardiac phase bins')
ylabel('Reaction time (ms)')
title('DC incon reaction time vs cardiac phase')

set(gca,'FontSize',14)