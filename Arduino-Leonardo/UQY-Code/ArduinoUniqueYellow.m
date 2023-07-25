function ptptID = ArduinoUniqueYellow(taskNumber)

%Loading and setting up the arduino device - Do not touch this code!
a = OpenArduinoPort;

% Asks for participant ID
ptptID = input('Participant Code: ', 's');

% Red/green mixture parameters.
red = round(255 * rand());          % Red value
green = round(255 * rand());        % green value
rgDeltas = [10 5 2 1];              % Set of rg deltas
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
    
% Tell user where we are
fprintf('Red = %d, Green = %d, R/G Ratio = %0.3f, Delta = %d\n', red, green, (red / green), rgDelta);

% Execution loop. Runs until all trials are completed.
while completedTrials < taskNumber

    % Writes red and green values to the device
    writeRGB(a, red, green, 0);
    
    % Waits for a key press
    [keyName, ~] = FindKeypress;

    % If the "=" key is pressed, completes the trial count so that the program saves and exits
    if strcmp(keyName,'=+')
        completedTrials = taskNumber;
    
    % If the "a" key is pressed, increases the brightness of the red light
    elseif strcmp(keyName,'a')
        red = red + rgDelta;
        % Stops red going over 255
        if (red > 255)
            red = 255;
        end

    % If the "d" key is pressed, decreases the brightness of the red light
    elseif strcmp(keyName,'d')
        red = red - rgDelta;
        % Stops red going below 0
        if (red < 0)
            red = 0;
        end

    % If the "w" key is pressed, increases the brightness of the green light
    elseif strcmp(keyName,'w')
        green = green + rgDelta;
        % Stops green going over 255
        if (green > 255)
            green = 255;
        end

    % If the "s" key is pressed, decreases the brightness of the green light   
    elseif strcmp(keyName,'s')
        green = green - rgDelta;
        % Stops green going below 0
        if (green < 0)
            green = 0;
        end
        
    % If the "k" button is pressed, decreases rg delta (the amount of
    % change in red & green that occurs with each key press, i.e. the step size)
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
        fprintf('Red = %d, Green = %d, R/G Ratio = %0.3f, Delta = %d\n', red, green, (red / green), rgDelta);

    % If the "i" key is pressed, resets the trial. This randomises the
    % lights and resets the step size back to the maximum value.
    elseif strcmp(keyName,'i')
        % Randomise the starting red and green values for the next trial
        red = round(255 * rand());
        green = round(255 * rand());

        % Resets the step size
        rgDeltaIndex = 1;
        rgDelta = rgDeltas(rgDeltaIndex);

        % Displays the starting values for the new trial
        fprintf('Red = %d, Green = %d, R/G Ratio = %0.3f, Delta = %d\n', red, green, (red / green), rgDelta);
       
    % If the "return" or "enter" key is pressed, ends the trial      
    elseif strcmp(keyName,'return')
        % Adds 1 to the completed trials counter
        completedTrials = completedTrials + 1;

        % Prints final values of the trial in the console
        fprintf('Red = %d, Green = %d, R/G Ratio = %0.3f, Delta = %d\n', red, green, (red / green), rgDelta);
        
        % Informs the experimenter that the results will be saved
        disp("Saving results...");
        disp(" ");

        % Adds the results to "ParticipantMatchesUQY.mat"
        SaveUQYResults(ptptID, completedTrials, red, green, rgDelta);

        % If this isn't the last trial...
        if completedTrials < taskNumber

            % Display the current trial number
            disp(strjoin(["TRIAL", num2str(completedTrials + 1), "STARTING..."],' '));

            % Randomise the starting red and green values for the next trial
            red = round(255 * rand());
            green = round(255 * rand());

            % Resets the step size
            rgDeltaIndex = 1;
            rgDelta = rgDeltas(rgDeltaIndex);

            % Displays the starting values for the new trial
            fprintf('Red = %d, Green = %d, R/G Ratio = %0.3f, Delta = %d\n', red, green, (red / green), rgDelta);
            
            % Pauses for .5 seconds
            pause(.5);
        end

    end
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;

end
