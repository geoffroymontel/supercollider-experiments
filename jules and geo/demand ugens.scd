(
{
	var trig, snd, tempo, clock;
	// trig = Impulse.ar(1);
	tempo = 1.0;
	clock = Impulse.kr(tempo);
	trig = Demand.kr(clock, 0, Dseq([0.25, tempo],repeats: inf));
	trig = Impulse.ar(trig.poll(clock));

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

	trig.lag(0.01)

}.plot(10)
)

(
{
	Impulse.ar(2).lag
}.plot()
)




