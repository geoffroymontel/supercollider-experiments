(
{
	var trig, snd, tempo, clock, kick, drone, note;

	note = 41; // fa
	tempo = 60/60;
	clock = Impulse.kr(tempo);
	trig = TDuty.kr(Dseq([Dwrand([1/3, 2/3], [0.9, 0.1], 1), 1/3, 1/3, 1],inf)+Dwhite(-0.01, 0.01,inf));

	kick = SinOsc.ar(
		freq: EnvGen.ar(
			envelope: Env(
				levels: [472, 472, 60],
				times: [0.0, 0.01],
				curve: 'exp'),
			gate: trig
		)
	)
	* EnvGen.ar(
		envelope: Env.perc(0.001, 0.3, curve: \lin),
		gate: trig
	);

	drone = Splay.ar( (1..10).collect({ |i|
		Saw.ar(
			freq: note.midicps * i,
			mul: 1/i
		)
	}));

	drone = drone * (1- (trig.lag(0.3) * 10)); // sidechain compressor
	kick + drone * -12.dbamp;
}.play
)

