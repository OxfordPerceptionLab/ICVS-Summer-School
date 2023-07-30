function luminance = measureLuminance(device,port)
% This function controls external devices for measuring luminance. 
%
% device - which device is being used for measurement. options: 'colorCal' or
% 'UDT'.

if nargin < 2 || isempty(port)
    if IsWin
        port = serialportlist('available');
        port = port(end);
    else
        port = FindSerialPort('usbmodem', 1);
    end
end


switch device
    % if using colorCal
    case 'colorCal'
        % colourCal values must be corrected using the in-built color matrix.
        cMatrix = ColorCal2('ReadColorMatrix');
        s = ColorCal2('MeasureXYZ');
        correctedValues = cMatrix(1:3,:) * [s.x s.y s.z]';

    case 'UDT'
        %TBC
        
    case 'spectroCal'
        % give spectroCal a default wavelength range
        S = [380 5 81];
        l1 = S(1);
        l2 = S(1)+(S(2)*(S(3)-1));
        step = S(2);
        % measure luminance
        [~, ~, luminance] = SpectroCALMakeSPDMeasurement(port,l1,l2,step);

end
end