%% s05_grand_average_roi
% Grand-averaged ROI waveforms (group mean +- SEM) per condition and age
% group, as in Fig. 6. N1 ROI: Oz, O1, O2, PO7, PO8, POz, P3, P4.
% P3 ROI: Pz, POz, Oz. Time axis is shown relative to target onset.
% Input : <work_dir>/04_erp/<cond>/<id>.mat
% Output: figures in <work_dir>/figures

clear; clc;
C = ant_config();

groups   = {'young', 'older'};
measures = {'N1', 'P3'};
out_dir  = fullfile(C.work_dir, 'figures');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

% Collect subject-level ROI waveforms
wave = struct();
for file_idx = 1:numel(C.files)
    [id, group, excluded] = participant_info(C.files(file_idx), C);
    if excluded, continue; end
    for c = 1:numel(C.conditions)
        cond = C.conditions{c};
        load(fullfile(C.work_dir, '04_erp', cond, [id '.mat']), 'erp');
        for m = 1:numel(measures)
            ch = ismember(erp.label, arrayfun(@num2str, C.roi.(measures{m}), 'UniformOutput', false));
            w  = mean(erp.avg(ch, :), 1);
            key = sprintf('%s_%s_%s', group, cond, measures{m});
            if ~isfield(wave, key), wave.(key) = []; end
            wave.(key)(end+1, :) = w;
        end
    end
end
t = (erp.time - C.target_time) * 1000; % ms from target

% Plot
for m = 1:numel(measures)
    for g = 1:numel(groups)
        figure('Color', 'w'); hold on;
        for c = 1:numel(C.conditions)
            X  = wave.(sprintf('%s_%s_%s', groups{g}, C.conditions{c}, measures{m}));
            mu = mean(X, 1);
            se = std(X, 0, 1) / sqrt(size(X, 1));
            fill([t fliplr(t)], [mu+se fliplr(mu-se)], 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none', ...
                'HandleVisibility', 'off');
            plot(t, mu, 'LineWidth', 1.2, 'DisplayName', C.conditions{c});
        end
        xline(0, 'k-', 'HandleVisibility', 'off');
        xline(-500, 'r--', 'HandleVisibility', 'off');
        xw = C.win.(measures{m}) * 1000;
        yl = ylim;
        patch([xw(1) xw(2) xw(2) xw(1)], [yl(1) yl(1) yl(2) yl(2)], [0.6 0.6 0.6], ...
            'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        xlabel('Time from target (ms)'); ylabel('Amplitude (\muV)');
        title(sprintf('%s, %s adults', measures{m}, groups{g}));
        legend('Location', 'best'); box off;
        print(fullfile(out_dir, sprintf('grand_average_%s_%s', measures{m}, groups{g})), '-dpng', '-r300');
    end
end
