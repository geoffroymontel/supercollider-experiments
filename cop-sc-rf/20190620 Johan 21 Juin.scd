//Faire le tempo global !
//2 = bpm 120 assumed in the following, impacting on some delay recipes.
TempoClock.default.tempo = 0.75;

// Synthés utilisés
(
SynthDef(\pad, {
    var snd, freq;
    freq = \freq.kr(440);
    // Four pulse waves (two one octave down) with randomly modulated pitches and pulse widths
    snd = Pulse.ar(
        freq * ({ LFNoise2.kr(3).range(-0.05, 0.05).midiratio }.dup(4)) * [1, 1/2, 1/2, 1],
        { LFNoise2.kr(3).range(0.3, 0.7) }.dup(4)
    );
    // Spread across stereo field
    snd = Splay.ar(snd);
    // Sharp hi cut made by cascading three lowpass filters
    3.do { snd = LPF.ar(snd, \ffreq.kr(1500)); };
    snd = snd * Env.asr(3, 1, 3, -4).ar(Done.freeSelf, \gate.kr(1));
    Out.ar(\out.kr(0), Balance2.ar(snd[0], snd[1], \pan.kr(0), \amp.kr(0.1)));
}).add;

SynthDef(\verb, {
    var snd, wet;
    snd = In.ar(\out.kr(0), 2);
    // Wet part of reverb has an additional octave pitched-up version of itself
    wet = snd.sum;
    wet = DelayN.ar(wet, 0.2, 0.2) + PitchShift.ar(wet, 0.2, 2, 0.01, 0.1);
    wet = GVerb.ar(wet, 100, 5);
    wet = HPF.ar(wet, 100) * -3.dbamp;
    snd = snd + wet;
    // Add a little bit of tape flutter
    snd = DelayC.ar(snd, 0.2, LFNoise2.kr(1).range(0, 0.005));
    ReplaceOut.ar(\out.kr(0), snd);
}).add;

SynthDef(\pluck, {
    var snd, freq;
    freq = \freq.kr(440);
    snd = CombC.ar(SinOsc.ar(XLine.ar(\ffreq.kr(1000), 100, 0.04)) * Env.perc(0.01, 0.04).ar, freq.reciprocal, freq.reciprocal, 1);
    snd = AllpassN.ar(snd, 0.2, 0.2, 2);
    snd = BPF.ar(snd, [814, 1144, 1324], [0.1, 0.1, 0.1]).sum;
    snd = LPF.ar(snd, 2000);
    snd = snd * Env.perc(0.01, 1, 1, 4).ar(Done.freeSelf);
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;

SynthDef(\sigh, {
    var snd, freq;
    freq = \freq.kr(440, 0.3) * LFNoise2.kr(6).range(-0.1, 0.1).midiratio;
    snd = Pulse.ar(freq, LFNoise2.kr(6).range(0.3, 0.7));
    snd = RLPF.ar(snd, LFNoise2.kr(3).exprange(500, 1000), 0.2);
    snd = LPF.ar(snd, 1000);
    snd = snd * Env.asr(0.1, 1, 3).ar(Done.freeSelf, \gate.kr(1));
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;

SynthDef(\bow, {
    var snd, freq;
    freq = \freq.kr(440, 0.3);
    snd = CombC.ar(LeakDC.ar({ PinkNoise.ar }.dup(2)), freq.reciprocal, freq.reciprocal, 5);
    snd = LeakDC.ar(snd);
    snd = RLPF.ar(snd, LFNoise2.kr(6).exprange(100, 600), 0.3);
    snd = snd * Env.perc(4, 1, 1, 4).ar(Done.freeSelf);
    Out.ar(\out.kr(0), Balance2.ar(snd[0], snd[1], \pan.kr(0), \amp.kr(0.1)));
}).add;
)

// Exécution du morceau

(
var pattern_bow = Pbind(*[
			instrument: \bow,
			amp: -15.dbamp,
			octave: Pseq([1, 2, 3], inf), // orig 2 3
			degree: Prand([0, 4], inf),
			dur: Pwhite(4, 8, inf), // orig 4 8
		]);

var pattern_pluck = Pbind(*[
			instrument: \pluck,
			amp: -33.dbamp,
			degree: Pxrand([0, 1, 4], inf),
			octave: Prand([3, 4, 5], inf),
			dur: Pwhite(0.1, 0.3, inf),
			ffreq: Pexprand(400, 1500, inf),
			pan: Pwhite(-0.6, 0.6)
		]);

var pattern_sigh = PmonoArtic(*[
			\sigh,
			amp: -43.dbamp,
			degree: Pseq([0, -1, Rest()], inf) + [0, -3],
			legato: Pseq([1.0, 0.9, 1.0], inf),
			octave: 6,
			dur: Pseq([Pwhite(3.0, 0.5, 1), Pwhite(0.2, 0.4, 1), Pwhite(5.0, 10.0, 1)], inf)
		]);

var pattern_pad = Pbind(*[
			instrument: \pad,
			amp: -30.dbamp,
			octave: 6,
			dur: 5,
			legato: 1,
			ffreq: Pseq([1500, 1000], inf),
			degree: Pseq([
				[0, 2, 4, 6, 8],
				[0, 3, 4, 5, 8],
				[2, 4, 6, 10],
				[1, 4, 6, 9],
			], inf) // je cale les répétitions du morceau sur la répétition de ce motif
		]);

// riff_0 : intro bow : 12 mes // voir comment caler durée dans le Psync
var riff_0 = Psync(pattern_bow,1,48);

// riff_1 : bow + pluck : 8 mes// voir comment caler durée dans le Psync
var riff_1 = Psync(Ppar([pattern_pluck,pattern_bow]),1,48);// voir comment ajuster durée

// riff_2 : bow + pluck + sigh : 8 mes// voir comment caler durée dans le Psync
var riff_2 = Psync(Ppar([pattern_pluck, pattern_sigh, pattern_bow]),1,48);

// riff_3 : bow + pluck + sigh + pad : 24 mes (coeur du morceau)// voir comment caler durée dans le Psync
var riff_3 = Psync(Ppar([pattern_pad, pattern_pluck, pattern_sigh, pattern_bow]),1,72);

// riff_4 : bow + pluck + pad : 8 mes// voir comment caler durée dans le Psync
var riff_4 = Psync(Ppar([pattern_pad, pattern_pluck, pattern_bow]),1,48);

// riff_5 : bow + pad : 8 mes // voir comment caler durée dans le Psync
var riff_5 = Psync(Ppar([pattern_pad, pattern_bow]),1,48);

// riff_6 : pad solo final : 4 mes
var riff_6 = Psync(pattern_pad,1,inf);

Pfx(
    Pbind(*[
        scale: Scale.minor,
        root: 0,
	]) <> Pseq([riff_0,riff_1, riff_2, riff_3, riff_4, riff_5, riff_6]),
    \verb
).play;
)

Scale.directory