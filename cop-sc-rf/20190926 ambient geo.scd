(
~routine = {
	Ndef(\fm7).play;
	Ndef(\fm7).fadeTime = 20;
	while (true) {
		Ndef(\fm7, {
			var ctls, mods, chans, freq, freqs;
			freq = 40.midicps;
			freqs = 6.collect { |i|
				Demand.kr(
					Impulse.kr(([2,2.1,4,4.1,8, 8.1].choose)/100),
					0,
					Dseries(
						Drand(
							[freq, freq+1, freq+2, 2*freq, 2*freq+1, 2*freq+2, 3*freq, 3*freq+1, 3*freq+2, 3*freq+3],
							inf),
						50,
						40
					)
				);
			};
			ctls = 6.collect { |i|
				[freqs[i], rrand(0,pi), rrand(0,1)]
			};
			mods = 6.collect { |i|
				6.collect { |j|
					if (0.1.coin) {
						LFNoise1.kr(0.1).range(0, 1)
					} {
						0
					}
				};
			};
			chans = Splay.ar(FM7.ar(ctls, mods)) * -12.dbamp;
		}).play;
		"change".postln;
		(20..60).choose.wait;
	}
}.fork;
)

~routine.stop;
Ndef(\fm7).stop(30);
Ndef(\fm7).play

VSTPlugin.search

(
VSTPlugin.pluginKeys.do { |plug|
	plug.postln;
};
)

(
SynthDef(\insert, { |bus|
	ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), 2));
}).add;
)

(
{
	~insert1 = Synth(\insert, [bus: 0], addAction: \addToTail);
	~insert2 = Synth(\insert, [bus: 0], addAction: \addToTail);
	~insert3 = Synth(\insert, [bus: 0], addAction: \addToTail);
	~vst1 = VSTPluginController(~insert1);
	~vst1.open("GlissEQ", editor: true);
	2.wait;
	~vst1.editor;
	~vst2 = VSTPluginController(~insert2);
	~vst2.open("ValhallaVintageVerb", editor: true);
	2.wait;
	~vst2.editor;
	~vst3 = VSTPluginController(~insert3);
	~vst3.open("TDR Kotelnikov", editor: true);
	3.wait;
	~vst3.editor;
}.fork;
)

~vst3.editor;
