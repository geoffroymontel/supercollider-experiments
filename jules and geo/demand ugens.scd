(
{
	var trig, snd, tempo, clock;
	tempo = 60/60;
	trig = TDuty.kr(Drand([Dseq(1,1,1,1), Dseq(1/2)]*tempo, repeats: inf));

	snd = SinOsc.ar(
		freq: EnvGen.ar(
			envelope: Env(
				levels: [472, 472, 60],
				times: [0.0, 0.045],
				curve: 'exp'),
			gate: trig
		)
	)
	* EnvGen.ar(
		envelope: Env.perc(0.001, 0.3, curve: \lin),
		gate: trig
	);

}.plot(10)
)

Prand


(
{
	SinOsc.ar(freq: SinOsc.kr(1).range(300,400))
}.play
)

(
SynthDef(\test,
{ |freq|
	var n = 3;
		Out.ar(0, Splay.ar(Array.fill(n, { |i| SinOsc.ar(freq: freq + Rand(0, 10)) * (1/n) })));
}).add;
)


Synth(\test, [freq: 800])

