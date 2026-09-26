%% s11_phase_bin_amplitudes
% Subject-level mean N1 and P3 amplitudes per respiration and cardiac bin,
% for the repeated-measures ANOVAs (phase x age group, run in SPSS).
% Amplitude = mean over the a priori ROI electrodes and time window
% (N1 165-215 ms, P3 290-350 ms after target), averaged across the four
% ANT conditions. Per-condition values are also written.
% Input : <work_dir>/06_phase_erp/<resp|cardiac>/<cond>/<id>.mat
% Output: <work_dir>/06_phase_erp/phase_amplitudes_long.csv (per condition)
%         <work_dir>/06_phase_erp/phase_amplitudes_anova.csv (wide, averaged across conditions)

clear; clc;
C = ant_config();

types    = {'resp', 'cardiac'};
labels   = {C.resp.labels, C.cardiac.labels};
measures = {'N1', 'P3'};

long = {};
for file_idx = 1:numel(C.files)
    [id, group, excluded] = participant_info(C.files(file_idx), C);
    if excluded, continue; end
    for p = 1:numel(types)
        for c = 1:numel(C.conditions)
            cond = C.conditions{c};
            load(fullfile(C.work_dir, '06_phase_erp', types{p}, cond, [id '.mat']), 'erp_bin');
            for b = 1:numel(erp_bin)
                for m = 1:numel(measures)
                    amp = roi_amplitude(erp_bin{b}, C, measures{m});
                    long(end+1, :) = {id, group, types{p}, labels{p}{b}, cond, measures{m}, amp}; %#ok<SAGROW>
                end
            end
        end
    end
end

L = cell2table(long, 'VariableNames', ...
    {'id', 'group', 'phase_type', 'bin', 'condition', 'measure', 'amplitude_uV'});
writetable(L, fullfile(C.work_dir, '06_phase_erp', 'phase_amplitudes_long.csv'));

% Average across conditions, one row per participant (SPSS layout)
G = groupsummary(L, {'id', 'group', 'phase_type', 'bin', 'measure'}, 'mean', 'amplitude_uV');
G.var = strcat(G.measure, '_', G.phase_type, '_', G.bin);
W = unstack(G(:, {'id', 'group', 'var', 'mean_amplitude_uV'}), 'mean_amplitude_uV', 'var');
writetable(W, fullfile(C.work_dir, '06_phase_erp', 'phase_amplitudes_anova.csv'));

function amp = roi_amplitude(erp, C, measure)
if isempty(erp), amp = NaN; return; end
ch  = ismember(erp.label, arrayfun(@num2str, C.roi.(measure), 'UniformOutput', false));
win = C.target_time + C.win.(measure);
tt  = erp.time >= win(1) - 1e-9 & erp.time <= win(2) + 1e-9;
amp = mean(mean(erp.avg(ch, tt), 1), 2);
end
