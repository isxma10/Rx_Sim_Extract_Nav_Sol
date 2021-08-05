function [spfPositions] = spfpos_matt(transmitTime, satno, spoofSat, currMeasNr)
%% Initialize constants ===================================================
numOfSatellites = length(satno);

%% Initialize results =====================================================

spfPositions = zeros(6, numOfSatellites);

%% Process each satellite =================================================

for satNr = 1 : numOfSatellites

    
    
    %--- Compute satellite coordinates ------------------------------------
    
    x = spoofSat.ECEFx(currMeasNr,satNr);
    y = spoofSat.ECEFy(currMeasNr,satNr);
    z = spoofSat.ECEFz(currMeasNr,satNr);
    
    %--- Compute Sattelite velocities--------------------------------------

    if currMeasNr > 1
        Vx = (x-spoofSat.ECEFx(currMeasNr-1,satNr))/1000;
        Vy = (y-spoofSat.ECEFy(currMeasNr-1,satNr))/1000;
        Vz = (z-spoofSat.ECEFz(currMeasNr-1,satNr))/1000;
    else
        Vx = 0;
        Vy = 0;
        Vz = 0;
    end
    

      
    spfPositions(1, satNr) = x;
    spfPositions(2, satNr) = y;
    spfPositions(3, satNr) = z;
    spfPositions(4, satNr) = Vx;
    spfPositions(5, satNr) = Vy;
    spfPositions(6, satNr) = Vz;
    



    
end