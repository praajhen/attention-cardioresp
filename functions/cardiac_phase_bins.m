function [bin, delay] = cardiac_phase_bins(rlocs, samples, edges)
% CARDIAC_PHASE_BINS  Cardiac bin of each sample from the preceding R-peak.
% rlocs   : R-peak sample locations
% samples : e.g. target onset samples
% edges   : [0 systole_end early_diastole_end mean_IBI] in ms (= samples at 1 kHz)
% Bins: 1 systole, 2 early diastole, 3 late diastole.
% Delays longer than the mean IBI (last edge) are assigned to late diastole.

samples = samples(:);
delay   = nan(size(samples));
for t = 1:numel(samples)
    prev = rlocs(rlocs <= samples(t));
    if ~isempty(prev)
        delay(t) = samples(t) - max(prev);
    end
end

bin = discretize(delay, edges);
bin(isnan(bin) & ~isnan(delay)) = 3;
end
