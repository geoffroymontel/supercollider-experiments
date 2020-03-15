// dont plagiarize these thanks!

(
SynthDef(\syntheticKick, {
    var snd, freq;
    freq = \freq.kr(40) * (1 + (Env.perc(0, \bendTime.kr(0.05)).ar * \bend.kr(5)));
    snd = SinOsc.ar(freq, phase: 0.5pi) * Env.perc(\attack.kr(1e-3), \decay.kr(0.5)).ar(Done.freeSelf);
    snd = snd * \amp.kr(-20.dbamp) ! 2;
    Out.ar(\out.kr(0), snd);
}).add;
)

// very tight, synthetic-sounding kick
// deep sort of house kick i guess
Synth(\syntheticKick, [amp: 0.5])
Synth(\syntheticKick, [amp: 0.5, freq: 50, bend: 5, decay: 0.3])

(
SynthDef(\syntheticKick2, {
    var snd, freq;
    freq = \freq.kr(40) * (1 + (Env.perc(0, \bendTime.kr(0.05)).ar * \bend.kr(5)));
    // whitenoise changes too much from impact to impact
    // replace with deterministic white noise
    // i hate RandSeed so: (because sometimes RandSeed still disturbs your randomness, its annoying)
    snd = (BPF.ar(Hasher.ar(Sweep.ar), 800, 0.8) * Env.perc(0.001, 0.02).ar * -2.dbamp);
    snd = snd + SinOsc.ar(freq, phase: 0.5pi);
    snd = snd * Env.perc(\attack.kr(1e-3), \decay.kr(2.0)).ar(Done.freeSelf);
    snd = snd * \amp.kr(-20.dbamp) ! 2;
    Out.ar(\out.kr(0), snd);
}).add;
)

// even a little bit of noise changes it...
// Some noise in this one
// don't like this one anymore haha
Synth(\syntheticKick2, [amp: 0.5])
Synth(\syntheticKick2, [amp: 0.5, freq: 50, bend: 8, bendTime: 0.02, decay: 0.3])

(
SynthDef(\syntheticKick3, {
    var snd, freq, popDecay = \popDecay.kr(0.01);
    freq = \freq.kr(50) * (1 + (Env.perc(0, \bendTime.kr(0.05)).ar * \bend.kr(5)));
    snd = (BPF.ar(Hasher.ar(Sweep.ar), 800, 0.8) * Env.perc(0.001, 0.03).ar * -2.dbamp);
    snd = snd + LPF.ar(SinOsc.ar(XLine.ar(16000, 50, popDecay)) * Env.perc(0.0, popDecay).ar * 5.dbamp, 1000);
    snd = snd + SinOsc.ar(freq, phase: 0.5pi);
    snd = snd * Env.perc(\attack.kr(0), \decay.kr(0.3)).ar(Done.freeSelf);
    snd = snd + HPF.ar((snd * 5.dbamp).tanh, 400);
    snd = snd * \amp.kr(-20.dbamp) ! 2;
    Out.ar(\out.kr(0), snd);
}).add;
)

// turn up ya speakers
// this ones good
Synth(\syntheticKick3, [amp: 0.5])


// ok lets make a snare, i have not done this in forever so it might suck !
// theres also lots of snares ranging from drum machine type to more dnb style snares

(
SynthDef(\snare, {
    var snd, freq;
    freq = 180 * XLine.kr(2, 1, 0.01);
    snd = SinOsc.ar(freq + (Line.ar(0, 1, 0.05) * SinOsc.ar(freq))) * -15.dbamp;
    snd = snd + (SinOsc.ar(XLine.ar(500, 100, 0.01)) * Env.perc(0, 0.01).ar);
    snd = snd + (BPF.ar(WhiteNoise.ar, 2500, 0.8) * Env.perc(0.08, 0.05).ar);
    snd = snd + (BPF.ar(WhiteNoise.ar, 6000, 0.8) * Env.perc(0.03, 0.2).ar * -15.dbamp);
    snd = snd * Env.perc(\attack.kr(0), \decay.kr(0.2)).ar(Done.freeSelf);
    snd = (snd * 5.dbamp).tanh;
    snd = snd * \amp.kr(-20.dbamp) ! 2;
    Out.ar(\out.kr(0), snd);
}).add;
)

// its alright. its veyr drum machine-y
Synth(\snare, [amp: 0.5])

// this is one i learned from the livecoding slack some time ago.
// you take a bunch of 909 type kicks like this one, and you layer them with random frequencies and decay times.
// usually sounds really cool. or at least it did last time i tried. lets go
(
SynthDef(\acousticKick, {
    var snd, freq, freqs, baseFreqs;
    freq = \freq.ir(50);
    baseFreqs = freq * [1, 1.3, 1.8, 1.5];
    freqs = baseFreqs * (1 + (Env.perc(0, [5, 3, 4, 1] * 1 * 1e-2).ar * 6));
    snd = SinOsc.ar(freqs, phase: 0.5pi); // amazing how much this phase matters
    snd = snd * (Array.series(4, 0, 0).dbamp);
    snd = snd * Env.perc(0, [1, 0.3, 0.1, 0.2]).ar;
    snd = snd.sum;
    // seems like these noise sources are extremely important for a convincing acoustic kick
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 600, 0.8) * Env.perc(0.001, 0.02).ar * 5.dbamp);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 6000, 0.8) * Env.perc(0.01, 0.03).ar * -5.dbamp);
    snd = snd * Env.perc(0.001, \decay.kr(0.3)).ar(Done.freeSelf);
    snd = snd.tanh;
    snd = snd * \amp.kr(-20.dbamp) ! 2;
    Out.ar(\out.kr(0), snd);
}).add;
)

// yeahhhhh
// ok yeah that's good
Synth(\acousticKick, [amp: 0.5]);

// claps are VERY hard to do and usually when i try to make em it sounds pretty crap
// they always sound like damn paper or whatever instead of real claps
// going to dig out an old example because i forget how i got this once
(
SynthDef(\clap, {
    var snd;
    // delay adds a 0-value segment to the beginning of an envelope
    // it has to be like, EXACTLY these frequencies or it sounds stupid
    snd = BPF.ar(Hasher.ar(Sweep.ar), [ 1120.0, 1280.0, 1300.0 ], 0.4) * Env.perc(0.001, [0.05, 0.06, 0.15] * 0.58).delay([0, 2, 3] * 0.008).ar;
    snd = snd.sum;
    snd = snd * 18.dbamp;
    snd = snd * Env.linen(0, 1, 0).ar(Done.freeSelf); // just for now
    snd = snd * \amp.kr(-20.dbamp) ! 2;
    Out.ar(\out.kr(0), snd);
}).add;
)

Synth(\clap, [amp: -6.dbamp]);

(
// GOD DAMN IT PATTERNS
Pspawner({ |spawner|
    loop {
        spawner.seq(Pseq([
            (instrument: \syntheticKick3, freq: 50)
        ], 1));
        spawner.par(Pseq([
            (instrument: \syntheticKick3, freq: 50)
        ], 1));
        spawner.seq(Pseq([
            (instrument: \clap, amp: -30.dbamp)
        ], 1));
    };
}).play(TempoClock(130 / 60));
)

// ther eyou h ave it: pretty good kicks, nice clap, a snare that might have a use somewhere
// thanks all for joining bye
