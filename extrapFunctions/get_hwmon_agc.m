function [agc] = get_hwmon_agc(fid)

fread(fid, 1, 'uint16');% Read the payload length (but do not use it currently)
fread(fid, 1, 'uint32'); % 0 to 4
fread(fid, 1, 'uint32'); % 4 to 8
fread(fid, 1, 'uint32'); % 8 to 12
fread(fid, 1, 'uint32'); % 12 to 16
fread(fid, 1, 'uint16'); % 16 to 18
agc = fread(fid, 1, 'uint16'); %18 to 20 Reads theAGC monitor (counts SIGHI xor SIGLO,range 0 to 8191)
end