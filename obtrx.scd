(
SynthDef.new(\obtrx, {
	var out = \out.kr(0),
	in = \in.kr(0),
	gate = \gate.kr(0),
	osc1_freq = \osc1_freq.kr(440).spec_(ControlSpec(1, 10000, \exp, 0, 440, units: " Hz")),
	osc1_shape = \osc1_shape.kr(0).spec_(ControlSpec(0,4)),
	osc1_pulse_width = \osc1_pulse_width.kr(0.5).spec_(ControlSpec(0,1)),
	osc1_level = \osc1_level.kr(1).spec_(ControlSpec(0,1)),
	osc2_freq = \osc2_freq.kr(440).spec_(ControlSpec(1, 10000, \exp, 0, 440, units: " Hz")),
	osc2_shape = \osc2_shape.kr(0).spec_(ControlSpec(0,4)),
	osc2_pulse_width = \osc2_pulse_width.kr(0.5).spec_(ControlSpec(0,1)),
	osc2_level = \osc2_level.kr(1).spec_(ControlSpec(0,1)),
	osc3_freq = \osc3_freq.kr(1).spec_(ControlSpec(0.05, 500, \exp, 0, 1, units: " Hz")),
	osc3_shape = \osc3_shape.kr(0).spec_(ControlSpec(0,4)),
	osc3_level = \osc3_level.kr(1).spec_(ControlSpec(0,1)),
	noise_level = \noise_level.kr(0).spec_(ControlSpec(0,1)),
	sample_and_hold_freq = \sample_and_hold_freq.kr(1),
	sample_and_hold_level = \sample_and_hold_level.kr(1),
	ringmod_level = \ringmod_level.kr(0),
	filter_freq = \filter_freq.kr(0),
	filter_shape = \filter_shape.kr(0),
	filter_resonance = \filter_resonance.kr(0);

	var osc1, osc2, osc3, osc3_prefader, noise, sample_and_hold, input, filter, adsr, ringmod, fx1, output, output_channel1, output_channel2;

	// osc1
	osc1 = SelectX.ar(osc1_shape, [SinOsc.ar(osc1_freq), LFTri.ar(osc1_freq), Pulse.ar(osc1_freq, osc1_pulse_width), VarSaw.ar(osc1_freq, 0, osc1_pulse_width), Blip.ar(osc1_freq, osc1_pulse_width*30)]);
	osc1 = osc1 * osc1_level;

	// osc2
	osc2 = SelectX.ar(osc2_shape, [SinOsc.ar(osc2_freq), LFTri.ar(osc2_freq), Pulse.ar(osc2_freq, osc2_pulse_width), VarSaw.ar(osc2_freq, 0, osc2_pulse_width), Blip.ar(osc2_freq, osc2_pulse_width*30)]);
	osc2 = osc2 * osc2_level;

	// osc3
	osc3_prefader = SelectX.ar(osc3_shape, [SinOsc.ar(osc3_freq), LFTri.ar(osc3_freq), Pulse.ar(osc3_freq, 0.5), Saw.ar(osc3_freq), WhiteNoise.ar]);
	osc3 = osc3_prefader * osc3_level;

	// noise
	noise = PinkNoise.ar * noise_level;

	// sample and hold
	sample_and_hold = Latch.ar(osc3_prefader, Impulse.kr(sample_and_hold_freq));
	sample_and_hold = sample_and_hold * sample_and_hold_level;

	// output
	output = Pan2.ar(output_channel1, 0) + Pan2.ar(output_channel2, 0);
	Out.ar(out, output);

}).add;
)

SynthDescLib.global.at(\obtrx).specs;
SynthDescLib.global.at(\obtrx).makeGui;

a = Synth(\obtrx);
a.set(\osc1_freq, 200);

(
p = Pmono(\obtrx,
	\osc1_freq, Pwhite(200, 800),
	\dur, 1
).play;
)