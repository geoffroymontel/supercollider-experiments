play({ PMOsc.ar(Line.kr(600, 900, 5), 600, 3, 0, 0.1) }); // modulate carfreq

play({ PMOsc.ar(300, Line.kr(600, 900, 5), 3, 0, 0.1) }); // modulate modfreq

play({ PMOsc.ar(300, 550, Line.ar(0,20,8), 0, 0.1) }); // modulate index

(
e = Env.linen(2, 5, 2);
Routine.run({
    loop({
        play({
            LinPan2.ar(
				in: EnvGen.ar(e, doneAction: Done.freeSelf) *
				PMOsc.ar(carfreq: 2000.0.rand,
					modfreq: 800.0.rand,
					pmindex: Line.kr(0.0, 12.0.rand,9),
					modphase: 0,
					mul: 0.1),
				pos: 1.0.rand2)});
        2.wait;
    })
})
)