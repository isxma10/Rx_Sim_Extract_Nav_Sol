% This function interpolators the UBX-reciever data to fill in for any
% missing gaps where the TOW skips a second.

function [ubxreciever] = the_interpolator(ubxreciever)

index = 1:(length(ubxreciever.iTOW)-60);

fields = fieldnames(ubxreciever);

for i = 1:length(fields)
    ubxreciever.(fields{i})(isnan(ubxreciever.(fields{i})))=0; %converts NaN to 0
    ubxreciever.(fields{i})( :, all(~ubxreciever.(fields{i}),1) ) = [];
    ubxreciever.(fields{i})( all(~ubxreciever.(fields{i}),2), : ) = [];
    ubxreciever.(fields{i}) = ubxreciever.(fields{i})(60:end,:);
    ubxreciever.(fields{i}) = interp1(ubxreciever.(fields{i})(:,:),index,'linear','extrap');
end
time = (ubxreciever.iTOW - (ubxreciever.iTOW(1)-1000))*1e-3;
ubxreciever.time = time;

% for i = 1:length(fields)
%     ubxreciever.(fields{i}) = interp1(trueTime,ubxreciever.(fields{i})(:,:),time,'linear','extrap');
% end

end % function end
