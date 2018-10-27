/******************************************/
/* Jonathan Coon                          */
/* THX Deep Note Variation                */
/* MUSC 115 - Experimental Sound Design   */
/* 10/23/2014                             */
/******************************************/

// Each of these synths is a variation of SuperCollider code that replicates the TXH Deep Note
// A tutorial for replicating the THX Deep Note can be found at
// http://www.earslap.com/article/recreating-the-thx-deep-note.html

/*********************************************************/
/* ==================== ARRANGEMENT ==================== */
/*********************************************************/
(
{
	s.record;
	1.wait;
	(
		~low.play;
		~high.play;
	);
	39.95.wait;
	~bees.play;
	20.wait;
	~buzz.play;
	32.wait;
	~trem.play;
	33.5.wait;
	(
		~beebot1.play;
		~beebot2.play;
	);
	29.wait;
	~end.play;
	30.wait;
	s.stopRecording;
}.fork;
)


/**********************************************************/
/* ==================== SYNTHESIZERS ==================== */
/**********************************************************/

// Low droning
(
~low = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(10.0, 40.0) }).sort.reverse; // starting with low frequencies
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(10, 40, 0, 10))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * -36.midicps).wrapExtend(numVoices).sort; // low fundamental ending frequency and its octaves
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(0.1, i/3)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(10.5, 20), rrand(8.5, 9)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = ((1 - sweepEnv) * startFreqs) + (sweepEnv * endFreqs);
	// filtered sawtooth waves
	snd = BLowPass.ar(Saw.ar(freqs), freq: freqs * 20, rq: 0); // rq is 0
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// make it stereo, apply ampEnv, limiter
	ampEnv = Env([0, 0.1, 1.6, 2, 0], [8, 12, 13, 20.7], [2, 2, -10]).kr(doneAction: 2);
	snd = Splay.ar(snd.scramble, spread: 0.5, level: ampEnv);
	Limiter.ar(snd,0.2);
};
)

// High-pitched ascension
(
~high = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(200.0, 400.0) }).sort.reverse;
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(200, 400, 3, 90))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * 14.5.midicps).wrapExtend(numVoices).sort;
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(0.1, i/3)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(10.5, 20), rrand(8.5, 9)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = ((1 - sweepEnv) * startFreqs) + (sweepEnv * endFreqs);
	// filtered sawtooth waves
	snd = BLowPass.ar(Saw.ar(freqs), freq: freqs * 20, rq: 0); // rq is 0
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// make it stereo, apply ampEnv, limiter
	ampEnv = Env([0, 0.1, 1.6, 2, 0], [8, 12, 13, 20.7], [2, 10, -10]).kr(doneAction: 2);
	snd = Splay.ar(snd.scramble, spread: 0.5, level: ampEnv);
	Limiter.ar(snd,0.1);
};
)

// These bees were killed by static
(
~bees = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(200.0, 400.0) }).sort.reverse;
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(200, 400, 3, 90))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * 14.5.midicps).wrapExtend(numVoices).sort;
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(0.1, i/3)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(5.5, 6), rrand(8.5, 9)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = ((1 - sweepEnv) * startFreqs) + (sweepEnv * endFreqs);
	// filtered sawtooth waves
	snd = BLowPass.ar(Saw.ar(freqs), freq: freqs * 20, rq: 0.6); // freqs multiplied in BLowPass freq argument to eventually produce static
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// make it stereo, apply ampEnv, limiter
	ampEnv = Env([0, 1.6, 2, 0], [6, 13, 4], [2, 2, -2]).kr(doneAction: 2);
	snd = Splay.ar(snd.scramble, spread: 0.5, level: ampEnv);
	Limiter.ar(in: snd, level: 0.9);
};
)

// Rumbling static transforms into buzz
(
~buzz = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(200.0, 400.0) }).sort.reverse;
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(200, 400, 3, 90))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * 14.5.midicps).wrapExtend(numVoices).sort;
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(0.1, i/3)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(5.5, 6), rrand(8.5, 9)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = (((10 - endFreqs) * sweepEnv) + (sweepEnv * startFreqs)); // messed with the freqs array to cause chaos
	// filtered sawtooth waves
	snd = BLowPass.ar(SinOsc.ar(freqs), freq: freqs * 6, rq: 0.6);
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// make it stereo, apply ampEnv, limiter
	ampEnv = Env([0, 0.1, 1.6, 2, 0], [10, 6, 13, 4], [2, 15, -4]).kr(doneAction: 2);
	snd = Splay.ar(snd.scramble, spread: 1, level: ampEnv);
	Limiter.ar(snd);
};
)

// Increasing tremelo rate into low drone
(
~trem = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(200.0, 400.0) }).sort.reverse;
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(200, 400, 3, 90))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * -36.midicps).wrapExtend(numVoices).sort; // low fundamental ending frequency and its octaves
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(100, i/10)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(5.5, 6), rrand(8.5, 9)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = ((1 - sweepEnv) * startFreqs) + (sweepEnv * endFreqs);
	// filtered sawtooth waves
	snd = BLowPass.ar(Pulse.ar(freqs), freq: freqs * 6, rq: 0.6);
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// apply ampEnv, tremelo effect, limiter
	ampEnv = Env([0, 1.6, 2, 0], [6, 13, 15], [2, 2, -2]).kr(doneAction: 2);
	snd = Mix(snd.scramble);
	snd = Pan2.ar(in: snd, pos: SinOsc.ar(freq: Env(levels: [0, 5, 50], times: [10, 10], curve: [0, 0]).kr), level: ampEnv);
	Out.ar(0, Limiter.ar(snd));
};
)

// Beebot1 and Beebot2 are meant for each other
(
~beebot1 = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(200.0, 400.0) }).sort.reverse;
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(200, 400, 3, 90))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * 14.5.midicps).wrapExtend(numVoices).sort;
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(0.1, i/3)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(5.5, 6), rrand(8.5, 9)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = (((1 - endFreqs) * sweepEnv) + (sweepEnv * startFreqs)); // messed with the freqs array to cause chaos
	// filtered sawtooth waves
	snd = BLowPass.ar(SinOsc.ar(freqs), freq: freqs * 20, rq: 0.001); // rq is 0.001
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// make it stereo, apply ampEnv, limiter
	ampEnv = Env([0, 1.6, 2, 0], [6, 13, 10], [2, 15, -4]).kr(doneAction: 2);
	snd = Splay.ar(snd.scramble, spread: 0.5, level: ampEnv);
	Limiter.ar(snd, 0.5);
};

~beebot2 = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(200.0, 400.0) }).sort.reverse;
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(200, 400, 3, 90))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * 14.5.midicps).wrapExtend(numVoices).sort;
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(0.1, i/3)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(5.5, 6), rrand(8.5, 9)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = (((1 - endFreqs) * sweepEnv) + (sweepEnv * startFreqs)); // messed with the freqs array to cause chaos
	// filtered sawtooth waves
	snd = BLowPass.ar(SinOsc.ar(freqs), freq: freqs * 10, rq: 0.001); // different filter than beebot1
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// make it stereo, apply ampEnv, limiter
	ampEnv = Env([0, 1.6, 2, 0], [6, 13, 10], [2, 15, -4]).kr(doneAction: 2);
	snd = Splay.ar(snd.scramble, spread: 0.5, level: ampEnv);
	Limiter.ar(snd, 0.5);
};
)

// Descending into dissonance
(
~end = {
	var numVoices, startFreqs, deviation1, endFreqs, deviation2, sweepEnv, louderBass, filterFreq, ampEnv, freqs, snd;
	numVoices = 30;
	// starting point
	startFreqs = Array.fill(numVoices, { rrand(20.0, 40.0) }).sort.reverse; // starting with low frequencies
	deviation1 = startFreqs.collect({|freq| LFNoise2.kr(0.5, freq.linlin(30, 40, 0, 40))});
	startFreqs = startFreqs + deviation1;
	// ending point
	endFreqs = ([1, 2, 4, 8, 16, 32, 64] * 14.5.midicps).wrapExtend(numVoices).sort;
	deviation2 = Array.fill(numVoices, {|i| LFNoise2.kr(0.1, i/3)});
	endFreqs = endFreqs + deviation2;
	// glissando envelope
	sweepEnv = Array.fill(numVoices,{Env(
		[0, rrand(0.1, 0.2), 1],
		[rrand(10.5, 11), rrand(15.5, 16)],
		[rrand(2.0, 3.0), rrand(4.0, 5.0)])}).collect({|env| env.kr});
	freqs = ((1 - sweepEnv) * endFreqs) + (sweepEnv * startFreqs); // messed with freqs array in order to descend into dissonance
	// filtered sawtooth waves
	snd = BLowPass.ar(Saw.ar(freqs), freq: freqs * 6, rq: 0.6);
	filterFreq = Env([2000, 3800, 20000], [8, 4], [2, 4]).kr;
	louderBass = Array.fill(30, {|i| 1.01 - (1/(i+1))}); // louder bass in the beginning
	snd = BLowPass.ar(snd, freq: filterFreq, rq: 0.5, mul: louderBass);
	// make it stereo, apply ampEnv, limiter
	ampEnv = Env([0, 1.6, 2, 0], [10, 13, 4], [2, 2, -2]).kr(doneAction: 2);
	snd = Splay.ar(snd.scramble, spread: 0.75, level: ampEnv);
	Limiter.ar(snd);
};
)