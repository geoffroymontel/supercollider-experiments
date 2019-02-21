(
{
	var trig, snd, tempo, clock, kick, drone, note,envcomp;

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

	envcomp = Env.new(levels:[1, -20.dbamp, 1], times:[0.1,0.3]);
	// drone = drone * (1- (trig.lag(0.3) * 10)); // basic sidechain compressor
	//drone = Compander.ar(drone, kick, 0.1, 1, 0.3, 0.01, 0.1); // with a real compressor
	drone = drone * EnvGen.kr(envelope: envcomp, gate: trig);

	kick + drone * -12.dbamp;
}.play
)


