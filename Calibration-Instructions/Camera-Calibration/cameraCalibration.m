% written by ACH 28/07/2023 for the ICVS Summer School 2023
% code to find conversion matrix required to turn RGB into XYZ measurements for a camera
% requires RGB and XYZ measurements of MacBeth Colour Check samples

% desktop tidy up
clear all; clc; close all;

%% Step 1: load the RGB and XYZ colour samples

load('RGB_camera_example_measurements.mat');
load('XYZ_camera_example_measurements.mat');

%% Step 2: check if any of the samples are out of gamut for the camera
% Can you discuss amongst your groups why this step is important?

c=1;
for i = 1:24 % loop over all samples
    if sum(rgb(i,:)<0.001)==0 %for this camera anything out of gamut is set to either very close to 0
        if sum(rgb(i,:)>0.999)==0 % or very close to 1
            usable_RGB_camera(:,c) = RGB_camera(i,:)';
            usable_XYZ_camera(:,c) = XYZ_camera(i,:)'; 
            c=c+1;
        end
    end
end

%% Step 3: find the conversion matrices

xyz2rgb = usable_RGB_camera/usable_XYZ_camera;
rgb2xyz = usable_XYZ_camera/usable_RGB_camera;

%% Step 4: check how accurate your calibration worked
% Can you discuss in your groups why this might be important?
% Can you discuss in your groups what is being implemented here as a check?

est_XYZ_camera = (rgb2xyz*usable_RGB_camera);
Lab_camera = XYZToLab(usable_XYZ_camera, usable_XYZ_camera(:,19));
est_Lab_camera = XYZToLab(est_XYZ_camera, usable_XYZ_camera(:,19));
deltaEs = ComputeDE2000_Lab(Lab_camera', est_Lab_camera');



    
    