function [trl, event] = mytrialfun(cfg)
% MYTRIALFUN  Custom trial function for FieldTrip
%
% This function defines trials based on EDF annotations and a specific
% trigger pattern in the event structure.
%
% Author: praghajieeth raajhen santhana gopalan

% -------------------------------------------------------------------------
% Basic trial definition settings
% -------------------------------------------------------------------------

% we are using EDF 'annotation' events as triggers
cfg.trialdef.eventtype  = 'annotation';

% time (in seconds) before the trigger to include in each trial
cfg.trialdef.prestim    = 0.200; % in seconds

% set post-stimulus window only for cfg.nr == 1 or 2
p = [];
if cfg.nr == 1 || cfg.nr == 2
    p = 0.5;  % time (in seconds) after trigger to include in each trial
end

cfg.trialdef.poststim   = p; % in seconds

% -------------------------------------------------------------------------
% Read header and event information from the dataset
% -------------------------------------------------------------------------

hdr   = ft_read_header(cfg.dataset);  % sampling rate etc.
event = ft_read_event(cfg.dataset);   % all events (including annotations)

% -------------------------------------------------------------------------
% Clean up events: remove entries with empty "value" fields
% -------------------------------------------------------------------------

% Find indices of events where the 'value' field is empty
emptyValueIndices = find(arrayfun(@(x) isempty(x.value), event));

% Remove events with empty 'value' to avoid issues later
event(emptyValueIndices) = [];

% -------------------------------------------------------------------------
% Extract event values and sample indices
% -------------------------------------------------------------------------

% cell array of event values (e.g. '8Bit 11', '8Bit 31', etc.)
value  = {event(:).value}';

% corresponding sample indices for each event
sample = {event(:).sample}';

% -------------------------------------------------------------------------
% Convert pre/post time windows from seconds to samples
% -------------------------------------------------------------------------

pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs); % negative offset in samples
posttrig =  round(cfg.trialdef.poststim * hdr.Fs); % positive offset in samples

% -------------------------------------------------------------------------
% Define spacing ("f") between the first and second trigger to be checked
% -------------------------------------------------------------------------

f = [];
if cfg.nr == 1 || cfg.nr == 2
    f = 4;  % look 4 events ahead for the second trigger (trg2)
end 

% -------------------------------------------------------------------------
% Build the trial definition matrix "trl"
% Each row of trl is: [trlbegin trlend offset]
% -------------------------------------------------------------------------

trl = [];
for j = 1:(length(value) - f)
    % first trigger in the pair
    trg1 = value{j};
    % second trigger in the pair (f events later)
    trg2 = value{j+f};
  
    % ---------------------------------------------------------------------
    % Case 1: cfg.nr == 1
    % Look for a pattern: '8Bit 11' followed by '8Bit 31'
    % ---------------------------------------------------------------------
    if cfg.nr == 1
        if trg1 == "8Bit 11" && trg2 == "8Bit 31"
            % define trial around the event at j+2 (as in your original logic)
            trlbegin = sample{j+2} + pretrig;   % start of trial in samples
            trlend   = sample{j+2} + posttrig;  % end of trial in samples
            offset   = pretrig;                 % relative offset of time 0

            % append new trial to trl matrix
            newtrl   = [trlbegin trlend offset];
            trl      = [trl; newtrl];
        end
        
    % ---------------------------------------------------------------------
    % Case 2: cfg.nr == 2
    % Look for a pattern: '8Bit 12' followed by '8Bit 31'
    % ---------------------------------------------------------------------
    elseif cfg.nr == 2
        if trg1 == "8Bit 12" && trg2 == "8Bit 31"
            % define trial around the event at j+2 (same logic as above)
            trlbegin = sample{j+2} + pretrig;   % start of trial in samples
            trlend   = sample{j+2} + posttrig;  % end of trial in samples
            offset   = pretrig;                 % relative offset of time 0

            % append new trial to trl matrix
            newtrl   = [trlbegin trlend offset];
            trl      = [trl; newtrl];
        end
    end
end

