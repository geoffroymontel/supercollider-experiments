// https://scsynth.org/t/the-fm7-appreciation-thread/3186

~fm7SynthNames = 32.collect{|algoNum| "fm7algo%".format(algoNum).asSymbol};

~fm7SynthNames.do{|synthName, algo|
	SynthDef(synthName, {|out=0, dur=0.01, sustain=0, freqScale=0.5, spread=0.25, pan=0, feedback=1.0, amp=0.5|
		var env = Env.perc.kr(gate:1, timeScale: dur * (1+sustain), doneAction: Done.freeSelf);
		var ctls =
		[
			// freq, phase, amp
			[freqScale * 300, pi.rand, 1],
			[freqScale * 2500, pi.rand, 1],
			[freqScale * SinOsc.ar(Rand(0.1,10.0)).exprange(3,100), 0, 1],
			[freqScale * LFNoise2.ar(10).exprange(1300,0.5), 0, 1],
			[freqScale * ExpRand(30,1500), pi.rand, 1],
			[freqScale * ExpRand(30,500), pi.rand, 1]
		];

		var sig = FM7.arAlgo(algo, ctls , feedback * 2.0);
		sig = Splay.ar(sig, spread: spread, center: pan);
		sig = sig * env * amp;

		Out.ar(out, sig);
	}).add;
};

(
Pbind(
	\instrument, Pshuf(~fm7SynthNames, inf).trace,
	\dur, Pwhite(0.01,0.125)*8*4,
	\sustain, Pwhite(0.0,1.0),
	\feedback, Pshuf(Array.rand(8, 0.25,1.0),inf),
	\freqScale, Pxrand(Array.rand(8, 0.25,4.0),inf),
	\amp, Pwhite(0.125,0.5),
	\spread, Pwhite(0.0,1.0),
	\pan, Pwhite(-1.0,1.0)
).play;
)