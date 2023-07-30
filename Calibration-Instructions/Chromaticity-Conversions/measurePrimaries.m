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
        port = serialportlist('available');
        port = port(end);
        PR670init(port);
end

%initialise display
[window, windowDimensions] = initialiseDisplay(display);

%assign colours and pre-assign output variable for speed
colorCode = [1,0,0;0,1,0;0,0,1];
displayPrimaries = zeros(S(3),size(colorCode,1)+1);
displayPrimaries(:,1) = S(1):S(2):(S(1)+(S(2)*(S(3)-1)));
%loop through each channel
for channel = 2:size(displayPrimaries,2)
    %draw color to screen
    drawColorToDisplay(colorCode(:,channel-1).*WhiteIndex(window),display,window,windowDimensions)
    %make spectral recording
    displayPrimaries(:,channel) = measureRadiance(meter,S,0);

end
sca;


%plot primaries
for channel = 2:size(displayPrimaries,2)
    plot(displayPrimaries(:,1),displayPrimaries(:,channel),'Color',colorCode(:,channel-1),'LineWidth',2);hold on
end
xlabel('wavelength (nm)')
ylabel('energy')
xlim([S(1) displayPrimaries(end,1)])


%save primary recordings
save('displayPrimaries.mat','displayPrimaries');
