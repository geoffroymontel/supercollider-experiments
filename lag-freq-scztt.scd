(
SynthDef(\test, {
    var trig, sig, lag, lagSkew, freq, feed;

    freq     = \freq.kr;
    trig     = \trig.tr(0);
    lag     = \lagT.kr(0.1);
    lagSkew = \lagSkew.kr(0.04);
    lag     = 12.collect {
        |i|
        lag * 2.pow(lagSkew * i.linlin(0.0, 12.0, -1.0, 1.0))
    };

    // feedback
    feed = LocalIn.ar(2);
    feed = LeakDC.ar(feed);
    feed = DelayC.ar(feed, 1, [1/6, 1/4] - ControlDur.ir);
    feed = feed - FreqShift.ar(feed, {
        TRand.ar(-0.05, 0.05, trig).lag(0.05)
    } ! 2);
    feed = feed - (-1.dbamp * CombC.ar(feed, 1, (freq*2.01).lag(0.15).reciprocal, 0.3));
    feed = \feed.kr(-3.dbamp) * feed;

    // freq lag
    freq = freq * [1, 2 + (1/60), 3 + (1/123)];
    freq = freq.lag(lag);

    // saw
    sig = LFSaw.ar(freq).sum;
    sig = -6.dbamp * sig;
    sig = RLPF.ar(sig, \lpf.kr.lag3(0.04), 0.8);
    sig = sig + feed;

    sig = sig * Env.perc(
        0.01,
        [\decay1.kr, \decay2.kr]
    ).kr(gate:[\trig1.tr, \trig2.tr], );

    sig = sig.tanh;

    LocalOut.ar(sig);

    Out.ar(\out.kr, sig);
}).add;

Pdef(\snap, Pmono(
    \test,
    \scale,     Scale.chromatic,
    \octave,     Pwrand([3, 6], [0.96, 0.04], inf),

    \lagT,         Pwhite().lincurve(0, 1, 0.025, 0.5, 15),
    \lagSkew,     Pseg([0.01, 0.4, 0.01], [3, 3], \exp).repeat.trace,

    \feed,         -60.dbamp,

    \degree,     Pxrand([2, 5, 12 + 5, 12 + 4, 11, -7], inf),
    \lpf,         Pseg([0, 500, 0], [24, 8], [8, -8]).repeat + Pwhite(0, 1).lincurve(0, 1, 200, 1000, -12),
    \dur,         Pseq([ 1, 1, 1, 1, 1, 2, 1, 1 ], inf) / 8,

    \trig1,     Prand([0, 0.1, 0.5, 1], inf),
    \trig2,     Prand([0, 0.1, 0.5, 1], inf),
    \decay1,     Pwhite().lincurve(0, 1, 0.15, 1, 4) * Pseg([1, 4, 1], [12, 4]).repeat,
    \decay2,     Pwhite().lincurve(0, 1, 0.15, 1, 4) * Pseg([1, 4, 1], [12, 4]).repeat
)).play;
)
