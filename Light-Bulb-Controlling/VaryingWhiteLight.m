% Varying white light

%% White
a = [9000:-1:5000];
packet = lifx_udp(120, 0, 1, 9000);

%% Varying
for i = 1:length(a)       
    packet = lifx_udp(120, 0, 1, a(i));
end