(
SynthDef(\test, { |out=0, gate=1, freq=440, filterFreq=440|
	var sig;
	filterFreq.poll;
	sig = VarSaw.ar(freq);
	sig = DFM1.ar(sig, filterFreq, 0.5);
	sig = EnvGen.kr(Env.asr, gate, doneAction: Done.freeSelf) * sig;
	sig = Out.ar(out, sig * -12.dbamp);
}).add;
)

// solution with bus

~filterFreqBus = Bus.control(s, 1);

(
Pbind(*[
	type: \bus,
	out: ~filterFreqBus,
	array: Pseq([400, 1000], inf),
	dur: 0.4
]).play;
)

~filterFreqBus.plot(1); // seems to work

(
Pbind(*[
	instrument: \test,
	freq: Pwhite(400, 2000, inf),
	filterFreq: ~filterFreqBus.asMap,
	dur: 2,
	legato: 2
]).play;
)

// with pmono

(
Pmono(\test, *[
	freq: Pwhite(400, 2000, inf),
	filterFreq: ~filterFreqBus.asMap,
	dur: 2,
]).play;
)

// solution with pseg

a = Pseg(Pseq([400, 1000], inf), Pseq([0.4, 0.4], inf), \step).asStream;
a.next;

// works if pbind duration is shorter than pseg durations
(
Pbind(*[
	instrument: \test,
	freq: Pwhite(400, 2000, inf),
	filterFreq: Pseg(Pseq([400, 1000], inf), Pseq([1, 1], inf), \step),
	dur: 0.5,
	legato: 1
]).play;
)

// does not work if pbind duration is longer
(
Pbind(*[
	instrument: \test,
	freq: Pwhite(400, 2000, inf),
	filterFreq: Pseg(Pseq([400, 1000], inf), Pseq([0.4, 0.4], inf), \step),
	dur: 1,
	legato: 2
]).play;
)
