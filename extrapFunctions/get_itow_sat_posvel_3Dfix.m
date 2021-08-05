function [iTOW, gps_3Dfix, pos, vel , nb_sv_used,fTOW, cagc] = get_itow_sat_posvel_3Dfix(fid )


fread(fid, 1, 'uint16');                                            % Read the payload length (but do not use it currently)

iTOW = fread(fid, 1, 'uint32');

fTOW = fread(fid, 1, 'int32');                                            % Read the payload length (but do not use it currently)
fread(fid, 1, 'int16');                                            % Read the payload length (but do not use it currently)

gps_3Dfix = fread(fid, 1, 'uint8');                                            % Read the payload length (but do not use it currently)

fread(fid, 1);    %flags                                        % Read the payload length (but do not use it currently)

if (gps_3Dfix == 3)
    cagc = 1;
    x_coord = fread(fid, 1, 'int32');
    y_coord = fread(fid, 1, 'int32');
    z_coord = fread(fid, 1, 'int32');
    
    fread(fid, 1, 'uint32');                                            % Read the payload length (but do not use it currently)
    
    v_x = fread(fid, 1, 'int32');
    v_y = fread(fid, 1, 'int32');
    v_z = fread(fid, 1, 'int32');
    
    fread(fid, 1, 'uint32');
    fread(fid, 1, 'uint16');
    fread(fid, 1, 'uint8');
    nb_sv_used= fread(fid, 1, 'uint8');
else
    cagc =0;
    x_coord = NaN;
    y_coord = NaN;
    z_coord = NaN;
    
    v_x = NaN;
    v_y = NaN;
    v_z = NaN;
    nb_sv_used=NaN;
    
    fread(fid, 1, 'int32');
    fread(fid, 1, 'int32');
    fread(fid, 1, 'int32');
    fread(fid, 1, 'uint32');
    fread(fid, 1, 'int32');
    fread(fid, 1, 'int32');
    fread(fid, 1, 'int32');
    fread(fid, 1, 'uint32');
    fread(fid, 1, 'uint16');
    fread(fid, 1, 'uint8');
    fread(fid, 1, 'uint8');
    
end
cagc = cagc;
pos = [x_coord; y_coord; z_coord];
vel = [v_x; v_y; v_z];
fread(fid, 4, 'uint8');
end