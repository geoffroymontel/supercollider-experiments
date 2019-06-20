// http://sccode.org/1-4RM#c877
(
fork { loop {
	Ndef(\winter_curves, {
		var bands = 5.rrand(15) * 2;
		var freqs = Array.exprand(bands.debug('bands'), 20, 18000);
		Pan2.ar(
			SinOsc.ar(
				freqs,
				Array.rand(bands, 0, pi),
				AmpCompA.kr(freqs, freqs.sort.first)
			).perform(0.5.coin.if(\tanh,\value).debug('kind')),
			SinOsc.kr(
				Array.exprand(bands, 0.01, 15),
				Array.rand(bands, 0, pi),
			),
			bands.reciprocal
			* LFGauss.kr(SinOsc.kr(Array.rand(bands, 0.05, 0.1)).range(1,10), 0.3)
			* SinOsc.kr(
				Array.exprand(bands, 0.1, 15),
				0.3
			).range(0,1)
		).sum
		* SelectX.kr(
			SinOsc.kr(Array.exprand(bands, 0.1, 15)).range(0,1),
			[
				EnvGen.kr(
					Env.perc(
						SinOsc.kr(1/16).range(0.01,0.1),
						SinOsc.kr(1/8).range(0.25,0.3)
					).blend(
						Env.sine( // 1/4
							SinOsc.kr(Array.exprand(bands, 0.1, 15)).range(0.05,2)
						).blend(
							Env.sine(1/4),
							SinOsc.kr(Array.exprand(bands, 0.1, 15)).range(0.05,2).mean
						),
						SinOsc.kr(Array.exprand(bands, 0.1, 15)).range(0,1)
					).circle,
					1, 0.8,
					SinOsc.kr(freqs.linlin(20,18000,0.1,20)).range(0, 0.2).mean
				),
				1
			]
		).clump(2).mean
	}).fadeTime_(0.5.rrand(2.5)).play;
	8.rrand(30).debug('len').wait;
} }
)
