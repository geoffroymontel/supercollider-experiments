// dans le style d'Autechre - Mirrage
// https://www.deezer.com/en/album/70963252

(
{
	var note, snd, delaytime, damp, size, diff, feedback, localout;
	note = Demand.kr(Impulse.kr(0) + Dust.kr(0.1), 0, Diwhite(60, 80, inf));
	delaytime = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(0.1, 0.3, inf));
	damp = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.2, 0.6, inf));
	size = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(2, 10, inf));
	diff = Demand.kr(Impulse.kr(0) + Dust.kr(0.2), 0, Dwhite(0.5, 1.0, inf));
	feedback = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.8, 1.0, inf));
	snd = SinOsc.ar(freq: [note, note+LFNoise1.kr(freq: 0.1).range(-0.25, 0.25)].midicps);
	localout = Mix.ar(5.collect({ |i|
		Pan2.ar(
			in: Greyhole.ar(in: PitchShift.ar(in: snd, pitchRatio: i), delayTime: delaytime, damp: damp, size: size, diff: diff, feedback: feedback, modDepth: 0.1, modFreq: 5),
			pos: LFNoise1.ar(freq: TRand.ar(10.reciprocal, 1, Impulse.kr(8.reciprocal))).range(-1,1),
			level: (i+1).reciprocal
		) * -20.dbamp;
	}));
	localout = Compander.ar(in: localout, control: localout, thresh: -6.dbamp, slopeAbove: 3.reciprocal);
	LocalOut.ar(localout);
	snd = LocalIn.ar(2);
	snd.tanh;
}.play;
)

