~buf = Buffer.alloc(s, Server.default.sampleRate * 0.6, 1);

(
{
    var in, pos, snd;
    in = Impulse.ar(0);
    snd = LocalIn.ar(1) * 1.0; // <- feedback coefficient
    pos = DelTapWr.ar(~buf, snd);
    snd = in + (DelTapRd.ar(~buf, pos, { rrand(0.05, 0.2) + (LFNoise2.kr(rrand(0.5, 1.5)) * 0.005) } ! 14).sum * 0.3);
    snd = (snd + 0.1).tanh;
    snd = LeakDC.ar(snd);
    LocalOut.ar(snd);
    snd = Splay.ar(DelTapRd.ar(~buf, pos, { rrand(0.05, 0.2) } ! 20));
    snd = snd + NHHall.ar(snd, 5);
	snd = (snd * -10.dbamp).tanh;
}.play;
)

(
{
    var snd;
    snd = (SinOsc.ar(440) ! 2) + (LocalIn.ar(2) * -3.dbamp);
    LocalOut.ar({ PitchShift.ar(snd, 0.2, 1.5, 0.01, 0.05).tanh } ! 2);
    snd = snd * -5.dbamp;
    snd;
}.play;
)

