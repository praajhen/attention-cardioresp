%% compute_reaction_times_and_resp_phase.m
% Reaction time and respiration phase extraction from ANT triggers
% Author: praghajieeth raajhen santhana gopalan

%% Fieldtrip
clear

addpath('PATH_TO_FIELDTRIP_FOLDER');  % e.g. C:\...\fieldtrip-20230427
ft_defaults

data_folder = 'PATH_TO_EDF_DATA_FOLDER';  % Folder containing your EDF datasets
dataset_files = dir(fullfile(data_folder, '*.edf'));  % List all .edf files in the folder

phase_data = {};

%% Reaction time calculation for DC
for file_idx = 1:50 %length(dataset_files)
    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    events = ft_read_event(dataset_filename);

    % Initialize a new cell array to store the selected data
    selectedData = cell(0, 2); % Assuming 2 columns for 'value' and 'sample'

    % Define the values you want to select
    desiredValues = {'8Bit 21', '8Bit 22', '8Bit 23', '8Bit 24', '8Bit 31','8Bit 32','8Bit 33'};

    % Loop through the structure and select the data based on the desired values
    for i = 1:numel(events)
        if any(strcmp(events(i).value, desiredValues))
            selectedData(end+1, :) = {events(i).value, events(i).sample};
        end
    end

    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);

    t_Mt = [];
    % Loop through the selectedData and calculate reaction times

    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 23') || strcmp(prev_event, '8Bit 24') % 21,22 nc and 23,24 dc
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    doublecue_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{1,file_idx} = t_Mt(nonZeroDC);

    channel = {'Resp','ecg','90'};
    for j = 1
        cfg            = [];
        cfg.trialfun   = 'mytrialfun';
        cfg.dataset    = dataset_filename;
        cfg.channel    = channel(j);
        Resp(j)        = ft_preprocessing(cfg);
    end

    resp = Resp.trial{1,1}; %complete resp data
    respPhase = angle(hilbert(resp)); % Angle and Hilbert transform of respiration data

    % Extract respiration phase
    for t = 1:length(targetMt{1,file_idx})
        phase_data{1,file_idx}(t,1) = respPhase(1, targetMt{1,file_idx}(t));
    end

%% Reaction time calculation for NC
       
    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);
    t_Mt = [];

    % Loop through the selectedData and calculate reaction times
    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 21') || strcmp(prev_event, '8Bit 22') % 21,22 nc and 23,24 dc
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    no_cue_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{2,file_idx} = t_Mt(nonZeroDC);

    % Extract respiration phase
    for t = 1:length(targetMt{2,file_idx})
        phase_data{2,file_idx}(t,1) = respPhase(1, targetMt{2,file_idx}(t));
    end

%% Reaction time calculation for congruent
       
    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);
    t_Mt = [];

    % Loop through the selectedData and calculate reaction times
    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 21') || strcmp(prev_event, '8Bit 23') % 21,23 congruent
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    con_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{3,file_idx} = t_Mt(nonZeroDC);

    % Extract respiration phase
    for t = 1:length(targetMt{3,file_idx})
        phase_data{3,file_idx}(t,1) = respPhase(1, targetMt{3,file_idx}(t));
    end

%% Reaction time calculation for incongruent
       
    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);
    t_Mt = [];

    % Loop through the selectedData and calculate reaction times
    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 22') || strcmp(prev_event, '8Bit 24') % 22,24 incongruent
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    incon_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{4,file_idx} = t_Mt(nonZeroDC);

    % Extract respiration phase
    for t = 1:length(targetMt{4,file_idx})
        phase_data{4,file_idx}(t,1) = respPhase(1, targetMt{4,file_idx}(t));
    end

%% Reaction time calculation for no cue congruent
       
    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);
    t_Mt = [];

    % Loop through the selectedData and calculate reaction times
    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 21') % 21 no cue congruent
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    nc_con_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{5,file_idx} = t_Mt(nonZeroDC);

    % Extract respiration phase
    for t = 1:length(targetMt{5,file_idx})
        phase_data{5,file_idx}(t,1) = respPhase(1, targetMt{5,file_idx}(t));
    end

%% Reaction time calculation for no cue incongruent
       
    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);
    t_Mt = [];

    % Loop through the selectedData and calculate reaction times
    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 22') % 22 no cue incongruent
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    nc_incon_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{6,file_idx} = t_Mt(nonZeroDC);

    % Extract respiration phase
    for t = 1:length(targetMt{6,file_idx})
        phase_data{6,file_idx}(t,1) = respPhase(1, targetMt{6,file_idx}(t));
    end

%% Reaction time calculation for double cue congruent
       
    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);
    t_Mt = [];

    % Loop through the selectedData and calculate reaction times
    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 23')  % 23 double cue incongruent
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    dc_con_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{7,file_idx} = t_Mt(nonZeroDC);

    % Extract respiration phase
    for t = 1:length(targetMt{7,file_idx})
        phase_data{7,file_idx}(t,1) = respPhase(1, targetMt{7,file_idx}(t));
    end

%% Reaction time calculation for double cue incongruent
       
    % Initialize reaction time result array
    reactionTime = zeros(size(selectedData, 1), 1);
    t_Mt = [];

    % Loop through the selectedData and calculate reaction times
    for i = 2:size(selectedData, 1)
        current_event = selectedData{i, 1};
        current_value = selectedData{i, 2};

        % Check if the current event is '8Bit 31'
        if strcmp(current_event, '8Bit 31')
            % Find the previous event
            prev_event = selectedData{i-1, 1};
            prev_value = selectedData{i-1, 2};

            % Check if the previous event is '8Bit 21' or '8Bit 22'
            if strcmp(prev_event, '8Bit 24')  % 24 double cue incongruent
                reactionTime(i) = current_value - prev_value;
                t_Mt (i,1) = prev_value;
            end
        end
    end

    % Find non-zero rows using logical indexing
    nonZeroRows = reactionTime ~= 0;
    nonZeroDC = t_Mt ~= 0;

    % Extract non-zero rows from the matrix
    dc_incon_reaxn_time{1,file_idx} = reactionTime(nonZeroRows);
    targetMt{8,file_idx} = t_Mt(nonZeroDC);

    % Extract respiration phase
    for t = 1:length(targetMt{8,file_idx})
        phase_data{8,file_idx}(t,1) = respPhase(1, targetMt{8,file_idx}(t));
    end

end

rxnTime_data_folder = 'PATH_TO_REACTION_TIME_OUTPUT_FOLDER'; 

filename = fullfile(rxnTime_data_folder,'dc');
save(filename, 'doublecue_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'nc');
save(filename, 'no_cue_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'incon');
save(filename, 'incon_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'cong');
save(filename, 'con_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'nc_con');
save(filename, 'nc_con_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'nc_incon');
save(filename, 'nc_incon_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'dc_con');
save(filename, 'dc_con_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'dc_incon');
save(filename, 'dc_incon_reaxn_time','-v7.3');

filename = fullfile(rxnTime_data_folder,'phase_data');
save(filename, 'phase_data','-v7.3');

filename = fullfile(rxnTime_data_folder,'targetMt');
save(filename, 'targetMt','-v7.3');
