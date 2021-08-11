time = (ubxreciever.iTOW(60:end) - (ubxreciever.iTOW(60)-1000))*1e-3;

fields = fieldnames(ubxreciever);

for i = 1:length(fields)
    ubxreciever.(fields{i})(isnan(ubxreciever.(fields{i})))=0; %converts NaN to 0
    ubxreciever.(fields{i})( :, all(~ubxreciever.(fields{i}),1) ) = [];
    ubxreciever.(fields{i})( all(~ubxreciever.(fields{i}),2), : ) = [];
    ubxreciever.(fields{i}) = ubxreciever.(fields{i})(60:end,:);
    ubxreciever.(fields{i}) = interp1(ubxreciever.(fields{i})(:,:),time,'linear','extrap');
end

time = time(1):time(end);

for i = 1:length(fields)
    ubxreciever.(fields{i}) = interp1(ubxreciever.(fields{i})(:,:),time,'linear','extrap');
end