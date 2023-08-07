function ptptID = ArduinoRayleighMatch(taskNumber)

% Clear everything before starting program
delete(instrfindall)
clearvars -except taskNumber;

% Loading and setting up the arduino device - Do not touch this code!
a = OpenArduinoPort;
disp(" ");

% Reset lights
writeRGB(a,0,0,0);
writeYellow(a,0);

% Asks for participant ID
ListenChar(0);
ptptID = input('Participant Code: ', 's');
disp(" ");
ListenChar(2);
FlushEvents;

% Red/green mixture parameters.  These get traded off in the
% mixture by a parameter lambda.
redAnchor = 50;                                 % Red value for lambda = 1
greenAnchor = 350;                              % Green value for lambda = 0
lambdaDeltas = [0.05 0.02 0.005];               % Set of lambda deltas
% Yellow LED parameters
yellowDeltas = [15 5 1];                        % Set of yellow deltas

% Accepted confidence ratings
acceptedConfidenceRatings = 1:4;

% Sets counter of number of completed trials
trialNumber = 0;

% Execution loop. Continues to loop until all trials have been completed.
while trialNumber < taskNumber

    trialNumber = trialNumber + 1;

    matchType = 0;

    % Displays current trial number
    disp(strjoin(["TRIAL", num2str(trialNumber), "STARTING..."],' '));

    while matchType < 3

        pause(.5);

        matchType = matchType + 1;

        switch matchType
            case 1
                lambda = rand();                                % Lambda value
                lambdaDeltaIndex = 1;                           % Lambda step size
                lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Lambda delta
                yellow = round(255 .* rand());                  % Yellow value
                yellowDeltaIndex = 1;                           % Yellow step size
                yellowDelta = yellowDeltas(yellowDeltaIndex);   % Yellow delta

                disp(" ");
                fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
                fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta);
                disp(" ");
                disp("Make your best match!");
            
            case 2
                bestLambda = lambda;                            % Saves best match lambda value to re-use in matchType 3
                lambdaDeltaIndex = length(lambdaDeltas);        % Makes the lambda delta the smallest available value
                lambdaDelta = lambdaDeltas(lambdaDeltaIndex);
                disp("Now add red until the lights no longer match!");
            
            case 3
                lambda = bestLambda;                            % Reinstates the lambda value of the best match
                disp("Now add green until the lights no longer match!");
        end

        subTrialCompleted = 0;

        while subTrialCompleted == 0

            % Sets red and green values based on current lambda
            [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);
            % Writes red and green values to device
            writeRGB(a, red, green, 0);
            % Writes yellow value to device
            writeYellow(a, yellow);
        
            % Waits for a key press
            [keyName, ~] = FindKeypress;
        
            switch keyName
                % If the "=" key is pressed, completes the trial count so that the program saves and exits
                case '=+'
                    trialNumber = taskNumber;
                    matchType = 3;
                    subTrialCompleted = 1;
                
                % If the "a" key is pressed, increases lambda (the proportion of red in the red/green light)
                case 'a'
                    lambda = lambda + lambdaDelta;
                    % Stops lambda going over 1
                    if (lambda > 1)
                        lambda = 1;
                    end
                
                % If the "d" key is pressed, decreases lambda (the proportion of red in the red/green light)
                case 'd'
                    lambda = lambda - lambdaDelta;
                    % Stops lambda going below 0
                    if (lambda < 0)
                        lambda = 0;
                    end
                  
                % If the "w" key is pressed, increases the brightness of the yellow light
                case 'w'
                    if matchType == 1
                        yellow = round(yellow+yellowDelta);
                        % Stops yellow going over 255
                        if (yellow > 255)
                            yellow = 255;
                        end
                    end
            
                % If the "s" key is pressed, decreases the brightness of the yellow light
                case 's'
                    if matchType == 1
                        yellow = round(yellow-yellowDelta);
                        % Stops yellow going below 0
                        if (yellow < 0)
                            yellow = 0;
                        end
                    end
            
                % If the "k" button is pressed, decreases lambda delta (the amount of
                % change in lambda that occurs with each key press, i.e. the step size)
                case 'k'
                    lambdaDeltaIndex = lambdaDeltaIndex+1;
                    % If already at the smallest step size, does not change
                    if (lambdaDeltaIndex > length(lambdaDeltas))
                        lambdaDeltaIndex = length(lambdaDeltas);
                    end
                    lambdaDelta = lambdaDeltas(lambdaDeltaIndex);
            
                % If the "l" button is pressed, decreases yellow delta (the amount of
                % change in yellow that occurs with each key press, i.e. the step size)
                case 'l'
                    if matchType == 1
                        yellowDeltaIndex = yellowDeltaIndex+1;
                        % If already at the smallest step size, does not change
                        if (yellowDeltaIndex > length(yellowDeltas))
                            yellowDeltaIndex = length(lambdaDeltas);
                        end        
                        yellowDelta = yellowDeltas(yellowDeltaIndex);
                    end
            
                % If the "o" key is pressed, prints  the current light values in the
                % console without ending the trial
                case 'o'
                    fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
                    fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta); 
            
                % If the "i" key is pressed, resets the trial. This randomises the
                % lights and resets the step sizes back to the maximum value.
                case 'i'
                    if matchType == 1
                        lambda = rand();                                % Lambda value
                        lambdaDeltaIndex = 1;                           % Lambda step size
                        lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Lambda delta
                        yellow = round(255 .* rand());                  % Yellow value
                        yellowDeltaIndex = 1;                           % Yellow step size
                        yellowDelta = yellowDeltas(yellowDeltaIndex);   % Yellow delta
                
                        % Prints the new light values
                        fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
                        fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta); 
                    end
                   
                % If the "return" or "enter" key is pressed, ends the trial
                case 'return'
            
                    % Prints final values of the trial in the console
                    fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n', lambda, red, green, yellow); 
                    fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta);

                    % Confidence rating
                    % Opens responses in console
                    ListenChar(0);
                    % Loops until a valid value in entered for the confidence rating
                    confidenceRating = NaN;
                    while ~ismember(confidenceRating, acceptedConfidenceRatings)
                            confidenceRating = input("Rate your confidence 1-4: ");
                    end
                    % Closes responses in console
                    ListenChar(2);
                    
                    % Informs the experimenter that the results will be saved
                    disp("Saving results...");
                    disp(" ");
            
                    % Adds the results to "ParticipantMatchesRLM.mat"
                    SaveRLMResults(ptptID, trialNumber, matchType, red, green, yellow, lambda, lambdaDelta, yellowDelta, confidenceRating);
    
                    % Sets subTrialCompleted to 1 to move on to the next trial
                    subTrialCompleted = 1;
            end
        end
    end
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;

end
