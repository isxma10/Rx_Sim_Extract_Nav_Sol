function [sat_info] = get_observations(fid )

week= fread(fid, 1, 'uint16'); %week
leapS=fread(fid, 1, 'int8');  % leapS

nb_of_meas=fread(fid, 1, 'uint8'); %nb of measuremnts

status=fread(fid, 1);  %rec status
fread(fid, 3, 'uint8');%reserved1

sat_info=NaN(32,7);
for inc=1:nb_of_meas
    
    pseudornage = fread(fid, 1, 'float64'); % [m]
    carrier_meas = fread(fid, 1, 'float64'); % [cycles]
    doppler = fread(fid, 1, 'float32'); % [Hz]
    gnss_ID = fread(fid, 1, 'uint8');% GNSS ID (GPS, GLONASS, ect)
    if gnss_ID==0
        sv_ID = fread(fid, 1, 'uint8');
        
        fread(fid, 1, 'uint8');%reserved2
        fread(fid, 1, 'uint8');%freq ID
        fread(fid, 1, 'uint16');%locktime
        
        c_n0 = fread(fid, 1, 'uint8');%C/N0 dBHz
        
        std_psr = fread(fid, 1);%prStdev
        std_psr = 0.01*(2^std_psr);
        fread(fid, 1);%cpStdev
        std_do = fread(fid, 1);%doStdev
        std_do = 0.002*(2^std_do);
        trck_status = fread(fid, 1);%tracking status bit field
        fread(fid, 1, 'uint8');%reserved3
        if trck_status>0
        sat_info(sv_ID,1)=pseudornage;
        sat_info(sv_ID,2)=carrier_meas;
        sat_info(sv_ID,3)=doppler;
        sat_info(sv_ID,4)=gnss_ID;
        sat_info(sv_ID,5)=c_n0;
        sat_info(sv_ID,6)= std_psr;
        sat_info(sv_ID,7)= std_do;
        end
    else
        fread(fid, 1, 'uint8');%sv_ID
        fread(fid, 1, 'uint8');%reserved2
        fread(fid, 1, 'uint8');%freq ID
        fread(fid, 1, 'uint16');%locktime
        fread(fid, 1, 'uint8');%C/N0 dBHz
        
        fread(fid, 1);%prStdev        
        fread(fid, 1);%cpStdev
        fread(fid, 1);%doStdev
        fread(fid, 1);%tracking status bit field
        fread(fid, 1, 'uint8');%reserved3
    end
end

end