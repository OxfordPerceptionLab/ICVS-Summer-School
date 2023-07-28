function [out, matrix] = RGBconversion(output,RGB,displayPrimaries,whitepoint)
%This function uses display primary measurements from 'measurePrimaries.m'
%to create matrices that allow for the conversion from a display's RGB
%color representation to standardised colorspaces.
%
%output - desired colorspace output. Either 'xyz', 'lms', 'luv' or 'lab'
%
%RGB - input linear RGB values
%
%displayPrimaries - 3x81 array with red, green and blue channel recordings -
%these must be in in the lambda format [380 5 81]
%
%whitepoint - for lab and luv, a whitepoint reference is required. Select
%either 'd65' or 'EEW'. 

if nargin < 4 || isempty(whitepoint)
    whitepoint = '';
end

%whitepoint is defined - either 'd65' or 'Equal Energies White'
switch whitepoint
    case 'd65'
        white = load("d65.txt");
        white = white(91:481,:);
        white = white(:,2)/max(white(:,2));
    case 'EEW'
        white = ones(391,1);
    case''
end

load(displayPrimaries);
%different conversion procedure
switch output 
    case 'xyz'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %create matrix
       
        matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        out = matrix * RGB';
        out = out';    
    
    case 'lms'
        %load cone fundamentals
        matchingFunction = table2array(readtable('linss10e_1.csv'));
        matchingFunction(isnan(matchingFunction(:,4)),4) = 0;
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
       
        matrix = matchingFunction(:,2:4)'*displayPrimaries(:,2:4);

        out = matrix * RGB';
        out = out';

    case 'lab'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix

        matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        %calculate XYZ values
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);
        XYZ = matrix * RGB';
        out = XYZToLab(XYZ,whiteXYZ');
        out = out';

    case 'luv'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        %calculate XYZ
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);
        XYZ = matrix * RGB';
        
        out = XYZToLuv(XYZ,whiteXYZ');
        out = out';
    
    
    case 'xyY'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        %calculate XYZ and then xyY
        xyz = matrix * RGB';
        
        out = XYZToxyY(xyz);
        out = out';


end
end
