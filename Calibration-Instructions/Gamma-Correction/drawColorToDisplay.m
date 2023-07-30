function drawColorToDisplay(color,display,window,windowDimensions)
% global window windowDimensions
switch display
    case 'standard'
        Screen('FillRect',window,color,windowDimensions)
        Screen('Flip',window)





end
end