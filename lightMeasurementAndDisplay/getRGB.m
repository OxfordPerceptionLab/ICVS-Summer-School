function [out, matrix] = getRGB(inputType,input,displayPrimaries,whitepoint)
%This function uses display primary measurements from 'measurePrimaries.m'
%to create matrices that allow for the conversion from standardised 
%colorspaces a display's RGB.
%
%inputType - input colorspace ('xyz', 'xyY', 'luv', 'lab', 'lms')
%
%input - desired tristimulus value
%
%displayPrimaries - 4x81 array with red, green and blue channel recordings -
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

switch inputType
    case 'xyz'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %create matrix

        RGB2XYZ_matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        matrix = inv(RGB2XYZ_matrix);
        
        out = matrix * input';
        out = out';
        
    case 'lms'
        %load cone fundamentals
        matchingFunction = table2array(readtable('linss10e_1.csv'));
        matchingFunction(isnan(matchingFunction(:,4)),4) = 0;
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        RGB2LMS_matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        matrix = inv(RGB2LMS_matrix);

        out = matrix * input';
        out = out';

    case 'MB'
        matchingFunction = table2array(readtable('linss10e_1.csv'));
        matchingFunction(isnan(matchingFunction(:,4)),4) = 0;
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);

        RGB2LMS_matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        matrix = inv(RGB2LMS_matrix);

        Lw = 0.692839;
        Mw = 0.349676;
        Sw = 2.146879448901693;

        LMS(1) = (input(1)*input(3))/Lw;
        LMS(2) = (input(3)-(LMS(1)*Lw))/Mw;
        LMS(3) = (input(2)*input(3))/Sw;

        out = matrix * LMS';
        out = out';


    case 'xyY'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %create matrix
        RGB2XYZ_matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        matrix = inv(RGB2XYZ_matrix);
        
        XYZ = xyYToXYZ(input');

        out = matrix * XYZ;
        out = out';

     case 'lab'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        RGB2XYZ_matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        matrix = inv(RGB2XYZ_matrix);
        
        %calculate XYZ values
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);
        
        XYZ = LabToXYZ(input',whiteXYZ');
        
        out = matrix * XYZ;
        out = out';       
        
        
    case 'luv'
        %load CMFs
        matchingFunction = table2array(readtable('lin2012xyz10e_1_7sf.csv'));
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        RGB2XYZ_matrix = matchingFunction(:,2:4)' * displayPrimaries(:,2:4);

        matrix = inv(RGB2XYZ_matrix);
        
        %calculate XYZ
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);

        XYZ = LuvToXYZ(input',whiteXYZ');
        
        out = matrix * XYZ;
        out = out';
end
end