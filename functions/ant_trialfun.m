function [trl, event] = ant_trialfun(cfg)
% ANT_TRIALFUN  Cue-locked ANT epochs with correct responses only.
%
% Epoch: 200 ms before the (possible) cue to 1000 ms after it, i.e. 500 ms
% after the target. Baseline is the 200 ms before the cue.
%
% cfg.condition: 'NC', 'DC', 'CON' or 'INCON'
%
% Event codes
%   8Bit 11  no-cue marker        8Bit 21  no-cue, congruent target
%   8Bit 12  double cue           8Bit 22  no-cue, incongruent target
%   8Bit 31  correct response     8Bit 23  double cue, congruent target
%                                 8Bit 24  double cue, incongruent target
%
% Column 4 of trl holds the target onset sample (kept as trialinfo).

hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);
event(arrayfun(@(x) isempty(x.value), event)) = [];

value  = {event.value};
sample = [event.sample];

pre  = round(0.2 * hdr.Fs);
post = round(1.0 * hdr.Fs);

switch cfg.condition
    case 'NC',    cues = {'8Bit 11'};            targets = {'8Bit 21', '8Bit 22'};
    case 'DC',    cues = {'8Bit 12'};            targets = {'8Bit 23', '8Bit 24'};
    case 'CON',   cues = {'8Bit 11', '8Bit 12'}; targets = {'8Bit 21', '8Bit 23'};
    case 'INCON', cues = {'8Bit 11', '8Bit 12'}; targets = {'8Bit 22', '8Bit 24'};
    otherwise, error('Unknown condition: %s', cfg.condition);
end

trl = zeros(0, 4);
for j = 1:numel(value) - 4
    if any(strcmp(value{j}, cues)) && any(strcmp(value{j+2}, targets)) ...
            && strcmp(value{j+4}, '8Bit 31')
        trl(end+1, :) = [sample(j) - pre, sample(j) + post, -pre, sample(j+2)]; %#ok<AGROW>
    end
end
end
