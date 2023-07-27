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
        matchingFunction = csvread('lin2012xyz10e_1_7sf.csv');
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %create matrix
        Lr = displayPrimaries(:,2)' * matchingFunction(:,2);
        Lg = displayPrimaries(:,3)' * matchingFunction(:,2);
        Lb = displayPrimaries(:,4)' * matchingFunction(:,2);
        
        Mr = displayPrimaries(:,2)' * matchingFunction(:,3);
        Mg = displayPrimaries(:,3)' * matchingFunction(:,3);
        Mb = displayPrimaries(:,4)' * matchingFunction(:,3);
        
        Sr = displayPrimaries(:,2)' * matchingFunction(:,4);
        Sg = displayPrimaries(:,3)' * matchingFunction(:,4);
        Sb = displayPrimaries(:,4)' * matchingFunction(:,4);

        RGB2XYZ_matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];

        matrix = inv(RGB2XYZ_matrix);
        
        out = matrix * input';
        out = out';
        
    case 'lms'
        %load cone fundamentals
        matchingFunction = csvread('linss10e_1.csv');
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        Lr = displayPrimaries(:,2)' * matchingFunction(:,2);
        Lg = displayPrimaries(:,3)' * matchingFunction(:,2);
        Lb = displayPrimaries(:,4)' * matchingFunction(:,2);
        
        Mr = displayPrimaries(:,2)' * matchingFunction(:,3);
        Mg = displayPrimaries(:,3)' * matchingFunction(:,3);
        Mb = displayPrimaries(:,4)' * matchingFunction(:,3);
        
        Sr = displayPrimaries(:,2)' * matchingFunction(:,4);
        Sg = displayPrimaries(:,3)' * matchingFunction(:,4);
        Sb = displayPrimaries(:,4)' * matchingFunction(:,4);

        RGB2LMS_matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];
        
        matrix = inv(RGB2LMS_matrix);

        out = matrix * input';
        out = out';

    case 'xyY'
        %load CMFs
        matchingFunction = csvread('lin2012xyz10e_1_7sf.csv');
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %create matrix
        Lr = displayPrimaries(:,2)' * matchingFunction(:,2);
        Lg = displayPrimaries(:,3)' * matchingFunction(:,2);
        Lb = displayPrimaries(:,4)' * matchingFunction(:,2);
        
        Mr = displayPrimaries(:,2)' * matchingFunction(:,3);
        Mg = displayPrimaries(:,3)' * matchingFunction(:,3);
        Mb = displayPrimaries(:,4)' * matchingFunction(:,3);
        
        Sr = displayPrimaries(:,2)' * matchingFunction(:,4);
        Sg = displayPrimaries(:,3)' * matchingFunction(:,4);
        Sb = displayPrimaries(:,4)' * matchingFunction(:,4);

        RGB2XYZ_matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];

        matrix = inv(RGB2XYZ_matrix);
        
        XYZ(1) = (input(3)*input(1))/input(2);
        XYZ(2) = input(3);
        XYZ(3) = ((input(3)*(1-input(1)-input(2))))/input(2);

        out = matrix * XYZ';
        out = out';

     case 'lab'
        %load CMFs
        matchingFunction = csvread('lin2012xyz10e_1_7sf.csv');
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        Lr = displayPrimaries(:,2)' * matchingFunction(:,2);
        Lg = displayPrimaries(:,3)' * matchingFunction(:,2);
        Lb = displayPrimaries(:,4)' * matchingFunction(:,2);
        
        Mr = displayPrimaries(:,2)' * matchingFunction(:,3);
        Mg = displayPrimaries(:,3)' * matchingFunction(:,3);
        Mb = displayPrimaries(:,4)' * matchingFunction(:,3);
        
        Sr = displayPrimaries(:,2)' * matchingFunction(:,4);
        Sg = displayPrimaries(:,3)' * matchingFunction(:,4);
        Sb = displayPrimaries(:,4)' * matchingFunction(:,4);

        RGB2XYZ_matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];
        
        matrix = inv(RGB2XYZ_matrix);
        %calculate XYZ values
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);
        
        %calculate X
        if (((input(1)+16)/116)+(input(2)/500)) > 6/29
            XYZ(1) = whiteXYZ(1)*(((input(1)+16)/116)+(input(2)/500))^3;
        else
            XYZ(1) = whiteXYZ(1)*(3*(6/29)^2)*((((input(1)+16)/116)+(input(2)/500))-(4/29));
        end
        %calculate Y
        if ((input(1)+16)/116) > 6/29
            XYZ(2) = whiteXYZ(2)*(((input(1)+16)/116)+(input(2)/500))^3;
        else
            XYZ(2) = whiteXYZ(2)*(3*(6/29)^2)*((((input(1)+16)/116))-(4/29));
        end
        %calculate Z
        if (((input(1)+16)/116)-(input(3)/200)) > 6/29
            XYZ(3) = whiteXYZ(3)*(((input(1)+16)/116)+(input(3)/500))^3;
        else
            XYZ(3) = whiteXYZ(3)*(3*(6/29)^2)*((((input(1)+16)/116)-(input(3)/200))-(4/29));
        end
        
        out = matrix * XYZ';
        out = out';       
        
        
    case 'luv'
        %load CMFs
        matchingFunction = csvread('lin2012xyz10e_1_7sf.csv');
        matchingFunction = matchingFunction(1:5:391,:);
        displayPrimaries = displayPrimaries(3:end,:);
        %generate matrix
        Lr = displayPrimaries(:,2)' * matchingFunction(:,2);
        Lg = displayPrimaries(:,3)' * matchingFunction(:,2);
        Lb = displayPrimaries(:,4)' * matchingFunction(:,2);
        
        Mr = displayPrimaries(:,2)' * matchingFunction(:,3);
        Mg = displayPrimaries(:,3)' * matchingFunction(:,3);
        Mb = displayPrimaries(:,4)' * matchingFunction(:,3);
        
        Sr = displayPrimaries(:,2)' * matchingFunction(:,4);
        Sg = displayPrimaries(:,3)' * matchingFunction(:,4);
        Sb = displayPrimaries(:,4)' * matchingFunction(:,4);

        RGB2XYZ_matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];
        
        matrix = inv(RGB2XYZ_matrix);
        
        %calculate XYZ
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);

        uprimeWhite = (4*whiteXYZ(1))/(whiteXYZ(1)+15*whiteXYZ(2)+3*whiteXYZ(3));
        vprimeWhite = (9*whiteXYZ(2))/(whiteXYZ(1)+15*whiteXYZ(2)+3*whiteXYZ(3));

        uprime = (input(2)/(13*input(1)))+uprimeWhite;
        vprime = (input(3)/(13*input(1)))+vprimeWhite;
        
        XYZ = zeros(1,3);
        if input(1) <= 8
            XYZ(2) = whiteXYZ(2)*input(1)*(3/29)^3;
        else
            XYZ(2) = whiteXYZ(2)*((input(1)+16)/116)^3;
        end
        
        XYZ(1) = XYZ(2)*((9*uprime)/(4*vprime));
        XYZ(3) = XYZ(2)*((12-(3*uprime)-(20*vprime))/(4*vprime));
        
        out = matrix * XYZ';
        out = out';
end
end