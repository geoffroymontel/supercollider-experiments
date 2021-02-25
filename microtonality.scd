// using https://github.com/danielmkarlsson/SuperClean

(
Pdef(0,
    Pbind(*[
        type: \cln,
        snd: \sin,
        freq: Pseq((20,21..40),inf)
            + Pseq((20,23..60),inf)
            + Pseq((20,25..80),inf)
            + Pseq((20,27..100),inf)
            + Pseq((20,29..120),inf)
            + Pseq((20,31..140),inf)
            + Pseq((20,33..160),inf),
        amp: Pexprand(0.5,1.0),
        pan: Pseq(((0.0,0.01..1.0) ++ (0.99,0.98..0.01)),inf),
        tri: Pexprand(0.0001,0.2),
        dur: Pseq([
            1/3,1/3,
            1/5,1/5,1/5,
            1/7,1/7,1/7,1/7,
            1/9,1/9,1/9,1/9,1/9,
            1/11,1/11,1/11,1/11,1/11,1/11,
            1/13,1/13,1/13,1/13,1/13,1/13,1/13,
            1/15,1/15,1/15,1/15,1/15,1/15,1/15,1/15,
            1/17,1/17,1/17,1/17,1/17,1/17,1/17,1/17,1/17
        ],inf),
        rel: Pexprand(0.1,4.0),
        crv: (Pwhite(-2.0,-10.0) + Pexprand(0.01,6.0)).trace,
        sustain: 8,
        legato: 8,
        bpf: 20*Pseq((1..20),inf),
        hpf: 20*Pseq((1,3..30),inf),
        lhf: Pwhite(0.0,1.0),
        scm: Pexprand(1.0,1.025)-1,
        rma: Pexprand(1.0,1.5)-1,
        rmf: Pexprand(50,500),
        stretch: Pseq((1,1.01..3.0),inf),
        dark: 0.01,
    ])
).play(quant:1);
)

Pdef(0).stop;
