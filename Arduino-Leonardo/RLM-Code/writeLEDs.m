function writeLEDs(a, RGBY)

% Locations of red, green, blue, and yellow LED
dNum = ["D6", "D5", "D3", "D9"];

for i = 1:4
    colVal = (255 - RGBY(i)) / 255;
    writePWMDutyCycle(a, dNum(i), colVal);
end

end
