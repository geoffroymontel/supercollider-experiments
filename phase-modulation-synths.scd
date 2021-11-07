(
s.waitForBoot{
    SynthDef(\pmOperator, {
        var sig, env, freq, vibrato, detune;
        env = Env.adsr(
            \atk.kr(0.01), \dec.kr(0.3), \sus.kr(0.5), \rel.kr(1.0),
            curve: \curve.kr(-4)).ar(2, \gate.kr(1));
        detune = LFNoise1.kr(\detuneRate.kr(0.2)!2).bipolar(\detuneAmt.kr(0.1)).midiratio;
        vibrato = SinOsc.kr(\vibRate.kr(2)).bipolar(\vibAmt.kr(0.2)).midiratio;
        freq = \freq.kr(440) * vibrato * detune;
        sig = SinOsc.ar(freq * \ratio.kr(1), In.ar(\in.kr(0), 2));
        sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), env);
        sig = LeakDC.ar(sig);
        Out.ar(\out.kr(0), sig * \amp.kr(0.3));
    }).add;

    s.sync;

    // use busses to connect modulators to carriers:
    s.newBusAllocators;
    ~b0 = Bus.audio(s, 2);
    ~b1 = Bus.audio(s, 2);
    ~b2 = Bus.audio(s, 2);
    ~b3 = Bus.audio(s, 2);
    ~b4 = Bus.audio(s, 2);
    ~b5 = Bus.audio(s, 2);

    // use groups to ensure modulators are before carriers on the node tree:
    ~g0 = Group.new;
    ~g1 = Group.after(~g0);
    ~g2 = Group.after(~g1);
    ~g3 = Group.after(~g2);
    ~g4 = Group.after(~g3);
    ~g5 = Group.after(~g4);

    s.sync;

    // use arrays in Pbind to play multiple operators simultaneously:
    Pbind(
        \instrument, \pmOperator,
        \tempo, 1,
        \dur, Pwhite(3.0, 6.0),
        \root, -5,
        \octave, Pfunc{{rrand(2, 3)} ! 6},
        \degree, Pxrand((0..7), inf).stutter(5),
        \harmonic, Pfunc{{rrand(1, 8)} ! 6},
        \group, [~g0, ~g1, ~g2, ~g3, ~g4, ~g5],
        \in, [~b0, ~b1, ~b2, ~b3, ~b4, ~b5],
        \out, [~b1, ~b2, 0, ~b4, ~b5, 0],
        \ratio, Pfunc{[1, 1, 2, 2, 3, 3].scramble},
        \vibAmt, Pfunc{{rrand(0.0, 0.2)} ! 6} * 0.3,
        \vibRate, Pfunc{[2, 3, 4, 4, 6, 8].scramble},
        \detuneAmt, Pfunc{{rrand(0.0, 0.2)} ! 6} * 0.2,
        \detuneRate, Pfunc{{rrand(0.1, 0.5)} ! 6},
        \legato, Pfunc{{rrand(0.4, 0.8)} ! 6} * 1.2,
        \atk, Pfunc{{rrand(1.5, 4.5)} ! 6},
        \dec, Pfunc{{rrand(0.9, 1.6)} ! 6},
        \sus, Pfunc{{rrand(0.4, 0.9)} ! 6},
        \rel, Pfunc{{rrand(1.5, 4.5)} ! 6} * 2.5,
        \curve, Pfunc{{rrand(-5, -1)} ! 6},
        \amp, [1.2, 1.4, 0.3, 1.4, 1.2, 0.3],
        \pan, [-0.8, 0.8, -0.3, -0.8, 0.8, 0.3],
    ).play;
}
)