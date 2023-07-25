% if the code doesn't work, check that the arduino port (written in
% ConstantsHFP) is the right one (for windows, check Device Manager->ports)

function ptptID = ArduinoHeterochromaticFlickerPhotometry(taskNumber)

% Clear everything before starting program
delete(instrfindall)
clearvars -except taskNumber;

% Call arduino object
serialObj=serialport(ConstantsHFP.serialPort, 9600);

% Create variables
completedTrials = 0;

% Turn off character capture
ListenChar(0);

% Ask to enter participant ID
ptptID = input('Participant Code: ', 's');

% Turn on character capture
ListenChar(2);

% Set constants
increaseInputs={'q', 'w', 'e'};     % Key codes for increasing the red light that the arduino can read
decreaseInputs={'r', 't', 'y'};     % Key codes for decreasing the red light that the arduino can read
deltaIndex = 1;                     % Red light delta
rDeltas = [20, 5, 1];               % Red light step sizes

% Loops until all trials have been completed
while completedTrials < taskNumber
    
    % Open the arduino device
    fopen(serialObj);

    % Display the current trial
    disp(strjoin(["TRIAL", num2str(completedTrials + 1), "STARTING..."],' '));
    
    % Send character "i" to the device, which randomises the red light
    fprintf(serialObj, 'i');

    % Red the initial red and green values from the device
    % Note! The green light is defaulted to 128 in the Arduino code
    rValinit=read(serialObj, 6, "char");
    gValinit=read(serialObj, 6, "char");

    % Store the initial values as the correct numbers
    rValinit = str2num(rValinit) - 100;
    gValinit = str2num(gValinit) - 100;

    % Print the initial red and green values
    fprintf("Initial Red Value = %d, Initial Green Value = %d, Red Delta Value = %d \n", rValinit, gValinit, rDeltas(deltaIndex));

    % pause the program for .5 seconds
    pause(.5)

    % Sets goToNextTrial as 0. The next trial will only start when this changes to a 1.
    goToNextTrial = 0;

    % Trial loop: will loop until next trial starts
    while goToNextTrial == 0

    % Waits for a key press
    [keyName, ~] = FindKeypress;

        % If the "=" key is pressed, completes the trial count and goes to the next trial 
        % so that the program saves and exits
        if strcmp(keyName,'=+')
            completedTrials = taskNumber;
            goToNextTrial = 1;

        % If the "a" key is pressed, increases the red value based on the
        % current delta
        elseif strcmp(keyName,'a')
            arduinoInput = increaseInputs{deltaIndex};
            % Sends increase in red value to device
            fprintf(serialObj, arduinoInput);

        % If the "d" key is pressed, decreases the red value based on the
        % current delta
        elseif strcmp(keyName,'d')
            arduinoInput = decreaseInputs{deltaIndex};
            % Sends decrease in red delta to the device
            fprintf(serialObj, arduinoInput);
            
        % If the "k" button is pressed, decreases red delta (the amount of
        % change in red that occurs with each key press, i.e. the step size)
        elseif strcmp(keyName,'k')
            deltaIndex = deltaIndex + 1;
            % If already at the smallest step size, does not change
            if deltaIndex > length(rDeltas)
                deltaIndex = length(rDeltas);
            end

        % If the "o" key is pressed, sends an 'o' character to the device.
        % This tells the device to send all the current values to MATLAB.
        elseif strcmp(keyName,'o')
            % Sends the 'o' character to the device
            fprintf(serialObj, 'o');

            % Reads the current red and green values from the device
            rVal=read(serialObj, 6, "char");
            gVal=read(serialObj, 6, "char");

            % Stores these values as the correct numbers
            rVal = str2num(rVal) - 100;
            gVal = str2num(gVal) - 100;

            % Prints the current red, green, & delta values in the console
            fprintf("Current Red Value = %d, Current Green Value = %d, Red Delta Value = %d \n", rVal, gVal, rDeltas(deltaIndex));

        % If the "i" key is pressed, resets the trial. This randomises the
        % red light and resets the step size back to the maximum value.
        elseif strcmp(keyName, 'i')
            % Send character "i" to the device, which randomises the red light
            fprintf(serialObj, 'i');
        
            % Red the initial red and green values from the device
            rValinit=read(serialObj, 6, "char");
            gValinit=read(serialObj, 6, "char");
        
            % Store the initial values as the correct numbers
            rValinit = str2num(rValinit) - 100;
            gValinit = str2num(gValinit) - 100;
        
            % Print the initial red and green values
            fprintf("Initial Red Value = %d, Initial Green Value = %d, Red Delta Value = %d \n", rValinit, gValinit, rDeltas(deltaIndex));

        % If the "return" or "enter" key is pressed, ends the trial
        elseif strcmp(keyName,'return')

            % Adds 1 to the completed trial counter
            completedTrials = completedTrials + 1;
            
            % Tells the user that the results are being processed
            disp("Printing final results... please wait");

            % Sends a 'u' character to the device, which tells it to send
            % all the values to MATLAB and re-randomise the red value for
            % the next trial
            fprintf(serialObj, 'u');
 
            % Reads the initial and final red and green values from the device
            rValinit=read(serialObj, 6, "char");
            rVal=read(serialObj, 6, "char");
            gValinit=read(serialObj, 6, "char");
            gVal=read(serialObj, 6, "char");

            % Stores these values as the correct numbers
            rValinit = str2num(rValinit) - 100;
            rVal = str2num(rVal) - 100;
            gValinit = str2num(gValinit) - 100;
            gVal = str2num(gVal) - 100;

            % Prints the final values in the console
            fprintf("Final Red Value = %d, Final Green Value = %d, Red Delta Value = %d \n", rVal, gVal, rDeltas(deltaIndex));
            disp(" ");

            % Saves the resulte to "ParticipantMatchesHFP.mat"
            SaveHFPResults(ptptID, completedTrials, rVal, gVal, rValinit, gValinit, rDeltas(deltaIndex));

            % Resets the delta value
            deltaIndex = 1;

            % Tells MATLAB to go to the next trial
            goToNextTrial = 1;
        end
    end
end

% Clear devices
delete(instrfindall);

% Turn off character capture.
ListenChar(0)

end
