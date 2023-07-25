function SaveBRMResults(ptptID, trialNumber, currentColour, testColour, yellow, rgDelta)
%This code creates structure variable "ParticipantMatches"

%'ParticipantCode' is the code of each participant ('rp_001', 'rp_002', etc.)

%'DateTime' represents date and time of the end of the experiment

%'RedValue', 'GreenValue', 'YellowValue', represent the intensity (in 
%bytes, 0-255) of Red, Green, and Yellow light

%% record current date and time
CurrentDateAndTime=round(clock);

trialNumber = num2str(trialNumber);
testColour = num2str(testColour);
yellow = num2str(yellow);
rgDelta = num2str(rgDelta);

if ~exist("ParticipantMatchesBRM.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesBRM=table([], [], [], [], [], [], [],...
        'VariableNames',{'ParticipantCode', 'Trial', 'DateTime', 'TestColour', 'TestColourValue', ...
        'Yellow', 'rgDelta'});
else
    % Load Structure File
    load('ParticipantMatchesBRM.mat');
end

%% new participant results
newResults=table({ptptID}, str2num(trialNumber), CurrentDateAndTime, ... 
    {currentColour}, str2num(testColour), str2num(yellow), str2num(rgDelta),...
    'VariableNames',...
    {'ParticipantCode', 'Trial', 'DateTime', ... 
    'TestColour', 'TestColourValue', 'Yellow', 'rgDelta'});

%% new table
ParticipantMatchesBRM=[ParticipantMatchesBRM; newResults];

%% show and save file
save('ParticipantMatchesBRM', 'ParticipantMatchesBRM');
clear
