function [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor)

red = round(lambda*redAnchor);
if (red < 0)
    red = 0;
elseif (red > 255)
    red = 255;
end
    
green = round((1-lambda)*greenAnchor);
if (green < 0)
    green = 0;
elseif (green > 255)
    green = 255;
end

end