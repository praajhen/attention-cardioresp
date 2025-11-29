%% resp_phase_vs_reactiontime_incon_bins.m
% Bin reaction times by respiration phase (incongruent condition)
% Author: praghajieeth raajhen santhana gopalan

%% DC
clear; clc;

load('PATH_TO_REACTION_TIME_FOLDER/phase_data.mat');
load('PATH_TO_REACTION_TIME_FOLDER/incon.mat');
% load('PATH_TO_REACTION_TIME_FOLDER/nc.mat');

data_folder   = 'PATH_TO_EDF_DATA_FOLDER';     % Folder containing your EDF datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

%% Reaction time calculation
for file_idx = 1:50 %length(dataset_files)

    cue_cond = 4; % 1 DC, 2 NC, 3 CON, 4 INCON, 5 nc_con, 6 nc_incon, 7 dc_con, 8 dc_incon

    plot_phase  = phase_data{cue_cond, file_idx}(:,:);
    plot_rxn    = incon_reaxn_time{1,file_idx}(:,:); %change here

    % Define the bin edges
    edges = linspace(-3.14, 3.14, 3); % 10 bins on each side of 0

    % Group data into bins
    bin_indices = discretize(plot_phase, edges);
    all_sub_binIndices{file_idx} = bin_indices;

end


%% sort rxn time based on bins

num_bins     = 2;   % number of bins
num_subjects = 50;  % number of subjects

% Initialize a cell array to store N1 amplitudes for each bin for each subject
rxn_by_bin = cell(num_bins, num_subjects);

% Loop through each subject
for subject = 1:num_subjects
    bin_indices = all_sub_binIndices{subject};          % Get the bin indices for the current subject
    plot_rxn    = incon_reaxn_time{1,subject}(:,:);     % change here

    % Loop through each bin
    for bin = 1:num_bins
        % Find rxn time for the current subject within the current bin
        plot_rxn_in_bin = plot_rxn(bin_indices == bin);

        % Store rxn time for the current subject and bin
        resp_vs_rxn_time_incon{bin, subject} = plot_rxn_in_bin;
    end
end

for i = 1:50
    for j = 1:2
        % if i ~= 16 % remove subject 16
        mean_rxn_incon{i, j} = mean(resp_vs_rxn_time_incon{j, i});
        % end
    end
end


%% Rearrange rxn time as bins

% Initialize a cell array to store concatenated N1 amplitudes for each bin
bin_data_nc = cell(1, num_bins);

for bin = 1:num_bins
    % Initialize an empty array to store concatenated N1 amplitudes for the current bin
    current_bin_data = [];

    % Loop through each subject
    for subject = 1:num_subjects
        % Extract N1 amplitudes for the current subject in the current bin
        a = resp_vs_rxn_time_nc{bin, subject};

        % Concatenate N1 amplitudes vertically for the current subject and bin
        current_bin_data = [current_bin_data; a];
    end

    % Store concatenated N1 amplitudes for the current bin in the cell array
    bin_data_nc{bin} = current_bin_data;
end


% Mean rxn time of each bins

for i = 1:2
    data = bin_data_dc{1, i};
    mean_values_incon_e(i) = mean(data);
    std_deviation          = std(data);
    sem_values_incon_e(i)  = std_deviation / sqrt(size(data, 1));
end


folder = 'PATH_TO_OUTPUT_FOLDER_FOR_RESP_RXN'; 

filename = fullfile(folder,'resp vs. reaxn time');
save(filename, 'resp_vs_rxn_time_dc','-v7.3');
     
     
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

xlim([0 11]);
% Adding legend with labels
legend([h1, h2, h3, h4], 'nc', 'dc', 'nc-elderly', 'dc-elderly');


%% Box plot

% Create a cell array to store N1 amplitudes for each bin, padding with NaN if necessary
max_length      = max(cellfun(@length, bin_data));
padded_bin_data = cellfun(@(x) [x; nan(max_length - length(x), 1)], bin_data, 'UniformOutput', false);

% Combine the padded bin data into a matrix
combined_data = cell2mat(padded_bin_data);

% Create a grouped box plot for all bins in a single figure
figure;
boxplot(combined_data, 'Labels', 1:num_bins);
xlabel('Breathing phase in bins (range: -3.14 to 3.14 rad)');
ylabel('Mean reaxn time in ms');
title('Grouped Box Plot of DC mean rxn time for All Bins');
