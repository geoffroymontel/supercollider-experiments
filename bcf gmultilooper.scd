~bcf = BCF2000Mixer.new(s, 8, 1);
~looper = GMultiLooper.new(4, [0, 2, 4, 6] + ~bcf.inBuses[0].index);

VSTPlugin.search(s, "c:/audio/vst")

(
SynthDef(\insert, { |bus = 0|
    ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), 2));
}).add;
)

~synth = Synth(\insert, addAction: \addToTail);
~synth.free
~fx = VSTPluginController(~synth);
~fx.browse;
~fx.editor;

{ SinOsc.ar * -20.dbamp }.play