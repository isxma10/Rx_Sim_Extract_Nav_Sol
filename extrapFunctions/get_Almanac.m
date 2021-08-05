function [alm_1] = get_Almanac( fileName )
%   getMessageUBX_NAV_SOL-MEAS waits for receiving a message UBX_NAV_SOL from the
%   file
%
%   Inputs : fileName           e.g 'COM5_160426_091653.ubx'
%
%   Outputs :
% open the file for reading
fid = fopen(fileName, 'rb');
% if you want to skip bytes do it here
fseek(fid, 0, 'bof');

SYNC1 = fread(fid, 1,  'uint8');
while ~feof(fid)
    if SYNC1 == 181
        % If we read the following bytes
        SYNC2 = fread(fid, 1, 'uint8');
        class = fread(fid, 1, 'uint8');
        ID = fread(fid, 1, 'uint8');
        if (SYNC1 == 181) && (SYNC2 == 98) && (class == 2)
            %---------------------------------------
            %%%%%%%%% UBX-RXM-ALM message %%%%%%%%%
            
            if (ID == 48) %%%% Rxm Alm
                
                length_alm = fread(fid, 1, 'uint16');  % length
                
                 if (length_alm == 40)

                SV_ID_alm = fread(fid, 1, 'uint32'); % SV ID                                
                alm = get_alm_from_subframe(fid);
                alm_1(SV_ID_alm)=alm;
                fread(fid, 1);
                fread(fid, 1);
                 end
                
            end
        end
        SYNC1 = fread(fid, 1);
    else
        
        SYNC1 = fread(fid, 1);
        
    end
end
fclose(fid);