function writeLEDs(a, RGBY)

pwmRGBY = zeros(1,4);
dNum = ["D6", "D5", "D3", "D9"];

for colour = 1:4
    pwmRGBY(colour) = (255 - RGBY(colour)) / 255;
    writePWMDutyCycle(a, dNum(colour), pwmRGBY(colour));
end

end
