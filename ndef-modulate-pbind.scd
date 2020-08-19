Pbind(
	\freq, Ndef(\freqPara, {
		LFDNoise3.kr(1).range(200, 600);
	}),
	\dur, 1
).play;
