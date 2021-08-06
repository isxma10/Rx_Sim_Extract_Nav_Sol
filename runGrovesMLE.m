%% This scripts organises satellite data to produce a MLE PVT solution %%          
 
%% Initialise Variables ===================================================

c = 299792458;
sampleTime = length(GPSsat.Index);



GPSprnList = GPSno;
no_GPS_meas = length(GPSno);

GALdata = exist ('GALsat');
if GALdata == 0
    no_GAL_meas = 0;
else
    no_GAL_meas = length(GALno);
    GALList = GALno;
end

if no_GAL_meas == 0
    no_GNSS_meas =  + no_GPS_meas; 
else
    no_GNSS_meas =  no_GPS_meas + no_GAL_meas;
end

%% Set Paths to functions called within script ============================
restoredefaultpath
addpath navFunctions          
addpath geoFunctions 

%% Initialise Predicted States ============================================

predicted_r_ea_e = [0,0,0];
predicted_v_ea_e = [0,0,0];

%% Interpolate Velocities =================================================    

delta_x_GPS=(diff(GPSsat.ECEFx));
delta_y_GPS=(diff(GPSsat.ECEFy));
delta_z_GPS=(diff(GPSsat.ECEFz));

if GALdata == 1
        delta_x_GAL=(diff(GALsat.ECEFx));
        delta_y_GAL=(diff(GALsat.ECEFy));
        delta_z_GAL=(diff(GALsat.ECEFz));
end

velocityTime = GPSsat.gpsToW(1:length(delta_x_GPS))+0.5;

%% Check if the number of satellites is still above 3 =====================

if (sampleTime < 36) || no_GNSS_meas <= 4
    % Show the error message and exit
    disp('Record is to short or too few satellites tracked to calculate position')
    return
end
%% Initialization of current measurement ==================================

for currMeasNr = 1:sampleTime
    TOW = GPSsat.gpsToW(currMeasNr,1);
    transmitTime = TOW; 
    
    for satNR = 1:no_GNSS_meas
        
        if satNR <=  no_GPS_meas
           
            GNSS_measurements(satNR,1) = GPSsat.pseudoRange(currMeasNr,satNR);
            GNSS_measurements(satNR,2) = GPSsat.psrRate(currMeasNr,satNR);
            GNSS_measurements(satNR,3) = GPSsat.ECEFx(currMeasNr,satNR);
            GNSS_measurements(satNR,4) = GPSsat.ECEFy(currMeasNr,satNR);
            GNSS_measurements(satNR,5) = GPSsat.ECEFz(currMeasNr,satNR);
            
            delta_x_interp = interp1(velocityTime,delta_x_GPS(:,satNR),GPSsat.gpsToW,'linear','extrap');
            vx(:,satNR) = delta_x_interp(:,1);
            delta_y_interp = interp1(velocityTime,delta_y_GPS(:,satNR),GPSsat.gpsToW,'linear','extrap');
            vy(:,satNR) = delta_y_interp(:,1);
            delta_z_interp = interp1(velocityTime,delta_z_GPS(:,satNR),GPSsat.gpsToW,'linear','extrap');
            vz(:,satNR) = delta_z_interp(:,1);
            
            GNSS_measurements(satNR,6) = vx(currMeasNr,satNR);
            GNSS_measurements(satNR,7) = vy(currMeasNr,satNR);
            GNSS_measurements(satNR,8) = vz(currMeasNr,satNR);
            
        else
            
            GNSS_measurements(satNR,1) = GALsat.pseudoRange(currMeasNr,(satNR-no_GPS_meas));
            GNSS_measurements(satNR,2) = GALsat.psrRate(currMeasNr,satNR-no_GPS_meas);
            GNSS_measurements(satNR,3) = GALsat.ECEFx(currMeasNr,satNR-no_GPS_meas);
            GNSS_measurements(satNR,4) = GALsat.ECEFy(currMeasNr,satNR-no_GPS_meas);
            GNSS_measurements(satNR,5) = GALsat.ECEFz(currMeasNr,satNR-no_GPS_meas);
         
            delta_x_interp = interp1(velocityTime,delta_x_GAL(:,satNR-no_GPS_meas),GALsat.gpsToW,'linear','extrap');
            vx(:,satNR) = delta_x_interp(:,1);
            delta_y_interp = interp1(velocityTime,delta_y_GAL(:,satNR-no_GPS_meas),GALsat.gpsToW,'linear','extrap');
            vy(:,satNR) = delta_y_interp(:,1);
            delta_z_interp = interp1(velocityTime,delta_z_GAL(:,satNR-no_GPS_meas),GALsat.gpsToW,'linear','extrap');
            vz(:,satNR) = delta_z_interp(:,1);  
            
            GNSS_measurements(satNR,6) = vx(currMeasNr,satNR);
            GNSS_measurements(satNR,7) = vy(currMeasNr,satNR);
            GNSS_measurements(satNR,8) = vz(currMeasNr,satNR);
            
        end
    end

%% Calculate receiver position ============================================

%-single Constellation ----------------------------------------------------
    if GALdata == 0
        
        [est_r_ea_e,est_v_ea_e,est_clock] = GNSS_LS_position_velocity(...
            GNSS_measurements,no_GNSS_meas,predicted_r_ea_e,predicted_v_ea_e);

%-Multi-Constellation
    else
        
        [est_r_ea_e,est_r_lla,est_r_e,est_r_n,est_r_u,est_v_ea_e,est_clock,est_intTB,el,az, dop] = INTGNSS_LS_position_velocity(...
            GNSS_measurements,no_GNSS_meas,no_GAL_meas,predicted_r_ea_e,predicted_v_ea_e);
    
    end

%% Save Position Data =====================================================

    navSolutions.X(currMeasNr)          = est_r_ea_e(1);
    navSolutions.Y(currMeasNr)          = est_r_ea_e(2);
    navSolutions.Z(currMeasNr)          = est_r_ea_e(3);
    navSolutions.dt(currMeasNr)         = est_clock(1);
%     navSolutions.lat(currMeasNr)        = est_r_lla(1);
%     navSolutions.long(currMeasNr)       = est_r_lla(2);
%     navSolutions.alt(currMeasNr)        = est_r_lla(3);
%     navSolutions.east(currMeasNr)       = est_r_e;
%     navSolutions.north(currMeasNr)      = est_r_n;
%     navSolutions.up(currMeasNr)         = est_r_u;
    navSolutions.vX(currMeasNr)         = est_v_ea_e(1);
    navSolutions.vY(currMeasNr)         = est_v_ea_e(2);
    navSolutions.vZ(currMeasNr)         = est_v_ea_e(3);
    navSolutions.ddt(currMeasNr)        = est_clock(2);
    navSolutions.intContBias(currMeasNr) = est_intTB;
    navSolutions.Gdop(currMeasNr)       = dop(1);
    navSolutions.Pdop(currMeasNr)       = dop(2);
    navSolutions.Hdop(currMeasNr)       = dop(3);
    navSolutions.Vdop(currMeasNr)       = dop(4);
    navSolutions.Tdop(currMeasNr)       = dop(5);
    navSolutions.az(currMeasNr,:)         = az;
    navSolutions.el(currMeasNr,:)         = el;

end
restoredefaultpath