% This function interpolators the UBX-reciever data to fill in for any
% missing gaps where the TOW skips a second.

function [ubxreciever] = the_interpolator(ubxreciever)

time = (ubxreciever.iTOW - (ubxreciever.iTOW(1)-1000))*1e-3;

fields = fieldnames(ubxreciever);

for i = 1:length(fields)
    ubxreciever.(fields{i})(isnan(ubxreciever.(fields{i})))=0; %converts NaN to 0
    ubxreciever.(fields{i})( :, all(~ubxreciever.(fields{i}),1) ) = [];
    ubxreciever.(fields{i})( all(~ubxreciever.(fields{i}),2), : ) = [];
    ubxreciever.(fields{i}) = interp1(ubxreciever.(fields{i})(:,:),time,'linear','extrap');
end

time = time(1):time(end);

for i = 1:length(fields)
    ubxreciever.(fields{i}) = interp1(ubxreciever.(fields{i})(:,:),time,'linear','extrap');
end

end % function end
