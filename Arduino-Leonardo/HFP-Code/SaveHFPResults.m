function SaveHFPResults(PPcode, trialNumber, matchType, red, green, redInit, greenInit, rDelta, confidenceRating)
%This code creates structure variable "ParticipantMatches"

%'ParticipantCode' is the code of each participant ('rp_001', 'rp_002', etc.)

%'DateTime' represents date and time of the end of the experiment

%'RedValue', 'GreenValue', 'YellowValue', represent the intensity (in 
%bytes, 0-255) of Red, Green, and Yellow light

%% record current date and time
CurrentDateAndTime=round(clock);

varNames = {'ParticipantCode', 'Trial', 'MatchType', 'DateTime', 'RedValue', 'GreenValue', ...
        'InitialRedSetting', 'InitialGreenSetting', 'RedDelta', 'ConfidenceRating'};

if matchType == 1
    matchName = 'Best';
elseif matchType == 2
    matchName = 'MaxRed';
elseif matchType == 3
    matchName = 'MinRed';
end

if ~exist("ParticipantMatchesHFP.mat", 'file')
    % create new table if one doesn't exist
    ParticipantMatchesHFP=table.empty(0,length(varNames));
    ParticipantMatchesHFP.Properties.VariableNames = varNames;
else
    % Load Structure File
    load('ParticipantMatchesHFP.mat');
end

%% new participant results
newResults=table({PPcode}, trialNumber, {matchName}, CurrentDateAndTime, ...
    red, green, redInit, greenInit, rDelta, confidenceRating,... 
    'VariableNames', varNames);

%% new table
ParticipantMatchesHFP=[ParticipantMatchesHFP; newResults];

%% show and save file
save('ParticipantMatchesHFP', 'ParticipantMatchesHFP');
clear;

end
