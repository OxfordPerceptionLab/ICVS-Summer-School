function ptptID = ArduinoBrightnessMatch(taskNumber)

%Loading and setting up the arduino - Do not touch this section!
a = OpenArduinoPort;

% Asks for participant ID
ptptID = input('Participant Code: ', 's');

% Asks for brightness value of reference light
% Will only move forward when a) a yellow value is entered, b) it is a number of class "double", 
% c) it is an integer, d) it is not less than 0, and e) it is not greater than 255
while ~exist("yellow", 'var') || ~isa(yellow, "double") || rem(yellow, 1) ~= 0 || yellow < 0 || yellow > 255
    yellow = input('Enter an integer 0-255 for the yellow reference light: ');
end

% Red/green parameters. Test colour is either red or green.
testColour = round(255 * rand());   % Initial brightness of the test colour
currentColour = "red";              % Keeps track of which colour we're testing
rgDeltas = [10 5 2 1];              % Set of lambda deltas
rgDeltaIndex = 1;                   % Delta index
rgDelta = rgDeltas(rgDeltaIndex);   % Current delta

% Setup character capture.  Note that if you crash out of the program
% you need to execute ListenChar(0) before you can enter keys at keyboard 
% again.
ListenChar(2);
FlushEvents;

% Sets counter of number of completed trials
completedTrials = 0;

% Displays current trial number
disp(strjoin(["TRIAL", num2str(completedTrials + 1), "STARTING..."],' '));

% Displays current test colour
disp(strjoin(["Current colour:", upper(currentColour)],' '));
    
% Tell user where we are
fprintf('Test colour = %d, Yellow = %d, Delta = %d\n', testColour, yellow, rgDelta); 

% Write the reference yellow brightness to the device
writeYellow(a,yellow);

% Execution loop. Continues to loop until all trials have been completed.
while completedTrials < taskNumber
    % Writes the brightness value to the correct LED
    if strcmp(currentColour, "red")
        writeRGB(a, testColour, 0, 0);
    elseif strcmp(currentColour, "green")
        writeRGB(a, 0, testColour, 0);
    end
    
    % Waits for a key press
    [keyName, ~] = FindKeypress;

    % If the "=" key is pressed, completes the trial count so that the program saves and exits
    if strcmp(keyName,'=+')
        completedTrials = taskNumber;
            
    % If the "w" key is pressed, increases the brightness of the current test colour
    elseif strcmp(keyName,'w')
        testColour = testColour + rgDelta;
        % Stops the brightness going over 255
        if (testColour > 255)
            testColour = 255;
        end

    % If the "s" key is pressed, decreases the brightness of the current test colour        
    elseif strcmp(keyName,'s')
        testColour = testColour - rgDelta;
        % Stops the brightness going below 0
        if (testColour < 0)
            testColour = 0;
        end    

    % If the "k" button is pressed, decreases the test light delta (the amount of
    % change in the test light that occurs with each key press, i.e. the step size)   
    elseif strcmp(keyName,'k')
        rgDeltaIndex = rgDeltaIndex+1;
        % If already at the smallest step size, does not change
        if (rgDeltaIndex > length(rgDeltas))
            rgDeltaIndex = length(rgDeltas);
        end
        rgDelta = rgDeltas(rgDeltaIndex);

    % If the "o" key is pressed, prints  the current light values in the
    % console without ending the trial
    elseif strcmp(keyName,'o')
        fprintf('Test colour = %d, Yellow = %d, Delta = %d\n', testColour, yellow, rgDelta); 

    % If the "i" key is pressed, resets the trial. This randomises the
    % test light and resets the step size back to the maximum value.
    elseif strcmp(keyName,'i')
        % Randomise the starting test light brightness
        testColour = round(255 * rand());

        % Reset the test light delta
        rgDeltaIndex = 1;
        rgDelta = rgDeltas(rgDeltaIndex);

        % Print the new starting values
        fprintf('Test colour = %d, Yellow = %d, Delta = %d\n', testColour, yellow, rgDelta); 

    % If the "return" or "enter" key is pressed, ends the trial       
    elseif strcmp(keyName,'return')

        % Prints the final values of the trial to the console
        fprintf('Test colour = %d, Yellow = %d, Delta = %d\n', testColour, yellow, rgDelta); 
        
        % Informs the experimenter that the results will be saved
        disp("Saving results...");

        % Adds the results to "ParticipantMatchesBRM.mat"
        SaveBRMResults(ptptID, completedTrials + 1, currentColour, testColour, yellow, rgDelta);

        % If the current test light is red, switch to green for the next
        % test. Doesn not end the trial.
        if strcmp(currentColour, "red")
            currentColour = "green";

        % If the current test light colour is green, switch to red and end
        % the trial.
        elseif strcmp(currentColour, "green")

            % Adds 1 to the completed trial count
            completedTrials = completedTrials + 1;

            % If this isn't the final trial...
            if completedTrials < taskNumber

                % Switch the test light colour to red
                currentColour = "red";

                % Display the new trial number
                disp(" ");
                disp(strjoin(["TRIAL", num2str(completedTrials + 1), "STARTING..."],' '));
            end
        end

        % If this isn't the final trial...
        if completedTrials < taskNumber

            % Display the current test light colour
            disp(strjoin(["Current colour:", upper(currentColour)],' '));

            % Randomise the starting test light brightness
            testColour = round(255 * rand());

            % Reset the test light delta
            rgDeltaIndex = 1;
            rgDelta = rgDeltas(rgDeltaIndex);

            % Print the new starting values
            fprintf('Test colour = %d, Yellow = %d, Delta = %d\n', testColour, yellow, rgDelta); 

            % Pause for .5 seconds
            pause(.5);
        end

    end
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;

end
