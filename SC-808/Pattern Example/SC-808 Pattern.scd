TempoClock.tempo = (131.5/60/4);

s.plotTree;


s.meter;
//stop

(
Pbindef(\bdPT).stop;
Pbindef(\snPT).stop;
Pbindef(\cprawPT).stop;
Pbindef(\hatPT).stop;
Pbindef(\ohPT).stop;
Pbindef(\cowbellPT).stop;
Pbindef(\hicongaPT).stop;
Pbindef(\lowcongaPT).stop;
Pbindef(\lowtomPT).stop;
Pbindef(\midtomPT).stop;
Pbindef(\hitomPT).stop;
)
//play

Pbindef(\bdPT).play;
Pbindef(\snPT).play;
Pbindef(\cprawPT).play;
Pbindef(\hatPT).play;
Pbindef(\ohPT).play;
Pbindef(\cowbellPT).play;
Pbindef(\hicongaPT).play;
Pbindef(\lowcongaPT).play;
Pbindef(\lowtomPT).play;
Pbindef(\midtomPT).play;
Pbindef(\hitomPT).play;


(
Pbindef(\bdPT,
	\instrument, \bd,
	\dur, 1/4,
	\decay, 20,
	\tone, 60,
	\amp, Pseq([1, 0, 1.5, 1.5, 0,
		1.5, 0, 1.5,
		0, 1], inf).trace
).play;

Pbindef(\snPT,
	\instrument, \sn,
	\dur, 1/4,
	\amp, Pseq([0, 1.6], inf).trace,
	\tone, 340,
	\tone2, 189,
	\snappy, 0.3,
	\amp2, 0.8
).play;

Pbindef(\cprawPT,
	\instrument, \cpRaw,
	\dur, 1/4,
	\amp, Pseq([
		0, 0, 0, 1, 0, 0,
		0, 0, 0, 0, 1, 0,
		0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 1
	],inf).trace
).play;

Pbindef(\hatPT,
	\instrument, \hat,
	\dur, Pseq([1/16, 1/16, 1/16, 1/16, 1/16, 1/16, 1/16, 1/16, 1/32, 1/32], inf),
	\amp, Pseq([0.45], inf).trace,
	\pan, Pwhite(0, 0, inf)
).play;


Pbindef(\ohPT,
	\instrument, \openhihat,
	\dur, 1/16,
	\amp, Pseq([
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 4, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 4, 0
	], inf).trace,
	\pan, 0
).play;

Pbindef(\cowbellPT,
	\instrument, \cowbell,
	\dur, 1/8,
	\amp, Pseq([
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0.2], inf).trace
).play;

Pbindef(\hicongaPT,
	\instrument, \HC,
	\dur, 1/16,
	\freq, Pwhite(160, 180, inf),
	\amp, Pseq([
		0.3, 0, 0, 0.3, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0.5],
	inf).trace
).play;

Pbindef(\lowcongaPT,
	\instrument, \LC,
	\dur, 1/16,
	\freq, Pwhite(160, 180, inf),
	\amp, Pseq([
		0, 0.4, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0],
	inf).trace
).play;

Pbindef(\lowtomPT,
	\instrument, \LT,
	\dur, 1/16,
	\amp, Pseq([
		0, 0, 0, 0,
		0, 0, 0, 0.4,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0.4, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
	], inf).trace,
	\freq, Pseq([
		0, 0, 0, 0,
		0, 0, 0, 105,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 95, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
	], inf).trace
).play;


Pbindef(\midtomPT,
	\instrument, \MT,
	\dur, 1/16,
	\amp, Pseq([
		0, 0, 0.4, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0.4, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
	], inf).trace,
	\freq, Pseq([
		0, 0, 128, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		110, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
	], inf).trace
).play;


Pbindef(\hitomPT,
	\instrument, \HT,
	\dur, 1/16,
	\amp, Pseq([
		0, 0, 0, 0,
		0.4, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0.4, 0, 0,
		0, 0, 0, 0,
	], inf).trace,
	\freq, Pseq([
		0, 0, 0, 0,
		165, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 200, 0, 0,
		0, 0, 0, 0,
	], inf).trace
).play;
)