% Neon fruit illusion
a = [140:-1:100];
b = fliplr(a);
packet = lifx_udp(120, 0, 1, 9000);
pause(5);

for j = 1:3
    packet = lifx_udp(140, 1, 1, 9000);
    pause(5);
    for i = 1:length(a)
        
        
        packet = lifx_udp(a(i), 1, 1, 9000);
        pause(0.1);
        
    end
    pause(5);
    for i = 1:length(a)
        
        
        packet = lifx_udp(b(i), 1, 1, 9000);
        pause(0.1);
        
    end
end

packet = lifx_udp(120, 0, 1, 9000);