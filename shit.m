    
    intReciever.ECEF(:,1)= interp1(reciever.GPSTOW(1:end,1),reciever.ECEFx(1:length(reciever.GPSTOW),1),ubxreciever.TOW);
    intReciever.ECEF(:,2)= interp1(reciever.GPSTOW(1:end,1),reciever.ECEFy(1:length(reciever.GPSTOW),1),ubxreciever.TOW);
    intReciever.ECEF(:,3)= interp1(reciever.GPSTOW(1:end,1),reciever.ECEFz(1:length(reciever.GPSTOW),1),ubxreciever.TOW);