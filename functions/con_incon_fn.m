function [trl, event] = con_incon_fn(cfg)
% CON_INCON_FN  Custom FieldTrip trial function for congruent / incongruent targets
%
% Conditions (cfg.nr):
%   1 = no-cue congruent   (8Bit 11 -> 8Bit 21 -> 8Bit 31)
%   2 = no-cue incongruent (8Bit 11 -> 8Bit 22 -> 8Bit 31)
%   3 = double-cue congruent   (8Bit 12 -> 8Bit 23 -> 8Bit 31)
%   4 = double-cue incongruent (8Bit 12 -> 8Bit 24 -> 8Bit 31)
%
% Author: praghajieeth raajhen santhana gopalan

%----------------------------------------------------------------------
% Basic trial definition settings
%----------------------------------------------------------------------
cfg.trialdef.eventtype  = 'annotation';
cfg.trialdef.prestim    = 0.200; % in seconds

% post-stimulus window in seconds (same for all conditions here)
p = [];
if cfg.nr == 1 || cfg.nr == 2
    p = 1;
else
    p = 1;
end

cfg.trialdef.poststim   = p; % in seconds

%----------------------------------------------------------------------
% Read header and events from dataset
%----------------------------------------------------------------------
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

%----------------------------------------------------------------------
% Remove events with empty 'value' fields
%----------------------------------------------------------------------
emptyValueIndices = arrayfun(@(x) isempty(x.value), event);
event(emptyValueIndices) = [];

%----------------------------------------------------------------------
% Convert to simple cell arrays for easier indexing
%----------------------------------------------------------------------
value  = {event(:).value}';
sample = {event(:).sample}';

%----------------------------------------------------------------------
% Convert pre/post times from seconds to samples
%----------------------------------------------------------------------
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);

%----------------------------------------------------------------------
% Build trial definition (trl) based on trigger sequences
%----------------------------------------------------------------------
if cfg.nr == 1 || cfg.nr == 2

    trl = [];
    for j = 1:(length(value) - 4) % change to 2 if needed in future

        % three-event pattern:
        %   trg1: cue
        %   trg2: target
        %   trg3: end/response
        trg1 = value{j};
        trg2 = value{j+2};
        trg3 = value{j+4};

        %--------------------------------------------------------------
        % Condition 1: no-cue congruent target
        %   8Bit 11 (no cue) -> 8Bit 21 (congruent target) -> 8Bit 31
        %--------------------------------------------------------------
        if cfg.nr == 1
            if (trg1 == "8Bit 11" && trg2 == "8Bit 21" && trg3 == "8Bit 31")
                trlbegin = sample{j} + pretrig;
                trlend   = sample{j} + posttrig;
                offset   = pretrig;
                newtrl   = [trlbegin trlend offset];
                trl      = [trl; newtrl];
            end

        %--------------------------------------------------------------
        % Condition 2: no-cue incongruent target
        %   8Bit 11 (no cue) -> 8Bit 22 (incongruent target) -> 8Bit 31
        %--------------------------------------------------------------
        else cfg.nr == 2  % kept as in your original code
            if (trg1 == "8Bit 11" && trg2 == "8Bit 22" && trg3 == "8Bit 31")
                trlbegin = sample{j} + pretrig;
                trlend   = sample{j} + posttrig;
                offset   = pretrig;
                newtrl   = [trlbegin trlend offset];
                trl      = [trl; newtrl];
            end
        end
    end

else
    %------------------------------------------------------------------
    % Conditions 3 and 4: double-cue congruent / incongruent
    %------------------------------------------------------------------
    trl = [];
    for j = 1:(length(value) - 4)

        trg1 = value{j};
        trg2 = value{j+2};
        trg3 = value{j+4};

        %--------------------------------------------------------------
        % Condition 3: double-cue congruent target
        %   8Bit 12 (double cue) -> 8Bit 23 (congruent) -> 8Bit 31
        %--------------------------------------------------------------
        if cfg.nr == 3
            if (trg1 == "8Bit 12" && trg2 == "8Bit 23" && trg3 == "8Bit 31")
                trlbegin = sample{j} + pretrig;
                trlend   = sample{j} + posttrig;
                offset   = pretrig;
                newtrl   = [trlbegin trlend offset];
                trl      = [trl; newtrl];
            end

        %--------------------------------------------------------------
        % Condition 4: double-cue incongruent target
        %   8Bit 12 (double cue) -> 8Bit 24 (incongruent) -> 8Bit 31
        %--------------------------------------------------------------
        else cfg.nr == 4  % kept as in your original code
            if (trg1 == "8Bit 12" && trg2 == "8Bit 24" && trg3 == "8Bit 31")
                trlbegin = sample{j} + pretrig;
                trlend   = sample{j} + posttrig;
                offset   = pretrig;
                newtrl   = [trlbegin trlend offset];
                trl      = [trl; newtrl];
            end
        end
    end
end
