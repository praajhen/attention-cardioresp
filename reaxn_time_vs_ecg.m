%% ecg_phase_vs_rxn_time_dc_incon.m
% ECG phase (systole/diastole bins) vs DC incongruent reaction time
% Author: praghajieeth raajhen santhana gopalan

%% DC
clear; clc;

addpath('PATH_TO_FIELDTRIP_FOLDER');   % e.g. C:\...\fieldtrip-20230427
ft_defaults;

load('PATH_TO_REACTION_TIME_FOLDER/targetMt.mat');
load('PATH_TO_REACTION_TIME_FOLDER/dc_incon.mat');

load('PATH_TO_EDGES_FILE/edges.mat');

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';  % Folder containing your datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

%% Reaction time calculation
for file_idx = 1:50 %length(dataset_files)

    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);
    cfg         = [];
    cfg.dataset = dataset_filename;
    cfg.channel = 'ecg';
    ecg         = ft_preprocessing(cfg);

    % Extraction ECG data
    [rpeaks, locs] = findpeaks((ecg.trial{1,1}), 'MinPeakProminence', 700, 'MinPeakDistance', 700);

    % targetMt: 1 row DC, 2 row NC, 3 row con, 4 row incon,5 nc_con, 6 nc_incon,
    % 7 dc_con, 8 dc_incon

    differences = {};
    cond = 8;
    for t = 1:length(targetMt{cond,file_idx})
        [~, index] = max(locs(locs <= targetMt{cond,file_idx}(t))); % Find the nearest lower value from rpeaks location matrix
        differences{1,file_idx}(t,1) = targetMt{cond,file_idx}(t) - locs(index);  %
    end

    plot_ecg = differences{1, file_idx}(:,:);
    plot_rxn = dc_incon_reaxn_time{1,file_idx}(:,:); %change here

    % Define the bin edges
    edges = edge(file_idx,:); % 3 bins; 1 systole and 2 diastole

    % Group data into bins
    bin_indices = discretize(plot_ecg, edges);
    all_sub_binIndices{file_idx} = bin_indices;
end


%% sort rxn time based on bins

num_bins     = 3;   % number of bins
num_subjects = 50;  % number of subjects

% Initialize a cell array to store rxn time for each bin for each subject
rxn_by_bin = cell(num_bins, num_subjects);

% Loop through each subject
for subject = 1:num_subjects
    bin_indices = all_sub_binIndices{subject}; % Get the bin indices for the current subject
    plot_rxn    = dc_incon_reaxn_time{1,subject}(:,:); %change here

    % Loop through each bin
    for bin = 1:num_bins
        % Find rxn time for the current subject within the current bin
        plot_rxn_in_bin = plot_rxn(bin_indices == bin);

        % Store rxn time for the current subject and bin
        rxn_by_bin_dc_incon{bin, subject} = plot_rxn_in_bin;
    end
end


for i = 1:50
    for j = 1:3
        if i ~= 16 % remove subject 16
            mean_rxn_dc_incon{i, j} = mean(rxn_by_bin_dc_incon{j, i});
        end
    end
end



%% Rearrange rxn time as bins

% Initialize a cell array to store concatenated rxn time for each bin
bin_data = cell(1, num_bins);

for bin = 1:num_bins
    % Initialize an empty array to store concatenated rxn time for the current bin
    current_bin_data = [];

    % Loop through each subject
    for subject = 1:num_subjects
        % Extract N1 amplitudes for the current subject in the current bin
        a = rxn_by_bin_dc{bin, subject};

        % Concatenate rxn time vertically for the current subject and bin
        current_bin_data = [current_bin_data; a];
    end

    % Store concatenated rxn time for the current bin in the cell array
    bin_data{bin} = current_bin_data;
end



%% Mean rxn time of each bins

for i = 1:3
    data = bin_data{1, i};
    mean_values_nc_e(i) = mean(data);
    std_deviation       = std(data);
    sem_values_nc_e(i)  = std_deviation / sqrt(size(data, 1));
end



%% extra code

figure;

% Plotting with error bars for each group
h1 = errorbar(mean_values_nc,   sem_values_nc,   'o-', 'LineWidth', 1.2, 'MarkerSize', 8, 'CapSize', 10);
hold on;
h2 = errorbar(mean_values_dc,   sem_values_dc,   'o-', 'LineWidth', 1.2, 'MarkerSize', 8, 'CapSize', 10);
h3 = errorbar(mean_values_nc_e, sem_values_nc_e, 'o-', 'LineWidth', 1.2, 'MarkerSize', 8, 'CapSize', 10);
h4 = errorbar(mean_values_dc_e, sem_values_dc_e, 'o-', 'LineWidth', 1.2, 'MarkerSize', 8, 'CapSize', 10);

% Customizing the plot
set(gca, 'FontSize', 15, 'FontName', 'Arial');
xlabel('X-axis Label', 'FontSize', 15, 'FontName', 'Arial');
ylabel('Y-axis Label', 'FontSize', 15, 'FontName', 'Arial');
title('Mean and SEM Plot', 'FontSize', 18, 'FontName', 'Arial');

xlim([0 4]);
% Adding legend with labels
legend([h1, h2, h3, h4], 'nc', 'dc', 'nc-elderly', 'dc-elderly');


b = 1:3;

figure;
scatter(b, m, 50, 'b', 'filled');
hold on;
errorbar(b, m, sd, 'k.','LineWidth', 0.5);  % Calculate error lines for standard deviation
hold off;
xlim ([0 4])
xlabel('Bins (systole + diastole)');
ylabel('Mean reaxn time of DC in ms');
title('Scatter Plot of DC mean rxn time vs. ECG');


%% Box plot

% Create a cell array to store N1 amplitudes for each bin, padding with NaN if necessary
max_length      = max(cellfun(@length, bin_data));
padded_bin_data = cellfun(@(x) [x; nan(max_length - length(x), 1)], bin_data, 'UniformOutput', false);

% Combine the padded bin data into a matrix
combined_data = cell2mat(padded_bin_data);

% Create a grouped box plot for all bins in a single figure
figure;
boxplot(combined_data, 'Labels', 1:num_bins);
xlabel('Bins (systole + diastole)');
ylabel('Mean reaxn time in ms');
title('Grouped Box Plot of NC mean rxn time for All Bins');
