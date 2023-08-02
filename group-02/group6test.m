%group 5 project
% set a R-G ratio, and then ppt controls y luminance
% ask ppt if they can make a match
% if so, record R-G ratio as within acceptable range, report y value
% if not, record as out of range, also report y. 
% if out of range, this leads to a decrease in the staircase value
% if within range, staircase value needs to be increased until out of range
% randomise this between R-biased and G-biased staircases until thresholds
% for both are found.
% then check a periodic step within the range to ensure that matches are
% continuous across the found range

%% housekeeping
clear
a = OpenArduinoPort;

% Asks for participant ID
ptptID = input('Participant Code: ', 's');

yellowDeltas = [25 10 5 1];                     % Set of yellow deltas
yellowDeltaIndex = 1;                           % Delta index    
yellowDelta = yellowDeltas(yellowDeltaIndex);   % Current yellow delta

redAnchor = 50;                                 % Red value for lambda = 1
greenAnchor = 350;                              % Green value for lambda = 0
lambda = rand();                                % Initial lambda value
lambdaDeltas = [0.05 0.02 0.005 0.001];         % Set of lambda deltas
lambdaDeltaIndex = 1;                           % Delta index
lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Current delta

ListenChar(2);
FlushEvents;

%%


if ~exist([pwd,'/',ptptID,'_initLambda.mat'])
    initLambda = ArduinoRayleighMatch_group6(3,a,ptptID);
    initLambda = mean(initLambda);
    save([pwd,'/',ptptID,'_initLambda.mat'],'initLambda')
else
    load([pwd,'/',ptptID,'_initLambda.mat'])
end

ListenChar(2);

%%

%initalise staircase
stop = zeros(2,1);
NumTrials = 80;
grain = 101;
step = 1000;
PF = @PAL_Gumbel;
% GstimRange = initLambda:-1/step:0;
% RstimRange = (1-initLambda):-1/step:0;

GstimRange = 1:step;
RstimRange = 1:step;

outOfThreshold = zeros(2,NumTrials);

priorAlphaRange = linspace(0,step,grain);
priorBetaRange =  linspace(log10(.0625),log10(10),grain);
priorGammaRange = 0.5;
priorLambdaRange = .02;

%"too green"
PM(1) = PAL_AMPM_setupPM('priorAlphaRange',priorAlphaRange,...
                      'priorBetaRange',priorBetaRange,...
                      'priorGammaRange',priorGammaRange,...
                      'priorLambdaRange',priorLambdaRange,...
                      'numtrials',NumTrials,...
                      'PF' , PF,...
                      'stimRange',GstimRange); 
PM(1).xCurrent = step;
PM(1).x = step;
% "too red"
PM(2) = PAL_AMPM_setupPM('priorAlphaRange',priorAlphaRange,...
                      'priorBetaRange',priorBetaRange,...
                      'priorGammaRange',priorGammaRange,...
                      'priorLambdaRange',priorLambdaRange,...
                      'numtrials',NumTrials,...
                      'PF' , PF,...
                      'stimRange',RstimRange); 
PM(2).xCurrent = step;
PM(2).x = step;

trial_cnt = ones(2,1);
while(~(sum(stop)==2))
    randDir = randperm(2);
    for direction = randDir
        if PM(direction).stop ==0
            noMatch = 1;
            if direction == 1
                lambda = initLambda - (PM(direction).xCurrent/step)/initLambda; 
            else
                lambda = ((PM(direction).xCurrent/step)*(1-initLambda)) + initLambda; 
            end

            yellow = round(255 .* rand());                  % Initial yellow value
            [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);
            % Writes red and green values to device
            writeRGB(a, red, green, 0);
            % Writes yellow value to device
            while noMatch
                writeYellow(a,yellow);
        
                [keyName, ~] = FindKeypress;
        
        
                % If the "w" key is pressed, increases the brightness of the yellow light
                if strcmp(keyName,'w')
                    yellow = round(yellow+yellowDelta);
                    % Stops yellow going over 255
                    if (yellow > 255)
                        yellow = 255;
                    end
            
                % If the "s" key is pressed, decreases the brightness of the yellow light
                elseif strcmp(keyName,'s')
                    yellow = round(yellow-yellowDelta);
                    % Stops yellow going below 0
                    if (yellow < 0)
                        yellow = 0;
                    end
        
                elseif strcmp(keyName,'l')
                    yellowDeltaIndex = yellowDeltaIndex+1;
                    % If already at the smallest step size, does not change
                    if (yellowDeltaIndex > length(yellowDeltas))
                        yellowDeltaIndex = length(lambdaDeltas);
                    end        
                    yellowDelta = yellowDeltas(yellowDeltaIndex);
    
                elseif strcmp(keyName,'o') % o = 'too green'
                    if direction == 1
                        noMatch = 0;
                        outOfThreshold(direction,trial_cnt(direction)) = 1;
                        %update staircase - fail
                        PM(direction) = PAL_AMPM_updatePM(PM(direction), outOfThreshold(direction,trial_cnt(direction))); %update PM structure
                    else
                        noMatch = 0;
                        outOfThreshold(direction,trial_cnt(direction)) = 0;
                        %update staircase - success
                        PM(direction) = PAL_AMPM_updatePM(PM(direction), outOfThreshold(direction,trial_cnt(direction))); %update PM structure
                    end
                elseif strcmp(keyName,'p') % p = 'too red'
                    if direction == 1
                        noMatch = 0;
                        outOfThreshold(direction,trial_cnt(direction)) = 0;
                        %update staircase - success
                        PM(direction) = PAL_AMPM_updatePM(PM(direction), outOfThreshold(direction,trial_cnt(direction))); %update PM structure
                    else
                        noMatch = 0;
                        outOfThreshold(direction,trial_cnt(direction)) = 1;
                        %update staircase - fail
                        PM(direction) = PAL_AMPM_updatePM(PM(direction), outOfThreshold(direction,trial_cnt(direction))); %update PM structure
                    end
                end
                if trial_cnt(direction) > 10 && mean(PM(direction).seThreshold(trial_cnt(direction)-5:trial_cnt(direction)-1)) < 2
                    PM(direction).stop = 1;
                    stop(direction) = 1;
                end
            end    
        end
        trial_cnt(direction) = trial_cnt(direction)+1;
    end
end