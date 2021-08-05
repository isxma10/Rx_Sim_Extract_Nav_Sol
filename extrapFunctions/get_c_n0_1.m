function [C_N0,nb_sats,residual] = get_c_n0_1(fid )

fread(fid, 1, 'uint32'); %iTOW
numCh=fread(fid, 1, 'uint8'); % numCh
fread(fid, 1); % globalFlags
fread(fid, 2, 'uint8');%reserved1

C_N0=NaN(32,1);
residual=NaN(32,1);
nb_sats =0;
for inc=1:numCh
    fread(fid, 1, 'uint8');%Channel number
    satID = fread(fid, 1, 'uint8'); % SAT ID
    flag = fread(fid, 1); % flag NAV
    
    if (flag == 13)
        quality = fread(fid, 1); % quality
        %         if quality == 0 || quality  == 7 || quality  == 6 || quality == 0 || quality == 4 || quality==5
        C_N0(satID) = fread(fid, 1, 'uint8'); %c/N0
        nb_sats = nb_sats+1;
        %         else
        %             fread(fid, 1, 'uint8');
        %         end
        fread(fid, 1, 'int8');%elevation
        fread(fid, 1, 'int16');%azimuth
        prRES=fread(fid, 1, 'int32');%prRES
        residual(satID) =prRES/100 ;%
    else
        fread(fid, 1); % quality
        fread(fid, 1, 'uint8'); %c/N0
        fread(fid, 1, 'int8');%elevation
        fread(fid, 1, 'int16');%azimuth
        fread(fid, 1, 'int32');%prRES
    end
    
end
end