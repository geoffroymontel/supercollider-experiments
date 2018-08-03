(
~numberOfPlayers = 10;
~tempo = 120/60;
~minPatternDuration = 5;
~maxPatternDuration = 25;
TempoClock.default.tempo = ~tempo;

~durationToBeats = { |duration|
	duration * ~tempo;
};

~patterns = [
	// 1
	Pbind(*[note: Pseq([0,4], 3), dur: Pseq([0.1, 0.9], 3), octave: 5]),
	// 2
	Pbind(*[note: Pseq([0,4,5,4], 1), dur: Pseq([0.1, 0.45, 0.45, 1], 1), octave: 5]),
	// 3
	Pbind(*[note: Pseq([Rest(),4,5,4], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5], 1), octave: 5]),
	// 4
	Pbind(*[note: Pseq([Rest(),4,5,7], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5], 1), octave: 5]),
	// 5
	Pbind(*[note: Pseq([4,5,7,Rest()], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5], 1), octave: 5]),
	// 6
	Pbind(*[note: 0, dur: Pwhite(4,20,1), octave: 6]),
	// 7
	Pbind(*[note: Pseq([Rest(),0,0,0,Rest()], 1), dur: Pseq([3.5, 0.25, 0.25, 0.5, 4.5], 1), octave: 5]),
	// 8
	Pbind(*[note: Pseq([7,5], 1), dur: Pseq([3, Pwhite(4,20,1)], 1), octave: 5]),
	//9
	Pbind(*[note: Pseq([11,7, Rest()], 1), dur: Pseq([0.25, 0.25, 3.5], 1), octave: 5]),
	//10
	Pbind(*[note: Pseq([11,7], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
	//11
	Pbind(*[note: Pseq([5, 7, 11, 7, 11, 7], 1), dur: Pseq([0.25], 6), octave: 5]),
	//12
	Pbind(*[note: Pseq([5, 7, 11, 12], 1), dur: Pseq([0.5, 0.5, 4, 1], 1), octave: 5]),
	//13
	Pbind(*[note: Pseq([11, 7, 7, 5, 7, Rest(), 7], 1), dur: Pseq([0.25, 0.75, 0.25, 0.25, 0.5, 0.75, 3.25], 1), octave: 5]),
	//14
	Pbind(*[note: Pseq([12, 11, 7, 6], 1), dur: Pseq([4], 4), octave: 5]),
	//15
	Pbind(*[note: Pseq([7, Rest()], 1), dur: Pseq([0.25,3.75], 1), octave: 5]),
	//16
	Pbind(*[note: Pseq([7, 11, 12, 7], 1), dur: Pseq([0.25], 4), octave: 5]),
	//17
	Pbind(*[note: Pseq([11, 12, 11, 12, 11, Rest()], 1), dur: Pseq([0.25], 6), octave: 5]),
	//18
	Pbind(*[note: Pseq([4, 6, 4, 6, 4, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.75, 0.25], 1), octave: 5]),
	//19
	Pbind(*[note: Pseq([Rest(), 7], 1), dur: Pseq([1.5, 1.5], 1), octave: 6]),
	//20
	Pbind(*[note: Pseq([4, 6, 4, 6, -5, 4, 6, 4, 6, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.75, 0.25, 0.25, 0.25, 0.25, 0.25], 1), octave: 5]),
	//21
	Pbind(*[note: Pseq([6], 1), dur: Pseq([3], 1), octave: 5]),
	//22
	Pbind(*[note: Pseq([4, 4, 4, 4, 4, 6, 7, 9, 11], 1), dur: Pseq([1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 0.5], 1), octave: 5]),
	//23
	Pbind(*[note: Pseq([4, 6, 6, 6, 6, 6, 7, 9, 11], 1), dur: Pseq([0.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1], 1), octave: 5]),
	//24
	Pbind(*[note: Pseq([4, 6, 7, 7, 7, 7, 7, 9, 11], 1), dur: Pseq([0.5, 0.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 0.5], 1), octave: 5]),
	//25
	Pbind(*[note: Pseq([4, 6, 7, 9, 9, 9, 9, 9, 11], 1), dur: Pseq([0.5, 0.5, 0.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5], 1), octave: 5]),
	//26
	Pbind(*[note: Pseq([4, 6, 7, 9, 11, 11, 11, 11, 11], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5, 1.5, 1.5, 1.5, 1.5, 1.5], 1), octave: 5]),
	//27
	Pbind(*[note: Pseq([4, 6, 4, 6, 7, 4, 7, 6, 4, 6, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25], 1), octave: 5]),
	//28
	Pbind(*[note: Pseq([4, 6, 4, 6, 4, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.75, 0.25], 1), octave: 5]),
	//29
	Pbind(*[note: Pseq([4, 7, 12], 1), dur: Pseq([3, 3, 3], 1), octave: 5]),
	//30
	Pbind(*[note: Pseq([12], 1), dur: Pseq([6], 1), octave: 5]),
	//31
	Pbind(*[note: Pseq([7, 6, 7, 11, 7, 11], 1), dur: Pseq([0.17, 0.17, 0.16, 0.17, 0.17, 0.16], 1), octave: 5]),
	//32
	Pbind(*[note: Pseq([6, 7, 6, 7, 11, 6, 7], 1), dur: Pseq([0.17, 0.17, 0.16, 0.17, 0.17, 3.16, 1.5], 1), octave: 5]),
	//33
	Pbind(*[note: Pseq([7, 6, Rest()], 1), dur: Pseq([0.25, 0.25, 0.5], 1), octave: 5]),
	//34
	Pbind(*[note: Pseq([7, 6], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
	//35
	Pbind(*[note: Pseq([5, 7, 11, 7, 11, 7, 11, 7, 11, 7, Rest(), 10, 19, 21, 19, 23, 21, 19, 16, 19, 18, Rest(), 16, 17], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 3.5, 1, 3, 0.5, 1, 0.5, 1.5, 0.5, 3, 0.5, 3.5, 2.5, 2.5, 6], 1), octave: 5]),
	//36
	Pbind(*[note: Pseq([5, 7, 11, 7, 11, 7], 1), dur: Pseq([0.25], 6), octave: 5]),
	//37
	Pbind(*[note: Pseq([5, 7], 1), dur: Pseq([0.25], 2), octave: 5]),
	//38
	Pbind(*[note: Pseq([5, 7, 11], 1), dur: Pseq([0.25], 3), octave: 5]),
	//39
	Pbind(*[note: Pseq([11, 7, 5, 7, 11, 12], 1), dur: Pseq([0.25], 6), octave: 5]),
    //40
	Pbind(*[note: Pseq([11, 5], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
    //41
	Pbind(*[note: Pseq([11, 5], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
    //42
	Pbind(*[note: Pseq([12, 11, 9, 12], 1), dur: Pseq([2], 4), octave: 5]),
    //43
	Pbind(*[note: Pseq([5, 4, 5, 4, 4, 4, 4, 5, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 1, 1, 0.5, 0.25, 0.25], 1), octave: 6]),
    //44
	Pbind(*[note: Pseq([5, 4, 4, 4, 0], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5, 1], 1), octave: 6]),
    //45
	Pbind(*[note: Pseq([2, 2, -5], 1), dur: Pseq([1, 1, 1], 1), octave: 6]),
    //46
	Pbind(*[note: Pseq([7, 14, 16, 14, Rest(), 7, Rest(), 7, Rest(), 7, 7, 14, 16, 14], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25, 0.25], 1), octave: 5]),
    //47
	Pbind(*[note: Pseq([14, 16, 14], 1), dur: Pseq([0.25, 0.25, 0.5], 1), octave: 5]),
    //48
	Pbind(*[note: Pseq([7, 7, 5], 1), dur: Pseq([3, 2, Pwhite(4,20,1)], 1), octave: 5]),
    //49
	Pbind(*[note: Pseq([5, 7, 10, 7, 10, 7], 1), dur: Pseq([0.25], 6), octave: 5]),
	//50
	Pbind(*[note: Pseq([5, 7], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
	//51
	Pbind(*[note: Pseq([5, 7, 10], 1), dur: Pseq([0.25, 0.25, 0.25], 1), octave: 5]),
	//52
	Pbind(*[note: Pseq([7, 10], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
	//53
	Pbind(*[note: Pseq([10, 7], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
];

~commonPattern = Pbind(*[lag: Pwhite(-0.05, 0.05, inf)]);
)

(
SynthDef(\instr1, { |out = 0, freq = 440, amp = 0.1, numharmonics = 4, pan = 0|
	var signal;
	signal = Blip.ar(freq,numharmonics) +WhiteNoise.ar(0.05);
	signal = signal + DelayL.ar(in: DFM1.ar(in: signal, freq: freq*4, res: ExpRand.new(lo: 0.9, hi: 1.1)), delaytime: 0.01, mul: 0.3);
	signal = EnvGen.ar(Env.perc(0.05, 1, 1, -4),  doneAction: Done.freeSelf) * signal * amp;
	signal = Pan2.ar(signal, pan);
	Out.ar(out, signal);
}).add;

SynthDef(\instr2, { |out = 0, freq = 440, amp = 0.1, pan = 0, decaytime = 3|
	var signal;
	signal = Pluck.ar(in: WhiteNoise.ar(0.1), trig: Impulse.kr(0), maxdelaytime: freq.reciprocal, delaytime: freq.reciprocal, decaytime: decaytime, coef: 0);
	DetectSilence.ar(signal, 0.001, 0.5, doneAction:2);
	signal = Pan2.ar(signal * amp * 4, pan);
	Out.ar(out, signal);
}).add;

SynthDef(\instr3, { |out = 0, freq = 440, amp = 0.1, pan = 0, gate = 1|
	var signal = DWGBowedSimple.ar(freq: freq, velb: 0.5, force: ExpRand.new(lo: 0.7, hi: 1.0), gate: gate, pos: ExpRand.new(lo: 0.12, hi: 0.14), release: ExpRand.new(lo: 0.1, hi: 0.4), c1: 0.25, c3: 31);
    signal = DWGSoundBoard.ar(signal);
	signal = DFM1.ar(in: signal, freq: freq*2);
	Out.ar(out, Pan2.ar(signal * amp, pan));
}).add;

SynthDef(\instr4, {
	|freq = 440, t60 = 1, pitchy = 1, amp = 0.25, gate=1, pan  = 0|
	var sig, exciter;
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;
	sig = Klank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:freq*pitchy
	);
	sig = sig * amp * 0.25;
	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(0, Pan2.ar(sig, pan));
}).add;


SynthDef(\instr5,{ // orgue
	|out= 0 freq = 440 amp = 0.3 gate=1 lforate = 10 lfowidth= 0.0 cutoff= 100 rq=0.5 pan=0.0|

	var vibrato, pulse, filter, env;

	vibrato = SinOsc.ar(lforate,Rand(0,2.0));

	pulse = Mix(
		VarSaw.ar(freq:([1,1.9953843530485,3.0139733629359]*freq)*(1.0+(lfowidth*vibrato)),iphase: Rand(0.0,1.0)!3,width: Rand(0.3,0.5)!3,mul: [1.0,0.7,0.3]))*4;

	filter = RLPF.ar(pulse,cutoff,rq);

	env = EnvGen.ar(Env.adsr(0.01,0.5,1.0,0.5),gate,doneAction:2);

	Out.ar(out,Pan2.ar(filter*env*amp,pan));

}).add;
)

~patterns[~patterns.size() - 1].play;

(
~players = Array.newClear(~numberOfPlayers);
~numberOfPlayers.do({ |i|
	var instr, pairs;
	instr = [\instr1, \instr2, \instr3, \instr4, \instr5].choose;
	pairs = switch(instr,
		\instr1, { (instrument: \instr1, numharmonics: [2, 4, 10, 20].choose)},
		\instr2, { (instrument: \instr2, decaytime: rrand(2.0, 5.0)) },
		\instr3, { (instrument: \instr4) },
		\instr4, { (instrument: \instr4, pitchy: (1..4).choose, t60: rrand(0.5, 9)) },
		\instr5, { (instrument: \instr5) }
	);
	~players[i] = pairs ++ (pan: rrand(-1.0, 1.0), amp: 1.0/~numberOfPlayers);
	("player "+i+" : "+~players[i]).postln;
});
)

// joueur de la pulse
(
Pbind(*[instrument: \instr5, degree: 0, pan: 0, dur: 1/2, octave: 5,db: Pseq([-20, -24, -22, -24], inf)]).play(quant:1);
)

// Test
(
Pbind(*[degree: Pseq((0..7)), instrument: \instr5, amp: 1]).play
)


// 1 seul joueur
(
~numberOfPlayers.do({ |player|
	Pspawner({ |sp|
		// attend
		("player "+player+" : ").post;
		sp.wait(~durationToBeats.value(rrand(~minPatternDuration,~maxPatternDuration).postln));
		~patterns.do ({ |i|
			("player "+player+" : ").post;
			// jouer le pattern i entre 45s et 1,30 min
			sp.seq(
				Pchain(~commonEvent,Pbindf(Pfindur(~durationToBeats.value(rrand(~minPatternDuration,~maxPatternDuration).postln), Pn(i, inf))),~players[player]);
			);
		});
	}).play(quant: 1);
});
)
~players[0].asPairs
(
a = Pbind(*[
    octave: 4,
    note: Pseq((0..11), 1)
]);

c = (octave: 8, amp: 0.5);

b = Pchain(c, a);
b.asStream.next(Event.new)
)