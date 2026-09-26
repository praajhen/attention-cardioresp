%% s08_check_respiration_phase
% Visual check of the Hilbert respiration phase against the raw belt signal.
% Phase increases over time: -pi -> 0 -> pi. The phase is 0 at signal peaks
% and +-pi at troughs. So the half before each peak (-pi..0) is the rising
% part of the signal and the half after it (0..pi) is the falling part.
% Use this to confirm which bin corresponds to inspiration for this
% belt/amplifier setup (C.resp.labels in ant_config).

clear; clc;
C = ant_config();

%--------------------------------------------------------------------------
file_idx = 1;          % participant
t_range  = [60 90];    % seconds to show
%--------------------------------------------------------------------------

dataset = fullfile(C.raw_dir, C.files(file_idx).name);
resp    = read_physio(dataset, 'Resp');
phase   = angle(hilbert(resp));

idx = round(t_range(1) * C.fs):round(t_range(2) * C.fs);
t   = idx / C.fs;

figure('Color', 'w');
subplot(2, 1, 1);
plot(t, resp(idx), 'k'); hold on;
neg = phase(idx) < 0;
plot(t(neg), resp(idx(neg)), 'b.', 'MarkerSize', 2);
plot(t(~neg), resp(idx(~neg)), 'r.', 'MarkerSize', 2);
ylabel('Respiration (raw)');
title(sprintf('%s: blue = bin 1 (%s), red = bin 2 (%s)', ...
    participant_info(C.files(file_idx), C), C.resp.labels{1}, C.resp.labels{2}));
subplot(2, 1, 2);
plot(t, phase(idx), 'k'); yline(0, ':');
ylabel('Phase (rad)'); xlabel('Time (s)');
