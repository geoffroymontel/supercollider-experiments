(

///////////////////////////////////
// "Forked" event stream trick
Ndef(\sound, { DC.ar([0,0]) }).play;

// A base pattern.....
Pdef(\basePattern, Pbind(
	// Point to my ndef
	\group, Ndef(\sound).group,
	\out, Ndef(\sound).bus,

	\instrument, {
		var sig = WhiteNoise.ar([1,1])
			* Env.perc(0.01, \amp.kr * 0.2).kr(gate:\gate.kr(1), doneAction:2)
			* \amp.kr;
		Out.ar(\out.kr, sig);
	},

	\dur, 1/3,
	\amp, Pfunc({ rrand(0.2, 0.7) }),
	\octave, 3,
	// \scale, Scale.chromatic,
	\degree, Pseq([0, 2, 4, 7], inf),
	\legato, 0.3,

	\bumpDelay, Prand([true] ++ (false ! 20), inf)
));

// A pattern for modifying my post-processing Ndef
Pdef(\bumpDelay, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\postProcess).group }),
	\args, [\bumpDelay, \freq],

	\bumpDelay, Prand([0.3, 0.5, 1], inf),
	\degree, Pseq([0, 2, 4, 2], inf),
	\octave, 4
));

// A player
Pdef(\player,
	Ppar([ // two parallel streams...

		// just forward the \basePattern event along
		Pfunc({ |e| e }),

		// second stream only plays when \bumpDelay, else it's just silent
		Pif(
			Pfunc({ |e| e.bumpDelay }),  		// if our condition is true....
			Pdef(\bumpDelay),			  		// then use this pattern
			Pfunc({ |e| Event.silent(e.dur) }) 	// else, don't do anything
		)
	])
	<> Pdef(\basePattern)
).play;

// A static post-process stage.
Ndef(\postProcess, {
	var sig, delay, delayAmt;

	sig = Ndef(\sound).ar(2);

	delayAmt = Decay.kr(\bumpDelay.tr(0), 0.5);

	delay = sig * delayAmt;
	delay = LPF.ar(delay, 3000);
	delay = CombC.ar(delay, 1, \freq.kr(100).reciprocal, 5);

	sig = LPF.ar(sig, 2000) + delay;
}).play;

)