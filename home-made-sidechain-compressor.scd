(
{
    var trig, tempo, drone, note;
    note = 41; // fa
    tempo = 70/60;

    trig = TDuty.kr(Dseq([Dwrand([1/3, 2/3], [0.9, 0.1], 1), 1/3, 1/3, 1],inf) / tempo +Dwhite(-0.01, 0.01,inf));

    drone = Splay.ar( (1..10).collect({ |i|
        Saw.ar(
            freq: note.midicps * i,
            mul: 1/i
        )
    }));

	// drone = drone * (1 - EnvGen.kr(
	// 	envelope: Env.perc(0.01, 0.3),
	// 	gate: trig
	// ));

	drone = drone * EnvGen.kr(
		envelope: Env.new(levels: [0, 0, 1], times: [0.01, 0.3], loopNode: 1),
		gate: trig
	);

}.play
)