function a = OpenArduinoPort

if (~exist('arduinosetup.m','file'))
    if (~strcmp(computer,'MACI64'))
        error('You need to modify code for Windows/Linux to get the Arduino AddOn Toolbox onto your path and to get the arduino call to find the device');
    end
    a = ver;
    rel = a(1).Release(2:end-1);
    sysInfo = GetComputerInfo;
    user = sysInfo.userShortName;
    addpath(genpath(fullfile('/Users',user,'Documents','MATLAB','SupportPackages',rel)));
end

clearvars -except taskNumber;
clear a;
devRootStr = '/dev/cu.usbmodem';
arduinoType = 'leonardo';
possiblePorts = dir([devRootStr '*']);
openedOK = false;
if (isempty(possiblePorts))
    try 
        a = arduino;
        openedOK = true;
        fprintf('Opened arduino using arduino function''s autodetect of port and type\n');
    catch e
        fprintf('Could not detect the arduino port or otherwise open it.\n');
        fprintf('Rethrowing the underlying error message.\n');
        rethrow(e);
    end
else
    for pp = 1:length(possiblePorts)
        thePort = fullfile(possiblePorts.folder,possiblePorts.name);
        try
            a = arduino(thePort,arduinoType);
            openedOK = true;
        catch e
        end
    end
    if (~openedOK)
        fprintf('Despite our best cleverness, unable to open arduino. Exiting with an error\n');
        error('');
    else
        fprintf('Opened arduino on detected port %s\n',thePort);
    end
end

end