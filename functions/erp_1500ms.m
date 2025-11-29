function [trl, event] = erp_1500ms(cfg)
% ERP_1500MS  Custom FieldTrip trial function for 1500 ms ERP segments
%
% Conditions (cfg.nr):
%   3 = congruent targets (no-cue or double-cue)
%   4 = incongruent targets (no-cue or double-cue)
%
% Trigger logic:
%   Congruent:
%       (8Bit 11 OR 8Bit 12) -> (8Bit 21 OR 8Bit 23) -> 8Bit 31
%   Incongruent:
%       (8Bit 11 OR 8Bit 12) -> (8Bit 22 OR 8Bit 24) -> 8Bit 31
%
% Segment length:
%   -0.2 s to +1.5 s around trigger sample j
%
% Author: praghajieeth raajhen santhana gopalan

% -------------------------------------------------------------------------
% Trial definition settings
% -------------------------------------------------------------------------
cfg.trialdef.eventtype  = 'annotation';
cfg.trialdef.prestim    = 0.200; % in seconds

p = 1.5;                % post-stimulus window in seconds
cfg.trialdef.poststim   = p;     % in seconds

% -------------------------------------------------------------------------
% Read header and events from the dataset
% -------------------------------------------------------------------------
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% -------------------------------------------------------------------------
% Remove events with empty "value" fields
% -------------------------------------------------------------------------
emptyValueIndices = arrayfun(@(x) isempty(x.value), event);
event(emptyValueIndices) = [];

% -------------------------------------------------------------------------
% Extract event values and sample indices
% -------------------------------------------------------------------------
value  = {event(:).value}';
sample = {event(:).sample}';

% -------------------------------------------------------------------------
% Convert prestim / poststim windows to samples
% -------------------------------------------------------------------------
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);

% -------------------------------------------------------------------------
% Build trial matrix "trl"
% Each row: [trlbegin trlend offset]
% -------------------------------------------------------------------------
trl = [];
for j = 1:(length(value) - 4) % change to 2 if you ever simplify the pattern

    % we look at three events:
    %   trg1 = value at j
    %   trg2 = value at j+2
    %   trg3 = value at j+4
    trg1 = value{j};
    trg2 = value{j+2};
    trg3 = value{j+4};

    % ---------------------------------------------------------------------
    % cfg.nr == 3 : congruent targets
    %   (8Bit 11 or 8Bit 12) followed by (8Bit 21 or 8Bit 23) and 8Bit 31
    % ---------------------------------------------------------------------
    if cfg.nr == 3   % Congruent target
        if ((trg1 == "8Bit 11" || trg1 == "8Bit 12") && ...
            ((trg2 == "8Bit 21" && trg3 == "8Bit 31") || ...
             (trg2 == "8Bit 23" && trg3 == "8Bit 31")))
         
            trlbegin = sample{j} + pretrig;
            trlend   = sample{j} + posttrig;
            offset   = pretrig;
            newtrl   = [trlbegin trlend offset];
            trl      = [trl; newtrl];
        end

    % ---------------------------------------------------------------------
    % cfg.nr == 4 : incongruent targets
    %   (8Bit 11 or 8Bit 12) followed by (8Bit 22 or 8Bit 24) and 8Bit 31
    % ---------------------------------------------------------------------
    else cfg.nr == 4 % Incongruent target (kept in your original style)
        if ((trg1 == "8Bit 11" || trg1 == "8Bit 12") && ...
            ((trg2 == "8Bit 22" && trg3 == "8Bit 31") || ...
             (trg2 == "8Bit 24" && trg3 == "8Bit 31")))
         
            trlbegin = sample{j} + pretrig;
            trlend   = sample{j} + posttrig;
            offset   = pretrig;
            newtrl   = [trlbegin trlend offset];
            trl      = [trl; newtrl];
        end
    end
end
