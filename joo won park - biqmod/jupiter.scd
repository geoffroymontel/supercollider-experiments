// scztt https://discord.com/channels/813532499262701678/813532541302210680/815257990952648706

(
Ndef(\jupiter, {
  arg freq=100, pan=0, amp=0.1;
  var sig,
    num=128,
    lfo1, lfo2, lfo3, lfo4, lfo5, lfo6, lfo7, lfo8,
    freqOffset, feed, bpRange, chord;

  lfo1 = LFNoise1.kr(1/9).range(0.1,0.9);
  lfo2 = LFNoise1.kr(1/9).range(0.1,0.9);
  lfo3 = LFNoise1.kr(1/19).exprange(0.01,0.9);
  lfo4 = Duty.kr(Dseq([1,0.7,0.9,0.4],inf)*2, 0, Dseq([
    Drand([
      Dseq([1],20),
      Dseq([1],40),
      Dseq([lfo3],20),
      Dseq([1,0],7),
      Dseq([
        1,1,1,1,
        0,0,0,0,
        Dseq([lfo3],4),
      ],4),
    ],1),
  ],inf)).lag(2);

  freqOffset = Decay.kr(Impulse.kr(1/16), 30).linexp(0, 1, 0.5, 16);

  feed = LocalIn.ar(2).tanh;
  freq = freq +.f (feed * freq * 2);
  chord = TChoose.kr(Impulse.kr(1/8), [4, 5]).midiratio;
  freq = num.collect {
    |i|
    freq.wrapAt(i)
    * TWChoose.kr(
      Dust.kr(0.1),
      [1, 2, 4, chord],
      [5, 2, 1, 1],
      1
    )
  };

  sig = VarSaw.ar(
    freq + ({rrand(0.0, 1.0)} ! num).linlin(
      0, 1,
      SinOsc.kr(1/7).exprange(2, freqOffset).neg,
      SinOsc.kr(1/8).exprange(2, freqOffset)
    ),
    Rand(0, 2),
    SinOsc.kr((0..num-1) / 100).range(0.05, 0.8)
  );

  sig = sig.collect {
    |sig, i|
    var f = [2, 2, 6, 6, 6, 6, 7, 12].scramble.wrapAt(i);
    var trig = Dust.kr(3);
    Decay.kr(
      Impulse.kr(f) * Trig1.kr(trig, TRand.kr(0.3, 1.6, trig)),
      0.6
    ) * sig;
  };

  bpRange = [
    SinOsc.kr(1/32, [0, 1, 2, 3]/2).exprange(70, 600),
    SinOsc.kr(1/27, [0, 1, 2, 3]/2).exprange(6000, 19000)
  ];

  sig = RLPF.ar(sig,LFNoise1.kr(1/222!num).exprange(100.01,18000.0), lfo1 * 0.35);
  sig = BPF.ar(sig, Amplitude.kr(sig).lagud(0.03, 0.4).rotate(1).linexp(0,2, bpRange[0], bpRange[1]), lfo2);
  pan = pan + LFNoise1.kr(1/432!sig.size).range(-1.0,1.0);
  sig = 8 * amp * Splay.ar(sig.scramble);
  sig = AllpassL.ar(sig, 1/2, 1/2,1) + sig;
  LocalOut.ar(sig);
  sig = Compander.ar(sig, sig, 0.1, 1.001, 0.4, 0.01, 0.1);
  sig = sig * 15;
}).play;
);

// histoires https://discord.com/channels/813532499262701678/813532541302210680/815023715133554698
(
Ndef(\jupiter, { arg freq=200, pan=0, amp=0.1;
    var sig;
    var num=100;
    var lfo1, lfo2, lfo3, lfo4, lfo5, lfo6, lfo7, lfo8;
    lfo1 = LFNoise1.kr(1/9).range(0.1,0.9);
    lfo2 = LFNoise1.kr(1/9).range(0.1,0.9);
    lfo3 = LFNoise1.kr(1/19).exprange(0.01,0.9);
    lfo4 = Duty.kr(Dseq([1,0.7,0.9,0.4],inf)*2, 0, Dseq([
        Drand([
            Dseq([1],20),
            Dseq([1],40),
            Dseq([lfo3],20),
            Dseq([1,0],7),
            Dseq([
                1,1,1,1,
                0,0,0,0,
                Dseq([lfo3],4),
            ],4),
        ],1),
    ],inf)).lag(2);
    sig = LFSaw.ar(LFNoise1.kr(1/1122!num).exprange(50,18000) * ( SinOsc.ar( LFNoise1.kr(1/222!num).exprange(100.01,18000.0) * lfo4 ) * LFNoise1.kr(1/332!num).exprange(0.01,1.0) + 1 ));
    sig = RLPF.ar(sig,LFNoise1.kr(1/222!num).exprange(100.01,18000.0)  , lfo1);
    sig = BPF.ar(sig, Amplitude.kr(sig).lag(0.2).rotate(1).linexp(0,2,50,17000), lfo2);
    pan = pan + LFNoise1.kr(1/432!sig.size).range(-1.0,1.0);
    sig = Pan2.ar(sig, pan, amp).mean * 8;
    sig = AllpassL.ar(sig, 1/2, 1/2,1) + sig;
    sig = Compander.ar(sig, sig, \cpt.kr(0.1), \cpbelow.kr(1.001), \cpabove.kr(0.4), \cpclamp.kr(0.01), \cprelax.kr(0.1));
    sig = sig * 5;
    sig.debug("sig");
}).play;
);

// pulu https://discord.com/channels/813532499262701678/813532541302210680/814621038302330880
(
Ndef(\seams, {
    var fbs, freqs, iphase, width, sig, chains, trail;
    fbs = LocalIn.ar(2);
    freqs = [1, 3/2, 4/3] * 200.0;
    freqs = freqs.collect { |freq|
        freq * (1.01.pow(LFNoise1.ar(0.121).range(-1.0, 1.0)));
    };
    iphase = {
        LFNoise0.ar(809.8).range(0.0, 1.0);
    };
    width = {
        var steps, slide, power, zig, rmin, rmax;
        steps = LFNoise0.ar(LFNoise0.ar(1.1).range(1.0, 3.0)).range(0.0, 1.0);
        slide = LFNoise2.ar(0.44) * 0.2;
        zig = LFNoise1.ar(LFNoise2.ar(0.67).range(0.2, 200.0)) * LFNoise2.ar(0.99) * 0.4;
        power = LFNoise1.ar(2.4).exprange(0.1, 5.0);
        rmin = LFNoise0.ar(2.21).range(0.0, 0.5).lag(0.1);
        rmax = LFNoise0.ar(2.247).range(0.5, 1.0).lag(0.1);
        (steps + slide + zig).pow(power).linlin(0, 1, rmin, rmax);
    };
    sig = Mix.ar(freqs.collect { |freq|
        var sig;
        sig = VarSaw.ar(freq, iphase, width) * ({ LFNoise1.ar(LFNoise0.ar(80.2).exprange(0.1, 20.0)).exprange(0.5, 1.0)} ! 2);
        sig = Pan2.ar(sig[0], LFNoise2.ar(1.13).range(-1.0, 1.0));
        sig;
    }) / freqs.size;
    chains = sig.collect { |c|
        var chain;
        chain = FFT(LocalBuf(2048), c);
        chain = PV_BinShift(chain, 0.9, LFNoise1.ar(1.0).range(-1.0, 1.0) * 8.0);
        chain;
    };
    trail = chains.collect { |c, i|
        var sig;
        sig = IFFT(c);
        sig = sig + (fbs[i] * 0.7);
        sig = DelayC.ar(sig, 2.0, LFNoise2.ar(0.11).exprange(0.2, 2.0));
        sig = HPF.ar(sig, 600.0);
        sig = LPF.ar(sig, 9000.0);
        sig;
    };
    LocalOut.ar(trail.reverse);
    sig = (sig*1.0) + (trail*0.85 * LFNoise0.ar(3.34).exprange(0.5, 1.0)).pow(LFNoise0.ar(0.75).range(0.7, 1.0));
    sig * 0.5;
}).play;
)
﻿