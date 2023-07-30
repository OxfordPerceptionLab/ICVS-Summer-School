% Written by DHB, July 2023 for ICVS Summer School

% Initialize
clear; close all;

% Load spectral data and set calibration file
S = [390 1 441];
%whichCones = 'SmithPokornyJudd1951';
whichCones = 'SmithPokorny';
outputDir = fullfile(pwd,whichCones);
if (~exist(outputDir,'dir'))
    mkdir(outputDir);
end

switch (whichCones)
    case 'SmithPokorny'
		load T_cones_sp
		load T_xyzJuddVos
		T_cones = SplineCmf(S_cones_sp,T_cones_sp,S);
		T_XYZ = SplineCmf(S_xyzJuddVos,T_xyzJuddVos,S);
    case 'DemarcoPokornySmith'
		load T_cones_dps
		load T_xyzJuddVos
		T_cones = SplineCmf(S_cones_dps,T_cones_dps,S);
		T_XYZ = SplineCmf(S_xyzJuddVos,T_xyzJuddVos,S);
    case 'SmithPokornyJudd1951'
		load T_cones_sp
		load T_xyzJuddVos
        load T_Y_Judd1951;
        T_Y = SplineCmf(S_Y_Judd1951,T_Y_Judd1951,S);
		T_cones = SplineCmf(S_cones_sp,T_cones_sp,S);
		T_XYZ = SplineCmf(S_xyzJuddVos,T_xyzJuddVos,S);
        T_XYZ(2,:) = T_Y;
	case 'StockmanSharpe'
		load T_cones_ss2
		load T_xyzCIEPhys2
		T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,S);
        T_XYZ = SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,S);
    otherwise
        error('Unknown cone fundamentals specified')
end

% Set up luminance and xform matrix
T_Y = T_XYZ(2,:);
M_LMSToXYZ = (T_cones'\T_XYZ')';

% Get spectrum of D65
load spd_D65.mat
spd_D65 = SplineSpd(S_D65,spd_D65,S);

% Check standard D65 chrom
load T_xyz1931
T_XYZ_1931 = SplineCmf(S_xyz1931,T_xyz1931,S);
xyY1931D65 = XYZToxyY(T_XYZ_1931*spd_D65);
fprintf('D65 chrom: %0.3f, %0.3f\n',xyY1931D65(1),xyY1931D65(2));

% Recreate the spectrum locus and equal energy white shown in Figure 8.2
% of CIE 170-2:2015 (if StockmanSharpe set). Otherwise make the
% MacLeod-Boynton diagram from Smith-Pokorny land, which differs from the
% CIE standard.
lsSpectrumLocus = LMSToMacBoyn(T_cones,T_cones,T_Y);
xyYSpectrumLocus = XYZToxyY(T_XYZ);
wls = SToWls(S);
plotWls = SToWls([400 10 31]);
for ii = 1:length(plotWls)
    plotIndex(ii) = find(wls == plotWls(ii));
end

% Get point colors for spectrum locus using SRGB
plotColors = SRGBGammaCorrect(XYZToSRGBPrimary((T_XYZ(:,plotIndex))));

% Compute the sum of the ls values in the spectrum locus, and compare
% to the value that this example computed in February 2019, entered
% here to four places as 412.2608.  This comparison provides a
% check that this routine still works the way it did when we put in the
% check.
if (strcmp(whichCones,'StockmanSharpe'))
    check = round(sum(lsSpectrumLocus(:)),4);
    if (abs(check-412.2608) > 1e-4)
        error('No longer get same check value as we used to');
    end
end

% Compute representations for equal energy white.
% Scale by hand to make the plotted point end up
% in a reasonable place in the 3D plot.
EEFactor = 200;
LMSEEWhite = sum(T_cones,2)/EEFactor;
XYZEEWhite = M_LMSToXYZ*LMSEEWhite;
xyYEEWhite = XYZToxyY(XYZEEWhite);
lsEEWhite = LMSToMacBoyn(LMSEEWhite,T_cones,T_Y);

% Compute representations for D65
D65Factor = 4000;
LMSD65 = T_cones*spd_D65/D65Factor;
XYZD65 = M_LMSToXYZ*LMSD65;
xyYD65 = XYZToxyY(XYZD65);
lsD65 = LMSToMacBoyn(LMSD65,T_cones,T_Y);

% Plot M-B diagram
figure; clf; hold on;
set(gca,'FontName','Helvetica','FontSize',16);
for ii = 1:length(plotIndex)
    plot(lsSpectrumLocus(1,plotIndex(ii)),lsSpectrumLocus(2,plotIndex(ii)), ...
        'o','Color',plotColors(:,ii)/255,'MarkerFaceColor',plotColors(:,ii)/255,'MarkerSize',12);
end
plot(lsSpectrumLocus(1,:),lsSpectrumLocus(2,:),'k','LineWidth',2);
plot(lsEEWhite(1),lsEEWhite(2), ...
    's','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',12);
plot(lsD65(1),lsD65(2), ...
    's','Color',[0 0 0.5],'MarkerFaceColor',[0 0 0.5],'MarkerSize',12);
xlabel('l'); ylabel('s');
title({'MacLeod-Boynton' ; ['Based on ' whichCones]}, ...
    'FontName','Helvetica','FontSize',20);
xlim([0.4 1]); ylim([0,1]);
axis('square');
saveas(gcf,fullfile(outputDir,'MacLeodBoynton.tiff'),'tif');

% Zoomed version, as is typical in some papers
if (strcmp(whichCones,'StockmanSharpe'))
    xlim([0.6 0.8]); ylim([0 0.1]);
elseif (strcmp(whichCones,'SmithPokorny') | ...
        strcmp(whichCones,'SmithPokornyJudcd1951') | ...
        strcmp(whichCones,'DemarcoPokornySmith'))
    xlim([0.6 0.7]); ylim([0 0.1]);
elseif (strcmp(whichCones,'SmithPokornyJudcd1951'))
    xlim([0.6 0.7]); ylim([0 0.1]);
end
saveas(gcf,fullfile(outputDir,'MacLeodBoyntonZoom.tiff'),'tif');

% Plot xy chromaticity
figure; clf; hold on;
set(gca,'FontName','Helvetica','FontSize',16);
for ii = 1:length(plotIndex)
    plot(xyYSpectrumLocus(1,plotIndex(ii)),xyYSpectrumLocus(2,plotIndex(ii)), ...
        'o','Color',plotColors(:,ii)/255,'MarkerFaceColor',plotColors(:,ii)/255,'MarkerSize',12);
end
plot(xyYSpectrumLocus(1,:),xyYSpectrumLocus(2,:),'k','LineWidth',2);
plot(xyYEEWhite(1),xyYEEWhite(2), ...
    's','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',12);
plot(xyYD65(1),xyYD65(2), ...
    's','Color',[0 0 0.5],'MarkerFaceColor',[0 0 0.5],'MarkerSize',12);
xlabel('x'); ylabel('y');
if (strcmp(whichCones,'StockmanSharpe'))
    title({'Chromaticity' ; 'CIE Physiological XYZ'},'FontName','Helvetica','FontSize',20);
elseif (strcmp(whichCones,'SmithPokorny'))
    title({'Chromaticity' ; 'Judd-Vos XYZ'},'FontName','Helvetica','FontSize',20);
end
xlim([0 1]); ylim([0 1]);
axis('square');
saveas(gcf,fullfile(outputDir,'xyChrom.tiff'),'tif');

% Plot spectrum locus and EE white in LMS
figure; clf; hold on;
set(gca,'FontName','Helvetica','FontSize',16);
for ii = 1:length(plotIndex)
    plot3(T_cones(1,plotIndex(ii)),T_cones(2,plotIndex(ii)),T_cones(3,plotIndex(ii)), ...
        'o','Color',plotColors(:,ii)/255,'MarkerFaceColor',plotColors(:,ii)/255,'MarkerSize',12);
end
plot3(T_cones(1,:),T_cones(2,:),T_cones(3,:),'k','LineWidth',2);
plot3(LMSEEWhite(1),LMSEEWhite(2),LMSEEWhite(3), ...
    's','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',12);
plot3(LMSD65(1),LMSD65(2),LMSD65(3), ...
    's','Color',[0 0 0.5],'MarkerFaceColor',[0 0 0.5],'MarkerSize',12);
xlabel('L');
ylabel('M');
zlabel('S');
title({'LMS Space' ; whichCones},'FontName','Helvetica','FontSize',20);
view([50 16]);
axis('square');
xlim([0 1]); ylim([0 1]); zlim([0 1]);
set(gca,'XTick',[0 0.5 1]);
set(gca,'YTick',[0 0.5 1]);
set(gca,'ZTick',[0 0.5 1]);
saveas(gcf,fullfile(outputDir,'LMSSpace.tiff'),'tif');

% Plot spectrum locus and EE white in XYZ
figure; clf; hold on;
set(gca,'FontName','Helvetica','FontSize',16);
for ii = 1:length(plotIndex)
    plot3(T_XYZ(1,plotIndex(ii)),T_XYZ(2,plotIndex(ii)),T_XYZ(3,plotIndex(ii)), ...
        'o','Color',plotColors(:,ii)/255,'MarkerFaceColor',plotColors(:,ii)/255,'MarkerSize',12);
end
plot3(T_XYZ(1,:),T_XYZ(2,:),T_XYZ(3,:),'k','LineWidth',2);
plot3(XYZEEWhite(1),XYZEEWhite(2),XYZEEWhite(3), ...
    'o','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',12);
plot3(XYZD65(1),XYZD65(2),XYZD65(3), ...
    's','Color',[0 0 0.5],'MarkerFaceColor',[0 0 0.5],'MarkerSize',12);
xlabel('X');
ylabel('Y');
zlabel('Z');
if (strcmp(whichCones,'StockmanSharpe'))
    title({'XYZ Space' ; 'CIE Physiological XYZ'},'FontName','Helvetica','FontSize',20);
elseif (strcmp(whichCones,'SmithPokorny'))
    title({'XYZ Space' ; 'Judd-Vos XYZ'},'FontName','Helvetica','FontSize',20);
end
view([50 16]);
axis('square');
xlim([0 1.6]); ylim([0 1.6]); zlim([0 1.6]);
set(gca,'XTick',[0 0.8 1.6]);
set(gca,'YTick',[0 0.8 1.6]);
set(gca,'ZTick',[0 0.8 1.6]);
saveas(gcf,fullfile(outputDir,'XYZSpace.tiff'),'tif');

% Plots of cones and XYZ
figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',16);
plot(wls,T_cones(1,:),'r','LineWidth',3);
plot(wls,T_cones(2,:),'g','LineWidth',3);
plot(wls,T_cones(3,:),'b','LineWidth',3);
legend({'L', 'M', 'S'},'FontName','Helvetica','FontSize',12);
xlabel('Wavelength (nm)','FontName','Helvetica','FontSize',20);
ylabel('Normalized Sensitivity','FontName','Helvetica','FontSize',20);
title(whichCones);
xlim([400 700]);
saveas(gcf,fullfile(outputDir,'LMSFundamentals.tiff'),'tif');

figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',16);
plot(wls,T_XYZ(1,:),'r','LineWidth',3);
plot(wls,T_XYZ(2,:),'g','LineWidth',3);
plot(wls,T_XYZ(3,:),'b','LineWidth',3);
legend({'X', 'Y', 'Z'},'FontName','Helvetica','FontSize',12);
xlabel('Wavelength (nm)','FontName','Helvetica','FontSize',20);
ylabel('CMF Value','FontName','Helvetica','FontSize',20);
if (strcmp(whichCones,'StockmanSharpe'))
    title('CIE Physiological XYZ','FontName','Helvetica','FontSize',20);
elseif (strcmp(whichCones,'SmithPokorny'))
    title({'Judd-Vos XYZ'},'FontName','Helvetica','FontSize',20);
end
xlim([400 700]);
saveas(gcf,fullfile(outputDir,'XYZColorMatchingFcns.tiff'),'tif');
