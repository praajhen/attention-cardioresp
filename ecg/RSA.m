%% compute_RSA_from_ECG_and_resp.m
% Compute respiratory sinus arrhythmia (RSA) from respiration + ECG
% Author: praghajieeth raajhen santhana gopalan

close all; clear; clc;

%% ================= USER PATHS =================
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
data_folder    = 'PATH_TO_TEBC_EDF_DATA_FOLDER';

%% ================= SETUP =================
addpath(fieldtrip_path);
ft_defaults;

dataset_files = dir(fullfile(data_folder, '*.edf'));
num_subjects  = length(dataset_files);

for file_idx = 1:num_subjects

    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    cfg = [];
    cfg.dataset = dataset_filename;
    cfg.channel = {'Resp','ecg'};
    data = ft_preprocessing(cfg);

    %% signals
    Fs = data.fsample;

    heartbeat   = data.trial{1}(1,:);
    respiration = data.trial{1}(2,:);

    %% R peaks
    [~, loc] = findpeaks(heartbeat, ...
        'MinPeakProminence',300, ...
        'MinPeakDistance',round(0.4*Fs));

    RtoR = diff(loc);

    %% respiration thresholds
    meanResp  = mean(respiration);
    stdResp   = std(respiration);

    InspireTh = meanResp + stdResp;
    ExpireTh  = meanResp;

    %% classify inspiration / expiration
    RtoR_I = [];
    RtoR_E = [];

    for k = 3:length(loc)

        resp2 = respiration(loc(k));
        resp1 = respiration(loc(k-1));

        if resp2 < ExpireTh && resp1 < ExpireTh
            RtoR_E = [RtoR_E; RtoR(k-1)];
        elseif resp2 > InspireTh && resp1 > InspireTh
            RtoR_I = [RtoR_I; RtoR(k-1)];
        end

    end

    %% mean RR
    meanI(file_idx,1) = mean(RtoR_I);
    meanE(file_idx,1) = mean(RtoR_E);

    stdI(file_idx,1) = std(RtoR_I);
    stdE(file_idx,1) = std(RtoR_E);

    %% RSA
    RSA(file_idx,1) = ...
        ((meanE(file_idx)-meanI(file_idx)) / ...
        (0.5*(meanE(file_idx)+meanI(file_idx)))) * 100;

end

disp('RSA computation finished')