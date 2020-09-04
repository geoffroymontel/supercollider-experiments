~bcf = BCF2000Mixer.new(s, 8, 1);
~looper = GMultiGranularizer.new(4, [0, 2, 4, 6] + ~bcf.inBuses[0].index);
