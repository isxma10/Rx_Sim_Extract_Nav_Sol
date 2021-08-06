function [satPositions] = satpos_matt(transmitTime, satno, GPSsat, currMeasNr)
%% Initialize constants ===================================================
numOfSatellites = length(satno);

%% Initialize results =====================================================

satPositions = zeros(6, numOfSatellites);

%% Process each satellite =================================================

for satNr = 1 : numOfSatellites

    
    
    %--- Compute satellite coordinates ------------------------------------
    
    x = GPSsat.ECEFx(currMeasNr,satNr);
    y = GPSsat.ECEFy(currMeasNr,satNr);
    z = GPSsat.ECEFz(currMeasNr,satNr);
    
    %--- Compute Sattelite velocities--------------------------------------

    if currMeasNr > 1
        Vx = (x-GPSsat.ECEFx(currMeasNr-1,satNr));
        Vy = (y-GPSsat.ECEFy(currMeasNr-1,satNr));
        Vz = (z-GPSsat.ECEFz(currMeasNr-1,satNr));
    else
        Vx = 0;
        Vy = 0;
        Vz = 0;
    end
    

      
    satPositions(1, satNr) = x;
    satPositions(2, satNr) = y;
    satPositions(3, satNr) = z;
    satPositions(4, satNr) = Vx;
    satPositions(5, satNr) = Vy;
    satPositions(6, satNr) = Vz;
    



    
end