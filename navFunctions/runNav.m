%% Calculate navigation solutions =========================================
    disp('   Calculating navigation solutions...');
    [satSolutions, navSolutions] =  NavSol(GPSsat, GPSno);

    disp('   Processing is complete for this data block');
    
     %save('navSolutions', 'navSolutions');
     
    % plotNavigation(navSolutions, settings);

