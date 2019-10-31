(
SynthDef.new(\dx7Algo31, {
	var freq = \freq.kr(440);
	var out = \out.kr(0);
	var freqCoeff = \freqCoeff.kr(1.0 ! 6);
	var volCoeff = \volCoeff.kr(1.0 ! 6);
	var feedback = \feedback.kr(0.0);

	var sig;
	var sigOsc5;

	sigOsc5 = SinOsc.ar(
		freq: (freq * freqCoeff[5]),
		mul: freq * volCoeff[5]
	) +  (LocalIn.ar(1) * feedback);

	LocalOut.ar(sigOsc5);

	sig = (0..3).collect({ |i| SinOsc.ar(freq * freqCoeff[i]) * volCoeff[i]}).sum;

	sig = sig + SinOsc.ar(
		freq: (freq * freqCoeff[4]) + sigOsc5,
		mul: volCoeff[4]
	);

	sig = (sig / 5);

	Out.ar(out, sig);
}).add;
)

x = Synth(\dx7Algo31, [freq: 200, out: 0]);
x.set(\freqCoeff, [1.0, 2.0, 1.0, 1.0, 1.0, 1.0]);
x.set(\volCoeff, [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]);
x.set(\freq, 200);
x.set(\feedback, 0.4);
