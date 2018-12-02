(
Ndef(\storm, {
    var rain, wind, thunder, snd;
    thunder = {
        var trig, snd;
        snd = WhiteNoise.ar;
        snd = Latch.ar(snd, Dust.ar(XLine.kr(8000, 16000, 3)));
        snd = LPF.ar(snd, LFNoise2.kr(8).linexp(-1, 1, 300, 600));
        snd = (snd * 30.dbamp * Env.perc(0.1, 5.0).kr).tanh;
        snd = LPF.ar(snd, 3000);
        snd = snd * Env([0, 1, 0.5, 1, 0], [0.01, 0.25, 0.05, 5], 4).ar;
        snd = snd ! 2;
        snd;
    }.();

    wind = {
        var snd;
        snd = { WhiteNoise.ar } ! 2;
        snd = RLPF.ar(snd, LFNoise2.kr(1).exprange(500, 1000), LFNoise2.kr(2).range(0.5, 0.8));
        snd;
    }.();

    rain = {
        snd = { TRand.ar(-1, 1, Dust.ar(10e3)) } ! 2;
        snd = BPF.ar(snd, 500, 0.6);
        snd;
    };

    snd = (wind * -23.dbamp) + (thunder * -23.dbamp);
    snd = snd + JPverb.ar(snd, 1);
    snd = snd + (rain * -18.dbamp);

    snd;
}).play;
)
