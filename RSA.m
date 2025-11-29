%% compute_RSA_from_ECG_and_resp.m
% Compute respiratory sinus arrhythmia (RSA) from respiration + ECG
% Author: praghajieeth raajhen santhana gopalan

close all;
clear all

addpath('PATH_TO_FIELDTRIP_FOLDER');                    % e.g. C:\...\fieldtrip-20230427
ft_defaults;

data_folder   = 'PATH_TO_TEBC_EDF_DATA_FOLDER';         % e.g. C:\...\Personalised TEBC (2024-2025)\data\TEBC\
dataset_files = dir(fullfile(data_folder, '*.edf'));    % List all .edf files in the folder

for file_idx = 1:13  % enter the file number

    dataset_filename = fullfile(data_folder, dataset_files(file_idx).name);

    cfg         = [];
    % cfg.trialfun = 'mytrialfun';
    cfg.dataset = dataset_filename;
    cfg.channel = {'Resp','ecg'};
    data        = ft_preprocessing(cfg);

    %% RSA = respiratory sinus arrhythmia

    plotORnot = 0;
    Fs        = 1000;

    heartbeat   = data.trial{1, 1}(1,:);   % channel 1
    respiration = data.trial{1, 1}(2,:);   % channel 2

    %% visualization of the respiration and heartbeat signals
    % plot if plotORnot == 1
    if plotORnot == 1
        sweeplength = 10;
        time = linspace(0, sweeplength, Fs*sweeplength);
        k = 1;
        while k < length(respiration)
            subplot(2, 1, 1); plot(time, respiration(k:(k+sweeplength*Fs)-1));
            title(['start at ', int2str(k/Fs), ' s.'])
            subplot(2, 1, 2); plot(time, heartbeat(k:(k+sweeplength*Fs)-1));
            pause(0.2);
            k = k + Fs*sweeplength;
        end
    end

    %% Find R-peaks
    [pks, loc] = findpeaks(heartbeat, 'MinPeakProminence', 300, 'MinPeakDistance', 400);
    RtoR       = diff(loc);
%   display(['RtoR is on average ', int2str((mean(RtoR)/Fs)*1000), ' ms.']);

    %% Find Inspiration and Expiration thresholds
    meanResp  = mean(respiration);
    stdResp   = std(respiration);
    InspireTh = meanResp + stdResp;
    ExpireTh  = meanResp;

    %% code RtoR peaks into Inspiration and Expiration

    RtoR_I = [];
    RtoR_E = [];

    for k = 3:length(loc)
        respValue2 = respiration(loc(k));
        respValue1 = respiration(loc(k-1));
        if respValue2 < ExpireTh && respValue1 < ExpireTh
            RtoR_E = vertcat(RtoR_E, RtoR(k-1)); %#ok<AGROW>
        elseif respValue2 > InspireTh && respValue1 > InspireTh
            RtoR_I = vertcat(RtoR_I, RtoR(k-1)); %#ok<AGROW>
        end
    end
       
    %% longest r-r interval during expiration by shortest r-r interval during inspiration
    % rsa(file_idx,1) = max(RtoR_E)/ min(RtoR_I);

    %% calculate means and standard deviations
    meanI(file_idx,1) = mean(RtoR_I);
    meanE(file_idx,1) = mean(RtoR_E);
    stdI(file_idx,1)  = std(RtoR_I);
    stdE(file_idx,1)  = std(RtoR_E);

    RSAI(file_idx, 1) = ((meanE(file_idx, 1) - meanI(file_idx, 1)) / ...
                        (0.5 * (meanE(file_idx, 1) + meanI(file_idx, 1)))) * 100;

end

% display(['Mean RtoR during inspiration is ', int2str((meanI/Fs)*1000), ' +/- ', int2str((stdI/Fs)*1000),' ms.']);
% display(['Mean RtoR during expiration is ', int2str((meanE/Fs)*1000), ' +/- ', int2str((stdE/Fs)*1000),' ms.']);
