(
// Ndef(\flanger).fadeTime = 20

Ndef(\flanger, {
	var sig, sigPluck, local, f, delay, cutoff, rate, width, pluckOffset, pluckCoef, bassTrig;
	var pulse, f0, famp, dist;

	sig = Ndef(\in).ar(2)[0];

	f0 = Select.kr(LFTri.kr(1/64).range(0, 3), [44, 43, 41]).lag(12);
	f = [
		43,
		// f0,
		43.05,
		50
	];

	f = ([
		f[0], f[0] + 0.1, f[1], f[2], f[0] + 12, f[1] + 12,
	]);

	f = f.midicps;
	f = f.scramble;

	f.postln;

	famp = 1;

	rate = 4;

	pluckOffset = 5;
	pluckCoef = 0.9;

	width = SinOsc.kr(1/34).range(0.1, 0.9);

	pulse = Impulse.ar(rate / 2) + Impulse.ar(rate / 2, 1/2.2);
	pulse = pulse * LFNoise2.ar(20).range(-20, 0).dbamp;
	pulse = Decay.ar(pulse, LFNoise2.ar(1).exprange(0.03, 0.8));

	delay = f / 2;

	cutoff = SinOsc.kr(1/60, rrand(0, 2.0)).lincurve(-1, 1, 100, 3400, 3);

	sig = BLowPass4.ar(VarSaw.ar(f, 0, 0, famp).sum, cutoff, 0.8);
	sig = LeakDC.ar(sig);
	bassTrig = Impulse.ar(1/20);

	local = LocalIn.ar(2);
	local = Rotate2.ar(local[0], local[1], SinOsc.kr(1/16).range(-1, 1));
	local = SoftClipAmp8.ar(local, 0.4);
	local = BLowPass.ar(local, cutoff);
	local = PitchShift.ar(local, 4 / f, [0.5, 4], 0.01).sum;
	local = Decimator.ar(local, f * 8, 16).sum;
	local = -20.dbamp * local;
	local = local + Splay.ar(DelayC.ar(local, 4, { rrand(0.0, 4.0) } ! 6, 0.5));

	sigPluck = delay.collect({
		|delay, i|
		delay = [
			LFCub.ar(1 / rrand(30, 36), 2.0.rand).range(delay - pluckOffset, delay + pluckOffset)
			+ SinOsc.ar(1/2).range(-0.2, 0.2),
			delay * 4.05
		];
		PeakFollower.kr(sig, 0.9) * Pluck.ar(
			sig + local, sig,
			4,
			delay.reciprocal,
			9,
			[pluckCoef, 0.1],
			[1, -16.dbamp]
		).sum;
	});

	sig = SoftClipAmp8.ar(sig + sigPluck, -30.dbamp, 1);
	sig = Splay.ar(sig);
	sig = sig + PitchShift.ar(sig, 2, 0.25);

	sig = LeakDC.ar(sig);
	LocalOut.ar(sig);

	sig = sig + (-20.dbamp * AdCVerb.ar(HPF.ar(sig, 900), 9));

	sig = -6.dbamp * sig;

}).play;
)