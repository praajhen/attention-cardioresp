function [trl, event] = erp_1500ms(cfg)
% erp_1500ms
% FieldTrip trial function for 1500 ms ERP segments
%
% cfg.nr:
% 3 = congruent targets
% 4 = incongruent targets
%
% Author: praghajieeth raajhen santhana gopalan

%% ================= SETTINGS =================
cfg.trialdef.eventtype = 'annotation';
cfg.trialdef.prestim   = 0.200;
cfg.trialdef.poststim  = 1.5;

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
trg2 = value{j+2};
trg3 = value{j+4};

switch cfg.nr

    case 3   % congruent

        cond = (trg1=="8Bit 11" || trg1=="8Bit 12") && ...
               (trg2=="8Bit 21" || trg2=="8Bit 23") && ...
                trg3=="8Bit 31";

    case 4   % incongruent

        cond = (trg1=="8Bit 11" || trg1=="8Bit 12") && ...
               (trg2=="8Bit 22" || trg2=="8Bit 24") && ...
                trg3=="8Bit 31";

end

if cond
trlbegin = sample{j} + pretrig;
trlend   = sample{j} + posttrig;
offset   = pretrig;

trl = [trl; trlbegin trlend offset];
end

end