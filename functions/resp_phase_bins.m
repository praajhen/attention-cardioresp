function [bin, phase] = resp_phase_bins(resp_phase, samples, edges)
% RESP_PHASE_BINS  Respiration phase (rad) at given samples and its bin.
% resp_phase : angle(hilbert(resp)) of the continuous respiration signal
% samples    : e.g. target onset samples
% Phase is rounded to two decimals so that values such as 3.1416 fall
% inside the outer bin edges (+-3.14).

phase = round(resp_phase(samples(:)), 2);
phase = phase(:);
bin   = discretize(phase, edges);
end
