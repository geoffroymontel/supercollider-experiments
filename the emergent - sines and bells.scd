//////////////////////////////// SINE AND BELLS /////////////////////////
//                                                                     //
//                           for Willow Wedemeyer                      //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

(
s.options.memSize_(2.pow(20));
s.options.inDevice_("Windows WDM-KS : Speakers (Conexant HD Audio output)");
s.options.outDevice_("Windows WDM-KS : Mikrofonarray (Conexant HD Audio capture)");
s.recSampleFormat_("int24");
s.recHeaderFormat_("wav");

// global variables
~out = 0;
// Tempo Clock
t = TempoClock(48/60).permanent_(true);

// Buses
// free any buses that might be lingering on the server unused
~makeBuses = {
		s.newBusAllocators;

		// bus dictionary
		~bus = Dictionary.new;
		~bus.add(\reverb -> Bus.audio(s,2)); // reverb bus
		~bus.add(\pitch -> Bus.audio(s,2)); // pitchshift bus
	~bus.add(\comp -> Bus.audio(s, 2)); // compressor bus
};

// make groups and effect synths
~makeNodes = {
	s.bind({
		~src = Group.new;
		~efx = Group.after(~src);
		~shift = Synth(
			\shift,
			[
				\in, ~bus[\pitch],
				\out, ~bus[\reverb]
			],
			~efx
		);
		~reverb = Synth.after(
			~shift,
			\reverb, [
				\in, ~bus[\reverb],
				\out, ~bus[\comp]
			],
			~efx
		);
		~comp = Synth(
			\comp, [
				\in, ~bus[\comp],
				\out, ~out
			],
			~efx,
			\addToTail
		);
	});
};

~cleanup = {
		s.newBusAllocators;
		ServerBoot.removeAll;
		ServerTree.removeAll;
		ServerQuit.removeAll;
};

// register functions
ServerBoot.add(~makeBuses);
ServerQuit.add(~cleanup);

//////////////////////////////// boot server /////////////////////////////////

s.waitForBoot({
	s.sync;

	// Synthdefs
	// meandering sine wave
	SynthDef(\sine, {
		var sig, env, dry;
		dry = \dry.kr(1);
		env = Env.asr(\atk.ir(0.05), 0.75, \rel.ir(2)).kr(2, \gate.kr(1));
		sig = SinOsc.ar(
			\freq.kr(220, \freqlag.kr(1.2)) + SinOsc.kr({Rand(0.02, 0.06)}, 0, {Rand(0.1, 2.0)}), // frequency: slowly meandering a bit
			{Rand(0.0, 2pi)}, // phase
			SinOsc.kr({Rand(1/60, 3/60)}).range(0.2, 0.5));  // meandering amplitude
		sig = sig * env * \amp.kr(0.2, 0.2);
		sig = Pan2.ar(sig, SinOsc.kr(Rand(1/12, 1/9), Rand(0.0, 2pi), Rand(0.1, 0.99))); // meandering panning
		Out.ar(\out.kr(~out), sig * dry);
		Out.ar(\fx.kr(~bus[\reverb]), sig * (1-dry));
	}).add;

	SynthDef(\fmbell, {
		var car, mod, env, iEnv, vib, freq, atk, rel, cAtk, cRel, mRatio, cRatio, index, dry;
		atk = \atk.ir(0.01);
		rel = \rel.ir(1);
		cAtk = \cAtk.ir(4);
		cRel = \cRel.ir(-4);
		mRatio = \mRatio.kr(1);
		cRatio = \cRatio.kr(1);
		index = \index.kr(1);
		dry = \dry.kr(1);
		freq = \freq.kr(500);
		iEnv = EnvGen.kr(
			Env.new(
				[index, index * \iScale.kr(5), index],
				[atk, rel],
				[cAtk, cRel]
			)
		);
		env = EnvGen.kr(Env.perc(atk, rel, curve:[cAtk, cRel]), doneAction:2);
		vib = SinOsc.ar({exprand(2.0,5.0)}, 0, freq * {rand(0.015, 0.02)});
		mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv);
		car = SinOsc.ar(freq * cRatio + mod + vib) * env * \amp.kr(-14.dbamp);
		car = HPF.ar(car, \hpcut.kr(200));
		car = Pan2.ar(car, \pan.kr(0));
		Out.ar(\out.kr(~out), car * dry);
		Out.ar(\fx.kr(~bus[\reverb]), car * (1-dry));
	}).add;

	e = Env.new([0, 1, 0],[0.005, 0.3],[0, -4]); //percussive envelope
	~grainEnv = Buffer.sendCollection(s, e.discretize(4096));

	SynthDef(\sparkle, {
		var sig, freq, freq1, env, dry, grainfreq, pan;
		freq = \freq.kr(440);
		pan = LFNoise1.kr(0.25).bipolar(\panwidth.kr(0.9));
		dry = \dry.kr(1);
		grainfreq = \grainfreq.kr(4);
		freq1 = LFNoise0.kr(grainfreq).exprange(freq, freq*\maxPartial.kr(12)).round(freq/2);
		env = Env.perc(\atk.ir(0.001), \rel.ir(5), 1, \curve.ir(-2)).kr(2);
		sig = GrainSin.ar(
			2,
			Dust.ar(grainfreq),
			\graindur.kr(0.05),
			freq1,
			pan,
			\envbuf.ir(~grainEnv),
			512, // cannot be modulated
			\amp.kr(-12.dbamp)
		) * env;
		Out.ar(\out.kr(~out), sig * dry);
		Out.ar(\fx.kr(~bus[\reverb]), sig * (1 - dry));
		Out.ar(\fx2.kr(~bus[\pitch]), sig * \send.kr(0.0)); // "send" out w/ independent volume
	}).add;

	// effects
	// pitchshift

	SynthDef.new(\shift, {
		var sig;
		sig = PitchShift.ar(
			In.ar(\in.kr(~bus[\pitch]), 2),
			\winSize.kr(0.2),
			\pitchRatio.kr(2),
			\pitchDisp.kr(0),
			\timeDisp.kr(0),
			\amp.kr(-1.dbamp)
		);
		Out.ar(\out.kr(~bus[\reverb]), sig);
	}).add;

	// reverb w/ JPverb
	SynthDef.new(\reverb, {
		var sig;
		sig = In.ar(\in.kr(~bus[\reverb]), 2);
		sig = JPverb.ar(
			sig,
			\t60.kr(4),
			\damp.kr(0.45),
			\size.kr(4.5),
			\earlyDiff.kr(0.707),
			\modDepth.kr(0.1),
			\modFreq.kr(2.0),
			\low.kr(0.7),
			\mid.kr(1),
			\high.kr(0.6),
			\lowcut.kr(500),
			\highcut.kr(2000)
		);
		sig = sig * \amp.kr(-3.dbamp);
		Out.ar(\out.kr(~bus[\comp]), sig);
	}).add;

	// compressor
	SynthDef.new(\comp, {
		var sig;
		sig = In.ar(\in.kr(~bus[\comp]), 2);
		sig = Compander.ar(
			sig,
			sig,
			0.6,
			1.0,
			\slopeAbove.kr(0.66),
			mul: \compAmp.kr(3.dbamp)
		);
		Out.ar(~out, sig);
	}).add;

	s.sync;

	ServerTree.add(~makeNodes);

	s.freeAll;

	s.sync;

	"ready".postln;

});
)

(
///////////////////////////// Patterns //////////////////////////////////////
///////////////////////////// Part 1 //////////////////////////////////////

// Layer 1: Meandering sines
~sines1 = Pbind(
	\instrument, \sine,
	\midinote, Pseq([
		ChordSymbol(\A25.asNotes)!2 ++ ChordSymbol(\A35.asNotes) ++ ChordSymbol(\A15.asNotes)[0],
		ChordSymbol(\D3major_fs.asNotes) ++ ChordSymbol(\D4major_fs.asNotes) ++ ChordSymbol(\D2major_fs.asNotes)[0],
		ChordSymbol(\A25.asNotes)!2 ++ ChordSymbol(\A35.asNotes) ++ ChordSymbol(\A15.asNotes)[0],
		ChordSymbol(\D3m_f.asNotes) ++ ChordSymbol(\D4m_f.asNotes) ++ ChordSymbol(\D2m_f.asNotes)[0]
	], inf),
	\amp, -24.dbamp,
	\dur, Pwhite(16,24),
	\atk, Pwhite(3.2, 4),
	\legato, 1.01,
	\dry, 0.2,
	\out, ~bus[\comp],
	\group, ~src
);

// layer 2: FM Bell melody
~bells1 = Pbind(
	\instrument, \fmbell,
	\midinote, Pseq([
		ChordSymbol(\A35),
		Pxrand(ChordSymbol(\D4major.asNotes), 2),
		Pxrand(ChordSymbol(\A35.asNotes), 2),
		Pxrand(ChordSymbol(\D4m.asNotes),2)
	], inf,  1),
	\dur, Pseq([
		Pwhite(16,24),
		Pn(Pwhite(8, 12), 3)
	], inf),
	\atk, 0.001,
	\rel, Pwhite(3.2, 4),
	\cAtk, -2,
	\cRel, -1,
	\mRatio, Pwhite(0.99, 1.01),
	\cRatio, Pwhite(1.99, 2.01),
	\iScale, Pwhite(2.4, 4.8),
	\amp, -12.dbamp,
	\dry, Pwhite(0.25, 0.75),
	\out, ~bus[\comp],
	\fx, ~bus[\reverb],
	\group, ~src
);

// layer 3: bling + granular sparkles

~grains1 = Pbind(
	\instrument, \sparkle,
	\midinote, Pseq([
		Pseq([[69, 81], [76, 88]]),
		Pseq([[62, 74], [66, 81]]),
		Pseq([[69, 81], [76, 88]]),
		Pseq([[62, 74], [65, 87]])
	], inf),
	\dur, Pwhite(8, 12),
	\rel, Pkey(\dur) * 0.8,
	\graindur, Pwhite(0.075, 0.1),
	\grainfreq, Pwhite(12,16),
	\maxPartial, Pwhite(8,12),
	\envbuf, ~grainEnv,
	\amp,  -16.dbamp,
	\dry, Pwhite(0.2,0.3),
	\sendlev, Pwhite(0.5, 0.9),
	\out, ~bus[\comp],
	\fx, ~bus[\reverb],
	\fx2, ~bus[\pitch],
	\group, ~src
);

//////////////////////////////////// Part 2 ////////////////////////////////////////

// first punctuating "gong"
~gong1 = Pbind(
	\instrument, \fmbell,
	\midinote, Pseq([28],1),
	\atk, 0.001,
	\rel, 12,
	\cAtk, -2,
	\cRel, -1,
	\mRatio, pi/2,
	\cRatio, 5.sqrt,
	\iScale, 9,
	\dry, 0.2,
	\amp, -20.dbamp,
	\out,  ~bus[\comp],
	\group,	~src
);

// second punctuating "gong"
~gong2 = Pbind(
	\midinote, 45
) <> ~gong1;

// slow sine phrases, in pairs
~sines2 = PmonoArtic(
	\sine,
	\midinote, Pseq([
		[40, 56],
		[57, 42],
		\,
		[59, 44],
		[42, 57],
		\,
		[56, 42],
		[52, 40],
		\,
		[44, 54],
		[52, 40],
		\,
	], inf),
	\amp, -12.dbamp,
	\dur, Pseq([2, 2, 4], 16),
	\atk, Pseq([2, 1, 0.1], inf),
	\freqlag, 3.2,
	\legato, Pseq([1.01, 0.9, 0], inf),
	\dry, 0.4,
	\out, ~bus[\comp],
	\fx, ~bus[\reverb],
	\fx2, ~bus[\pitch],
	\group, ~src
);

~grains2 = Pbind(
	\instrument, \sparkle,
	\midinote, Pfunc({
		2.collect{
			Scale.major.degrees.choose + [52,64].choose;
		};
	}),
	\dur, Prand([8, 12], inf),
	\rel, Pkey(\dur) * Pdup(2, Pseries(0.4, 0.04, 12)),
	\graindur, Pdup(2, Pseries(0.2, 0.08, 12)),
	\grainfreq, Pkey(\graindur).lincurve(0.2, 1.08, 24, 12, -4),
	\maxPartial, Pkey(\graindur).lincurve(0.2, 1.08, 16, 8, -2),
	\envbuf, -1, // sinusoial grain envelope
	\amp, -28.dbamp * Pkey(\graindur).lincurve(0.2, 1.08, 0.95, 0.6, -4),
	\dry, 0.2,
	\sendlev, Pkey(\graindur).lincurve(0.2, 1.08, 0.99, 0.25, -4),
	\out, ~bus[\comp],
	\group, ~src
);

//////////////////////////////////// outro ////////////////////////////////////////
~grains3 = Pbind(
	\instrument, \sparkle,
	\midinote, Pxrand((Scale.major.degrees), inf) + Pxrand([45, 57, 69], inf),
	\dur, Pwhite(6.0,9.0),
	\rel, Pkey(\dur) * 0.95,
	\graindur, Pdup(2, Pgeom(1.2, 0.9, 12)),
	\grainfreq, Pkey(\graindur).lincurve(0.05, 1.2, 24, 4, -4),
	\maxPartial, Pkey(\graindur).lincurve(0.05, 1.2, 16, 8, -2),
	\envbuf, Prand([~grainEnv, -1], inf),
	\amp, -20.dbamp * Pkey(\graindur).lincurve(0.2, 1.08, 0.95, 0.6, -4),
	\dry, Pdup(4, Pseries(0.5, -0.05, 6)),
	\sendlev, Pdup(4, Pseries(0.3, 0.1, 6)),
	\out, ~bus[\comp],
	\fx, ~bus[\reverb],
	\fx2, ~bus[\pitch],
	\group, ~src
);

//////////////////////////////// "score" Ptpars /////////////////////////////////

~part1 = Ptpar([
	0, ~sines1,
	24, ~bells1,
	30, ~grains1
]);

~part2 = Ptpar(
	[
		0, ~sines2,
		14, ~grains2,
	]
);
)
/////////////////////////////// Player Routine ///////////////////////

(
~player = Routine{

	s.record("C:/Users/User/Documents/mugge/sc-projects/recordings/mesopelagial1.wav");
	wait(0.02);

	~player1 = ~part1.play(t, quant:t.beatsPerBar);
	160.wait;

	t.schedAbs(t.nextBar, {~player1.stop; nil});

	12.wait;

	~gong1.play;
	8.wait;

	~player2 = ~part2.play(t, quant:2);
	240.wait;
	t.schedAbs(t.nextBar, {~player2.stop; nil});

	6.wait;

	~gong2.play;
	8.wait;

	~player1 = ~part1.play(t, quant:t.beatsPerBar);
	160.wait;

	t.schedAbs(t.nextBar, {~player1.stop; nil});

	12.wait;

	3.collect{~grains3.play(t)};

	200.wait;

	s.stopRecording;

	"the end.".postln;

}.play(t);
)

/////////////////////////// kthxbye! ////////////////////////////////
s.quit;