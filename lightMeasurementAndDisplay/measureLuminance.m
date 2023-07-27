function luminance = measureLuminance(device)
% This function controls external devices for measuring luminance. 
%
% device - which device is being used for measurement. options: 'colorCal' or
% 'UDT'.

switch device
    % if using colorCal
    case 'colorCal'
        % colourCal values must be corrected using the in-built color matrix.
        cMatrix = ColorCal2('ReadColorMatrix');
        s = ColorCal2('MeasureXYZ');
        correctedValues = cMatrix(1:3,:) * [s.x s.y s.z]';
        % 'Y' value in XYZ corresponds to relative luminance, rescale this 
        % to convert to luminance in cd/m^2
        luminance = correctedValues(2).*683.002;
    case 'UDT'
        %TBC

end
end