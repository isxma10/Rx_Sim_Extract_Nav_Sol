function [clk_bias, clk_drift,i_TOW2] = get_clk_bias(fid)


i_TOW2 = fread(fid, 1, 'uint32'); %iTOW [ms]

clk_bias = fread(fid, 1, 'int32'); %clock bias [ns]
clk_drift = fread(fid, 1, 'int32'); %clock drift [ns/s]

fread(fid, 1, 'uint32'); %Time accuracy estimate [ns]
fread(fid, 1, 'uint32'); %Frequency accuracy estimate [ps/s]
end