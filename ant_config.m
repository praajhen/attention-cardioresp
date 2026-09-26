function C = ant_config()
% ANT_CONFIG  Paths and analysis parameters used by all scripts.
% Edit the three paths below before running anything.

%% Paths (edit these)
C.fieldtrip = 'C:\toolboxes\fieldtrip-20230427';   % FieldTrip version used in the paper
C.raw_dir   = 'C:\data\ANT_cardiorespiratory\raw'; % .edf files: A001-A025 (young), AE001-AE025 (older)
C.work_dir  = 'C:\data\ANT_cardiorespiratory\derivatives'; % all intermediate and output files

%% Setup
repo = fileparts(mfilename('fullpath'));
addpath(fullfile(repo, 'functions'));
addpath(C.fieldtrip);
ft_defaults;

C.layout   = fullfile(C.fieldtrip, 'template', 'electrode', 'GSN-HydroCel-128.sfp');
C.channels = arrayfun(@num2str, 1:128, 'UniformOutput', false);
C.fs       = 1000; % Hz (NeurOne)

%% Participants
C.files   = dir(fullfile(C.raw_dir, '*.edf'));
C.exclude = {'A016'}; % one young adult excluded (excessive EEG noise)

%% Trial rejection (peak-to-peak, uV)
C.reject.low          = 175; % reject if more than max_channels exceed this ...
C.reject.max_channels = 25;
C.reject.high         = 300; % ... or any single channel exceeds this
C.reject.first_sample = 150; % peak-to-peak computed from this sample to epoch end

%% Conditions and ERP measures
% Epochs are cue-locked: -200 ms before (possible) cue to 1000 ms after it.
% The target appears 500 ms after the cue, so target-locked times = time - 0.5 s.
C.conditions  = {'NC', 'DC', 'CON', 'INCON'};
C.target_time = 0.5; % s, relative to cue

% Electrode numbers (HydroCel 128)
C.roi.N1 = [52 72 92 65 70 75 83 90]; % P3, POz, P4, PO7, O1, Oz, O2, PO8
C.roi.P3 = [62 72 75];                % Pz, POz, Oz

% Time windows relative to TARGET onset (s)
C.win.N1 = [0.165 0.215];
C.win.P3 = [0.290 0.350];

%% Physiological phase bins
% Respiration: Hilbert phase at target onset, split at 0 rad.
C.resp.edges  = [-3.14 0 3.14];
C.resp.labels = {'inspiration', 'expiration'}; % bin 1 = -pi..0, bin 2 = 0..pi, as labelled in the paper.
                                               % Verify with 04_physiology/s08_check_respiration_phase.m

% Cardiac: time from preceding R-peak to target onset, per-participant edges
% (hand-picked from the averaged ECG waveform, see s07_cardiac_bin_edges.m).
C.cardiac.edges_file = fullfile(C.work_dir, 'cardiac', 'edges.mat');
C.cardiac.labels     = {'systole', 'early_diastole', 'late_diastole'};

% R-peak detection (findpeaks: MinPeakProminence, MinPeakDistance in samples)
C.rpeak.erp = [600 500]; % used for ERP binning
C.rpeak.rt  = [700 700]; % used for reaction-time binning

end
