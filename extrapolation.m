%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 SKYDEL RAW DATA EXTRACTION FROM SIMULATION              %
% Authors:          Matlab-Matt Alcock, Alex Schofield                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is designed to extract and use the raw data csv files from  %
% skydel.                                                                 %
% Some file names may need to be renamed.                                 %
% The file transmitter Transmitter 1 will always need to be be renamed.   %
% Latest change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars % Clear all previous variables
clc
warning('off'); % Removes the warning captions from extracting table data
spoofYorN = input('Is there spoof data: ','s');
restoredefaultpath
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   PLEASE ENTER UBX FILENAME HERE                        
ubxfilename = 'awgn_dynamic_jam_5dB.ubx';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- Include folders with functions ---------------------------------------
                           
addpath navFunctions    
addpath extrapFunctions       
addpath geoFunctions          
                                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables to be declared, where being empty is important to the script
GPSno = []; %stores the names of which GPS satelittes are to be used
GALno = []; %stores the names of which Galileo satelittes are to be used
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following For If loops:
% Cycles through the 32 file types for each individual satelitte loading
% to the data variable. The sat variable is indexed at 1 in 10 for 1 second
% intervals as the simulator works at 10hz and U-centre 1hz. 
% If the simulator was not set to 10hz, this script will need be be amended
%
% The new indexed data is saved to sat along with the relevant columns.
% Checks to see if the body elevation is equal or more than 15 degrees
% if this is not true, the data is not added
%
% Columns in sat are identified as follows:
%
% Column 1: Elapsed Time (ms) 
% Column 2: ECEFx (m)
% Column 3: ECEFy (m)
% Column 4: ECEFz (m)
% Column 5: Geo Range (m)
% Column 6: PseudoRange (m)
% Column 7: Sat Clock Correction (s)
% Column 8: Ionospheric Correction (m)
% Column 9: Tropospheric Correction (m)
% Column 10: Doppler Frequency
% Column 11: GPS ToW
% Column 12: GPS Week Number
% Column 13: Body elevation
% Column 14: Body Azimuth
% Column 15: PsuedoRange Rate
%
% Use the info displayed from sat used to identify which cell of the
% variable sat to use. I.e to call the doppler frequency of sat 2 enter:
% sat{2}(:,6)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**********************GPS SIMULATOR SAT DATA*****************************%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:32
    n = sprintf('%02d',i);
    filename = ('Signals/GPS_Signals/L1CA '+string(n)+'.csv');
    if exist(filename) == 2;
        data{i} = readtable(filename);
            if rad2deg(mean(table2array(data{i}(:,9)))) >= 15
                GPSno(i) = i;
                data{i} = readtable(filename);
                data{i} = table2array(data{i});
                sat{i} = data{i}(6:10:end,[1,2,3,4,10,11,13,17,18,26,30,31,9,8,27]);
                
            else
                fprintf('body elevation is less than 15 degrees for GPS sat: %d \n',i)
            end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following formats and prints the satelitte numbers used
GPSno = nonzeros(GPSno);
fprintf('GPS satelittes used are: %d')
fprintf(' %d', GPSno')
fprintf('\n')
sat = sat(~cellfun('isempty',sat));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checks if 4 or more satelittes are used in the data. Ends the script
% if this is not the case the script is ended
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following organises the data from sat into a structure called GPSsat
% To use the structure, simple use GPSsat.inforRequired. See the info above
% the initial file loading to see the data gathered.

for i = 1:length(GPSno)

    GPSsat.Index(:,i) = sat{i}(:,[1]);
    GPSsat.ECEFx(:,i) = sat{i}(:,[2]);
    GPSsat.ECEFy(:,i) = sat{i}(:,[3]);
    GPSsat.ECEFz(:,i) = sat{i}(:,[4]);
    GPSsat.geoRange(:,i) = sat{i}(:,[5]);
    GPSsat.pseudoRange(:,i) = sat{i}(:,[6]);
    GPSsat.satClockCorr(:,i) = sat{i}(:,[7]);
	GPSsat.ionoCorr(:,i) = sat{i}(:,[8]);
	GPSsat.tropoCorr(:,i) = sat{i}(:,[9]);
	GPSsat.dopplerFreq(:,i) = sat{i}(:,[10]);
	GPSsat.gpsToW(:,i) = sat{i}(:,[11]);
	GPSsat.gpsWeekNumber(:,i) = sat{i}(:,[12]);
	GPSsat.bodyElevation(:,i) = sat{i}(:,[13]);
	GPSsat.bodyAzimuth(:,i) = sat{i}(:,[14]);
    GPSsat.psrRate(:,i) = sat{i}(:,[15]);
    GPSsat = structfun( @rmmissing , GPSsat , 'UniformOutput' , false);
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*********************GALILEO SIMULATOR SAT DATA**************************%
% Same process as the GPS sim sat data script, see above for comments     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:34
    n = sprintf('%02d',i);
    filename = ('Signals/GAL_Signals/E1 '+string(n)+'.csv');
    if exist(filename) == 2;
        data{i} = readtable(filename);
            if rad2deg(mean(table2array(data{i}(:,9)))) >= 15
                GALno(i) = i;
                data{i} = readtable(filename);
                data{i} = table2array(data{i});
                sat{i} = data{i}(6:10:end,[1,2,3,4,10,11,13,17,18,26,30,31,9,8,27]);
                
            else
                fprintf('body elevation is less than 15 degrees for Galileo sat: %d \n',i)
            end
    end
end

GALno = nonzeros(GALno);
fprintf('Galileo satelittes used are: %d')
fprintf(' %d', GALno')
fprintf('\n')
sat = sat(~cellfun('isempty',sat));

for i = 1:length(GALno)

    GALsat.Index(:,i) = sat{i}(:,[1]);
    GALsat.ECEFx(:,i) = sat{i}(:,[2]);
    GALsat.ECEFy(:,i) = sat{i}(:,[3]);
    GALsat.ECEFz(:,i) = sat{i}(:,[4]);
    GALsat.geoRange(:,i) = sat{i}(:,[5]);
    GALsat.pseudoRange(:,i) = sat{i}(:,[6]);
    GALsat.satClockCorr(:,i) = sat{i}(:,[7]);
	GALsat.ionoCorr(:,i) = sat{i}(:,[8]);
	GALsat.tropoCorr(:,i) = sat{i}(:,[9]);
	GALsat.dopplerFreq(:,i) = sat{i}(:,[10]);
	GALsat.gpsToW(:,i) = sat{i}(:,[11]);
	GALsat.gpsWeekNumber(:,i) = sat{i}(:,[12]);
	GALsat.bodyElevation(:,i) = sat{i}(:,[13]);
	GALsat.bodyAzimuth(:,i) = sat{i}(:,[14]);
    GALsat.psrRate(:,i) = sat{i}(:,[15]);
    GALsat = structfun( @rmmissing , GALsat , 'UniformOutput' , false);
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A minimum of 4 satelittes must be used for accurate recording           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if and(length(GPSno) < 4,length(GALno) < 4)
    fprintf('3 or less satelittes are utilised in this data.\n')
    fprintf('This is not sufficient and new data must be obtianed\n');
    fprintf('Script ended here\n')
    %return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% **********************RECIEVER (TRUTH DATA)*****************************%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loads the reciver and transmitter raw data if supplied. Checks to see if any data is
% presents on the file. File could still exist yet will be empty. Alerts
% the user to whether or not this exists and can be used. Data is then
% loaded into the struct reciever.

if exist('Signals/receiver_antenna.csv')==2;
    temp = table2array(readtable('Signals/receiver_antenna.csv'));
    fprintf("Reciever_Antenna file found, data loaded\n")
    reciever.ECEFx = temp(6:10:end,2);
    reciever.ECEFy = temp(6:10:end,3);
    reciever.ECEFz = temp(6:10:end,4);
    reciever.Yaw_deg = temp(6:10:end,5);
    reciever.Pitch_deg = temp(6:10:end,6);
    reciever.Roll_deg = temp(6:10:end,7);
    reciever.VelocityX = temp(6:10:end,8);
    reciever.VelocityY = temp(6:10:end,9);
    reciever.VelocityZ = temp(6:10:end,10);
    reciever.AccelX = temp(6:10:end,11);
    reciever.AccelY = temp(6:10:end,12);
    reciever.AccelZ = temp(6:10:end,13);
    reciever.GPSTOW = temp(6:10:end,14);
    reciever.GPSWeekNumber =temp(6:10:end,15);
    reciever = structfun( @rmmissing , reciever , 'UniformOutput' , false);
else
    fprintf("Reciever_Antenna file found empty, no data to be loaded\n")
    fprintf("Please check the file name is correct\nTerminating script\n")
    %return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%****************************JAMMER DATA**********************************%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jammer csv file logged at 100hz.
if exist('Signals/transmitter Transmitter 1.csv') == 2;
    temp = readtable('Signals/transmitter Transmitter 1.csv');
    fprintf("Jammer transmitter file found, data loaded\n")
    Jammer.ECEFx = table2array(temp(503:1000:end,2));
    Jammer.ECEFy = table2array(temp(503:1000:end,3));
    Jammer.ECEFz = table2array(temp(503:1000:end,4));
    Jammer.Yaw_deg = table2array(temp(503:1000:end,5));
    Jammer.Pitch_deg = table2array(temp(503:1000:end,6));
    Jammer.Roll_deg = table2array(temp(503:1000:end,7));
    Jammer.TxAntGain = table2array(temp(503:1000:end,8));
    Jammer.propLoss = table2array(temp(503:1000:end,9));
    Jammer.RxAntGain = table2array(temp(503:1000:end,10));
    Jammer.RxVis = table2array(temp(503:1000:end,11));
    Jammer = structfun( @rmmissing , Jammer , 'UniformOutput' , false);
else
    fprintf("Jammer transmitter file found empty, no data to be loaded\n")
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creates an index from the elasped time in seconds. Creates a new variable
% sample time for the total time recored

index = ((sat{GPSno(1)}(:,1)))/1000;
SampleTime = index(end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Retrieves the data from the UBX file. Combines iTOW and fTOW to TOW.
%Interpolates the data.
if exist(ubxfilename) == 2
    fprintf("loading UBX data.........")
    [ubxreciever] = getMessageUBX_NAV_SOL_struct(ubxfilename);
    ubxreciever.pos = ubxreciever.pos/100;
    ubxreciever = the_interpolator(ubxreciever);
    intReciever.ECEF(:,1)= interp1(reciever.GPSTOW(1:end,1),reciever.ECEFx(1:length(reciever.GPSTOW),1),ubxreciever.TOW);
    intReciever.ECEF(:,2)= interp1(reciever.GPSTOW(1:end,1),reciever.ECEFy(1:length(reciever.GPSTOW),1),ubxreciever.TOW);
    intReciever.ECEF(:,3)= interp1(reciever.GPSTOW(1:end,1),reciever.ECEFz(1:length(reciever.GPSTOW),1),ubxreciever.TOW);
    deviation = (intReciever.ECEF - ubxreciever.pos);
    fprintf("UBX data loaded successfully\n")
else
    fprintf("No UBX file found, please check file name\n")
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the navSol and least squares data
fprintf("loading Sat and Nav solutions.......")
%[satSolutions, navSolutions] = NavSol(GPSsat, GPSno);
fprintf("Loaded\n")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load spoofing data NEED MORE COMMENTS%%
% Similar to the previous process

rmpath sim                      %Removes sim path as file names are similar
addpath spoof\             %Adds path to spoof which has similar file names


if spoofYorN == "yes"
    fprintf("Loading GPS spoofing satelittes\n")

    for i=1:32
        n = sprintf('%02d',i);
        filename = ('Signals/SPF_Signals/L1CA '+string(n)+'.csv');
        if exist(filename) == 2;
            data{i} = readtable(filename);
                if rad2deg(mean(table2array(data{i}(:,9)))) >= 15
                    GPS_SpoofNo(i) = i;
                    data{i} = readtable(filename);
                    data{i} = table2array(data{i});
                    sat{i} = data{i}(6:10:end,[1,2,3,4,10,11,13,17,18,26,30,31,9,8]);
                
                else
                    fprintf('body elevation is less than 15 degrees for GPS Spoof sat: %d \n',i)
                end
        end
    end

    sat = sat(~cellfun('isempty',sat));
    GPS_SpoofNo = nonzeros(GPS_SpoofNo);
    
    for i = 1:length(GPS_SpoofNo)

        spoofSat.Index(:,i) = sat{i}(1:length(GPSsat.Index),[1]);
        spoofSat.ECEFx(:,i) = sat{i}(1:length(GPSsat.Index),[2]);
        spoofSat.ECEFy(:,i) = sat{i}(1:length(GPSsat.Index),[3]);
        spoofSat.ECEFz(:,i) = sat{i}(1:length(GPSsat.Index),[4]);
        spoofSat.geoRange(:,i) = sat{i}(1:length(GPSsat.Index),[5]);
        spoofSat.pseudoRange(:,i) = sat{i}(1:length(GPSsat.Index),[6]);
        spoofSat.satClockCorr(:,i) = sat{i}(1:length(GPSsat.Index),[7]);
        spoofSat.ionoCorr(:,i) = sat{i}(1:length(GPSsat.Index),[8]);
        spoofSat.tropoCorr(:,i) = sat{i}(1:length(GPSsat.Index),[9]);
        spoofSat.dopplerFreq(:,i) = sat{i}(1:length(GPSsat.Index),[10]);
        spoofSat.gpsToW(:,i) = sat{i}(1:length(GPSsat.Index),[11]);
        spoofSat.gpsWeekNumber(:,i) = sat{i}(1:length(GPSsat.Index),[12]);
        spoofSat.bodyElevation(:,i) = sat{i}(1:length(GPSsat.Index),[13]);
        spoofSat.bodyAzimuth(:,i) = sat{i}(1:length(GPSsat.Index),[14]);
        spoofSat = structfun( @rmmissing , spoofSat , 'UniformOutput' , false);
   
    end
else
    fprintf("No spoof data found\n")
end    
   
restoredefaultpath
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of script
fprintf("Script finished\n")