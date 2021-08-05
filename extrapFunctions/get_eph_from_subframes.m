function eph = get_eph_from_subframes(subframe_1, subframe_2, subframe_3 )

gpsPi = 3.1415926535898;

mat1 = dec2bin(subframe_1,24);
subframe1=num2str(mat1)';
mat2 = dec2bin(subframe_2,24);
subframe2=num2str(mat2)';
mat3 = dec2bin(subframe_3,24);
subframe3=num2str(mat3)';
%% subframe1
% It contains WN, SV clock corrections, health and accuracy
eph.weekNumber  = bin2dec(subframe1(1:10)) + 1024;
eph.accuracy    = bin2dec(subframe1(13:16));
eph.health      = bin2dec(subframe1(17:22));
eph.T_GD        = twosComp2dec(subframe1(113:120)) * 2^(-31);
eph.IODC        = bin2dec([subframe1(23:24) subframe1(121:128)]);
eph.t_oc        = bin2dec(subframe1(129:144)) * 2^4;
eph.a_f2        = twosComp2dec(subframe1(145:152)) * 2^(-55);
eph.a_f1        = twosComp2dec(subframe1(153:168)) * 2^(-43);
eph.a_f0        = twosComp2dec(subframe1(169:190)) * 2^(-31);

%% subframe2
eph.IODE_sf2    = bin2dec(subframe2(1:8));
eph.C_rs        = twosComp2dec(subframe2(9: 24)) * 2^(-5);
eph.deltan      = ...
    twosComp2dec(subframe2(25:40)) * 2^(-43) * gpsPi;
eph.M_0         = ...
    twosComp2dec([subframe2(41:48) subframe2(49:72)]) ...
    * 2^(-31) * gpsPi;
eph.C_uc        = twosComp2dec(subframe2(73:88)) * 2^(-29);
eph.e           = ...
    bin2dec([subframe2(89:96) subframe2(97:120)]) ...
    * 2^(-33);
eph.C_us        = twosComp2dec(subframe2(121:136)) * 2^(-29);
eph.sqrtA       = ...
    bin2dec([subframe2(137:144) subframe2(145:168)]) ...
    * 2^(-19);
eph.t_oe        = bin2dec(subframe2(169:184)) * 2^4;
%% subframe3
eph.C_ic        = twosComp2dec(subframe3(1:16)) * 2^(-29);
eph.omega_0     = ...
    twosComp2dec([subframe3(17:24) subframe3(25:48)]) ...
    * 2^(-31) * gpsPi;
eph.C_is        = twosComp2dec(subframe3(49:64)) * 2^(-29);
eph.i_0         = ...
    twosComp2dec([subframe3(65:72) subframe3(73:96)]) ...
    * 2^(-31) * gpsPi;
eph.C_rc        = twosComp2dec(subframe3(97:112)) * 2^(-5);
eph.omega       = ...
    twosComp2dec([subframe3(113:120) subframe3(121:144)]) ...
    * 2^(-31) * gpsPi;
eph.omegaDot    = twosComp2dec(subframe3(145:168)) * 2^(-43) * gpsPi;
eph.IODE_sf3    = bin2dec(subframe3(169:176));
eph.iDot        = twosComp2dec(subframe3(177:190)) * 2^(-43) * gpsPi;



end
% for i=1: length (sf2d)
% %% read subframe 2
%    
%     word3 = dec2bin(sf2d(i,1));
%     if length(word3) < 24
%         diff=24-length(word3);
%         word3 = str2vect(word3);
%         word3 = [zeros(1,diff) word3];
%         word3 = num2str(word3);
%         word3(word3==' ')='';
%     end
%     C_rs_bin = word3(9:24);
%     
%     if C_rs_bin(1) == '1'
%         C_rs(i) = bin2dec(C_rs_bin)-(2^(16));
%     else
%         C_rs(i) = bin2dec(C_rs_bin);
%     end
%     C_rs(i) = C_rs(i)*(2^(-5));
%    
%     
%     
%     word4 = dec2bin(sf2d(i,2));
%     if length(word4) < 24
%         diff=24-length(word4);
%         word4 = str2mat(word4);
%         word4 = [zeros(1,diff) word4];
%         word4 = num2str(word4);
%         word4(word4==' ')='';
%     end
%     delta_n_bin = word4(1:16);
%     delta_n(i) = bin2dec(delta_n_bin)*(2^(-43));
%     if delta_n_bin(1) == '1'
%          delta_n(i) = bin2dec(delta_n_bin)-(2^(16));
%     else
%         delta_n(i) = bin2dec(delta_n_bin);
%     end
%     delta_n(i) = delta_n(i)*(2^(-43));
%     M0_msb_bin = word4(17:24);
%     M0_msb_bin = str2vect(M0_msb_bin);
%    
%     
%     
%     word5 = dec2bin(sf2d(i,3));
%     if length(word5) < 24
%         diff=24-length(word5);
%         word5 = str2vect(word5);
%         word5 = [zeros(1,diff) word5];
%         word5 = num2str(word5);
%         word5(word5==' ')='';
%     end
%     M0_lsb_bin = word5(1:24);
%     M0_lsb_bin = str2vect(M0_lsb_bin);
%     M0_bin = [M0_msb_bin M0_lsb_bin];
%     M0_bin = num2str(M0_bin);
%     M0_bin(M0_bin==' ')='';
%     
%    
%     
%     if M0_bin(1) == '1'
%          M0(i) = bin2dec(M0_bin)-(2^(32));
%     else
%         M0(i) = bin2dec(M0_bin);
%     end
%     M0(i) = M0(i)*(2^(-31));
%     
%     
%     
%     word6 = dec2bin(sf2d(i,4));
%     if length(word6) < 24
%         diff=24-length(word6);
%         word6 = str2vect(word6);
%         word6 = [zeros(1,diff) word6];
%         word6 = num2str(word6);
%         word6(word6==' ')='';
%     end
%     C_uc_bin = word6(1:16);
%     
%     if C_uc_bin(1) == '1'
%         C_uc(i) = bin2dec(C_uc_bin)-(2^(16));
%     else
%         C_uc(i) = bin2dec(C_uc_bin);
%     end
%     C_uc(i) = C_uc(i)*(2^(-29));
%     e_msb_bin = word6(17:24);
% %     e_msb_bin = str2vect(e_msb_bin);
%     
%     
%     
%     word7 = dec2bin(sf2d(i,5),24);
% %      if length(word7) < 24
% %         diff=24-length(word7);
% %         word7 = str2vect(word7);
% %         word7 = [zeros(1,diff) word7];
% %         word7 = num2str(word7);
% %         word7(word7==' ')='';
% %     end
% %     e_lsb_bin = word7;
% %     e_lsb_bin = str2vect(e_lsb_bin);
% %     e_bin = [e_msb_bin e_lsb_bin];
% %     e_bin = num2str(e_bin);
% %     e_bin(e_bin==' ')='';
%       
%     
%     e_lsb_bin = word7;
%    
%     e_bin = strcat(e_msb_bin,e_lsb_bin);
%    
%     
%     
%     e(i) = bin2dec(e_bin)*(2^(-33));
% %      e(i) = bin2dec(e_bin);
%     
%     
%     
%     word8 = dec2bin(sf2d(i,6)); 
%     if length(word8) < 24
%         diff=24-length(word8);
%         word8 = str2vect(word8);
%         word8 = [zeros(1,diff) word8];
%         word8 = num2str(word8);
%         word8(word8==' ')='';
%     end
%     C_us_bin = word8(1:16);
%     C_us(i) = bin2dec(C_us_bin)*(2^(-29));
%     if C_us_bin(1) == '1'
%         C_us(i) = bin2dec(C_us_bin)-(2^(16));
%     else
%         C_us(i) = bin2dec(C_us_bin);
%     end
%     C_us(i) = C_us(i)*(2^(-29));
%     sqrtA_msb_bin = word8(17:24);
%     sqrtA_msb_bin = str2vect(sqrtA_msb_bin);
%    
%     
%     
%     word9 = dec2bin(sf2d(i,7));
%     if length(word9) < 24
%         diff=24-length(word9);
%         word9 = str2vect(word9);
%         word9 = [zeros(1,diff) word9];
%         word9 = num2str(word9);
%         word9(word9==' ')='';
%     end
%     sqrtA_lsb_bin = word9(1:24);
%     sqrtA_lsb_bin = str2vect(sqrtA_lsb_bin);
%     sqrtA_bin = [sqrtA_msb_bin sqrtA_lsb_bin];
%     sqrtA_bin = num2str(sqrtA_bin);
%     sqrtA_bin(sqrtA_bin==' ')='';
%     sqrtA(i) = bin2dec(sqrtA_bin)*(2^(-19));
%     
%     
%     
%     word10 = dec2bin(sf2d(i,8));
%     if length(word10) < 24
%         diff=24-length(word10);
%         word10 = str2vect(word10);
%         word10 = [zeros(1,diff) word10];
%         word10 = num2str(word10);
%         word10(word10==' ')='';
%     end
%     t_oe_bin = word10(1:16);
%     t_oe(i) = bin2dec(t_oe_bin)*(2^4);
%     
%     
% %% read subframe 3    
%     
% 
%     
%     word3 = dec2bin(sf3d(i,1));
%     if length(word3) < 24
%         diff=24-length(word3);
%         word3 = str2vect(word3);
%         word3 = [zeros(1,diff) word3];
%         word3 = num2str(word3);
%         word3(word3==' ')='';
%     end
%     C_ic_bin = word3(1:16);
%     C_ic(i) = bin2dec(C_ic_bin)*(2^(-29));
%     if C_ic_bin(1) == '1'
%       C_ic(i) = bin2dec(C_ic_bin)-(2^(16));
%     else
%       C_ic(i) = bin2dec(C_ic_bin);
%     end
%     C_ic(i) = C_ic(i)*(2^(-29));
%     Omega_0_msb_bin = word3(17:24);
%     Omega_0_msb_bin = str2vect(Omega_0_msb_bin);
%      
%     
%     
%     word4 = dec2bin(sf3d(i,2));
%     if length(word4) < 24
%         diff=24-length(word4);
%         word4 = str2vect(word4);
%         word4 = [zeros(1,diff) word4];
%         word4 = num2str(word4);
%         word4(word4==' ')='';
%     end
%     Omega_0_lsb_bin = word4;
%     Omega_0_lsb_bin = str2vect(Omega_0_lsb_bin);
%     Omega_0_bin = [Omega_0_msb_bin Omega_0_lsb_bin];
%     Omega_0_bin = num2str(Omega_0_bin);
%     Omega_0_bin(Omega_0_bin==' ')='';
%     
%     if Omega_0_bin(1) == '1'
%         Omega_0(i) = bin2dec(Omega_0_bin)-(2^(32));
%     else
%         Omega_0(i) = bin2dec(Omega_0_bin);
%     end
%     Omega_0(i) = Omega_0(i)*(2^(-31));
%     
%     
%     
%     word5 = dec2bin(sf3d(i,3));
%     if length(word5) < 24
%         diff=24-length(word5);
%         word5 = str2vect(word5);
%         word5 = [zeros(1,diff) word5];
%         word5 = num2str(word5);
%         word5(word5==' ')='';
%     end
%     C_is_bin = word5(1:16);
%     C_is(i) = bin2dec(C_is_bin)*(2^(-29));
%     if C_is_bin(1) == '1'
%         C_is(i) = bin2dec(C_is_bin)-(2^(16));
%     else
%         C_is(i) = bin2dec(C_is_bin);
%     end
%     C_is(i) = C_is(i)*(2^(-29));
%     i_0_msb_bin = word5(17:24);
%     i_0_msb_bin = str2vect(i_0_msb_bin);
%    
%     
%     
%     word6 = dec2bin(sf3d(i,4));
%      if length(word6) < 24
%         diff=24-length(word6);
%         word6 = str2vect(word6);
%         word6 = [zeros(1,diff) word6];
%         word6 = num2str(word6);
%         word6(word6==' ')='';
%     end
%     i_0_lsb_bin = word6(1:24);
%     i_0_lsb_bin = str2vect(i_0_lsb_bin);
%     i_0_bin = [i_0_msb_bin i_0_lsb_bin];
%     i_0_bin = num2str(i_0_bin);
%     i_0_bin(i_0_bin==' ')='';
%     i_0(i) = bin2dec(i_0_bin)*(2^(-31));
%     if i_0_bin(1) == '1'
%         i_0(i) = bin2dec(i_0_bin)-(2^(32));
%     else
%         i_0(i) = bin2dec(i_0_bin);
%     end
%     i_0(i) = i_0(i)*(2^(-31));
%     
%     
%     
%     word7 = dec2bin(sf3d(i,5));
%      if length(word7) < 24
%         diff=24-length(word7);
%         word7 = str2vect(word7);
%         word7 = [zeros(1,diff) word7];
%         word7 = num2str(word7);
%         word7(word7==' ')='';
%     end
%     C_rc_bin = word7(1:16);
%     C_rc(i) = bin2dec(C_rc_bin)*(2^(-5));
%     if C_rc_bin(1) == '1'
%         C_rc(i) = bin2dec(C_rc_bin)-(2^(16));
%     else
%         C_rc(i) = bin2dec(C_rc_bin);
%     end
%     C_rc(i) = C_rc(i)*(2^(-5));
%     om_msb_bin = word7(17:24);
%     om_msb_bin = str2vect(om_msb_bin);
%     
%     
%     
%     word8 = dec2bin(sf3d(i,6));
%      if length(word8) < 24
%         diff=24-length(word8);
%         word8 = str2vect(word8);
%         word8 = [zeros(1,diff) word8];
%         word8 = num2str(word8);
%         word8(word8==' ')='';
%     end
%     om_lsb_bin = word8;
%     om_lsb_bin = str2vect(om_lsb_bin);
%     om_bin = [om_msb_bin om_lsb_bin];
%     om_bin = num2str(om_bin);
%     om_bin(om_bin==' ')='';
%     om(i) = bin2dec(om_bin)*(2^(-31));
%     if om_bin == '1'
%         om(i) = bin2dec(om_bin)-(2^(32));
%     else
%         om(i) = bin2dec(om_bin);
%     end
%     om(i) = om(i)*(2^(-31));
%     
%     
%     
%     word9 = dec2bin(sf3d(i,7));
%     if length(word9) < 24
%         diff=24-length(word9);
%         word9 = str2vect(word9);
%         word9 = [zeros(1,diff) word9];
%         word9 = num2str(word9);
%         word9(word9==' ')='';
%     end
%         omega_dot_bin = word9;
%    
%     omega_dot(i) = bin2dec(omega_dot_bin)*(2^(-43));
%     if omega_dot_bin(1) == '1'
%         omega_dot(i) = bin2dec(omega_dot_bin)-(2^(24));
%     else
%         omega_dot(i) = bin2dec(omega_dot_bin);
%     end
%     omega_dot(i) = omega_dot(i)*(2^(-43));
%    
%     
%     
%     word10 = dec2bin(sf3d(i,8));
%     if length(word10) < 24
%         diff=24-length(word10);
%         word10 = str2vect(word10);
%         word10 = [zeros(1,diff) word10];
%         word10 = num2str(word10);
%         word10(word10==' ')='';
%     end
%     iode_bin = word10(1:8);
%     iode(i) = bin2dec(iode_bin);
%     idot_bin = word10(9:22);
%     idot_bin_m(i,:) = idot_bin;
%     
%     if idot_bin(1) == '1'
%       idot(i) = bin2dec(idot_bin)-(2^(14));
%     else
%         idot(i) = bin2dec(idot_bin);
%     end
%     idot(i) = idot(i)*(2^(-43));
% 
% 
% % eph.weekNumber  = bin2dec(subframe1(61:70)) + 1024;
% % eph.accuracy    = bin2dec(subframe1(73:76));
% % eph.health      = bin2dec(subframe1(77:82));
% % eph.T_GD        = twosComp2dec(subframe1(197:204)) * 2^(-31);
% % eph.IODC        = bin2dec([subframe1(83:84) subframe1(197:204)]);
% % eph.t_oc        = bin2dec(subframe1(219:234)) * 2^4;
% % eph.a_f2        = twosComp2dec(subframe1(241:248)) * 2^(-55);
% % eph.a_f1        = twosComp2dec(subframe1(249:264)) * 2^(-43);
% % eph.a_f0        = twosComp2dec(subframe1(271:292)) * 2^(-31);
% % 
% end

