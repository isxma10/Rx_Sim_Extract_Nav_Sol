% This function interpolators the UBX-reciever data to fill in for any
% missing gaps where the TOW skips a second.

function [ubxreciever] = the_interpolator(ubxreciever)

time = ubxreciever.TOW;

fields = fieldnames(ubxreciever);

for i = 1:length(fields)
    ubxreciever.(fields{i}) = interp1(ubxreciever.(fields{i})(:,:),time,'linear','extrap');
end

time = (ubxreciever.TOW(1):ubxreciever.TOW(end))';

for i = 1:length(fields)
    ubxreciever.(fields{i}) = interp1(ubxreciever.(fields{i})(:,:),time,'linear','extrap');
end

end % function end
