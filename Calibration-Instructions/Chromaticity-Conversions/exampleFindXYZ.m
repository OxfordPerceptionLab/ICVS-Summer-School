% exampleFindXYZ
% This script demos finding the XYZ coordinates of an RGB input to the
% display.

RGB = [0.4 0.6 0.7]; % Example input
display = 'standard';
device = 'pr670';

load('gammaValues.mat');
load('displayPrimaries.mat');

correctedRGB = RGB.^(1./gammaValues);

XYZ = RGBconversion('xyz',correctedRGB,displayPrimaries);














