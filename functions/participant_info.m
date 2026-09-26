function [id, group, excluded] = participant_info(file, C)
% PARTICIPANT_INFO  ID, age group and exclusion flag from an .edf file entry.
[~, id] = fileparts(file.name);
if startsWith(id, 'AE')
    group = 'older';
else
    group = 'young';
end
excluded = ismember(id, C.exclude);
end
