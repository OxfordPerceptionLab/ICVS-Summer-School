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

        matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];

        out = matrix * RGB';
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

        matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];

        out = matrix * RGB';
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

        matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];
        %calculate XYZ values
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);
        XYZ = matrix * RGB';

        %calculate fX
        if XYZ(1)/whiteXYZ(1) > (6/29)^3
            fX = (XYZ(1)/whiteXYZ(1)).^(1/3);
        else
            fX = (XYZ(1)/whiteXYZ(1))/(3*((6/29)^2))+4/29;
        end

        %calculate fY
        if XYZ(2)/whiteXYZ(2) > (6/29)^3
            fY = (XYZ(2)/whiteXYZ(2)).^(1/3);
        else
            fY = (XYZ(2)/whiteXYZ(2))/(3*((6/29)^2))+4/29;
        end

        %calculate fY
        if XYZ(3)/whiteXYZ(3) > (6/29)^3
            fZ = (XYZ(3)/whiteXYZ(3)).^(1/3);
        else
            fZ = (XYZ(3)/whiteXYZ(3))/(3*((6/29)^2))+4/29;
        end
        %calculate lab
        L = 116*(fY) - 16;
        a = 500*(fX - fY);
        b = 200*(fY - fZ);


        out = [L a b];

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

        matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];
        %calculate XYZ
        whiteXYZ = white(1:5:end)'*matchingFunction(:,2:4);
        whiteXYZ = whiteXYZ./(whiteXYZ(2)/100);
        XYZ = matrix * RGB';
        %calculate L
        if XYZ(2)/whiteXYZ(2) <= (6/29)^3 
            L = ((29/3)^3)*(XYZ(2)/whiteXYZ(2));
        else
            L = (116*(XYZ(2)/whiteXYZ(2))^(1/3))-16;
        end
        %calculate u' and v' for white and desired color
        uprime = (4*XYZ(1))/(XYZ(1)+15*XYZ(2)+3*XYZ(3));
        vprime = (9*XYZ(2))/(XYZ(1)+15*XYZ(2)+3*XYZ(3));

        uprimeWhite = (4*whiteXYZ(1))/(whiteXYZ(1)+15*whiteXYZ(2)+3*whiteXYZ(3));
        vprimeWhite = (9*whiteXYZ(2))/(whiteXYZ(1)+15*whiteXYZ(2)+3*whiteXYZ(3));
        %calculate u and v
        u = 13*L*(uprime-uprimeWhite);
        v = 13*L*(vprime-vprimeWhite);

        out = [L u v];


    case 'xyY'
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

        matrix = [Lr, Lg, Lb;
            Mr, Mg, Mb;
            Sr, Sg, Sb];
        %calculate XYZ and then xyY
        xyz = matrix * RGB';
        xy = xyz(1:2)./sum(xyz);
        out = [xy' xyz(2)];

end
end
