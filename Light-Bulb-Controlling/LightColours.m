%% Broadband light
% White
packet = lifx_udp(120, 0, 1, 9000);

%% Pure monochromatic light
% Red
packet = lifx_udp(360, 1, 1, 9000);

% Blue
packet = lifx_udp(1, 1, 1, 9000);

% Green
packet = lifx_udp(120, 1, 1, 9000);

% Yellow
packet = lifx_udp(60, 1, 1, 9000);

%% Biased light
% Red bised
packet = lifx_udp(360, 0.5, 1, 9000);

% Blue bised
packet = lifx_udp(1, 0.5, 1, 9000);

% Green bised
packet = lifx_udp(120, 0.5, 1, 9000);

% Yellow bised
packet = lifx_udp(60, 0.5, 1, 9000);

%% Turning Off
packet = lifx_udp(120, 0, 0, 9000);