VSTPlugin.search(s, ["C:/audio/vst"], false, true, action: { "vst plugin search done".postln });

VSTPlugin.plugins(s);
VSTPlugin.pluginKeys(s);

(
var plugs;
plugs = VSTPlugin.pluginKeys(s);
plugs.do { |plug|
	plug.postln;
}
)

// VST FX

(
// a simple stereo insert FX which reads from an audio bus
// and replaces the content with the processed output:
SynthDef.new(\insert, {arg bus;
    ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), 2));
}).add;

// load sound file
~buf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
// soundfile player
SynthDef(\test, {arg out = 0;
    Out.ar(out,
        PlayBuf.ar(1, ~buf, BufRateScale.kr(~buf), loop: 1).dup * 0.5;
    )
}).add;
)

(
// allocate an FX bus
~fxBus = Bus.audio(s, 2);
// play test signal on FX bus
~test = Synth(\test, [\out, ~fxBus]);
// send FX bus to output
SynthDef(\output, {arg in = 0, out = 0;
    Out.ar(out, In.ar(in, 2))
}).play(~test, [\in, ~fxBus, \out, 0], addAction: \addAfter);
)

// add an insert FX to the bus (after the test signal)
~insert = Synth(\insert, [\bus, ~fxBus], ~test, addAction: \addAfter);
~fx1 = VSTPluginController(~insert);
// open a plugin from the GUI and play with the parameters
~fx1.open("C:/audio/vst/reverb/ValhallaRoom_x64.dll", editor: true);
~fx1.editor;

~fx1.numParameters;
~fx1.info[\parameterNames];
~fx1.info[\parameterLabels];
~fx1.set(0, rand(1.0));

// add another insert FX (after '~fx1'):
~fx2 = VSTPluginController(Synth(\insert, [\bus, ~fxBus], ~fx1.synth, addAction: \addAfter));
// open plugin
~fx2.open("C:/audio/vst/delay/EchoBoy.dll", editor: true);
~fx2.editor;
// change the FX order dynamically, e.g. move '~fx2' before '~fx1':
~fx2.synth.moveBefore(~fx1.synth);

~fx1.synth.free; // remove from FX chain
~fx2.synth.free; // remove from FX chain


// VSTi

(
// a simple stereo insert FX which reads from an audio bus
// and replaces the content with the processed output:
SynthDef.new(\vsti, { |bus = 0|
    Out.ar(bus, VSTPlugin.ar(nil, 2));
}).add;
)

~vst = Synth(\vsti);
~vstPluginController = VSTPluginController(~vst);
~vstPluginController.open("Repro-5", editor: true);
~vstPluginController.editor;

(
Pbind(*[
	type: \midi,
	midiout: ~vstPluginController.midi,
	legato: 0.5,
	dur: 0.2,
	midinote: [66, 69, 74],
]).play;
)

~vstPluginController.numParameters;
~vstPluginController.set(rand(~vstPluginController.numParameters), rand(1.0));
