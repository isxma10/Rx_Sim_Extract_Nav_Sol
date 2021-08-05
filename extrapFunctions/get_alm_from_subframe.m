function alm = get_alm_from_subframe(fid)
alm.week = fread(fid, 1, 'uint32'); % SV ID
subframe_4(:) = fread(fid, 8, 'uint32');

gpsPi = 3.1415926535898;

mat4 = dec2bin(subframe_4,24);
subframe4=num2str(mat4)';

%% subframe4
% It contains WN, SV clock corrections, health
alm.e  = bin2dec(subframe4(9:24))* 2^(-33) ;
alm.t_oa    = bin2dec(subframe4(25:32)) *2^12;
alm.i_0 = twosComp2dec(subframe4(33:48))* 2^(-19)* gpsPi;
alm.omegaDot  = twosComp2dec(subframe4(49:64))* 2^(-38)* gpsPi;
alm.health    = bin2dec(subframe4(65:72));
alm.sqrtA      = bin2dec(subframe4(73:96))* 2^(-11);
alm.omega_0    = twosComp2dec(subframe4(97:120)) * 2^(-23)* gpsPi;
alm.omega      = twosComp2dec(subframe4(121:144)) * 2^(-23)* gpsPi;
alm.M_0      = twosComp2dec(subframe4(145:168)) * 2^(-23)* gpsPi;
alm.a_f0      = twosComp2dec([subframe4(169:176) subframe4(188:190)]) * 2^(-20);
alm.a_f1      = twosComp2dec(subframe4(177:187)) * 2^(-38);
end