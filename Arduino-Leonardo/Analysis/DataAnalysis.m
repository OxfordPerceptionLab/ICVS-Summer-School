ptptIDs = ['JP1', 'PO1', 'DT3', 'AG1', 'SP1'];
newPtptIDs = ['A', 'B', 'C', 'D', 'E'];
conditionStrings = ['None', 'No light', 'Red light', 'Green light'];

tbl = table2array(readtable('alldata.xlsx'));

redCols = [2,4,6,8];
greenCols = [3,5,7,9];

greenMaxLuminance = 665.2;

for i = redCols
    tbl(:,i) = log((tbl(:,i) / 255) * 2767.0);
end

for i = greenCols
    tbl(:,i) = log((tbl(:,i) / 255) * 665.2);
end

tbl(:,10) = tbl(:,2) ./ tbl(:,3);
tbl(:,11) = tbl(:,4) ./ tbl(:,5);
tbl(:,12) = tbl(:,6) ./ tbl(:,7);
tbl(:,13) = tbl(:,8) ./ tbl(:,9);

%%
t = tiledlayout(1, 5);

for i = 1:5
    nexttile
    b = bar(i,[tbl(i,10), tbl(i,11), tbl(i,12), tbl(i,13)]);
    ylim([0,2]);
end


%%
[~,~,stats] = anova1(tbl(:,10:13))

%%
c1 = multcompare(stats);

%%
