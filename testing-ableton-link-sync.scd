t = LinkClock.new.latency_(Server.default.latency);
t.tempo = 120/60

(
SynthDef(\test, { |freq=440, out=0, gate=1|
	var snd;

	snd = VarSaw.ar(freq: freq ! 2) * EnvGen.kr(Env.asr, gate, doneAction: Done.freeSelf) * -6.dbamp;
	Out.ar(out, snd);
}).add;
)

(
Pdef(\ab, Pbind(*[
	instrument: \test,
	freq: Pwhite(50,80,inf).midicps,
	dur: Prand([1, 2], inf)
]));
)

Pdef(\ab).play(t, quant: 1);
Pdef(\ab).stop;


Pbind(*[
	instrument: \test,
	freq: Pwhite(50,80,inf).midicps,
	dur: Prand([0.25, 0.5, 1, 2], inf)
]).play