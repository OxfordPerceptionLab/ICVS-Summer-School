function [window,windowDimensions] = initialiseDisplay(display)

switch display
    case 'standard'
        screenID = max(Screen('Screens'));
        [window,windowDimensions] = PsychImaging('OpenWindow',screenID,[0,0,0]);
end

end