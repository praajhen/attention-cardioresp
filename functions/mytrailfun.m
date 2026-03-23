function [trl, event] = mytrialfun(cfg)
% mytrialfun
% FieldTrip trial function for cue-based ERP extraction
%
% cfg.nr:
% 1 = no cue
% 2 = double cue
%
% Author: praghajieeth raajhen santhana gopalan

%% ================= SETTINGS =================
cfg.trialdef.eventtype = 'annotation';
cfg.trialdef.prestim   = 0.200;
cfg.trialdef.poststim  = 0.5;

%% ================= READ EVENTS =================
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% remove empty events
event(arrayfun(@(x) isempty(x.value), event)) = [];

value  = {event.value}';
sample = {event.sample}';

%% ================= TIME WINDOWS =================
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);

trl = [];

%% ================= TRIAL CREATION =================
for j = 1:(length(value)-4)

trg1 = value{j};
trg2 = value{j+4};

switch cfg.nr

    case 1  % no cue
        cond = trg1=="8Bit 11" && trg2=="8Bit 31";

    case 2  % double cue
        cond = trg1=="8Bit 12" && trg2=="8Bit 31";

end

if cond

trlbegin = sample{j+2} + pretrig;
trlend   = sample{j+2} + posttrig;
offset   = pretrig;

trl = [trl; trlbegin trlend offset];

end

end