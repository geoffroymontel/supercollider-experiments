// http://sccode.org/1-1f

(
{
	Limiter.ar(
		GVerb.ar(
			(
				BPF.ar(
					WhiteNoise.ar([0.07,0.07]) + Blip.ar([13,19], 200.rand, mul:0.5),
					SinOsc.kr(
						SinOsc.kr([1/108,1/109]).range(1/108, 1/13)
					).exprange(10, 2300),
					PMOsc.kr(1/54,1/216, 3).range(0.1, 2)
				)
				*
				SinOsc.ar(Array.rand(20, 1/216, 1), mul: Array.rand(20, 0.2, 1)).reshape(10,2)
			).sum,
			roomsize:10,
			damping: PMOsc.kr(1/27, 1/108, 3).range(0.5, 1),
			drylevel: SinOsc.kr(1/9).range(0.1, 1)
		)
		+
		GVerb.ar(
			Pan2.ar(
				LPF.ar(
					DynKlank.ar(
						`[
							Array.rand(6, 600, 4000).collect({|freq|
								SinOsc.kr(1/108).range(freq/2,freq)
							}),
							nil,
							Array.rand(6, 1/108, 1/27).collect({|freq|
								SinOsc.kr(freq).range(1/108,1/3)
							})
						],
						Limiter.ar(
							Dust.ar( SinOsc.kr(1/256).exprange(1/27, 3), TRand.kr(0.15, 0.25, Dust.kr(1/9)))
							+
							Impulse.ar( SinOsc.kr(1/108).exprange(1/54, 3), 0, TRand.kr(0.6, 0.8, Dust.kr(1/3)))
						)
					),
					1700,
					LFPar.kr(1/27).exprange(0.05, 0.2)
				),
				SinOsc.kr(1/9).range(-0.2, 0.2)
			),
			roomsize: 30,
			drylevel: 0.5
		)
	)
}.play;
)