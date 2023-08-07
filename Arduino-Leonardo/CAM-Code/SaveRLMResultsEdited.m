function SaveRLMResultsEdited(ptptID, completedTrials, red, green, lambda, lambdaDelta, matchType, timeTaken)
%This code creates structure variable "ParticipantMatches"

%'ParticipantCode' is the code of each participant ('rp_001', 'rp_002', etc.)

%'DateTime' represents date and time of the end of the experiment

%'RedValue', 'GreenValue', 'YellowValue', represent the intensity (in 
%bytes, 0-255) of Red, Green, and Yellow light

%% record current date and time
CurrentDateAndTime=round(clock);

red = num2str(red);
green = num2str(green);
lambda = num2str(lambda);
lambdaDelta = num2str(lambdaDelta);
completedTrials = num2str(completedTrials);
timeTaken = num2str(timeTaken);

if matchType == 1
    adaptationType = 'None';
elseif matchType == 2
    adaptationType = 'No light';
elseif matchType == 3
    adaptationType = 'Red light';
elseif matchType == 4
    adaptationType = 'Green light';
end

if ~exist("ParticipantMatchesCAM.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesCAM=table([], [], [], [], [], [], [], [], [],...
        'VariableNames',{'ParticipantCode', 'Trial', 'DateTime', 'Red', 'Green', ...
        'Lambda', 'LambdaDelta', 'AdaptationType', 'TimeTaken'});
else
    % Load Structure File
    load('ParticipantMatchesCAM.mat');
end

%% new participant results
newResults=table({ptptID}, str2num(completedTrials), CurrentDateAndTime, ... 
    str2num(red), str2num(green), str2num(lambda), str2num(lambdaDelta), {adaptationType}, str2num(timeTaken),...
    'VariableNames',...
    {'ParticipantCode', 'Trial', 'DateTime',... 
    'Red', 'Green', 'Lambda', 'LambdaDelta', 'AdaptationType', 'TimeTaken'});

%% new table
ParticipantMatchesCAM=[ParticipantMatchesCAM; newResults];

%% show and save file
save('ParticipantMatchesCAM', 'ParticipantMatchesCAM');
clear
