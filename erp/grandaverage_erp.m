%% grandaverage_erp.m
% Grand-averaged ERP computation and plotting (alerting & inhibition)
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

%% ================= USER PATHS =================
fieldtrip_path = 'PATH_TO_FIELDTRIP_FOLDER';
erp_folder     = 'PATH_TO_ERP_FOLDER';
layout_file    = 'PATH_TO_LAYOUT_SFP_FILE';

%% ================= SETUP =================
addpath(fieldtrip_path)
ft_defaults

%% ================= LOAD ERP FILES =================
erp_files = dir(fullfile(erp_folder,'*.mat'));

all_data = cell(1,length(erp_files));

for i = 1:length(erp_files)

    tmp = load(fullfile(erp_folder,erp_files(i).name));

    fields = fieldnames(tmp);
    all_data{i} = tmp.(fields{1});

end

%% ================= GRAND AVERAGE =================
cfg = [];
ga_all = ft_timelockgrandaverage(cfg, all_data{:});

%% ================= SINGLE CHANNEL PLOT =================
figure
plot(ga_all.time, ga_all.avg(90,:), 'LineWidth',1.5)
set(gca,'YDir','reverse')

xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Grand Average ERP')

%% ================= MULTIPLOT =================
cfg = [];
cfg.layout = layout_file;
cfg.xlim   = 'maxmin';
cfg.ylim   = 'maxmin';

ft_multiplotER(cfg, ga_all)

%% ================= TOPOPLOT =================
cfg = [];
cfg.layout = layout_file;
cfg.xlim   = [0.65 0.75];

ft_topoplotER(cfg, ga_all)

%% ================= ROI PLOT =================
roi = [52 72 92 65 70 75 83 90];

roi_data = mean(ga_all.avg(roi,:),1);

figure
plot(ga_all.time, roi_data,'LineWidth',1.5)
set(gca,'YDir','reverse')

xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('ROI averaged ERP')

disp('Grand average plotting finished')