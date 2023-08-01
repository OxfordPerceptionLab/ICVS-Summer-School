function SaveRLMResultsEdited(ptptID, completedTrials, red, green, lambda, lambdaDelta, matchType)
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

if matchType == 1
    adaptationType = "None";
elseif matchType == 2
    adaptationType = "No light";
elseif matchType == 3
    adaptationType = "Red light";
elseif matchType == 4
    adaptationType = "Green light";
end

if ~exist("ParticipantMatchesRLM.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesRLM=table([], [], [], [], [], [], [], [],...
        'VariableNames',{'ParticipantCode', 'Trial', 'DateTime', 'Red', 'Green', ...
        'Lambda', 'LambdaDelta', 'AdaptationType'});
else
    % Load Structure File
    load('ParticipantMatchesRLM.mat');
end

%% new participant results
newResults=table({ptptID}, str2num(completedTrials), CurrentDateAndTime, ... 
    str2num(red), str2num(green), str2num(lambda), str2num(lambdaDelta), {adaptationType},...
    'VariableNames',...
    {'ParticipantCode', 'Trial', 'DateTime', ... 
    'Red', 'Green', 'Lambda', 'LambdaDelta', 'AdaptationType'});

%% new table
ParticipantMatchesRLM=[ParticipantMatchesRLM; newResults];

%% show and save file
save('ParticipantMatchesRLM', 'ParticipantMatchesRLM');
clear
