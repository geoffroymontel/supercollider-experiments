s.boot;
VSTPlugin.search;

(
SynthDef(\dexed, { |out = 0|
	var snd;
	snd = VSTPlugin.ar(nil, 2, id: \dexed);
	snd = VSTPlugin.ar(snd, 2, id: \reverb);
	Out.ar(out, snd);
}).add;
)

~synth = Synth(\dexed);

(
~dexed = VSTPluginController.new(~synth, \dexed);
~dexed.open("Dexed", editor: true);
// ~dexed.gui; // QT
~reverb = VSTPluginController.new(~synth, \reverb);
~reverb.open("ValhallaPlate", editor: true);
)

(
~dexed.editor;
~reverb.editor;
)

(
Pbind(*[
	type: \midi,
	midiout: ~dexed.midi,
	degree: Pwhite(0, 12, inf),
    \dur, Prand(#[0.125, 0.25, 0.5, 1], inf),
    \legato, Pexprand(0.5, 2.0, inf),
    \amp, Pexprand(0.5, 1.0, inf)
]).play;
)