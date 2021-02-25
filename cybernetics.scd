// 1. Feedback loop with a filter only.
// https://youtu.be/MnYkqlSIr_I?t=177

(
Ndef(\test, {
	var in, sig;
	in = LocalIn.ar(1) * -60.dbamp;
	sig = DFM1.ar(in, \filter_freq.kr(1000, 0.1), \filter_res.kr(0.1, 0.1));
	LocalOut.ar(sig);
	sig.tanh;
}).play;

Spec.add(\filter_freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\filter_res,[0, 1.5, 'lin', 0.001, 0.1].asSpec);
)

Ndef(\test).gui;

// 2. Feedback loop with sine oscillator
// https://youtu.be/MnYkqlSIr_I?t=268

(
Ndef(\test, {
	var freq, sig;
	freq = LocalIn.ar(1);
	sig = DFM1.ar(SinOsc.ar(freq: freq * \sin_freq.kr(1.0, 0.1)), \filter_freq.kr(1000, 0.1), \filter_res.kr(0.1, 0.1));
	LocalOut.ar(sig);
	sig.tanh;
}).play;

Spec.add(\freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\sin_freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\filter_freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\filter_res,[0, 1.5, 'lin', 0.001, 0.1].asSpec);

Ndef(\test).gui
)

// 3. Feedback loop with two sine oscillators and FM synthesis
// https://youtu.be/MnYkqlSIr_I?t=501

(
Ndef(\test, {
	var in, sig, sine1, sine2;
	in = LocalIn.ar(1);
	sine2 = SinOsc.ar(\sin2_freq.kr(440.0));
	sine1 = SinOsc.ar(freq: \sin_freq.kr(440.0) * (1 + (\fm_amount.kr(0) * sine2)) * in);
	sig = DFM1.ar(
		sine1,
		\filter_freq.kr(1000),
		\filter_res.kr(0.1)
	);
	LocalOut.ar(sig);
	LeakDC.ar(sig.tanh);
}).play;

Spec.add(\freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\sin_freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\sin_freq2, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\fm_amount, [0, 10, 'lin', 0, 0].asSpec);
Spec.add(\filter_freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\filter_res,[0, 1.5, 'lin', 0.001, 0.1].asSpec);

Ndef(\test).gui;
)

// 4. Peak
// https://youtu.be/oGjpLmFJiT8?t=228

(
Ndef(\test, {
	var in, sig, osc1, osc2;
	in = LocalIn.ar(1);
	osc1 = SinOsc.ar(freq: \osc1_freq.kr(150)) * \osc1_amp.kr(0.4);
	osc2 = SinOsc.ar(freq: \osc2_freq.kr(448)) * \osc2_amp.kr(-0.3);
	osc1.max(osc2).distort;
}).play;

Spec.add(\osc1_freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\osc2_freq, [0.1, 14000, 'exp', 0, 440, "Hz"].asSpec);
Spec.add(\osc1_amp, [-1, 1, 'lin', 0, 0].asSpec);
Spec.add(\osc2_amp, [-1, 1, 'lin', 0, 0].asSpec);

Ndef(\test).gui;
)

