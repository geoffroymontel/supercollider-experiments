(
{
    var trig, snd;
    trig = Impulse.ar(1);
    snd = Trig.ar(trig, 5e-3) * 3;
    snd = snd - OnePole.ar(snd, 1 - 100e-3) + (snd * 0.04);
    snd = Select.ar(snd > 0, [0.7 * snd / (1 - snd), snd]);
    snd = Ringz.ar(snd, 60 * (1 + (OnePole.ar(Trig.ar(trig, 10e-3), 0.96)) + (snd * 0.1)), 1);
    snd = snd * -40.dbamp;
    snd ! 2;
}.play(fadeTime: 0);
)