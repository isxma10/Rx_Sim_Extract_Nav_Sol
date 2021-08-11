function [dataOut] = getMessageUBX_NAV_SOL_struct( fileName )

% [iTOW,fTOW,iTOW2,C_over_N0_1,Residual,pos,vel,nb_sv_used,nb_sv_used1,C_over_N0_2_1,Ranges_1,Phase_meas_1...
%     ,Doppler_1,Used_GNSS_1,rcv_tow,eph_1,eph_2,clock_bias,clock_drift,usable_sats,Std_ranges_1,Std_doppler_1] ...    

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

C_over_N0_1=[];
Residual=[];
nb_sv_used1=[];
C_over_N0_2_1=[];
Ranges_1=[];
Phase_meas_1=[];
Doppler_1 = [];
Used_GNSS_1 = [];
rcv_tow = [];
usable_sats = [];
Std_ranges_1 =[];
Std_doppler_1 = [];
iTOW = [];
fTOW = [];
pos = [];
agc = [];
cagc = 0;

SYNC1 = fread(fid, 1,  'uint8');
messageCount = 0;
sv_info_check=0;
RAWX_check=0;
EPH_check=0;
ALM_check=0;
clk_bias_check =0;
fix_3D=0;
flagitow=1;
flag_check_EPH_1=0;
while ~feof(fid)
    
    
    if SYNC1 == 181
        % If we read the following bytes
        SYNC2 = fread(fid, 1, 'uint8');
        class = fread(fid, 1, 'uint8');
        ID = fread(fid, 1, 'uint8');
        %--------------------------------------------------------------------------
        %%%%%%%%% UBX-HARDWARE-MONITOR message %%%%%%%%%
        if (SYNC1 == 181) && (SYNC2 == 98) && (class == 10) && (ID == 9) && (cagc == 1);
              agc(messageCount,:) = get_hwmon_agc(fid);
              cagc = 0;
        end
        if (SYNC1 == 181) && (SYNC2 == 98) && (class == 1)         % NAV
            
            %---------------------------------------
            %%%%%%%%% UBX-NAV-SOL message %%%%%%%%%
            
            if (ID == 6) %%%% Nav SOL
                [i_TOW, fix_3D, position, velocity , nb_sats_used,f_TOW, cagc] = get_itow_sat_posvel_3Dfix(fid);
                flagitow=1;               
                if (fix_3D == 3)
                    messageCount = messageCount + 1;
                    flag_check_EPH=0;
                    flag_check_ALM=0;
                    if (mod(messageCount,7200)==0)
                        fprintf('%dh  \n',(messageCount/7200)*2);
                    end
                    
                    if (mod(messageCount,7200*3.2)==0)
                        break;
                    end       
                    
                    iTOW(messageCount) = i_TOW;
                    fTOW(messageCount) = f_TOW;
                    gps_3Dfix(messageCount) = fix_3D;
                    pos(messageCount,:) = position;
                    vel(messageCount,:) = velocity;
                    nb_sv_used(messageCount) = nb_sats_used;
                    
                end
                if messageCount == 1
                flag_check_EPH_1=1;
                end
                %-----------------------------------------
                %%%%%%%%% UBX-NAV-SOL message %%%%%%%%%
                
            elseif  (ID == 48)  && (fix_3D == 3)  %% SV INFO
                
                sv_info_check = sv_info_check + 1;
                length_sv_info = fread(fid, 1, 'uint16'); %Length
                
                if (mod(length_sv_info-8,12)==0) && flagitow==1
                    [C_N0,nb_sats,residual] = get_c_n0_1(fid );
                    C_over_N0_1 (messageCount,:) = C_N0';
                    nb_sv_used1(messageCount,:) = nb_sats;
                    Residual(messageCount,:)=residual';
                    flagitow=0;
                    %                 elseif (mod(length_sv_info-8,12)==0) && flagitow==0
                    %                     [C_N0,nb_sats] = get_c_n0_1(fid );
                    %                     C_over_N0_1 (messageCount+1,:) = C_N0';
                    %                     nb_sv_used1(messageCount+1,:) = nb_sats;
                else
                    sv_info_check = sv_info_check -1;
                end
                
            elseif  (ID == 34)  && (fix_3D == 3)  %% CLOCK
                length_id = fread(fid, 1, 'uint16'); %Length
                
                if length_id == 20
                    
                    clk_bias_check = clk_bias_check + 1 ;
                    
                    [clk_bias, clk_drift,i_TOW2] = get_clk_bias(fid);
                    
                    clock_bias (messageCount) = clk_bias ;
                    clock_drift (messageCount) = clk_drift' ;
                    iTOW2 (messageCount) = i_TOW2 ;
                    
                end
            end
            
            %--------------------------------------------------------------------------
            %%%%%%%%% UBX-RXM message %%%%%%%%%
            
        elseif (SYNC1 == 181) && (SYNC2 == 98) && (class == 2)  && (flag_check_EPH_1 == 1) %%%% UBX-RXM
            
            %---------------------------------------
            %%%%%%%%% UBX-RXM-RAWX message %%%%%%%%%
            
            if (ID == 21)     %% RAWX
                
                RAWX_check=RAWX_check+1;            %Added, may need to delete but was causing RAWX_check to be 0 which was problematic (alex + matt)
                
                length_rawx = fread(fid, 1, 'uint16');  % length                                         % Read the payload length (but do not use it currently)
                
                if (mod(length_rawx-16,32) == 0)
                    rcv_tow(RAWX_check) = fread(fid, 1, 'float64'); % receiver time of week R8
                    
%                     if (round(rcv_tow(RAWX_check))== round(iTOW(messageCount)/1000))
                    if RAWX_check ==1 ||(rcv_tow(RAWX_check)> rcv_tow(RAWX_check-1))    
                        [sat_info] = get_observations(fid );
                        
                        Ranges_1 (RAWX_check,:) = sat_info(:,1)';
                        Std_ranges_1 (RAWX_check,:) = sat_info(:,6)';
                        Phase_meas_1 (RAWX_check,:) = sat_info(:,2)';
                        Doppler_1 (RAWX_check,:) = sat_info(:,3)';
                        Std_doppler_1 (RAWX_check,:) = sat_info(:,7)';
                        Used_GNSS_1 (RAWX_check,:) = sat_info(:,4)';
                        C_over_N0_2_1 (RAWX_check,:) = sat_info(:,5)';
                    else
                        RAWX_check =RAWX_check-1;
                    end
                else
                    RAWX_check =RAWX_check-1;
                end
                %--------------------------------------
                %%%%%%%%% UBX-RXM-EPH message %%%%%%%%%
                
             elseif (ID == 49)   %&&  (round(rcv_tow(RAWX_check))== round(iTOW(messageCount)/1000)) %% EPH
                flag_check_EPH=0
                 if flag_check_EPH==0
                    EPH_check = EPH_check +1;
                    flag_check_EPH=1;
                end
                
                length = fread(fid, 1, 'uint16');  % length
                if (length == 104)
                    
                    SV_ID = fread(fid, 1, 'uint32'); % SV ID
                    how = fread(fid, 1, 'uint32'); % how - Hand-Over Word of first Subframe. This is required if data is sent to the receiver. 0 indicates that no Ephemeris Data is following
                    %                     how_vec = dec2bin(how,24);
                    %                     how_str=num2str(how_vec);
                    %                     time = bin2dec(how_str(1:17));
                    %
                    ephem = get_ephemeris(fid);
                    eph_1(EPH_check,SV_ID)=ephem;
                    eph_2(RAWX_check,SV_ID)=ephem;
                end
%              elseif (ID == 48) % &&  (round(rcv_tow(RAWX_check))== round(iTOW(messageCount)/1000)) %% Rxm Alm
%                 if flag_check_ALM==0
%                     ALM_check = ALM_check +1;
%                     flag_check_ALM=1;
%                 end
%                 length_alm = fread(fid, 1, 'uint16');  % length
%                 
%                 if (length_alm == 40)
%                     
%                     SV_ID_alm = fread(fid, 1, 'uint32'); % SV ID
%                     
%                     alm = get_alm_from_subframe(fid);                    
%                     alm_1(ALM_check,SV_ID_alm)=alm;
%                     alm_2(RAWX_check,SV_ID_alm)=alm;
%                 end
                
             elseif (ID == 32)  % &&  (round(rcv_tow(RAWX_check))== round(iTOW(messageCount)/1000)) %% SVSI
                
                length_svsi = fread(fid, 1, 'uint16');  % length
                
                if (mod(length_svsi-8,6) == 0)
                    
                    [sats] = get_sats_usable(fid );
                    for i = 1:size(sats,2)
                        RAWX_check=RAWX_check+1;
                        usable_sats(RAWX_check,i) = sats(i);
                        
                    end
                end
                

            end

        end
        %--------------------------------------------------------------------------
        
        SYNC1 = fread(fid, 1);                                    % If the byte received does not correspond to the preamble read another byte
        
    else
        
        SYNC1 = fread(fid, 1);
        
    end
    
end
fclose(fid);

% dataOut = [iTOW,fTOW,iTOW2,C_over_N0_1,Residual,pos,vel,nb_sv_used];

%[iTOW,fTOW,iTOW2,C_over_N0_1,Residual,pos,vel,nb_sv_used,nb_sv_used1,C_over_N0_2_1,Ranges_1,Phase_meas_1...
%     ,Doppler_1,Used_GNSS_1,rcv_tow,eph_1,eph_2,clock_bias,clock_drift,usable_sats,Std_ranges_1,Std_doppler_1] ...    

dataOut.iTOW = iTOW';
dataOut.fTOW = fTOW';
dataOut.TOW = (iTOW * 1e-3 + fTOW * 1e-9)';
%dataOut.iTOW2 = iTOW2;
dataOut.C_over_N0_1 = C_over_N0_1;
dataOut.Residual = Residual;
dataOut.pos = pos;
dataOut.vel = vel;
dataOut.C_over_N0_2_1 = C_over_N0_2_1;
dataOut.Ranges_1 = Ranges_1;
dataOut.Phase_meas_1 = Phase_meas_1;
dataOut.Doppler_1 = Doppler_1;
%dataOut.Used_GNSS_1 = Used_GNSS_1;
dataOut.rcv_tow = nonzeros(rcv_tow');
%dataOut.eph_1 = eph_1;
%dataOut.eph_2 = eph_2;
dataOut.clock_bias = clock_bias';
dataOut.clock_drift = clock_drift';
dataOut.usable_sats = usable_sats;
dataOut.Std_ranges_1 = Std_ranges_1;
dataOut.Std_doppler_1 = Std_doppler_1;
dataOut.agc = agc / 83; % /83 to make info comparable with the ucentre table