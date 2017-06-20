test = ForcedChoice2('/dev/cu.usbmodem621');
test = ForcedChoice2('COM10');
test = ForcedChoice2('COM3');
num_trials = 800;
coherence_difficulty = 0.01;


Day1 = task(test,num_trials,coherence_difficulty);
Day1.run_day()