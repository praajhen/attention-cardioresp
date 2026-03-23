%% plot_ga_erp_inhibition.m
% Grand-averaged ERP computation and plotting (alerting & inhibition)
% Author: praghajieeth raajhen santhana gopalan

clear; clc;

addpath('PATH_TO_FIELDTRIP_FOLDER');  % e.g. C:\...\fieldtrip-20230427
ft_defaults;

% folder: ERP data (e.g., NC / DC, young & elderly)
cd('PATH_TO_ERP_FOLDER');  % e.g. D:\...\Intermediate files\ERP

%% no-cue incongruent (young)
cfg = [];
ga_nc_incon = ft_timelockgrandaverage(cfg, ...
    A001, A002, A003, A004, A005, A006, A007, A008, A009, A010, ...
    A011, A012, A013, A014, A015, A017, A018, A019, A020, ...
    A021, A022, A023, A024, A025);

%% no-cue incongruent (elderly)
cfg = [];
ga_nc_incon_e = ft_timelockgrandaverage(cfg, ...
    AE001, AE002, AE003, AE004, AE005, AE006, AE007, AE008, AE009, AE010, ...
    AE011, AE012, AE013, AE014, AE015, AE016, AE017, AE018, AE019, AE020, ...
    AE021, AE022, AE023, AE024, AE025);

%% double-cue incongruent (young)
cfg = [];
ga_dc_incon = ft_timelockgrandaverage(cfg, ...
    A001, A002, A003, A004, A005, A006, A007, A008, A009, A010, ...
    A011, A012, A013, A014, A015, A017, A018, A019, A020, ...
    A021, A022, A023, A024, A025);

%% double-cue incongruent (elderly)
cfg = [];
ga_dc_incon_e = ft_timelockgrandaverage(cfg, ...
    AE001, AE002, AE003, AE004, AE005, AE006, AE007, AE008, AE009, AE010, ...
    AE011, AE012, AE013, AE014, AE015, AE016, AE017, AE018, AE019, AE020, ...
    AE021, AE022, AE023, AE024, AE025);

%% quick check plot (example; uses ga_nc / ga_dc if present)
plot(ga_nc.time, ga_nc.avg(90, :)); 
hold on;
plot(ga_dc.time, ga_dc.avg(90, :));
set(gca, 'YDir', 'reverse');

%% Figure 1: no cue (young vs elderly)
figure(1);
plot(ga_nc_con.time, ga_nc_con.avg(90, :), 'k', 'LineWidth', 1.2);
hold on;
plot(ga_nc_con_e.time, ga_nc_con_e.avg(90, :), 'k--', 'LineWidth', 1.2);
xline(0, 'k--', 'LineWidth', 0.9);
set(gca, 'YDir', 'reverse');
set(gca, 'FontSize', 15, 'FontName', 'Arial');
xlabel('time (s)','FontSize',15, 'FontName', 'Arial');
ylabel('amplitude in uV','FontSize',15, 'FontName', 'Arial');
lgd = legend('no cue - young', 'no cue - elderly', 'FontSize', 10, 'FontName', 'Arial');
set(lgd, 'Location', 'best', 'Orientation', 'vertical');

print('ga_erp_alerting', '-dpng', '-r600');

%% Figure 2: double cue (young vs elderly)
figure(2);
plot(ga_dc.time, ga_dc.avg(90, :), 'r', 'LineWidth', 1.2);
hold on;
plot(ga_dc_e.time, ga_dc_e.avg(90, :), 'r--', 'LineWidth', 1.2);
xline(0.5, 'k--', 'LineWidth', 0.9);
% set(gca, 'YDir', 'reverse');
set(gca, 'FontSize', 15, 'FontName', 'Arial');
xlabel('time (s)','FontSize',15, 'FontName', 'Arial');
ylabel('amplitude in uV','FontSize',15, 'FontName', 'Arial');
lgd = legend('double cue - young','double cue - elderly', 'FontSize', 10, 'FontName', 'Arial');
set(lgd, 'Location', 'best', 'Orientation', 'vertical');

print('ga_erp_alerting', '-dpng', '-r600');

%% Multiplot example (requires ga_erp + ch + systole/diastole structures)
ga_erp.label = ch;
cfg = [];
cfg.layout      = 'PATH_TO_LAYOUT_SFP_FILE';  % e.g. ...\GSN-HydroCel-128.sfp
cfg.xlim        = 'maxmin';
cfg.ylim        = 'maxmin';
cfg.showlabels  = 'yes';
ft_multiplotER(cfg, ga_dc_incon_e_sys, ga_dc_incon_e_dia2);

%% Topoplot example
cfg = [];
cfg.layout = 'PATH_TO_LAYOUT_SFP_FILE';        % e.g. ...\GSN-HydroCel-128.sfp
cfg.xlim   = [0.665 0.750];
% cfg.zlim = [-3  4];
ft_topoplotER(cfg, ga_nc_con);

%% Layout plot
cfg = [];
cfg.layout = 'PATH_TO_LAYOUT_SFP_FILE';        % e.g. ...\GSN-HydroCel-128.sfp
layout = ft_prepare_layout(cfg);
ft_plot_layout(layout, 'label','no', 'box','no', ...
               'pointcolor','k', 'pointsize',9);

%% grand averages: congruent (young / elderly)
cfg = [];
ga_con = ft_timelockgrandaverage(cfg, ...
    A001, A002, A003, A004, A005, A006, A007, A008, A009, A010, ...
    A011, A012, A013, A014, A015, A017, A018, A019, A020, ...
    A021, A022, A023, A024, A025);

cfg = [];
ga_con_e = ft_timelockgrandaverage(cfg, ...
    AE001, AE002, AE003, AE004, AE005, AE006, AE007, AE008, AE009, AE010, ...
    AE011, AE012, AE013, AE014, AE015, AE016, AE017, AE018, AE019, AE020, ...
    AE021, AE022, AE023, AE024, AE025);

%% grand averages: incongruent (young / elderly)
cfg = [];
ga_incon = ft_timelockgrandaverage(cfg, ...
    A001, A002, A003, A004, A005, A006, A007, A008, A009, A010, ...
    A011, A012, A013, A014, A015, A017, A018, A019, A020, ...
    A021, A022, A023, A024, A025);

cfg = [];
ga_incon_e = ft_timelockgrandaverage(cfg, ...
    AE001, AE002, AE003, AE004, AE005, AE006, AE007, AE008, AE009, AE010, ...
    AE011, AE012, AE013, AE014, AE015, AE016, AE017, AE018, AE019, AE020, ...
    AE021, AE022, AE023, AE024, AE025);

%% Inhibition ERP plot at electrode 62
figure;
plot(ga_con.time,     ga_con.avg(62, :),    'k',  'LineWidth', 1.2);
hold on;
plot(ga_incon.time,   ga_incon.avg(62, :),  'r',  'LineWidth', 1.2);
plot(ga_con_e.time,   ga_con_e.avg(62, :),  'k--','LineWidth', 1.2);
plot(ga_incon_e.time, ga_incon_e.avg(62, :),'r--','LineWidth', 1.2);
% xline(0, 'k--', 'LineWidth', 0.9);
set(gca, 'YDir', 'reverse');
% ylim([-8 4]);
set(gca, 'FontSize', 15, 'FontName', 'Arial');
xlabel('time (s)','FontSize',15, 'FontName', 'Arial');
ylabel('amplitude in uV','FontSize',15, 'FontName', 'Arial');
legend('Congruent - young', 'Incongruenet - young', ...
       'Congruent - elderly', 'Incongruent - elderly', ...
       'FontSize', 12, 'FontName', 'Arial');
print('ga_erp_inhibition', '-dpng', '-r600');

%% Example: add a box at a specific time point for no-cue data
time_point   = 0.7;   % time (s)
box_width    = 0.1;
box_height   = max([ga_nc.avg(90,:), ga_nc_e.avg(90,:)]) - ...
               min([ga_nc.avg(90,:), ga_nc_e.avg(90,:)]);
rectangle('Position', [time_point - box_width/2, ...
          min([ga_nc.avg(90,:), ga_nc_e.avg(90,:)]), ...
          box_width, box_height], ...
          'EdgeColor', 'r', 'LineWidth', 1.5);

%% Region-of-interest example (elderly, channels 52,72,92,65,70,75,83,90)
nc_e(1,:) = ga_nc_e.avg(52,:);
nc_e(2,:) = ga_nc_e.avg(72,:);
nc_e(3,:) = ga_nc_e.avg(92,:);
nc_e(4,:) = ga_nc_e.avg(65,:);
nc_e(5,:) = ga_nc_e.avg(70,:);
nc_e(6,:) = ga_nc_e.avg(75,:);
nc_e(7,:) = ga_nc_e.avg(83,:);
nc_e(8,:) = ga_nc_e.avg(90,:);

elderly_nc = mean(nc_e);

% Plots using precomputed young_nc, young_dc, elderly_nc, elderly_dc
plot(-200:500, young_nc)
hold on;
plot(young_dc)
plot(elderly_nc)
plot(elderly_dc)
