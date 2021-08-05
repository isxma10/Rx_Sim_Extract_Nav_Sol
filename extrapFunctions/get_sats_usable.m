function [sats] = get_sats_usable(fid )

iTOW=fread(fid, 1, 'uint32'); %iTOW
fread(fid, 1, 'int16'); %week
fread(fid, 1, 'uint8'); %Number of visible satellites
numSV = fread(fid, 1, 'uint8'); %Number of per-SV data blocks following
sats = [];

for inc = 1:numSV
    
    svid = fread(fid, 1, 'uint8'); % Satellite ID
    flag = fread(fid,1) ; % Information Flags
    
    if flag ==48  
        sats = [sats svid];
    end
    fread(fid, 1, 'int16') ; % Azimuth
    fread(fid, 1, 'int8') ; % Elevation
    age = fread(fid,1) ; % Age of Almanac and Ephemeris
    if age==7 
        eph_age =age;
    end
end

end