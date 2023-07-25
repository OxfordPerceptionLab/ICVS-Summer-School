function SaveRLMResults(ptptID, trialNumber, red, green, yellow, lambda, lambdaDelta, yellowDelta)
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
yellow = num2str(yellow);
lambda = num2str(lambda);
lambdaDelta = num2str(lambdaDelta);
yellowDelta = num2str(yellowDelta);

if ~exist("ParticipantMatchesRLM.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesRLM=table([], [], [], [], [], [], [], [], [],...
        'VariableNames',{'ParticipantCode', 'Trial', 'DateTime', 'Red', 'Green', ...
        'Yellow', 'Lambda', 'LambdaDelta', 'YellowDelta'});
else
    % Load Structure File
    load('ParticipantMatchesRLM.mat');
end

%% new participant results
newResults=table({ptptID}, str2num(trialNumber), CurrentDateAndTime, ... 
    str2num(red), str2num(green), str2num(yellow), str2num(lambda), str2num(lambdaDelta), str2num(yellowDelta),...
    'VariableNames',...
    {'ParticipantCode', 'Trial', 'DateTime', ... 
    'Red', 'Green', 'Yellow', 'Lambda', 'LambdaDelta', 'YellowDelta'});

%% new table
ParticipantMatchesRLM=[ParticipantMatchesRLM; newResults];

%% show and save file
save('ParticipantMatchesRLM', 'ParticipantMatchesRLM');
clear
