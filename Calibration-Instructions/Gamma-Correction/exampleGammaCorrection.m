%exampleGammaCorrection
% This script demonstrates how the gamma values found in
% 'measureGamma.m' can be used to 'Gamma correct' a display's output.

%load existing gamma values
load('gammaValues.mat')

%just make sure to avoid 'white' value if 'full' mode was used
if length(gammaValues) > 3
    gammaValues = gammaValues(1:3);
end

%pre-correction values
initialValues = [0.5 0.5 0.5];

%gamma correction
correctedValues = initialValues.^(1./gammaValues);
