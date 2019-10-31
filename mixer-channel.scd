// needs James Harkins' ddwMixerChannel quark
Quarks.gui

(
SynthDef(\blipDelay, { |out, bufnum, t_repan|
   var dly, dtime, sig, newdly, bufRate;
   sig = In.ar(out, 2);
   // this technique is borrowed from MultiTap
   RecordBuf.ar(Mix.ar(sig) * 0.7, bufnum, 0, run:-1);
   bufRate = BufSampleRate.kr(bufnum);
   dtime = 0;
   dly = Mix.arFill(3, { |i|
      dtime = dtime + rrand(0.5, 2);
      dly = PlayBuf.ar(1, bufnum, -1, startPos:dtime * bufRate, loop:1);
      Pan2.ar(LPF.ar(dly, 5000 - (i*2000)),
         TRand.kr(-1.0, 1.0, t_repan), (i+3).reciprocal);
   });
   Out.ar(out, dly)
}).add;

SynthDef(\blipdrop, { |out, freq, freqdrop, dur, trigStart, trigEnd, bufnum|
   var trig, tfreq, amp, timeScale, osc, pan;
   trig = Impulse.kr((tfreq = XLine.kr(trigStart, trigEnd, dur))
      + LFNoise0.kr(12, tfreq * 0.8, tfreq));
   amp = EnvGen.kr(Env(#[0, 1, 0.8, 0], #[0.01, 4, 4].normalizeSum), 1, timeScale:dur,
      doneAction:2);
   pan = LFNoise1.kr(0.8, 0.8);
   freq = freq * LFNoise1.kr(1.2, 0.2, add: Line.kr(1, freqdrop, dur));
   osc = Osc.ar(bufnum, Latch.kr(freq, trig), 0, amp);
   Out.ar(out, Pan2.ar(Decay2.kr(trig, 0.01, 0.08) * osc, pan));
}).add;

// other resources needed by the synthdefs
~dlybuf = Buffer.alloc(s, 6.05 * s.sampleRate, 1);
~oscbuf = Buffer.alloc(s, 4096, 1)
   .sine2(({ |i| rrand(3-i, 6-i) + (i+2).reciprocal.rand2 } ! 4), (1..4).reciprocal);
)

~chan = MixerChannel(\blippy, s, 2, 2);

// play some synths every so often
(
r = Task({
   {   ~chan.play(\blipdrop, [\freq, rrand(1000, 2000), \freqdrop, rrand(0.4, 0.7),
         \dur, rrand(6, 10), \bufnum, ~oscbuf.bufnum,
         \trigStart, rrand(1.1, 1.4), \trigEnd, rrand(7.0, 10)]);
      rrand(5, 12).wait;
   }.loop;
}).play;
)

// add delay
~dlysynth = ~chan.playfx(\blipDelay, [\bufnum, ~dlybuf.bufnum, \t_repan, 1]);

// stop
r.stop;

// create master channel
~master = MixerChannel(\master, s, 2, 2, level:1);
~chan = MixerChannel(\blippy, s, 2, 2, outbus:~master);
// or ~chan.outbus = ~master;


~dly = MixerChannel(\dly, s, 2, 2, level:1);
~src = MixerChannel(\src, s, 2, 2);
~src.newPostSend(~dly, 1);  // this is explained in the next section
~src.play({ |out|
      // read later synths playing on the delay bus
   InFeedback.ar(~dly.inbus.index, 2)
});
   // one second delay with slight amplitude reduction
~dly.playfx({ |out| DelayN.ar(In.ar(out, 2), 1, 1, 0.98) });

(
   // source synths follow InFeedback in the execution chain
~src.play(\blipdrop, [\freq, rrand(1000, 2000), \freqdrop, rrand(0.4, 0.7),
   \dur, rrand(6, 10), \bufnum, ~oscbuf.bufnum,
   \trigStart, rrand(1.1, 1.4), \trigEnd, rrand(7.0, 10)]);
)

// cleanup from this example
[~dly, ~src].do(_.free);

// execute this only if you didn't create the master earlier
~master = MixerChannel(\master, s, 2, 2, level:1);

// restart the routine
r.play;

// reverb channel, feeding into the master
~rvbmc = MixerChannel.new("chn rvb", s, 2, 2, outbus:~master);

// play the reverb as an effect
(
~rvb = ~rvbmc.playfx({ |out|
   var numChan, maxDelay, preDelay, decay, numRefl, random;
   var sig, new, dlys;
   #numChan, maxDelay, preDelay, decay, numRefl, random = #[2, 0.181, 0.08, 4, 8, 0.1];
   sig = In.ar(out, numChan);
   new = sig;
   dlys = Array.fill(numRefl, {
      new = AllpassN.ar(new, maxDelay,
         Array.fill(numChan, { random.rand }) + preDelay, decay);
   });
   Mix.ar(dlys * Array.series(numRefl, 1, (numRefl+1).reciprocal.neg))
});
)

~send = ~chan.newPostSend(~rvbmc, 0.41);

~send.level = 0;

~send.levelTo(0.8, 40);  // fade it in slowly over 40 seconds


// with GUI

MixerChannel.freeAll;

(
~master = MixerChannel(\master, s, 2, 2, level:1);
~chan = MixerChannel(\blippy, s, 2, 2);
~rvbmc = MixerChannel.new("chn rvb", s, 2, 2);

~dlysynth = ~chan.playfx(\blipDelay, [\bufnum, ~dlybuf.bufnum, \t_repan, 1]);

~rvb = ~rvbmc.playfx({ |out|
   var numChan, maxDelay, preDelay, decay, numRefl, random;
   var sig, new, dlys;
   #numChan, maxDelay, preDelay, decay, numRefl, random = #[2, 0.181, 0.08, 4, 8, 0.1];
   sig = In.ar(out, numChan);
   new = sig;
   dlys = Array.fill(numRefl, {
      new = AllpassN.ar(new, maxDelay,
         Array.fill(numChan, { random.rand }) + preDelay, decay);
   });
   Mix.ar(dlys * Array.series(numRefl, 1, (numRefl+1).reciprocal.neg))
});

r.play;
)

~board = MixingBoard("demo", nil, ~chan, ~rvbmc, ~master);
