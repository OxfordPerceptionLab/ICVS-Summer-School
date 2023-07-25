Code to run several types of colour vision tasks on the Arduino Leonardo device.

Required Programs:
- MATLAB (tested for version R2023a)
- Psychtoolbox-3 (tested for version 3.0.19)
- 64-Bit GStreamer (tested for version 1.20.5)
- MATLAB Support Package for Arduino hardware (tested for version 23.1.0)
- HFP only: Arduino IDE (tested for version 1.8.19)

Any of these tasks can be used using the command: RunColourVisionStudy('code', trial_number) from the main folder in MATLAB, e.g. RunColourVisionStudy('HFP', 8).
	
NOTE: FlickeringLight.ino should be uploaded to the device using Arduino IDE before running the HFP task!
		You can switch from HFP to another task by using the RunColourVisionStudy command as usual. The board will be updated, then an error will occur.
		Re-run the new task code and it should work fine without errors. This will take a few minutes total.

Current available tasks:

RLM: Rayleigh match task. The mixture of red and green light can be modified, as well as the brightness of the reference yellow light.
	Participants should be instructed to modify these lights until they look perceptually identical.

HFP: Heterochromatic Flicker Photometry task. The red and green lights flicker in counterbalance - the brightness of the red light can be modified.
	Participants should be instructed to modify the brightness of the red light until the light looks "stable" or non-flickering.

BRM: Brightness match task. The yellow reference light is set, then a test light (either red or green) will be modifiable.
	Participants should be instructed to modify the test light until the test light and reference light have perceptually equal brightness.
	For each trial, the test light will initially be red, then will switch to green for a second match after the red match is completed.

UQY: Unique yellow task. The red and green lights can be increased and decreased in brightness, independent of each other.
	Participants should be instructed to adjust the brightness of the red and green lights intol the resulting light is a "pure" yellow with no red or green percieved.
