function writeLEDs(a, RGY)

% Locations of red, green, and yellow LED
dNum = ["D6", "D5", "D9"];      % Blue = "D3"

for i = 1:3
    colVal = (255 - RGY(i)) / 255;
    writePWMDutyCycle(a, dNum(i), colVal);
end

end
