// https://gist.github.com/scztt/01d677451891ecccd7eb0744aa4e83c6

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");

Ndef(\b).fadeTime = 10;
(
// Ndef(\b).clear;
Ndef(\b, {

	var sig, freqShiftBump, plainSig, wind, feed, phase, feedAmp, peaks, peakLimit, onOff, feedDelay;
	var chordTrig, chordEnv;

	onOff = ToggleFF.kr(Dust.kr(0.4)).lag(2);
	onOff = Trig.kr(1, 10);

	plainSig = PlayBuf.ar(1, b, 1/4, loop:1);
	plainSig = PitchShift.ar(plainSig, 1/[10, 10], 3, 0, 0.01);
	plainSig = HPF.ar(plainSig, 8000);

	phase = LFDNoise3.ar(LFDNoise3.kr().exprange(1/40, 0.2)).range(0, BufSamples.kr(b));
	phase = phase + LFTri.ar(60).range(0, 1/100 * SampleRate.ir);

	sig = BufRd.ar(1, b, phase, interpolation:4);

	feedDelay = LPF.ar(sig, SinOsc.kr(1/16).exprange(200, 4200)).exprange(0.1, 7);

	feed = LocalIn.ar(2);
	feed = -4.dbamp * feed;
	feed = feed + (
		SelectX.kr(onOff, [2.dbamp, -8.dbamp])
		* Pluck.ar(feed, sig, 1, 1/[feedDelay, feedDelay + 4], 4, 0.15)
	);
	feed = BLowShelf.ar(feed, 80, 1, 7);

	4.do {
		feed = MidEQ.ar(feed, LFDNoise3.kr(2).exprange(400, 12000), 0.03, 4)
	};

	feed = Rotate2.ar(feed[0], feed[1], SinOsc.kr(1/8).range(-0.1, 0.1));

	peakLimit = 0.8;
	peaks = ((feed - peakLimit) * (feed > peakLimit)) +  ((feed + peakLimit) * (feed < peakLimit.neg));
	peaks = BLowPass4.ar(peaks, 100, 0.3);
	peaks = LeakDC.ar(peaks);
	peaks = Pluck.ar(peaks, peaks, 1, 1/[46, 48.1].midicps, 4, 0.3);
	peaks = LeakDC.ar(peaks);

	feed = feed + peaks;
	feed = LeakDC.ar(feed);

	freqShiftBump = Decay.ar(Dust.ar(0.2), 4).linlin(0, 1, 0, 2);
	feedAmp = Amplitude.ar(feed[0], 0.5, 2);
	feed = feed.blend(
		FreqShift.ar(
			feed,
			(freqShiftBump * [1, -1]) + feedAmp.lincurve(0, 1, 0, [0.3, -0.3], 1).poll
		),
		feedAmp
	);
	feed = feed * (
		1 - (feedAmp * Env.perc(0.01, feedAmp.linexp(0, 1, 0.7, 0.04)).ar(
			gate:		Impulse.ar(feedAmp.linexp(0, 1, 0.6, 22)),
		))
	);
	feed = feed.softclip;


	sig = (feed + plainSig).blend(
		sig + feed,
		onOff
	);
	sig = LeakDC.ar(sig);

	chordTrig = Impulse.kr(1/16);
	chordEnv = Env.sine(2).kr(gate:chordTrig).poll;
	sig = sig + Pluck.ar(
		chordEnv * sig,
		sig,
		1,
		(50 + [0, 2, TChoose.kr(chordTrig, [7, 9]), 12]).midicps.reciprocal,
		6,
		0.3,
		0.1
	).flatten.clump(2).sum;

	wind = 0.4;

	sig = [
		PitchShift.ar(sig, wind, SinOsc.kr(1/13.5).range(-16, -9).midiratio, 0.1),
		PitchShift.ar(sig, wind, SinOsc.kr(1/12.5).range(-0.03, 0.4).midiratio, 0.1),
		PitchShift.ar(sig, wind, 1),
		PitchShift.ar(sig, wind, SinOsc.kr(1/19.0).range(-0.04, 0.7).midiratio, 0.01),
		PitchShift.ar(sig, wind, SinOsc.kr(1/17.5).range(4, 22).midiratio, 0.1),
	];

	sig = SelectX.ar(
		SinOsc.ar(1/8).range(0.5, sig.size - 1.5),
		sig
	);

	LocalOut.ar(sig);

	sig = Compander.ar(sig, sig[0], 0.5, 1, 1/40);

	sig;
}).play
)

// another one
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");

(
Ndef(\b, {

	var sig, tick, freqShiftBump, plainSig, wind, feed, phase, feedAmp, peaks, peakLimit, onOff, feedDelay;

	onOff = ToggleFF.kr(Dust.kr(0.4)).lag(0.5);

	tick = 2.collect {
		Impulse.ar(LFDNoise3.ar(LFDNoise3.ar(1).exprange(0.1, 10)).exprange(0.03, 1))
	};

	feed = LocalIn.ar(2);
	feed = LeakDC.ar(feed);
	feed = -3.dbamp * feed;
	feed = feed - FreqShift.ar(feed, [-0.03, 0.05]);
	feed = Balance2.ar(feed[0], feed[1], SinOsc.kr(1/4).range(-0.4, 0.4));
	feed = PitchShift.ar(feed, 1/20, 0.9);
	feed = feed + (10.dbamp * PitchShift.ar(feed, 1/10, 0.7));
	feed = feed + DelayC.ar(feed, 1, [3/4, 5/4], -10.dbamp);

	phase = TRand.ar(0, BufSamples.kr(b), tick);
	phase = phase.lag3(0.014).blend(
		phase.lag3(20),
		0.4
	);
	phase = phase + (BLowPass.ar(feed, 180, 0.5) * TExpRand.ar(0.5, 100, PulseDivider.ar(tick, 8)));

	phase = phase + LFTri.ar(
		Env.perc().ar(gate:tick).lincurve(0, 1, [30, 32].midicps, 100, 4)).range(
		0,
		1 / TExpRand.ar(100, 1000, PulseDivider.ar(tick, [4, 3])) * SampleRate.ir
	);

	sig = BufRd.ar(1, b, phase, interpolation:4);
	sig = BHiShelf.ar(sig, 9000, 0.6, 6);
	sig = LeakDC.ar(sig);
	sig = [
		sig[0] + (-10.dbamp * DelayC.ar(sig[1], 0.1, 1/303)),
		sig[1] + (-10.dbamp * DelayC.ar(sig[0], 0.1, 1/213))
	];

	feed = (-10.dbamp * feed).softclip;

	sig = sig + (-28.dbamp * JPverb.ar(HPF.ar(sig, 2000), 0.2, 0.3, 0.5, 0.4, 0.01, 10));

	LocalOut.ar(sig + feed);

	sig = sig + (-0.dbamp * DelayC.ar(feed, 1/6));
	sig = BLowShelf.ar(sig, 40, 0.9, 9);

	sig = Compander.ar(sig, sig[0], 0.5, 1, 1/40);

	sig;
}).play
)

(
Ndef(\a).free;
Ndef(\b).free;
)

