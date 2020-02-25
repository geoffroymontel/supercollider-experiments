VSTPlugin.search;

(
SynthDef(\repro5, { |bus|
	var sig;

	sig = VSTPlugin.ar(nil, 2, id: \synth1);
	sig = VSTPlugin.ar(sig, 2, id: \fx1);

	Out.ar(bus, sig);
}).add;
)

~synth = Synth(\repro5, [bus: 0], addAction: \addToTail);
~synthSynth1 = VSTPluginController(~synth, \synth1);
~synthSynth1.open("Repro-5", editor: true);
~synthSynth1.editor;
~synthFx1 = VSTPluginController(~synth, \fx1);
~synthFx1.open("ValhallaDelay", editor: true);
~synthFx1.editor;

~synthSynth1.midi

(
Pdef(\1, Pbind(*[
	type: \midi,
	midiout: ~synthSynth1.midi,
	chan: 0,
	root: 3,
	octave: 4,
	scale: Scale.minor,
	degree: Pseq([0, 2, 4, 6, 4, 2, 3], inf),
	dur: 8
])).play(quant: 1);
)

Pdef(\1).stop;