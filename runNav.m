%% Initialise the Environement ============================================

restoredefaultpath

%--- Include folders with functions ---------------------------------------
                           
addpath navFunctions           
addpath geoFunctions 

%% Calculate navigation solutions =========================================
    disp('   Calculating navigation solutions...');
    [satSolutions, navSolutions] =  NavSol(GPSsat, GPSno);

    disp('   Processing is complete for this data block');
    
     %save('navSolutions', 'navSolutions');
     
    % plotNavigation(navSolutions, settings);
    
restoredefaultpath

