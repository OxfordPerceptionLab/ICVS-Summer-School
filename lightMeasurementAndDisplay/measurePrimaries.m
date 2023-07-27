% measurePrimaries
% This script uses 'measureRadiance.m' to measure a display's primaries.

%select display type, meter and recording spacing
display = 'standard';
meter = 'pr670';
S = [380 5 81];

%scaling is defined here as the spectroCAL can sometimes struggle with high
%luminances. As such, recordings a dimmed and then re-scaled later on
switch meter
    case 'pr670'
        PR670init();
        scaling = 1;
    case 'spectroCal'
        scaling = 0.5;
end

%initialise display
[window, windowDimensions] = initialiseDisplay(display);

%assign colours and pre-assign output variable for speed
colorCode = [1,0,0;0,1,0;0,0,1];
displayPrimaries = zeros(S(3),size(colorCode,1));

%loop through each channel
for channel = 1:size(colorCode,1)
    %draw color to screen
    drawColorToDisplay(colorCode(:,channel).*scaling)
    %make spectral recording
    displayPrimaries(:,channel) = measureRadiance(meter,S,0)./scaling;

end
%save primary recordings
save('displayPrimaries.mat','displayPrimaries');
