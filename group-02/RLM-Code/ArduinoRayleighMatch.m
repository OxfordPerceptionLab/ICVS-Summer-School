function ptptID = ArduinoRayleighMatch(taskNumber)

%Loading and setting up the arduino device - Do not touch this code!
a = OpenArduinoPort;

% Asks for participant ID
ptptID = input('Participant Code: ', 's');

% Yellow LED parameters
yellow = round(255 .* rand());                  % Initial yellow value
yellowDeltas = [25 10 5 1];                     % Set of yellow deltas
yellowDeltaIndex = 1;                           % Delta index    
yellowDelta = yellowDeltas(yellowDeltaIndex);   % Current yellow delta

% Red/green mixture parameters.  These get traded off in the
% mixture by a parameter lambda.
redAnchor = 50;                                 % Red value for lambda = 1
greenAnchor = 350;                              % Green value for lambda = 0
lambda = rand();                                % Initial lambda value
lambdaDeltas = [0.05 0.02 0.005 0.001];         % Set of lambda deltas
lambdaDeltaIndex = 1;                           % Delta index
lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Current delta

% Setup character capture.  Note that if you crash out of the program
% you need to execute ListenChar(0) before you can enter keys at keyboard 
% again.
ListenChar(2);
FlushEvents;

% Sets counter of number of completed trials
completedTrials = 0;

% Displays current trial number
disp(strjoin(["TRIAL", num2str(completedTrials + 1), "STARTING..."],' '));

% Set red and green values based on current lambda
[red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);
    
% Tell user where we are
fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n', lambda, red, green, yellow); 
fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta);

% Execution loop. Continues to loop until all trials have been completed.
while completedTrials < taskNumber
    % Sets red and green values based on current lambda
    [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);
    % Writes red and green values to device
    writeRGB(a, red, green, 0);
    % Writes yellow value to device
    writeYellow(a,yellow);

    % Waits for a key press
    [keyName, ~] = FindKeypress;

    % If the "=" key is pressed, completes the trial count so that the program saves and exits
    if strcmp(keyName,'=+')
        completedTrials = taskNumber;
    
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
      
    % If the "w" key is pressed, increases the brightness of the yellow light
    elseif strcmp(keyName,'w')
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

    % If the "k" button is pressed, decreases lambda delta (the amount of
    % change in lambda that occurs with each key press, i.e. the step size)
    elseif strcmp(keyName,'k')
        lambdaDeltaIndex = lambdaDeltaIndex+1;
        % If already at the smallest step size, does not change
        if (lambdaDeltaIndex > length(lambdaDeltas))
            lambdaDeltaIndex = length(lambdaDeltas);
        end
        lambdaDelta = lambdaDeltas(lambdaDeltaIndex);

    % If the "l" button is pressed, decreases yellow delta (the amount of
    % change in yellow that occurs with each key press, i.e. the step size)
    elseif strcmp(keyName,'l')
        yellowDeltaIndex = yellowDeltaIndex+1;
        % If already at the smallest step size, does not change
        if (yellowDeltaIndex > length(yellowDeltas))
            yellowDeltaIndex = length(lambdaDeltas);
        end        
        yellowDelta = yellowDeltas(yellowDeltaIndex);

    % If the "o" key is pressed, prints  the current light values in the
    % console without ending the trial
    elseif strcmp(keyName,'o')
        fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
        fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta); 

    % If the "i" key is pressed, resets the trial. This randomises the
    % lights and resets the step sizes back to the maximum value.
    elseif strcmp(keyName,'i')
        yellow = round(255 .* rand());                  % Yellow value
        lambda = rand();                                % Lambda value
        yellowDeltaIndex = 1;                           % Yellow step size
        yellowDelta = yellowDeltas(yellowDeltaIndex);   % Yellow delta
        lambdaDeltaIndex = 1;                           % Lambda step size
        lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Lambda delta

        % Prints the new light values
        fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
        fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta); 
       
    % If the "return" or "enter" key is pressed, ends the trial
    elseif strcmp(keyName,'return')

        % Adds 1 to the completed trials counter
        completedTrials = completedTrials + 1;

        % Prints final values of the trial in the console
        fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n', lambda, red, green, yellow); 
        fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta);
        
        % Informs the experimenter that the results will be saved
        disp("Saving results...");
        disp(" ");

        % Adds the results to "ParticipantMatchesRLM.mat"
        SaveRLMResults(ptptID, completedTrials, red, green, yellow, lambda, lambdaDelta, yellowDelta);

        % If this isn't the final trial, resets the values for the next trial
        if completedTrials < taskNumber
            yellow = round(255 .* rand());                  % Yellow value
            lambda = rand();                                % Lambda value
            yellowDeltaIndex = 1;                           % Yellow step size
            yellowDelta = yellowDeltas(yellowDeltaIndex);   % Yellow delta
            lambdaDeltaIndex = 1;                           % Lambda step size
            lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Lambda delta

            % Calculates red and green values based on lambda value 
            [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);  
    
            % Dsiplays current trial number
            disp(strjoin(["TRIAL", num2str(completedTrials + 1), "STARTING..."],' '));

            % Displays new trial's starting values
            fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n', lambda, red, green, yellow); 
            fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta); 

            % pauses the program for .5 seconds 
            % (helps prevent accidentally skipping trials by long-pressing the "return" key)
            pause(.5);
        end

    end
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;

end
