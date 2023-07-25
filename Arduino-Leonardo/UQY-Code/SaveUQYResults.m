function SaveUQYResults(ptptID, trialNumber, red, green, rgDelta)
%This code creates structure variable "ParticipantMatches"

%'ParticipantCode' is the code of each participant ('rp_001', 'rp_002', etc.)

%'DateTime' represents date and time of the end of the experiment

%'RedValue', 'GreenValue', 'YellowValue', represent the intensity (in 
%bytes, 0-255) of Red, Green, and Yellow light

%% record current date and time
CurrentDateAndTime=round(clock);

trialNumber = num2str(trialNumber);
rgRatio = num2str(red / green);
red = num2str(red);
green = num2str(green);
rgDelta = num2str(rgDelta);

if ~exist("ParticipantMatchesUQY.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesUQY=table([], [], [], [], [], [], [],...
        'VariableNames',{'ParticipantCode', 'Trial', 'DateTime', 'Red', 'Green', 'rgRatio', ...
        'rgDelta'});
else
    % Load Structure File
    load('ParticipantMatchesUQY.mat');
end

%% new participant results
newResults=table({ptptID}, str2num(trialNumber), CurrentDateAndTime, ... 
    str2num(red), str2num(green), str2num(rgRatio), str2num(rgDelta),...
    'VariableNames',...
    {'ParticipantCode', 'Trial', 'DateTime', ... 
    'Red', 'Green', 'rgRatio', 'rgDelta'});

%% new table
ParticipantMatchesUQY=[ParticipantMatchesUQY; newResults];

%% show and save file
save('ParticipantMatchesUQY', 'ParticipantMatchesUQY');
clear
