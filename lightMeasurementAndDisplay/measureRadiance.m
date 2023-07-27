function spd = measureRadiance(device,S,init,port)
% This function controls external devices for measuring radiance. 
%
% device - which device is being used for measurement. options: 'pr670' or
% 'spectrocal'.
%
% S - wavelength/step options. S is a 1x3 array where defining i) starting
% lambda ii) step size iii) number of steps. Default is S = [380 5 81].
%
% init (optional, default = 1) - option to stop devices from reinitialising
% with each measurement.
%
% port (optional) - option to manually set port name. By default, finding
% the first available usbmodem device.


if nargin < 2 || isempty(S)
    S = [380 5 81];
end

if nargin < 3 || isempty(init)
    init = 1;
end

if nargin < 4 || isempty(port)
    port = FindSerialPort('usbmodem', 1);
end


switch device
    % if using PR670
    case 'pr670'
        % initialise if not already
        if init
            PR670init(port);
        end
        % measure spectral power density using defined lambda range
        spd = PR670measspd(S);
    % if using spectroCal
    case 'spectroCal'
        % rearrange steps for spectroCal format
        l1 = S(1);
        l2 = S(1)+(S(2)*S(3));
        step = S(2);
        % measure spectral power density using rearranged lambda range
        [~, ~, ~, ~, spd] = SpectroCALMakeSPDMeasurement(port,l1,l2,step);
        
end
end