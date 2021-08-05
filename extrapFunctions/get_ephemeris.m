function eph = get_ephemeris(fid)




subframe1(:) = fread(fid, 8, 'uint32');
subframe2(:) = fread(fid, 8, 'uint32');
subframe3(:) = fread(fid, 8, 'uint32');

if (norm(subframe1) && norm(subframe2) && norm(subframe3))
    
    eph = get_eph_from_subframes(subframe1, subframe2, subframe3 );

end

end