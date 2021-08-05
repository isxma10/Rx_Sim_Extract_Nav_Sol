function [est_r_ea_e,est_r_lla,est_r_e,est_r_n,est_r_u,est_v_ea_e,est_clock,est_intTB,el,az, dop] = INTGNSS_LS_position_velocity(...
    GNSS_measurements,no_GNSS_meas,no_GAL_meas,predicted_r_ea_e,predicted_v_ea_e)
%INTGNSS_LS_position_velocity - Calculates position, velocity, clock offset, 
%and clock drift using unweighted iterated least squares. Separate
%calculations are implemented for position ,clock offset and 
%interconstellation time bias  and for velocity and clock drift
%
% Software for use with "Principles of GNSS, Inertial, and Multisensor
% Integrated Navigation Systems," Second Edition.
%
% This function created 11/4/2012 by Paul Groves
% Calls: None
% Inputs:
%   GNSS_measurements     GNSS measurement data:
%     Column 1              Pseudo-range measurements (m)
%     Column 2              Pseudo-range rate measurements (m/s)
%     Columns 3-5           Satellite ECEF position (m)
%     Columns 6-8           Satellite ECEF velocity (m/s)
%   no_GNSS_meas          Number of satellites for which measurements are
%                         supplied
%   no_GAL_meas           Number of Galileo satellites for which measurements are
%                         supplied
%   predicted_r_ea_e      prior predicted ECEF user position (m)
%   predicted_v_ea_e      prior predicted ECEF user velocity (m/s)
%
% Outputs:
%   est_r_ea_e            estimated ECEF user position (m)
%   est_v_ea_e            estimated ECEF user velocity (m/s)
%   est_clock             estimated receiver clock offset (m) and drift (m/s)
%   est_intTB             estimated interconstellation timing biases(m)
%   el                    Satellites elevation angles (degrees)
%   az                    Satellites azimuth angles (degrees)
%   dop                   Dilutions Of Precision ([GDOP PDOP HDOP VDOP TDOP])   
 
% Copyright 2012, Paul Groves
% License: BSD; see license.txt for details
%CVS record:
%$Id: INTGNSS_LS_position_velocity.m,v 1.0.1.0 2016/03/18 17:20:11 dpl Exp $

%% Constants (some of these could be changed to inputs at a later date)====
c = 299792458; % Speed of light in m/s
omega_ie = 7.2921151467e-5;  % Earth rotation rate in rad/s
wgs84 = wgs84Ellipsoid('kilometer');

% Begins
pos     = zeros(4, 1);
az      = zeros(1, no_GNSS_meas);
el      = az;
X       = GNSS_measurements(:,3:5)';

% POSITION AND CLOCK OFFSET

% Setup predicted state
x_pred(1:3,1) = predicted_r_ea_e;
x_pred(4,1) = 0;
x_pred(5,1) = 0;
test_convergence = 1;
iterations = 0;

% To adapt to single constellation case
if(no_GAL_meas == 0)
    no_GAL_meas = 1;
end
% Repeat until convergence
while (test_convergence>0.0001)
    if iterations>200
        disp('Max iterations hit, position solution');
        break;
    end
    % Loop measurements
    for j = 1:no_GNSS_meas
            %--- Update equations -----------------------------------------
            rho2 = (X(1, j) - pos(1))^2 + (X(2, j) - pos(2))^2 + ...
                   (X(3, j) - pos(3))^2;
            traveltime = sqrt(rho2) / c ;

            %--- Correct satellite position (do to earth rotation) --------
            Rot_X = e_r_corr(traveltime, X(:, j));

            %--- Find the elevation angel of the satellite ----------------
            [az(j), el(j), dist] = topocent(pos(1:3, :), Rot_X - pos(1:3, :));        
        % Predict approx range 
        delta_r = X(:,j) - x_pred(1:3);
        approx_range = sqrt(delta_r' * delta_r);

        % Calculate frame rotation during signal transit time using (8.36)
        C_e_I = [1, omega_ie * approx_range / c, 0;...
                 -omega_ie * approx_range / c, 1, 0;...
                 0, 0, 1];

        % Predict pseudo-range using (9.143)
        delta_r = C_e_I *  X(:,j) - x_pred(1:3);
        range = sqrt(delta_r' * delta_r);
        % Predict line of sight and deploy in measurement matrix, (9.144)
        H_matrix (j,1:3) = - delta_r' / range;
        H_matrix (j,4) = 1;
        if(j > (no_GNSS_meas-no_GAL_meas))
            % add interconstellation time bias item for BeiDou measurements
            pred_meas(j,1) = range + x_pred(4)-x_pred(5);
            H_matrix (j,5) = -1;
        else
            % no interconstellation timebias item for GPS measurements
            pred_meas(j,1) = range + x_pred(4);
            H_matrix (j,5) = 0;
        end
  
    end % for j
    % Unweighted least-squares solution, (9.35)/(9.141)
    x_est = x_pred + inv(H_matrix(1:no_GNSS_meas,:)' * H_matrix(1:no_GNSS_meas,:))...
        * H_matrix(1:no_GNSS_meas,:)'...
        *(GNSS_measurements(1:no_GNSS_meas,1) -  pred_meas(1:no_GNSS_meas));
%     x_est = x_pred + ((H_matrix(1:no_GNSS_meas,:)' * H_matrix(1:no_GNSS_meas,:)) / (H_matrix(1:no_GNSS_meas,:)') *(GNSS_measurements(1:no_GNSS_meas,1)) -  pred_meas(1:no_GNSS_meas));
    
    % Test convergence    
    test_convergence = sqrt((x_est - x_pred)' * (x_est - x_pred));
    
    % Set predictions to estimates for next iteration
    x_pred = x_est;
    iterations = iterations + 1;
    % Check the residual
    x_res(:,iterations) = GNSS_measurements(1:no_GNSS_meas,1) -  pred_meas(1:no_GNSS_meas);
end % while


%--- Initialize output ------------------------------------------------
    dop     = zeros(1, 5);

    %--- Calculate DOP ----------------------------------------------------
    Q       = inv(H_matrix'*H_matrix);

    dop(1)  = sqrt(trace(Q));                       % GDOP
    dop(2)  = sqrt(Q(1,1) + Q(2,2) + Q(3,3));       % PDOP
    dop(3)  = sqrt(Q(1,1) + Q(2,2));                % HDOP
    dop(4)  = sqrt(Q(3,3));                         % VDOP
    dop(5)  = sqrt(Q(4,4));                         % TDOP



% Set outputs to estimates
est_r_ea_e(1:3,1) = x_est(1:3);
x_esti = est_r_ea_e(1);
y_esti = est_r_ea_e(2);
z_esti = est_r_ea_e(3);
est_r_lla = ecef2lla(est_r_ea_e(1:3,1)','WGS84');
lat_est = est_r_lla(1);
long_est = est_r_lla(2);
alt_est = est_r_lla(3);

[est_r_e,est_r_n,est_r_u] = ecef2enu(x_esti, y_esti, z_esti, lat_est, long_est, alt_est, wgs84);
est_clock(1) = x_est(4);
est_intTB(1) = x_est(5);

% % sanity check the pseudo-range using (9.143)
% delta_r = C_e_I *  GNSS_measurements(j,3:5)' - est_r_ea_e(1:3);
% range = sqrt(delta_r' * delta_r);
% pred_meas = range + est_clock(1);


% VELOCITY AND CLOCK DRIFT

method = 1;
if method == 1
    % Skew symmetric matrix of Earth rate
    Omega_ie = Skew_symmetric([0,0,omega_ie]);

    % Setup predicted state
    x_pred(1:3,1) = predicted_v_ea_e;
    x_pred(4,1) = 0;
    test_convergence = 1;

    iterations = 0;
    % Repeat until convergence
    while (test_convergence>0.0001)
        if iterations>200
            disp('Max iterations hit, velocity solution');
            break;

        end

        % Loop measurements
        for j = 1:no_GNSS_meas

            % Predict approx range 
            delta_r = X(:,j) - est_r_ea_e;
            approx_range = sqrt(delta_r' * delta_r);

            % Calculate frame rotation during signal transit time using (8.36)
            C_e_I = [1, omega_ie * approx_range / c, 0;...
                     -omega_ie * approx_range / c, 1, 0;...
                     0, 0, 1];

            % Calculate range using (8.35)
            delta_r = C_e_I *  X(:,j) - est_r_ea_e;
            range = sqrt(delta_r' * delta_r);

            % Calculate line of sight using (8.41)
            u_as_e = delta_r / range;

            % Predict pseudo-range rate using (9.143)
            range_rate = u_as_e' * (C_e_I * (GNSS_measurements(j,6:8)' +...
                Omega_ie * GNSS_measurements(j,3:5)') - (x_pred(1:3) +...
                Omega_ie * est_r_ea_e));        
            pred_meas(j,1) = range_rate + x_pred(4);
            % Predict line of sight and deploy in measurement matrix, (9.144)
            H_matrix (j,1:3) = - u_as_e';
            H_matrix (j,4) = 1;

        end % for j

        % Unweighted least-squares solution, (9.35)/(9.141)
        x_est(1:4) = x_pred(1:4) + inv(H_matrix(1:no_GNSS_meas,1:4)' *...
            H_matrix(1:no_GNSS_meas,1:4)) * H_matrix(1:no_GNSS_meas,1:4)' *...
            (GNSS_measurements(1:no_GNSS_meas,2) -  pred_meas(1:no_GNSS_meas));
%         x_est = x_pred + ((H_matrix(1:no_GNSS_meas,:)' * H_matrix(1:no_GNSS_meas,:)) / (H_matrix(1:no_GNSS_meas,:)') *(GNSS_measurements(1:no_GNSS_meas,1)) -  pred_meas(1:no_GNSS_meas));
        
        % Test convergence
        test_convergence = sqrt((x_est(1:4) - x_pred(1:4))' * (x_est(1:4) - x_pred(1:4)));

        % Set predictions to estimates for next iteration
        x_pred(1:4) = x_est(1:4);
        iterations = iterations + 1;
        v_res(:,iterations) = GNSS_measurements(1:no_GNSS_meas,2) -  pred_meas(1:no_GNSS_meas);
    end % while

    % Set outputs to estimates
    est_v_ea_e(1:3,1) = x_est(1:3);
    est_clock(2) = x_est(4);
else

    %calculate velocity from carrier frequency
    for j = 1:no_GNSS_meas
        r=sqrt(sum((x_est(1:3)-GNSS_measurements(j,3:5)').^2));
        satvol=GNSS_measurements(j,6:8);
        a(j,:)=(GNSS_measurements(j,3:5)'-x_est(1:3))/r;


        d(j,1)=-GNSS_measurements(j,2)+sum(satvol.*a(j,:));
        HH(j,:)=[a(j,:),1];
    end
    vel=HH\d;
    est_v_ea_e(1:3,1) =vel(1:3);
    est_clock(2) = -vel(4);
    
end
