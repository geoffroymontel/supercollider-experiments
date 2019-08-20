// beware of maths !
10 + 3 * 4
10 + (3 * 4)

// use parenthesis to execute many lines of code
(
"SuperCollider".postln;
"Crest".postln;
"Même combat".postln;
)

// boot server
s.boot;
// show server UI
s.makeGui;

// sine wave
{ SinOsc.ar(440) * -12.dbamp }.play;

// multichannel expansion
{ SyncSaw.ar([100, 102], 400) * -12.dbamp }.play;

// use UGens inside other UGens
{ SinOsc.ar(Line.kr([400, 401], [800, 200], 10)) * -12.dbamp }.play;

// random sine wave
Array.fill(500, {  rrand(0.0, 1.0) }).plot("Sequence of 500x rrand");
Array.fill(500, {  exprand(10e-9, 1.0) }).plot("Sequence of 500x exprand");

(
{
	var freq;
	freq = exprand(30, 10000);
	SinOsc.ar([freq, freq * (1 + rrand(10e-4, 10e-2))]) * -16.dbamp;
}.play;
)

// random enveloppes

Env.perc.plot;
Env.perc(releaseTime: 5).plot;

(
Env.new(
	levels: [0, 1, 0.5, 0.8, 0.2, 0],
	times: [0.01, 2, 0.05, 1, 2]
).plot;
)

(
{
	var freq;
	var env;
	freq = exprand(30, 10000);
	env = Env.new(
		levels: [0, 1, 0.5, 0.8, 0.2, 0],
		times: [0.01, 2, 0.05, 1, 2]
	);
	SinOsc.ar([freq, freq * (1 + rrand(10e-4, 10e-2))])
	* EnvGen.kr(env)
	* -16.dbamp;
}.play;
)

// One sound with a random volume enveloppe
(
{
	var freq;
	var volEnv;
	var envPointsNumber, envDurations, envLevels, envCurve;
	var snd;

	envPointsNumber = rrand(1, 10);
	envLevels = [0] ++ envPointsNumber.collect { |i|
		exprand(-60.dbamp, 0.dbamp)
	} ++ [0];
	envDurations = (envPointsNumber + 1).collect { |i|
		exprand(0.2, 10.0)
	};
	envCurve = (envPointsNumber +1).collect { |i|
		rrand(-8, 8)
	};

	volEnv = Env.new(envLevels, envDurations, envCurve);

	volEnv.plot(name: "vol");

	freq = exprand(30, 10000);
	snd = SinOsc.ar([freq, freq * (1 + rrand(10e-4, 10e-2))]);
	snd = snd * EnvGen.kr(volEnv, doneAction: Done.freeSelf);
}.play
)

// 100 sounds with random volume and pan enveloppes
(
var nb = 100;
nb.do {
	{
		var freq;
		var panEnv, volEnv;
		var envPointsNumber, envDurations, envLevels, envCurve;
		var panDurations, panLevels, panCurve;
		var snd;

		envPointsNumber = rrand(1, 10);
		envLevels = [0] ++ envPointsNumber.collect { |i|
			exprand(0.2, 1.0)
		} ++ [0];
		envDurations = (envPointsNumber + 1).collect { |i|
			exprand(0.2, 10.0)
		};
		envCurve = (envPointsNumber +1).collect { |i|
			rrand(-8, 8)
		};
		panDurations = envDurations.scramble;
		panLevels = (envPointsNumber + 2).collect { |i|
			(2.0 - rrand(0.0, 2.0)) - 1.0
		};
		panCurve = envCurve.scramble;

		volEnv = Env.new(envLevels, envDurations, envCurve);
		panEnv = Env.new(panLevels, panDurations, panCurve);

		// volEnv.plot(name: "vol");
		// panEnv.plot(name: "pan");

		freq = exprand(30, 10000);
		snd = SinOsc.ar([freq, freq * (1 + rrand(10e-4, 10e-2))]);
		snd = Balance2.ar(snd[0], snd[1], EnvGen.kr(panEnv));
		snd = snd * EnvGen.kr(volEnv, doneAction: Done.freeSelf);
		snd = snd / nb;
	}.play
}
)

// Eliane Radigue like
// randomize also the oscillators
(
var nb = 50;
nb.do {
	{
		var freq;
		var panEnv, volEnv;
		var envPointsNumber, envDurations, envLevels, envCurve;
		var panDurations, panLevels, panCurve;
		var snd;

		envPointsNumber = rrand(5, 10);
		envLevels = [0] ++ envPointsNumber.collect { |i|
			exprand(0.2, 3.0)
		} ++ [0];
		envDurations = (envPointsNumber + 1).collect { |i|
			exprand(10.0, 30.0)
		};
		envCurve = (envPointsNumber +1).collect { |i|
			rrand(-8, 8)
		};
		panDurations = envDurations.scramble;
		panLevels = (envPointsNumber + 2).collect { |i|
			(2.0 - rrand(0.0, 2.0)) - 1.0
		};
		panCurve = envCurve.scramble;

		volEnv = Env.new(envLevels, envDurations, envCurve);
		panEnv = Env.new(panLevels, panDurations, panCurve);

		freq = 30 * rrand(1, 20);
		snd = [SinOsc, Saw, Pulse].choose.ar([freq, freq * (1 + rrand(10e-4, 10e-2))]);
		snd = Balance2.ar(snd[0], snd[1], EnvGen.kr(panEnv));
		snd = snd * EnvGen.kr(volEnv, doneAction: Done.freeSelf);
		snd = snd.fold2.tanh;
		snd = snd / nb;
	}.play
}
)

// Gunnarsson
(
{
	var signal;

	signal = DemandEnvGen.ar(
		Dseq([-1, 0.1, Dwhite(-0.1, 0.1, 5), Dwhite(-0.2, 0.2, 5)], inf),
		SampleDur.ir * 1.2, 1, 0, 1, Impulse.ar([10, 40]));
	signal = signal * BrownNoise.ar(0.1);
	signal = BPeakEQ.ar(signal, 10000, 4, EnvGen.ar(Env([0, -1, -7], [4, 12])));
}.play
)