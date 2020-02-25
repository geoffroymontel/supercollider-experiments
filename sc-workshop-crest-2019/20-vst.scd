s.boot;
s.makeGui;

// reading samples

~buffer = Buffer.read(s, "/Users/geoffroy/dev/supercollider-experiments/sc-workshop-crest-2019/cusb-cyl5985d.wav");
~buffer.play;

// introducing synthdef

(
{
	SinOsc.ar([440, 441]);
}.play;
)

// behind the scenes, that's what SC does

(
SynthDef(\sine, {
	Out.ar(0, SinOsc.ar([440, 441]));
}).add;
)
Synth(\sine);

// you can add parameters to  your synth definitions

(
SynthDef(\sine, { |out = 0, freq = 440|
	Out.ar(out, SinOsc.ar([freq, freq * (1 + rrand(10e-4, 10e-2))])) * -12.dbamp;
}).add;
)

~synth1 = Synth(\sine);
~synth2 = Synth(\sine, [freq: 600]);
~synth3 = Synth(\sine, [freq: exprand(30, 500)]);

~synth1.free;
~synth2.free;
~synth3.free;

// sampler

(
SynthDef.new(\sampler, { |out = 0, bufnum, gate=1, startPos=0.0, rate=1.0, amp=1.0, pan=0.0|
	var snd;
	snd = PlayBuf.ar(2, bufnum, rate * BufRateScale.ir(bufnum), 1, startPos * BufFrames.ir(bufnum), doneAction: Done.freeSelf);
	snd = snd * EnvGen.ar(Env.asr(0.01, 1.0, 0.01), gate, doneAction: Done.freeSelf);
	snd = Balance2.ar(snd[0], snd[1], pan) * amp;
	Out.ar(out, snd);
}).add;
)

~synth = Synth(\sampler, [bufnum: ~buffer]);
~synth.set(\gate, 0); // stop it !

~synth = Synth(\sampler, [out: 0, bufnum: ~buffer, startPos: 0.0, rate: 1.0, amp: -12.dbamp]);
~synth = Synth(\sampler, [out: 0, bufnum: ~buffer, startPos: 0.0, rate: 4.midiratio, amp: -12.dbamp]);
~synth = Synth(\sampler, [out: 0, bufnum: ~buffer, startPos: 0.5, rate: 0.5, amp: -12.dbamp, pan: -1]);
~synth = Synth(\sampler, [out: 0, bufnum: ~buffer, startPos: 0.25, rate: 0.25, amp: -12.dbamp, pan: 1]);

// loop

(
Pbind(*[
	instrument: \sampler,
	bufnum: ~buffer,
	startPos: 0.5,
	rate: 1.0,
	dur: 4,
	legato: 1
]).play(quant: 1);
)

(
Pbind(*[
	instrument: \sampler,
	bufnum: ~buffer,
	startPos: Pwhite(0.3, 0.8, inf),
	rate: Prand([1.0, 0.5, 0.25], inf),
	dur: Pwhite(0.1, 4, inf),
	legato: 1
]).play(quant: 1);
)

// avec un autre son

~buffer = Buffer.read(s, "/Users/geoffroy/dev/supercollider-experiments/sc-workshop-crest-2019/evier.wav");
~buffer.play;

// on rajoute du pleurage
(
SynthDef.new(\sampler, { |out = 0, bufnum, gate=1, startPos=0.0, rate=1.0, amp=1.0, pan=0.0|
	var snd;
	snd = PlayBuf.ar(2, bufnum, rate * BufRateScale.ir(bufnum) * LFNoise1.kr(1).range(1-10e-3, 1+10e-3), 1, startPos * BufFrames.ir(bufnum), doneAction: Done.freeSelf);
	snd = snd * EnvGen.ar(Env.asr(0.01, 1.0, 0.01), gate, doneAction: Done.freeSelf);
	snd = Balance2.ar(snd[0], snd[1], pan + LFNoise1.kr(1).range(-10e-3, 10e-3)) * amp * LFNoise1.kr(1).range(1-10e-3, 1+10e-3);
	snd = snd.tanh;
	Out.ar(out, snd);
}).add;
)

(
Pbind(*[
	instrument: \sampler,
	bufnum: ~buffer,
	startPos: Pwhite(0.0, 1.0),
	rate: Prand([0.25, 0.5, 1.0], inf),
	dur: Pwhite(0.25, 8, inf),
	amp: 2.0,
	legato: 1
]).play(quant: 1);
)

// Pour le support des VSTs, il faut installer l'extension de l'IEM
// https://git.iem.at/pd/vstplugin/-/releases

// une fois installé
// liste des VSTs
VSTPlugin.search;

~myFavoriteVsts = ["ValhallaRoom_x64", "ValhallaSpaceModulator", "ValhallaVintageVerb_x64", "ValhallaPlate", "ValhallaFreqEcho", "ValhallaDelay", "TDR Kotelnikov", "TDR Nova", "TDR VOS SlickEQ"];

(
SynthDef(\insert, { |bus|
	ReplaceOut.ar(bus, VSTPlugin.ar(In.ar(bus, 2), 2));
}).add;
)

~insert1 = Synth(\insert, [bus: 0], addAction: \addToTail);
~insert2 = Synth(\insert, [bus: 0], addAction: \addToTail);
~vst1 = VSTPluginController(~insert1);
~vst1.open(~myFavoriteVsts.choose, editor: true);
~vst1.editor;
~vst2 = VSTPluginController(~insert2);
~vst2.open(~myFavoriteVsts.choose, editor: true);
~vst2.editor;

// randomize parameters
(
var plug;
plug = [~vst1, ~vst2].choose;
plug.numParameters.do { |param|
	if (0.2.coin) {
		plug.set(param, 1.0.rand);
	};
}
)

// generalisation
~nbInserts = 3;

~myFavoriteVsts = ["ValhallaPlate", "ValhallaDelay", "TDR Kotelnikov", "TDR Nova", "TDR VOS SlickEQ"];

(
~inserts = ~nbInserts.collect { |i|
	Synth(\insert, [bus: 0])
};
)
(
~vsts = ~nbInserts.collect { |i|
	VSTPluginController(~inserts[i])
}
)
(
~vsts.do { |vst|
	vst.open(~myFavoriteVsts.choose, editor: true);
}
)
(
~vsts.do { |vst|
	vst.editor;
}
)


(
var plug;
~vsts.do { |plug|
	plug.numParameters.do { |param|
		plug.set(param, exprand(0.1, 1.0) - 0.1);
	}
}
)
