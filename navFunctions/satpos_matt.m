function [satPositions] = satpos_matt(transmitTime, satno, simSat, currMeasNr)
%% Initialize constants ===================================================
numOfSatellites = length(satno);

%% Initialize results =====================================================

satPositions = zeros(6, numOfSatellites);

%% Process each satellite =================================================

for satNr = 1 : numOfSatellites

    
    
    %--- Compute satellite coordinates ------------------------------------
    
    x = simSat.ECEFx(currMeasNr,satNr);
    y = simSat.ECEFy(currMeasNr,satNr);
    z = simSat.ECEFz(currMeasNr,satNr);
    
    %--- Compute Sattelite velocities--------------------------------------

    if currMeasNr > 1
        Vx = (x-simSat.ECEFx(currMeasNr-1,satNr))/1000;
        Vy = (y-simSat.ECEFy(currMeasNr-1,satNr))/1000;
        Vz = (z-simSat.ECEFz(currMeasNr-1,satNr))/1000;
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