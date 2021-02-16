// cf. https://scsynth.org/t/buchla-ish-synth-based-on-passersby-norns-script/3130
(
// Synth voice
SynthDef(\west, {
	arg out, t_gate = 1, gate = 1, killGate = 1, fadeIn = 0.01, fadeOut = 0.01, freq = 220, pitchBendRatio = 1, glide = 0, fm1Ratio = 0.66, fm2Ratio = 3.3, fm1Amount = 0.0, fm2Amount = 0.0,
	vel = 0.7, pressure = 0, timbre = 0, waveShape = 0, waveFolds = 0, envType = 0, attack = 0.04, peak = 10000, decay = 1, amp = 1, lfoShape = 0, lfoFreq = 0.5,
	lfoToFreqAmount = 0, lfoToWaveShapeAmount = 0, lfoToWaveFoldsAmount = 0, lfoToFm1Amount = 0, lfoToFm2Amount = 0,
	lfoToAttackAmount = 0, lfoToPeakAmount = 0, lfoToDecayAmount = 0, lfoToReverbMixAmount = 0, drift = 0, dur=10, pan=0;

	var i_nyquist = SampleRate.ir * 0.5, signal, controlLag = 0.005, i_numHarmonics = 44,
	modFreq, mod1, mod2, mod1Index, mod2Index, mod1Freq, mod2Freq, sinOsc, triOsc, additiveOsc, additivePhase,
	filterEnvVel, filterEnvLow, lpgEnvelope, lpgSignal, asrEnvelope, asrFilterFreq, asrSignal, killEnvelope, i_driftRate = 0.15, maxDecay=8;

	// Make lfos
	var lfo = Select.kr(lfoShape, [
		LFTri.kr(lfoFreq),
		LFSaw.kr(lfoFreq),
		LFPulse.kr(lfoFreq),
		LFDNoise0.kr(lfoFreq * 2)
	]);

	var lfoArray = Array.fill(9, 0);
	lfoArray[0] = (lfo * lfoToFreqAmount * 18).midiratio; // Freq ratio
	lfoArray[1] = (lfo * lfoToWaveShapeAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Wave Shape
	lfoArray[2] = ((lfo * lfoToWaveFoldsAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2; // Wave Folds
	lfoArray[3] = ((lfo * lfoToFm1Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM1 Amount
	lfoArray[4] = ((lfo * lfoToFm2Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM2 Amount
	lfoArray[5] = ((lfo * lfoToAttackAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Attack
	lfoArray[6] = (((lfo * lfoToPeakAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 24).midiratio; // Peak multiplier
	lfoArray[7] = ((lfo * lfoToDecayAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Decay
	lfoArray[8] = (lfo * lfoToReverbMixAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Reverb Mix


	// LFO ins
	freq = (freq * lfoArray[0]).clip(0, i_nyquist);
	waveShape = (waveShape + lfoArray[1]).clip(0, 1);
	waveFolds = (waveFolds + lfoArray[2]).clip(0, 3);
	fm1Amount = (fm1Amount + lfoArray[3]).clip(0, 1);
	fm2Amount = (fm2Amount + lfoArray[4]).clip(0, 1);
	attack = (attack + lfoArray[5]).clip(0.003, 8);
	peak = (peak * lfoArray[6]).clip(100, 10000);
	decay = (decay + lfoArray[7]).clip(0.01, maxDecay);

	// Lag inputs
	freq = Lag.kr(freq * pitchBendRatio, 0.007 + glide);
	fm1Ratio = Lag.kr(fm1Ratio, controlLag);
	fm2Ratio = Lag.kr(fm2Ratio, controlLag);
	fm1Amount = Lag.kr(fm1Amount.squared, controlLag);
	fm2Amount = Lag.kr(fm2Amount.squared, controlLag);

	vel = Lag.kr(vel, controlLag);
	waveShape = Lag.kr(waveShape, controlLag);
	waveFolds = Lag.kr(waveFolds, controlLag);
	attack = Lag.kr(attack, controlLag);
	peak = Lag.kr(peak, controlLag);
	decay = Lag.kr(decay, controlLag);

	// Modulators
	mod1Index = fm1Amount * 22;
	mod1Freq = freq * fm1Ratio * LFNoise2.kr(freq: 0.1, mul: 0.001, add: 1);
	mod1 = SinOsc.ar(freq: mod1Freq, phase: 0, mul: mod1Index * mod1Freq, add: 0);
	mod2Index = fm2Amount * 12;
	mod2Freq = freq * fm2Ratio * LFNoise2.kr(freq: 0.1, mul: 0.005, add: 1);
	mod2 = SinOsc.ar(freq: mod2Freq, phase: 0, mul: mod2Index * mod2Freq, add: 0);
	modFreq = freq + mod1 + mod2;

	// Sine and triangle
	sinOsc = SinOsc.ar(freq: modFreq, phase: 0, mul: 0.5);
	triOsc = VarSaw.ar(freq: modFreq, iphase: 0, width: 0.5, mul: 0.5);

	// Additive square and saw
	additivePhase = LFSaw.ar(freq: modFreq, iphase: 1, mul: pi, add: pi);
	additiveOsc = Mix.fill(i_numHarmonics, {
		arg index;
		var harmonic, harmonicFreq, harmonicCutoff, attenuation;

		harmonic = index + 1;
		harmonicFreq = freq * harmonic;
		harmonicCutoff = i_nyquist - harmonicFreq;

		// Attenuate harmonics that will go over nyquist once FM is applied
		attenuation = Select.kr(index, [1, // Save the fundamental
			(harmonicCutoff - (harmonicFreq * 0.25) - harmonicFreq).expexp(0.000001, harmonicFreq * 0.5, 0.000001, 1)]);

		(sin(additivePhase * harmonic % 2pi) / harmonic) * attenuation * (harmonic % 2 + waveShape.linlin(0.666666, 1, 0, 1)).min(1);
	}
	);

	// Mix carriers
	signal = LinSelectX.ar(waveShape * 3, [sinOsc, triOsc, additiveOsc]);

	// Fold
	signal = Fold.ar(in: signal * (1 + (timbre * 0.5) + (waveFolds * 2)), lo: -0.5, hi: 0.5);

	// Hack away some aliasing
	signal = LPF.ar(in: signal, freq: 12000);

	// Noise
	signal = signal + PinkNoise.ar(mul: 0.003);

	// LPG
	filterEnvVel = vel.linlin(0, 1, 0.5, 1);
	filterEnvLow = (peak * filterEnvVel).min(300);

	lpgEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.003, decay], curve: [4, -20]), gate: t_gate, timeScale: dur);
	lpgSignal = RLPF.ar(in: signal, freq: lpgEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel), rq: 0.9);
	lpgSignal = lpgSignal * EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.002, decay], curve: [4, -10]), gate: t_gate, timeScale: dur);

	// ASR with 4-pole filter
	asrEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [attack, decay], curve: -4, releaseNode: 1), gate: gate);
	asrFilterFreq = asrEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel);
	asrSignal = RLPF.ar(in: signal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = RLPF.ar(in: asrSignal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = asrSignal * EnvGen.ar(envelope: Env.asr(attackTime: attack, sustainLevel: 1, releaseTime: decay, curve: -4), gate: gate);

	signal = Select.ar(envType, [lpgSignal, asrSignal]);

	signal = signal * vel.linlin(0, 1, 0.2, 1) ;

	// Saturation amp
	signal = tanh(signal * pressure.linlin(0, 1, 1.5, 3) * amp).softclip;

	// main Envelope
	signal = signal * EnvGen.kr(
		Env([0.0,1.0,1.0,0], [fadeIn, fadeOut], releaseNode: 2),
		gate: killGate,
		doneAction: 2
	);

	// Pan
	signal = Pan2.ar(signal, pan);

	Out.ar(out, signal);

}).add;
)

// Test
(
Pmono(\west,
	\freq, Pwhite(100.0,2400.0),
	\dur, Pseq([Pwhite(0.1,0.5,1), Rest(0.1)],inf),
	\gate, 1,
	\pitchBendRatio, Pwhite(0.0,1.0),
	\glide, Pwhite(0.25,0.9),
	\fm1Ratio, Pwhite(0.25,3.0),
	\fm2Ratio, Pkey(\fm1Ratio) + Pwhite(0.25,3.0),
	\fm1Amount, Pwhite(0.0,0.25),
	\fm2Amount, Pwhite(0.0,0.5),
	\vel, 0.5,
	\pressure, 0.5, //Pwhite(),
	\timbre, Pwhite(0.0,0.75),
	\waveShape, Pwhite(0.0,0.5),
	\waveFolds, Pwhite(0.0,0.5),
	\envType, Pwhite(0,1),
	\attack, Pwhite(0.01,0.1),
	\peak, Pwhite(1500.0,10000.0),
	\decay, Pwhite(1.0,4.0),
	\pan, Pbrown(-0.5,0.5,0.001),
	\amp, 0.5,
	\lfoShape, 0, //Pwhite(),
	\lfoFreq, Pwhite(0.1,5.0),
	\lfoToFreqAmount, Pwhite(),
	\lfoToWaveShapeAmount, Pwhite(),
	\lfoToWaveFoldsAmount, Pwhite(),
	\lfoToFm1Amount, Pwhite(),
	\lfoToFm2Amount, Pwhite(),
	\lfoToAttackAmount, Pwhite(),
	\lfoToPeakAmount, Pwhite(),
	\lfoToDecayAmount, Pwhite(),
	\lfoToReverbMixAmount, Pwhite(),
	\drift, Pwhite()
).play
)

// Midi Control

MIDIClient.init;
MIDIIn.connectAll;

a = Synth(\west);
a.set(\killGate, 0); // kill synth

(
MIDIFunc.cc({ |value, cc, chan|
	postf("% % %\n", value, cc, chan);
	switch(chan,
		0, { Ndef(\test).set(\freq1, value.linexp(0, 127, 20, 14000)) },
		1, { Ndef(\test).set(\freq2, value.linexp(0, 127, 20, 14000)) },
		2, { Ndef(\test).set(\freq3, value.linexp(0, 127, 20, 14000)) },
		3, { Ndef(\test).set(\res, value.linlin(0, 127, 0, 1)) }
	);
}, 7);
)