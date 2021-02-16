(
SynthDef(\prayer_bell, { |outbus, t_trig = 1, sing_switch = 0, freq = 2434, amp = 0.5, decayscale = 1, lag = 10, i_doneAction = 0|
	var sig, input, first, freqscale, mallet, sing;
	freqscale = freq / 2434;
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

	mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
	sing = LPF.ar(
		LPF.ar(
			{
				PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.997).linexp(0, 1, 0.01, 1) * amp
			} ! 2,
			2434 * freqscale
		) + Dust.ar(0.1), 10000 * freqscale
	) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
	input = mallet + (sing_switch.clip(0, 1) * sing);


	sig = DynKlank.ar(`[
		[
			(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
			first + LFNoise1.kr(0.5).range(1,3),
			LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
			LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
			LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
			LFNoise1.kr(2).range(8665, 8670),
			LFNoise1.kr(2).range(8704, 8709),
			LFNoise1.kr(2).range(8807, 8817),
			LFNoise1.kr(2).range(9570, 9607),
			LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
			LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
			LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
		],
		[
			LFNoise1.kr(1).range(-10, -5).dbamp,
			LFNoise1.kr(1).range(-20, -10).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			-20.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp,
			-10.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp
		],
		[
			20 * freqscale.pow(0.2),
			20 * freqscale.pow(0.2),
			5,
			5,
			0.6,
			0.5,
			0.3,
			0.25,
			0.4,
			0.5,
			0.4,
			0.6
		] * freqscale.reciprocal.pow(0.5)
	], input, freqscale, 0, decayscale);
	DetectSilence.ar(sig, doneAction: i_doneAction);
	Out.ar(outbus, sig * -15.dbamp;);
}).add;
)

(
Pdef(\bell_1,
	Pmono(\prayer_bell,
		\dur, Pseq([8, 20], inf),
		\freq, Pseq([2500, 500], inf),
		\amp, 0.5,
		\lag, 0,
		\trig, Pseq([0.1], inf) * Pwhite(0.5, 1, inf) * Pwrand([0, 1], [1, 5].normalizeSum, inf),
		\sing_switch, Pseq((0!4) ++ (1!4), inf)
	)
);

Pdef(\bell_2,
	Pmono(\prayer_bell,
		\dur, Pwhite(8, 20, inf),
		\trig, Pwhite(0.05, 0.09),
		\sing_switch, Pwrand([0, 1], [5, 3].normalizeSum, inf),
		\freq, Prand((240, 360 .. 2000), inf),
		\amp, 0.5
	)
);

Pdef(\bell_3,
	Ppar([
		Pmono(\prayer_bell,
			\freq, 100,
			\dur, 1,
			\trig, 0,
			\sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
			\amp, Pwhite(0.1, 0.5)
		),
		Pmono(\prayer_bell,
			\freq, 200,
			\dur, 1,
			\trig, 0,
			\sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
			\amp, Pwhite(0.1, 0.5)
		),
		Pmono(\prayer_bell,
			\freq, 300,
			\dur, 1,
			\trig, 0,
			\sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
			\amp, Pwhite(0.1, 0.5)
		)
	])
);

Pdef(\bell_1).play;
Pdef(\bell_2).play;
Pdef(\bell_3).play;
)


// midi control

(
var notes, on, off, pedal, fader1, fader2, decay_scale, lag, sing_switch, group;

MIDIClient.init;
MIDIIn.connectAll;

notes = Array.newClear(128);    // array has one slot per possible MIDI note
pedal = false;
sing_switch = 0;
decay_scale = 1;
lag = 10;

group = Group.new(s);

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	notes[num] = Synth(\prayer_bell, [\freq, num.midicps, \amp, veloc / 128.0, \t_trig, 1 - sing_switch, \sing_switch, sing_switch, \decay_scale, decay_scale, \lag, lag, \i_doneAction, Done.freeSelf], group);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
	notes[num].set(\t_trig, 0);
	notes[num].release;
});

pedal = MIDIFunc.cc({ |val, num, chan, src|
	sing_switch = val / 127;
	group.set(\sing_switch, sing_switch);
}, 64);

fader1 = MIDIFunc.cc({ |val, num, chan, src|
	decay_scale = val.linexp(0, 127, 0.01, 10);
	decay_scale.postln;
}, 7, 0);

fader2 = MIDIFunc.cc({ |val, num, chan, src|
	lag = val.linexp(0, 127, 0.01, 50);
	lag.postln;
}, 7, 1);

q = { on.free; off.free; pedal.free ; fader1.free ; fader2.free ; group.free ; };
)

// when done:
q.value;

MIDIFunc.trace(true);
MIDIFunc.trace(false);