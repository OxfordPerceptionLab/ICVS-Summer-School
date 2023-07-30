% This script measures the gamma of a display using measureLuminance

display = 'standard'; %'standard' or 'display++';
meter = 'spectroCal'; %'colorCal' or 'spectroCal'
steps = 10; %number of steps recorded from. 
mode = 'tri'; %which channel is recorded? 'full' = RGB+white, 'tri' = RGB, 'white' = only white

%initialise display
[window,windowDimensions] = initialiseDisplay(display);

%settings for channel mode
switch mode
    case 'full'
        name = {'Red','Green','Blue','White'};
        colorCode = [1,0,0;0,1,0;0,0,1;1,1,1];
    case 'tri'
        name = {'Red','Green','Blue'};
        colorCode = [1,0,0;0,1,0;0,0,1];
    case 'white'
        name = {'White'};
        colorCode = [1,1,1];
end

%pre-assigning arrays for speed
gamma = zeros(steps,1+length(name));
gamma(:,1) = 1/steps:1/steps:1;
gammaCoefficients = zeros(3,length(name));

%looping through each of the channels
for channel = 1:length(name)
    %looping through each step level
    for level = 1:steps
        
        %draw current channel-level combination to the screen
        drawColorToDisplay(colorCode(channel,:).*(level/steps).*WhiteIndex(window),display,window,windowDimensions)
    
        %record luminance and add to 'gamma'
        rec = measureLuminance(meter);
        gamma(level,1+channel) = rec;
    
    end
    %normalise so maximum value is at (1,1) 
    gamma(:,1+channel) = gamma(:,1+channel)./max(gamma(:,1+channel));
    
    %fit a power curve to the recorded data
    gammaFit = fit(gamma(:,1),gamma(:,1+channel),'b*x^c+d');
    gammaCoefficients(:,channel) = coeffvalues(gammaFit);


    %display gamma measurement
    scatter(gamma(:,1),gamma(:,1+channel),20,'filled','MarkerFaceColor',colorCode(channel,:),'MarkerEdgeColor',[0 0 0]);hold on
    xlabel('Display Setting')
    ylabel('Luminance')
    title('Gamma Function Measurement')
end
% legend(sprintf('val(x) = %f*x^{%f}+%f',gammaCoefficients(1,1),gammaCoefficients(2,1),gammaCoefficients(3,1)),sprintf('val(x) = %f*x^{%f}+%f',gammaCoefficients(1,2),gammaCoefficients(2,2),gammaCoefficients(3,2))sprintf('val(x) = %f*x^{%f}+%f',gammaCoefficients(1,3),gammaCoefficients(2,3),gammaCoefficients(3,3)))
sca;
%save gamma coefficients
gammaValues = gammaCoefficients(2,:);
save('gammaValues.mat','gammaValues')
