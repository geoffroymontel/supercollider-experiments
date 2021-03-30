(
SynthDef(\test, {
    var trig, sig;
    trig = \trig.tr(0).poll;
    sig = LFSaw.ar(\freq.kr.lag([0.01, 0.06]));
    sig = RLPF.ar(sig, \lpf.kr.lag(0.04), 0.9);
    sig = sig * Env.perc(
        0,
        [\decay1.kr, \decay2.kr]
    ).kr(gate:[\trig1.tr, \trig2.tr]);
    Out.ar(\out.kr, sig);
}).add;

Pdef(\snap, Pmono(
    \test,
    \scale, Scale.chromatic,
    \octave, 3,
    \degree, Pxrand([2, 5, 11, -7], inf),
    \lpf, Pwhite(100, 2000),
    \dur, Pseq([ 1, 1, 1, 1, 1, 2, 1, 1 ], inf) / 4,
    \trig1, Prand([0, 0.1, 0.5, 1], inf),
    \trig2, Prand([0, 0.1, 0.5, 1], inf),
    \decay1, Pwhite().lincurve(0, 1, 0.15, 1, 4) * Pseg([1, 2, 1], [8, 8]).repeat,
    \decay2, Pwhite().lincurve(0, 1, 0.15, 1, 4) * Pseg([1, 2, 1], [8, 8]).repeat
)).play;
)
