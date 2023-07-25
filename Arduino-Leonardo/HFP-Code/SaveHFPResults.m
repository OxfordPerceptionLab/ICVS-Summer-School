function SaveHFPResults(PPcode, trialNumber, red, green, redInit, greenInit, rDelta)
%This code creates structure variable "ParticipantMatches"

%'ParticipantCode' is the code of each participant ('rp_001', 'rp_002', etc.)

%'DateTime' represents date and time of the end of the experiment

%'RedValue', 'GreenValue', 'YellowValue', represent the intensity (in 
%bytes, 0-255) of Red, Green, and Yellow light

%% record current date and time
CurrentDateAndTime=round(clock);

trialNumber = num2str(trialNumber);
red = num2str(red);
green = num2str(green);
redInit = num2str(redInit);
greenInit = num2str(greenInit);
rDelta = num2str(rDelta);

if ~exist("ParticipantMatchesHFP.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesHFP=table([], [], [], [], [], [], [], [],...
        'VariableNames',{'ParticipantCode', 'Trial', 'DateTime', 'RedValue', 'GreenValue', ...
        'InitialRedSetting', 'InitialGreenSetting', 'Red Delta'});
else
    % Load Structure File
    load('ParticipantMatchesHFP.mat');
end

%% new participant results
newResults=table({PPcode}, str2num(trialNumber), CurrentDateAndTime, ...
    str2num(red), str2num(green), str2num(redInit), str2num(greenInit), str2num(rDelta), 'VariableNames',...
    {'ParticipantCode',  'Trial', 'DateTime', 'RedValue', 'GreenValue', ...
        'InitialRedSetting', 'InitialGreenSetting', 'Red Delta'});

%% new table
ParticipantMatchesHFP=[ParticipantMatchesHFP; newResults];

%% show and save file
save('ParticipantMatchesHFP', 'ParticipantMatchesHFP');
clear
end
