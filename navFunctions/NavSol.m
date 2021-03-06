function [satSolutions, navSolutions] = NavSol(GPSsat, GPSno)
%Function calculates navigation solutions for the receiver (pseudoranges,
%positions). At the end it converts coordinates from the WGS84 system to
%the UTM, geocentric or any additional coordinate system.
%
%[navSolutions, eph] = postNavigation(trackResults, settings)
%
%   Inputs:
%       trackResults    - results from the tracking function (structure
%                       array).
%       settings        - receiver settings.
%   Outputs:
%       navSolutions    - contains measured pseudoranges, receiver
%                       clock error, receiver coordinates in several
%                       coordinate systems (at least ECEF and UTM).
%       eph             - received ephemerides of all SV (structure array).

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis
% Written by Darius Plausinaitis with help from Kristin Larson
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------

%CVS record:
%$Id: postNavigation.m,v 1.1.2.22 2006/08/09 17:20:11 dpl Exp $

%% Check is there enough data to obtain any navigation solution ===========
% It is necessary to have at least three subframes (number 1, 2 and 3) to
% find satellite coordinates. Then receiver position can be found too.
% The function requires all 5 subframes, because the tracking starts at
% arbitrary point. Therefore the first received subframes can be any three
% from the 5.
% One subframe length is 6 seconds, therefore we need at least 30 sec long
% record (5 * 6 = 30 sec = 30000ms). We add extra seconds for the cases,
% when tracking has started in a middle of a subframe.


c = 299792458;
sampleTime = length(GPSsat.Index);

if (sampleTime < 36) || length(GPSno) <= 4
    % Show the error message and exit
    disp('Record is to short or too few satellites tracked to calcuolate position');
    navSolutions = [];
    eph          = [];
    return
end

%% Check if the number of satellites is still above 3 =====================
prnList = GPSno;
%spfList = spoofno;
NoSats = length(GPSno);
%NoSpoofs = length(spoofno);
activeChnList = [1:NoSats];
%activeSpoofList = [1:NoSpoofs];

if (isempty(prnList) || (length(prnList) < 4))
    % Show error message and exit
    disp('Too few satellites with ephemeris data for postion calculations. Exiting!');
    navSolutions = [];
    eph          = [];
    return
end

%% Initialization =========================================================

% Set the satellite elevations array to INF to include all satellites for
% the first calculation of receiver position. There is no reference point
% to find the elevation angle as there is no receiver position estimate at
% this point.


% Save the active channel list. The list contains satellites that are
% tracked and have the required ephemeris data. In the next step the list
% will depend on each satellite's elevation angle, which will change over
% time. 

%##########################################################################
%#   Do the satellite and receiver position calculations                  #
%##########################################################################

%% Initialization of current measurement ==================================

for currMeasNr = 1:sampleTime
    TOW = GPSsat.gpsToW(currMeasNr,1);
    transmitTime = TOW;  
        
%% Save list of satellites used for position calculation ==================
    for satNR = 1:NoSats
        satSolutions(satNR).PRN = prnList(satNR);
%% Find elevation and azimuth angle of each satellite =====================        
     
        satSolutions(satNR).az(:, currMeasNr) = GPSsat.bodyAzimuth(currMeasNr,satNR);
        satSolutions(satNR).el(:,currMeasNr) = GPSsat.bodyElevation(currMeasNr,satNR);
    

%% Find pseudoranges and correct for sat clcok error ======================
      
        satSolutions(satNR).rawP(:, currMeasNr) = GPSsat.pseudoRange(currMeasNr,:)+GPSsat.satClockCorr(currMeasNr,:)*c;
        satRange = satSolutions(satNR).rawP(:, currMeasNr);
    end
%% Find satellites positions ==============================================
        
        [satpos] = satpos_matt(transmitTime, GPSno, GPSsat, currMeasNr);
    
%% Find receiver position =================================================

    % 3D receiver position can be found only if signals from more than 3
    % satellites are available  
    if size(prnList, 1) > 3

%% Calculate receiver position ============================================
       
        
        freqforcal=zeros(1,length(prnList));
        freqforcal=GPSsat.dopplerFreq(currMeasNr,:);
               
        
        [posvel, dop] = leastSquarePosVelSat(satpos, satRange, ...
                                            freqforcal, c, currMeasNr, GPSsat, GPSno);
%--- Save results ---------------------------------------------------------
        
        navSolutions.X(currMeasNr)  = posvel(1);
        navSolutions.Y(currMeasNr)  = posvel(2);
        navSolutions.Z(currMeasNr)  = posvel(3);
        navSolutions.dt(currMeasNr) = posvel(4);
        navSolutions.vX(currMeasNr)  = posvel(5);
        navSolutions.vY(currMeasNr)  = posvel(6);
        navSolutions.vZ(currMeasNr)  = posvel(7);
        navSolutions.ddt(currMeasNr) = posvel(8);
        navSolutions.Gdop(currMeasNr) = dop(1);
        navSolutions.Pdop(currMeasNr) = dop(2);
        navSolutions.Hdop(currMeasNr) = dop(3);
        navSolutions.Vdop(currMeasNr) = dop(4);
        navSolutions.Tdop(currMeasNr) = dop(5);
       
        

%% Correct pseudorange measurements for Rx clocks error ===================
    for satNR = 1:NoSats
        navSolutions.correctedP(prnList, currMeasNr) = ...
        satRange(satNR) + ...
        navSolutions.dt(currMeasNr);
    end
    
    else % if size(prnList, 2) > 3 
         
%--- There are not enough satellites to find 3D position ------------------
        disp(['   Measurement No. ', num2str(currMeasNr), ...
                       ': Not enough information for position solution.']);

        %--- Set the missing solutions to NaN. These results will be
        %excluded automatically in all plots. For DOP it is easier to use
        %zeros. NaN values might need to be excluded from results in some
        %of further processing to obtain correct results.
        navSolutions.X(currMeasNr)  = NaN;
        navSolutions.Y(currMeasNr)  = NaN;
        navSolutions.Z(currMeasNr)  = NaN;
        navSolutions.dt(currMeasNr) = NaN;
        navSolutions.vX(currMeasNr)  = NaN;
        navSolutions.vY(currMeasNr)  = NaN;
        navSolutions.vZ(currMeasNr)  = NaN;
        navSolutions.ddt(currMeasNr) = NaN;
        navSolutions.Gdop(currMeasNr) = NaN;
        navSolutions.Pdop(currMeasNr) = NaN;
        navSolutions.Hdop(currMeasNr) = NaN;
        navSolutions.Vdop(currMeasNr) = NaN;
        navSolutions.Tdop(currMeasNr) = NaN;   

    end % if size(prnList, 2) > 3

%% Coordinate conversion ==================================================

%=== Convert to geodetic coordinates ======================================

%         [navSolutions.latitude(currMeasNr), ...
%         navSolutions.longitude(currMeasNr), ...
%         navSolutions.height(currMeasNr)] = ecef2lla(...
%                                             navSolutions.X(currMeasNr), ...
%                                             navSolutions.Y(currMeasNr), ...
%                                             navSolutions.Z(currMeasNr));

%=== Convert to UTM coordinate system =====================================
        
%         navSolutions.utmZone = findUtmZone(navSolutions.latitude(currMeasNr), ...
%                                            navSolutions.longitude(currMeasNr));
%         
%         [navSolutions.E(currMeasNr), ...
%          navSolutions.N(currMeasNr), ...
%          navSolutions.U(currMeasNr)] = cart2utm(posvel(1), posvel(2), ...
%                                                 posvel(3), ...
%                                                 navSolutions.utmZone);
%% Repeat for Spoofed Satellites =========================================   
    if exist('spoofSat') == 1
        
%% Save list of satellites used for position calculation ==================
        for spfNR = 1:NoSats
            spfSolutions(spfNR).PRN = prnList(spfNR);
%% Find elevation and azimuth angle of each satellite =====================        
     
            spfSolutions(spfNR).az(:, currMeasNr) = spoofSat.bodyAzimuth(currMeasNr,spfNR);
            spfSolutions(spfNR).el(:,currMeasNr) = spoofSat.bodyElevation(currMeasNr,spfNR);
    
%% Find pseudoranges and correct for sat clcok error ======================
      
            spfSolutions(spfNR).rawP(:, currMeasNr) = spoofSat.pseudoRange(currMeasNr,:)+spoofSat.satClockCorr(currMeasNr,:)*c;
            satRange = spfSolutions(spfNR).rawP(:, currMeasNr);
        end
        
%% Find satellites positions ==============================================
        
        [spoofpos] = satpos_matt(transmitTime, GPSno, spoofSat, currMeasNr);
    
%% Find receiver position =================================================

        % 3D receiver position can be found only if signals from more than 3
        % satellites are available  
        if size(spfList, 1) > 3

%% Calculate receiver position ============================================
        
            freqforcal=zeros(1,length(prnList));
            freqforcal=spoofSat.dopplerFreq(currMeasNr,:);
        
            [posvel, SpoofnavSolutions.DOP] = leastSquarePosVelSat(spoofpos, satRange, ...
                                            freqforcal, c, currMeasNr, spoofSat, GPSno);
%--- Save results ---------------------------------------------------------
        
            SpoofnavSolutions.X(currMeasNr)  = posvel(1);
            SpoofnavSolutions.Y(currMeasNr)  = posvel(2);
            SpoofnavSolutions.Z(currMeasNr)  = posvel(3);
            SpoofnavSolutions.dt(currMeasNr) = posvel(4);
            SpoofnavSolutions.vX(currMeasNr)  = posvel(5);
            SpoofnavSolutions.vY(currMeasNr)  = posvel(6);
            SpoofnavSolutions.vZ(currMeasNr)  = posvel(7);
            SpoofnavSolutions.ddt(currMeasNr) = posvel(8);

%% Correct pseudorange measurements for Rx clocks error ===================

            for spfNR = 1:NoSats
                SpoofnavSolutions.correctedP(prnList, currMeasNr) = ...
                satRange(spfNR) + ...
                SpoofnavSolutions.dt(currMeasNr);
            end  
            
    else % if size(prnList, 2) > 3 
         
%--- There are not enough satellites to find 3D position ------------------
        disp(['   Measurement No. ', num2str(currMeasNr), ...
                       ': Not enough information for position solution.']);

        %--- Set the missing solutions to NaN. These results will be
        %excluded automatically in all plots. For DOP it is easier to use
        %zeros. NaN values might need to be excluded from results in some
        %of further processing to obtain correct results.
        SpoofnavSolutions.X(currMeasNr)           = NaN;
        SpoofnavSolutions.Y(currMeasNr)           = NaN;
        SpoofnavSolutions.Z(currMeasNr)           = NaN;
        SpoofnavSolutions.dt(currMeasNr)          = NaN;
        SpoofnavSolutions.DOP(:, currMeasNr)      = zeros(5, 1);
        SpoofnavSolutions.latitude(currMeasNr)    = NaN;
        SpoofnavSolutions.longitude(currMeasNr)   = NaN;
        SpoofnavSolutions.height(currMeasNr)      = NaN;
        SpoofnavSolutions.E(currMeasNr)           = NaN;
        SpoofnavSolutions.N(currMeasNr)           = NaN;
        SpoofnavSolutions.U(currMeasNr)           = NaN;    

        end % if size(spfList, 2) > 3
    
        
    end % if exist(spoof)
    %=== Update the transmit time ("measurement time") ====================
    transmitTime = transmitTime + 1000 / 1000;

    
end %for currMeasNr...