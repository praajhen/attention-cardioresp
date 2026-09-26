function sig = read_physio(dataset, channel)
% READ_PHYSIO  Read one continuous channel ('Resp' or 'ecg') as a row vector.
cfg         = [];
cfg.dataset = dataset;
cfg.channel = channel;
d   = ft_preprocessing(cfg);
sig = d.trial{1};
end
