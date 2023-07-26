function packet = lifx_udp(h, s, b, k)

%LIFX_UDP sends a udp packet to the LIFX lightbulb in order to change its
% color
%
%INPUTS: 
%   h, a color in the range 1-360 (corresponds to a standard color wheel)
%   s, a saturation value in the range 0-1 
%   b, a brightness value in the range 0-1
%   k, a kelvin value for the "warmness" of the light, from 2500 (cool) to
%   9000 (warm)
%
%
%OUTPUTS: 
%   packet, the LIFX packet's value in binary.
%   see document/the block below for further explanation of input parameters
%%
%{
FURTHER EXPLANATION OF INPUT PARAMATERS

Hue - range from 1-360 in degrees
LIFX_hue = hue/360*65535
hexcode index: 39, 38 (remember to reverse)

Saturation - range from 0 to 1
LIFX_sat = sat*65535
hexcode index: 41, 40

Brightness - range from 0 to 1
LIFX_Bright = bright*65535
hexcode index: 43, 42

Kelvin - range 2500° (warm) to 9000° (cool)
LIFX_Kelvin = Kelvin
hexcode index: 45, 44

%}
%%
%INITIALIZE
hexcode = {'31', '00', '00', '34', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '00', '66', '00', '00', '00', '00', '55', '55', 'FF', 'FF', 'FF', 'FF', 'AC', '0D', '00', '00', '00', '00'};


%%
%HUE
hue = h/360 * 65535; %hue conversion formula, from degrees scale to LIFX scale
hue = floor(hue);
hue = dec2hex(hue);

if (length(hue) == 3) | (length(hue) == 1) 
    hue = strcat('0',hue);
end

hexcode(38) = {'00'};
hexcode(39) = {hue(1:2)};

if length(hue) > 2
    hexcode(38) = {hue(3:4)};
end

%%
%SATURATION
sat = s * 65535; %conversion formula
sat = floor(sat);
sat = dec2hex(sat);

if (length(sat) == 3) | (length(sat) == 1) 
    sat = strcat('0',sat);
end

hexcode(40) = {'00'};
hexcode(41) = {sat(1:2)};

if length(sat) > 2
    hexcode(40) = {sat(3:4)};
end

%%
%BRIGHTNESS
bright = b * 65535; %conversion formula
bright = floor(bright);
bright = dec2hex(bright);

if (length(bright) == 3) | (length(bright) == 1) 
    bright = strcat('0',bright);
end

hexcode(42) = {'00'};
hexcode(43) = {bright(1:2)};

if length(bright) > 2
    hexcode(42) = {bright(3:4)};
end

%%
%KELVIN
kelvin = k; 
kelvin = floor(kelvin);
kelvin = dec2hex(kelvin);

if (length(kelvin) == 3) | (length(kelvin) == 1) 
    kelvin = strcat('0',kelvin);
end

hexcode(44) = {'00'};
hexcode(45) = {kelvin(1:2)};

if length(kelvin) > 2
    hexcode(44) = {kelvin(3:4)};
end

%%
%PACKET IS DONE
packet = hex2dec(hexcode); 

%%
%CREATE UDP PACKET
%coment out if you only want the packet and don't want to send command to
%lightbulb

u = udp('255.255.255.255',56700); %lightbulb ip address and listening port

%'192.168.0.255'

fopen(u);

fwrite(u, packet, 'uint8');

fclose(u);
delete(u);
clear u;




 








