% SampleTime = 62;
% plotNavigation(navSolutions, SampleTime);

% refCoord.E = mean(navSolutions.E(~isnan(navSolutions.E)));
% refCoord.N = mean(navSolutions.N(~isnan(navSolutions.N)));
% refCoord.U = mean(navSolutions.U(~isnan(navSolutions.U)));

prnList = satno;
NoSats = length(satno);
for satNR = 1:NoSats
        twatSolutions(satNR).PRN = ...
                                        prnList(satNR);
end
