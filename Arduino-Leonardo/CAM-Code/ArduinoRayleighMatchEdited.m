function ptptID = ArduinoRayleighMatchEdited(taskNumber)

% Call structure of preset constants
constants = SetConstants;

%Loading and setting up the arduino device - Do not touch this code!
a = OpenArduinoPort;

% Asks for participant ID
ptptID = input('Participant Code: ', 's');

% Setup character capture.  Note that if you crash out of the program
% you need to execute ListenChar(0) before you can enter keys at keyboard 
% again.
ListenChar(2);
FlushEvents;

% Sets counter of number of completed trials
completedTrials = 0;

% Execution loop. Continues to loop until all trials have been completed.
while completedTrials < taskNumber

    % Displays current trial number
    disp(strjoin(["TRIAL", num2str(completedTrials + 1), "STARTING..."],' '));
    
    % type 1 = no adptation, type 2 = no light, type 3 = red adaptation, type 4
    % = green adaptation
    matchOrder = randperm(4);
    matchCount = 0;

    while matchCount < length(matchOrder)
        matchCount = matchCount + 1;
        matchType = matchOrder(matchCount);

        % Writes yellow value to device
        writeYellow(a, constants.yellowReferenceBrightness);
        pause(constants.referenceColourSeconds);
        writeYellow(a, 0);

        if matchType == 1
            disp("No adaptation")
        elseif matchType == 2
            disp("No light adaptation")
            pause(constants.adaptationSeconds);
        elseif matchType == 3
            disp("Red light adaptation");
            writeRGB(a, constants.redAdaptationBrightness, 0, 0);
            pause(constants.adaptationSeconds);
        elseif matchType == 4
            disp("Green light adaptation");
            writeRGB(a, 0, constants.greenAdaptationBrightness, 0);
            pause(constants.adaptationSeconds);
        end

        lambda = rand();                                % Initial lambda value
        lambdaDeltas = [0.05 0.02 0.005 0.001];         % Set of lambda deltas
        lambdaDeltaIndex = 1;                           % Delta index
        lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Current delta  

        subTrialCompleted = 0;

        disp("Now make a match!");
    
        while subTrialCompleted == 0

            [red, green] = SetRedAndGreen(lambda, constants.redAnchor, constants.greenAnchor);

            writeRGB(a, red, green, 0);

            % Waits for a key press
            [keyName, ~] = FindKeypress;

            % If the "=" key is pressed, completes the trial count so that the program saves and exits
            if strcmp(keyName,'=+')
                completedTrials = taskNumber;
                matchCount = length(matchOrder);
                subTrialCompleted = 1;
    
            % If the "a" key is pressed, increases lambda (the proportion of red in the red/green light)
            elseif strcmp(keyName,'a')
                lambda = lambda + lambdaDelta;
                % Stops lambda going over 1
                if (lambda > 1)
                    lambda = 1;
                end
            
            % If the "d" key is pressed, decreases lambda (the proportion of red in the red/green light)
            elseif strcmp(keyName,'d')
                lambda = lambda - lambdaDelta;
                % Stops lambda going below 0
                if (lambda < 0)
                    lambda = 0;
                end

            % If the "k" button is pressed, decreases lambda delta (the amount of
            % change in lambda that occurs with each key press, i.e. the step size)
            elseif strcmp(keyName,'k')
                lambdaDeltaIndex = lambdaDeltaIndex+1;
                % If already at the smallest step size, does not change
                if (lambdaDeltaIndex > length(lambdaDeltas))
                    lambdaDeltaIndex = length(lambdaDeltas);
                end
                lambdaDelta = lambdaDeltas(lambdaDeltaIndex);

            % If the "o" key is pressed, prints  the current light values in the
            % console without ending the trial
            elseif strcmp(keyName,'o')
                 fprintf('Lambda = %0.3f, Red = %d, Green = %d, Lambda delta = %0.3f\n', lambda, red, green, lambdaDelta); 

            % If the "i" key is pressed, resets the trial. This randomises the
            % lights and resets the step sizes back to the maximum value.
            elseif strcmp(keyName,'i')
                lambda = rand();                                % Lambda value
                lambdaDeltaIndex = 1;                           % Lambda step size
                lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Lambda delta
        
                fprintf('Lambda = %0.3f, Red = %d, Green = %d, Lambda delta = %0.3f\n', lambda, red, green, lambdaDelta); 
               
            % If the "return" or "enter" key is pressed, ends the trial
            elseif strcmp(keyName,'return')
        
                fprintf('Lambda = %0.3f, Red = %d, Green = %d, Lambda delta=  %0.3f\n', lambda, red, green, lambdaDelta); 
        
                subTrialCompleted = 1;
                
                % Informs the experimenter that the results will be saved
                disp("Saving results...");
                disp(" ");
        
                % Adds the results to "ParticipantMatchesRLM.mat"
                SaveRLMResults(ptptID, completedTrials + 1, red, green, lambda, lambdaDelta, matchType);
        
                % Adds 1 to the completed trials counter
                if matchCount == 4
                    completedTrials = completedTrials + 1;
                end
        
                % Turn off the test light
                writeRGB(a, 0, 0, 0);
        
            end
        end
    end
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;

end
