
/////////////
FX SEQUENCING
/////////////


s.boot;

s.freqscope;
s.scope;


1) Straight usage with unchanged effect order


1a) Source synth with sustained envelope

// boot server with extended resources

(
s.options.numPrivateAudioBusChannels = 1024;
s.options.memSize = 8192 * 16;
s.reboot;
)

// basic source and effect synthdefs for this next examples

(
// All ins and outs use two channels

// source synthdef, produces 100 % correlated 2-channel signal
// take releaseTime = decayTime

SynthDef(\source, { |out = 0, freq = 400, decayTime = 0.5,
	attackTime = 0.005, amp = 0.1, gate = 1|
	var env, sig = Decay.ar(Impulse.ar(0), decayTime, Saw.ar(freq));
	env = EnvGen.ar(Env.asr(attackTime, amp, decayTime, \lin), gate, doneAction: 2);
	Out.ar(out, sig ! 2 * env)
}).add;


// spat fx
// This effect introduces a very small delay,
// in examples balancing by lag (as it obviously has to be done with echo) is neglected.

SynthDef(\spat, { |out, in, freq = 1, maxDelayTime = 0.005,
	amp = 1, mix = 1|
	var sig, inSig = In.ar(in, 2);
	sig = DelayC.ar(
		inSig,
		maxDelayTime,
		{ LFDNoise3.ar(freq, maxDelayTime, maxDelayTime/2) } ! 2,
		amp
	);
	Out.ar(out, (1 - mix) * inSig + (sig * mix));
}).add;


// echo fx, always unified delay maxEchoDelta

SynthDef(\echo, { |out, in, maxEchoDelta = 0.2, echoDelta = 0.1,
	decayTime = 1, amp = 1, mix = 1|
	var sig, inSig = In.ar(in, 2);
	sig = DelayL.ar(
		CombL.ar(inSig, maxEchoDelta, echoDelta, decayTime, amp),
		maxEchoDelta,
		maxEchoDelta - echoDelta
	);
	Out.ar(out, (1 - mix) * inSig + (sig * mix));
}).add;


// wah-wah fx

SynthDef(\wah, { |out, in, resLo = 200, resHi = 5000,
	cutOffMoveFreq = 0.5, rq = 0.1, amp = 1, mix = 1|
	var sig, inSig = In.ar(in, 2);
	sig = RLPF.ar(
		inSig,
		LinExp.kr(LFDNoise3.kr(cutOffMoveFreq), -1, 1, resLo, resHi),
		rq,
		amp
	).softclip;
	Out.ar(out, (1 - mix) * inSig + (sig * mix));
}).add;


// reverb fx
// rough estimation: freeVerb's room arg = decayTime / 10

SynthDef(\reverb, { |out, in, damp = 0.5,
	decayTime = 10, amp = 1, mix = 1|
	var sig, inSig = In.ar(in, 2);
	Out.ar(out, FreeVerb.ar(inSig, mix, min(decayTime, 10) / 10, damp, amp));
}).add;
)


// Fx params are sequenced on a per-event base.

// see server window: number of groups (divided by 2) indicates
// the number of parallel event chains in action
// check while running with s.queryAllNodes

(
p = PbindFx([
		\instrument, \source,
		\dur, 0.25,
		\amp, 0.2,
		\midinote, Prand([
			Pwhite(80, 90, 1),
			Prand([60, 67, 70, 73]) + Prand([0, -12.3, -23.7], inf),
		], inf),

		// fxOrder is the essential key, here every event gets spat & wah
		\fxOrder, [1, 2],

		// With a sustained envelope \cleanupDelay refers to the maximum release time,
		// in SynthDef \source releaseTime = decayTime, so take cleanupDelay = decayTime
		\decayTime, Pwhite(0.2, 2),
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \spat,
		// oscillation of delay -> frequency modulation of source signal
		\freq, Prand([1, 2, 3], inf),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		// variation by sequencing of params
		\fx, \wah,
		\mix, Pseq([0.2, 0.5, 0.7], inf),
		\cutOffMoveFreq, Pseq([1, 2, 5, 10], inf),
		\cleanupDelay, 0.01
	]
);

q = p.play;
)

// see server window and compare "regular" stop
// (descending number of groups, synths and ugens reflects delayed cleanup)
// with stopping the same example by Cmd-Period

q.stop;




1b) Source synth with fixed-length envelope

// SynthDefs from Ex. 1a plus SynthDef variation with adsr args

(
SynthDef(\source_adsrFixed, { |out = 0, freq = 400, decayTime = 0.5,
	att = 0.005, dec = 0.01, sus = 0.2, rel = 0.3, susLevel = 0.5, amp = 0.1|
	var env, sig = Saw.ar(freq);
	env = EnvGen.kr(Env([0, 1, susLevel, susLevel, 0], [att, dec, sus, rel]), doneAction: 2);
	Out.ar(out, sig ! 2 * env * amp)
}).add;
)

// adsr values passed, \cleanupDelay estimated as max of sum

(
p = PbindFx([
		\instrument, \source_adsrFixed,
		\dur, 0.25,
		\att, Pwhite(0.005, 0.01),
		\dec, Pwhite(0.01, 0.02),
		\sus, Pwhite(0.02, 0.3),
		\rel, Pwhite(0.2, 1.5),

		\susLevel, 0.4,
		\amp, 0.2,

		\midinote, Prand([
			Pwhite(80, 90, 1),
			Prand([60, 67, 70, 73]) + Prand([0, -12.3, -23.7], inf),
		], inf),

		\fxOrder, [1, 2],

		// cleanupDelay must be larger than max env length, otherwise events might be cut !
		// here we do an estimation (att + dec + sus + rel < 2),
		// but it could be summed from those event values too, e.g. with
		// \cleanupDelay, Pfunc { |e| e.att + e.dec + e.sus + e.rel }
		\cleanupDelay, 2
	],[
		\fx, \spat,
		\freq, Prand([1, 2, 3], inf),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		\fx, \wah,
		\mix, Pseq([0.2, 0.5, 0.7], inf),
		\cutOffMoveFreq, Pseq([1, 2, 5, 10], inf),
		\cleanupDelay, 0.01
	]
);

q = p.play;
)


// check node order while running

s.queryAllNodes;

q.stop;



2) Sequencing of different effect chains

// PbindFx using spat and echo effects. Especially relevant keys:
// \fxOrder which determines fx sequencing and
// \cleanupDelay for proper releaseTimes of source and effects.

// SynthDefs from Ex.1a, see also extended server resources defined there.



2a) Determined fx sequence

(
p = PbindFx([
		\instrument, \source,
		\dur, 0.5,
		\amp, 0.3,
		\midinote, Pwhite(50, 90),

		// fx sequence \spat, \spat + \echo, etc.
		\fxOrder, Pseq([1, [1,2]], inf),

		// echo is delayed (maxEchoDelta = 0.2),
		// compensate here by shift when no echo
		// we need \lag rather than \timingOffset as the whole delaytime calculation refers to seconds
		\lag, Pseq([0.2, 0], inf),

		// in SynthDef \source releaseTime = decayTime, so take cleanupDelay = decayTime
		\decayTime, Pseq([1, 0.1], inf),
		\cleanupDelay, Pkey(\decayTime)
	],[
		// define effect with index 1
		\fx, \spat,
		\maxDelayTime, 0.005,

		// oscillation of delay -> frequence modulation of source signal
		\freq, Pseq([1, 1, 10], inf),

		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		// define effect with index 2
		\fx, \echo,
		\echoDelta, 0.08,
		\decayTime, Pwhite(0.8, 3),

		\cleanupDelay, Pkey(\decayTime)
	]
);

q = p.play;
)

q.stop;


2b) Random fx sequence

// If more than one synth per event is produced (here by key 'midinote'),
// the effect chain is applied to all of them,
// see Ex.3 for applying different effects to parallel synths.

// SynthDefs from Ex.1a, see also extended server resources defined there.


(
p = PbindFx([
		\instrument, \source,
		\dur, 0.2,
		\amp, 0.3,

		// downwards tendency + chord sequence
		\midinote, Pseq((90, 80..50), inf) +
			Pn(Pshuf([[0, 5], 0, [0, 2.5], [-2.5, 12.5], [-3, 0]])),

		// choosing from 'spat' and 'spat' & 'echo'
		// prob for the latter is twice as high
		\fxOrder, Prand([1, [1,2], [1,2]], inf),

		// lag must be adapted to maxEchoDelta
		\lag, Pfunc { |e| e.fxOrder.isArray.if { 0 }{ 0.2 } },

		// echo -> shorter source decay
		\decayTime, Pfunc { |e| e.fxOrder.isArray.if { 0.1 }{ 0.7 } },
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \spat,
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		\fx, \echo,
		\echoDelta, Pseq((1..5)/50, inf),
		\decayTime, 1,
		\cleanupDelay, Pkey(\decayTime)
	]
);

q = p.play;
)

q.stop;


2c) Some extensions

// Additional use of rests, reverb added.
// Here the reverb usage is deliberately wasteful,
// see Ex.2d for an alternative.
// The use of Pn + Pshuf (or equivalently Pshufn) gives
// balanced random variation for several key streams.

// SynthDefs from Ex.1a, see also extended server resources defined there.

(
p = PbindFx([
		\instrument, \source,
		\dur, Pn(Pshuf(0.2!5 ++ Rest(0.2))),

		\midinote, Pseq((90, 80..40), inf) +
			Pn(Pshuf([[0, 5], 0, [0, 2.5], [-2.5, 12.5], [-3, 0]])),

		\fxOrder, Pn(Pshuf([[1,2], [1,2,3], [3,1], 1])),

		\lag, Pfunc { |e| e.fxOrder.asArray.includes(2).if { 0 }{ 0.2 } },
		\amp, Pfunc { |e| (e.fxOrder != [1,2]).if { 0.3 }{ 0.6 } },

		\decayTime, Pfunc { |e|
			rrand(0.3, 0.8) / (e.fxOrder.asArray.includes(2).if { 10 }{ 1 })
		},
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \spat,
		\freq, Pn(Pshuf([1, 1, 1, 5, 20, 50])),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		\fx, \echo,
		\echoDelta, Pseq((1..5)/50, inf),
		\decayTime, Pwhite(0.3, 1.8),
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \reverb,
		\mix, 0.3,
		\damp, 0.1,
		\decayTime, Pwhite(3.0, 10),
		\cleanupDelay, Pkey(\decayTime)
	]
);

q = p.play;
)

q.stop;



2d) Saving resources

// If effects have a long cleanup delay, you will get a possibly large number of
// overlapping effect chains. E.g. in Ex.2c many reverb synths can be there in parallel,
// the decayTime is controlled by Pwhite(3.0, 10), so it might well be that
// reverbs with decayTimes 7.95, 8, and 8.1 are instantiated in parallel,
// which doesn't make much difference and is quite wasteful.
// Reverb is often placed at the last position of the effect chain,
// so a more efficient approach would be the following:
// do all effect sequencing without reverb with PbindFx and pipe the
// overall out to a permanently running reverb.

// SynthDefs from Ex.1a, see also extended server resources defined there.

// start two reverbs with different parameters, read from dedicated buses

(
a = Bus.audio(s, 2);
b = Bus.audio(s, 2);

x = Synth(\reverb, [mix: 0.3, damp: 0.1, decayTime: 3, in: a]);
y = Synth(\reverb, [mix: 0.2, damp: 0.1, decayTime: 10, in: b]);
)

// play PbindFx
// compare CPU usage with Ex. 2c

(
p = PbindFx([
		\instrument, \source,
		\dur, Pn(Pshuf(0.2!5 ++ Rest(0.2))),

		\midinote, Pseq((90, 80..40), inf) +
			Pn(Pshuf([[0, 5], 0, [0, 2.5], 0, [-2.5, 12.5], [-3, 0]])),

		\fxOrder, Pn(Pshuf([1, 2, [1,2]])),

		\lag, Pfunc { |e| e.fxOrder.asArray.includes(2).if { 0 }{ 0.2 } },
		\amp, Pfunc { |e| (e.fxOrder != [1,2]).if { 0.3 }{ 0.6 } },

		\decayTime, Pfunc { |e|
			rrand(0.3, 0.8) / (e.fxOrder.asArray.includes(2).if { 10 }{ 1 })
		},
		\cleanupDelay, Pkey(\decayTime),

		// pipe out to different reverbs resp. 0 (no reverb)
		\out, Pn(Pshuf([0, 0, a, a, b]))
	],[
		\fx, \spat,
		\freq, Pn(Pshuf([1, 1, 1, 5, 20, 50])),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		\fx, \echo,
		\echoDelta, Pseq((1..5)/50, inf),
		\decayTime, Pwhite(0.3, 1.8),
		\cleanupDelay, Pkey(\decayTime)
	]
);

q = p.play;
)

// stop

q.stop;

// free extra resources

[x, y, a, b].do(_.free);


3) Different effects for parallel synths (with PbindFx generator Function)

// Done with a PbindFx generator Function,
// this is Ex. 3b from PbindFx help and probably the clearest way,
// see Ex. 3a for an equivalent possibility.

// SynthDefs from Ex.1a, see also extended server resources defined there.



// 3 voices should get different fx sequences
// The example also employes data sharing between different event streams via variables

(
// master pattern for fxOrder
f = Pbind(
	\dur, 0.3,
	\type, \rest,
	\fxOrders, Pn(Pshuf([
		[[1, 3], 2, 1], [1, [1, 3], 2], [2, 1, [1, 3]],
		[0, 1, 1], [1, 0, 1], [1, 1, 0]
	]).collect { |o| ~o = o })
);

// PbindFx generator Function

g = { |i| PbindFx([
		\instrument, \source,
		\dur, 0.3,

		\fxOrder, Pfunc { ~o[i].asArray },
		\lag, Pfunc { |e| e.fxOrder.includes(2).if { 0 }{ 0.2 } },
		\amp, Pfunc { |e| e.fxOrder.any([2,3].includes(_)).if { 0.3 }{ 0.1 } },

		\decayTime, Pfunc { |e| rrand(0.5, 0.7) / (e.fxOrder.includes(2).if { 10 }{ 1 }) },
		\cleanupDelay, Pkey(\decayTime),
	],[
		\fx, \spat,
		\freq, Pn(Pshuf([1, 2, 3, 10])),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		\fx, \echo,
		\echoDelta, 3/50,
		\decayTime, Pwhite(0.3, 1.8),
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \wah,
		\mix, 0.5,
		\cutOffMoveFreq, Pseq([5, 10], inf),
		\cleanupDelay, 0.01
	]
);
};

// derive three Pbindfs from PbindFx generator,
// as PbindFx is a subclass of Pbind, you can apply Pbindf as to Pbind

u = Pbindf(g.(0), \midinote, 72);
v = Pbindf(g.(1), \midinote, Pstutter(Pwhite(5, 10), Prand((60..70), inf)));
w = Pbindf(g.(2), \midinote, Pstutter(Pwhite(5, 10), Prand((75..85), inf)));

d = 0.001;
q = Ptpar([0, f, d, u, d, v, d, w]).play;
)

q.stop;

// the following help file chapters are rather special or advanced and omitted here

4) Applying the same fx SynthDef more than once in a chain (implicit and explicit parallelism)
5) Tempo control
6) Further external routing (external modulation of source and fxs)
7) Replacement (Livecoding, exchanging parameters or whole fx and source patterns)
8) GUI control
9) Using value conversions with fx data


10) Parallel effects and arbitrary effect graphs


10a) Parallel effects

// Here source is routed to echo #1 and echo #2 in parallel,
// echo #1 (fx index 2) is a "classical" echo whereas
// echo #2 (fx index 3), due to short echoDelta, results in an additional frequency.
// The output of echo #2 is routed to a wah-wah, echo #1 directly to out.

// See picture in PbindFx help file

// SynthDefs from Ex.1a, see also extended server resources defined there.

(
p = PbindFx([
		\instrument, \source,
		\dur, Pseq([Pn(0.2, { rrand(8, 12) }), Pwhite(2.0, 4.0, 1)], inf),
		\amp, 0.3,
		\midinote, Prand([
			Pwhite(80, 90, 1),
			Prand([60, 67, 70, 73]) + Prand([0, -12.3, -23.7], inf),
		], inf),

		\fxOrder, `(0: 1, 1: [2, 3], 3: 4),
		//	 compare with this version, where echo #1 is less present, as it also goes to wah
		//	 \fxOrder, `(0: 1, 1: [2, 3], 3: 4, 2: 4),

		\decayTime, 0.1,
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \spat,
		\freq, Prand([0.1, 0.8], inf),
		\maxDelayTime, 0.001,
		\cleanupDelay, 0.1
	],[
		\fx, \echo,
		\echoDelta, 0.1,
		\decayTime, 3,
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \echo,
		\echoDelta, Pwhite(0.01, 0.05),
		\decayTime, 5,
		\amp, 0.5,
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \wah,
		\mix, 0.7,
		\cutOffMoveFreq, Pseq([1, 2, 5, 10], inf),
		\cleanupDelay, 0.05
	]
);

q = p.play;
)

q.stop;


10b) Modulation graphs

// A generalized modulating effect node has two ins: carrier and modulator.
// Fx convention of PbindFx demands one single In ugen per fx synth,
// but two ins can simply be handled by a 2-channel In ugen and hard-panned input signals.

// Spat SynthDef from Ex.1a, see also extended server resources defined there.


(
// sine source
SynthDef(\sine_adsrFixed, { |out = 0, freq = 400, decayTime = 0.5,
	att = 0.005, dec = 0.01, sus = 0.2, rel = 0.3, susLevel = 0.5, amp = 0.1|
	var env, sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env([0, 1, susLevel, susLevel, 0], [att, dec, sus, rel]), doneAction: 2);
	Out.ar(out, sig ! 2 * env * amp)
}).add;

// amplitude modulation synth
SynthDef(\ampMod, { |out, in, dev = 1, amp = 1, mix = 1|
	var sig, inSig = In.ar(in, 2);
	sig = inSig[0] * (inSig[1] * dev + DC.ar(1)) * amp;
	Out.ar(out, (1 - mix) * inSig + (sig * mix));
}).add;

// phase modulation synth
SynthDef(\phaseMod, { |out, in, maxDelay = 0.1, dev = 1, amp = 1, mix = 1|
	var sig, inSig = In.ar(in, 2);
	sig = DelayC.ar(inSig[0], maxDelay, maxDelay * dev * inSig[1], amp);
	Out.ar(out, (1 - mix) * inSig + (sig * mix));
}).add;

// modulator synths, no Ins

SynthDef(\sineM, { |out, in, freq = 100|
	Out.ar(out, [0, SinOsc.ar(freq)]);
}).add;

SynthDef(\pulseM, { |out, in, freq = 100, width = 0.5|
	Out.ar(out, [0, Pulse.ar(freq, width, 2)]);
}).add;

SynthDef(\sawM, { |out, in, freq = 100|
	Out.ar(out, [0, Saw.ar(freq)]);
}).add;
)

// blend of AM events

(
p = PbindFx([
		\instrument, \sine_adsrFixed,
		\dur, 1,
		\susLevel, 1,
		\att, 5,
		\sus, 0,
		\rel, 5,
		\amp, 0.03,
		\midinote, Pwhite(40, 80),
		\fxOrder, `(0: 1, 3: 1, 1: 2),

		\decayTime, 1,
		\cleanupDelay, 12
	],[
		\fx, \ampMod,
		\dev, Pwhite(0.1, 0.6)
	],[
		\fx, \spat,
		\freq, Pwhite(0.2, 2),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	],[
		\fx, \pulseM,
		\freq, Pwhite(200, 1000)
	]
);

q = p.play;
)

q.stop;


10c) Modulation graphs, changed per event

// SynthDefs from Ex. 10b, spat SynthDef from Ex.1a, see also extended server resources defined there.

// See picture in PbindFx help file

(
p = PbindFx([
		\instrument, \sine_adsrFixed,
		\dur, 0.3,
		\susLevel, 1,
		\att, 0.01,
		\sus, 0.15,
		\rel, Pwhite(0.3, 1.2),
		\amp, 0.05,

		\midinote, Pwhite(30, 60) + Prand([0, [0, -12.5]], 200),

		// changes between amplitude (pulse and saw) and phase modulation (sine)

		\fxOrder, Pn(Pshuf([
				`(0:1, 4:1, 1:6),
				`(0:1, 5:1, 1:6),
				`(0:2, 3:2, 2:6)
			])),

		// equivalent:
		// the source stream returns pairs, where the first number indicates
		// the modulation type and the second number the modulator,
		// the collect function packs the data into the right format of a ref'd Event.

		// \fxOrder, Pn(Pshuf([ [1, 4], [1, 5], [2, 3] ]))
		// .collect { |x| ().putPairs([0, x[0], x[1], x[0], x[0], 6]).asRef },

		\decayTime, 2,
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \ampMod,
		\dev, Pwhite(0.1, 0.5)
	],[
		\fx, \phaseMod,
		\dev, Pwhite(0.03, 0.05)
	],[
		\fx, \sineM,
		\freq, Pwhite(150, 700)
	],[
		\fx, \sawM,
		\freq, Pwhite(150, 700)
	],[
		\fx, \pulseM,
		\freq, Pwhite(150, 700)
	],[
		\fx, \spat,
		\freq, Pwhite(0.1, 1),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	]
);

q = p.play;
)

q.stop;



// a few changes (dur, att, sus, rel) turn the example into a semi-granular texture,
// modulator and midinote frequencies also changed

(
p = PbindFx([
		\instrument, \sine_adsrFixed,
		\dur, Pexprand(0.01, 0.6),
		\susLevel, 1,
		\att, 0.01,
		\sus, Pkey(\dur) * Pwhite(0.2, 1.4),
		\rel, 0.01,
		\amp, 0.1,

		\midinote, Pwhite(35, 80) + Prand([0, [0, -12.5]], 2000),

		// changes between amplitude (pulse and saw) and phase modulation (sine)

		\fxOrder, Pn(Pshuf([
				`(0:1, 4:1, 1:6),
				`(0:1, 5:1, 1:6),
				`(0:2, 3:2, 2:6)
			])),

		// equivalent:
		// the source stream returns pairs, where the first number indicates
		// the modulation type and the second number the modulator,
		// the collect function packs the data into the right format of a ref'd Event.

		// \fxOrder, Pn(Pshuf([ [1, 4], [1, 5], [2, 3] ]))
		// .collect { |x| ().putPairs([0, x[0], x[1], x[0], x[0], 6]).asRef },

		\decayTime, 2,
		\cleanupDelay, Pkey(\decayTime)
	],[
		\fx, \ampMod,
		\dev, Pwhite(0.1, 0.5)
	],[
		\fx, \phaseMod,
		\dev, Pwhite(0.03, 0.05)
	],[
		\fx, \sineM,
		\freq, Pwhite(150, 3000)
	],[
		\fx, \sawM,
		\freq, Pwhite(150, 3000)
	],[
		\fx, \pulseM,
		\freq, Pwhite(150, 3000)
	],[
		\fx, \spat,
		\freq, Pwhite(0.1, 1),
		\maxDelayTime, 0.005,
		\cleanupDelay, Pkey(\maxDelayTime)
	]
);

q = p.play;
)

q.stop;