function SaveRLMResults(ptptID, trialNumber, matchType, red, green, yellow, lambda, lambdaDelta, yellowDelta, confidenceRating)
%This code creates structure variable "ParticipantMatches"

%'ParticipantCode' is the code of each participant ('rp_001', 'rp_002', etc.)

%'DateTime' represents date and time of the end of the experiment

%'RedValue', 'GreenValue', 'YellowValue', represent the intensity (in 
%bytes, 0-255) of Red, Green, and Yellow light

%% record current date and time
CurrentDateAndTime=round(clock);

varNames = {'ParticipantCode', 'Trial', 'MatchType', 'DateTime', 'Red', 'Green', ...
        'Yellow', 'Lambda', 'LambdaDelta', 'YellowDelta', 'ConfidenceRating'};

if matchType == 1
    matchName = 'Best';
elseif matchType == 2
    matchName = 'MaxLambda';
elseif matchType == 3
    matchName = 'MinLambda';
end

if ~exist("ParticipantMatchesRLM.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesRLM=table.empty(0,length(varNames));
    ParticipantMatchesRLM.Properties.VariableNames = varNames;
else
    % Load Structure File
    load('ParticipantMatchesRLM.mat');
end

%% new participant results
newResults=table({ptptID}, trialNumber, {matchName}, CurrentDateAndTime, ... 
    red, green, yellow, lambda, lambdaDelta, yellowDelta, confidenceRating,...
    'VariableNames', varNames);

%% new table
ParticipantMatchesRLM=[ParticipantMatchesRLM; newResults];

%% show and save file
save('ParticipantMatchesRLM', 'ParticipantMatchesRLM');
clear;
