// buffer
~buffer = Buffer.read(server: s, path: "/Users/geoffroy/music/stromboli/samples/mandoline_tri.wav", action: { "buffer loaded".postln; });

(
SynthDef(\wavStereoPlayer, { |out = 0, bufnum = 0, gate = 1, speed = 1, pos = 0, pan = 0, amp = 1, loop = 0|
	var audio, rate, env;
  SendTrig.kr(gate,0,pos);
  pos = pos * BufFrames.kr(bufnum);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  // env
  env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:0);
  audio = PlayBuf.ar(numChannels: 2, bufnum: bufnum, rate: rate, trigger: gate, startPos: pos, loop: loop, doneAction:0);
  audio = Balance2.ar(audio[0], audio[1], pan, amp);
  Out.ar(out, audio * env);
}).add;
)

//test synth
x = Synth("\wavStereoPlayer", [out: 0, bufnum: ~buffer, gate: 0]);
x.set(\gate,1);
x.set(\gate,0);

//loop
x = Synth("\wavStereoPlayer", [out: 0, bufnum: ~buffer, gate: 1, loop: 1, speed: Line.kr(start: 1, end: 2, dur: 60, doneAction:2)]);

TempoClock.default.tempo = 120/60;

(
p = rrand(0.0,1.0);
p.postln;
4.do {
Pbind(*[
  instrument: \wavStereoPlayer,
  dur: Prand([1,2,4,8,12,16],50)*1/8,
  legato: 1,
  pan: Pfunc({rrand(-1.0,1.0)}),
  bufnum: ~buffer,
  speed: 1,
  amp: 2,
  pos: Pfunc({rrand(p,p+0.01)})
]).play(quant: 1);
}
)

// nice subtle melody
(
Pbind(*[
  instrument: \wavStereoPlayer,
  dur: Prand([1,2,4,8,12,16],50),
  legato: 2,
  pan: Pfunc({rrand(-1.0,1.0)}),
  bufnum: ~buffer,
  amp: 2,
  speed: Prand([-1,-2,-3,-4,-6,0,1,2,3,4,6],50).midiratio,
  pos: Pfunc({rrand(0.0,0.1)})
]).play(quant: 1);
)


Scale.directory

a = Scale.bartok;
a.degrees;        // [ 0, 2, 4, 5, 7, 9, 11 ]
a.semitones;        // [ 0, 2, 4, 5, 7, 9, 11 ]
a.cents;        // [ 0, 200, 300, 500, 700, 900, 1100 ]
a.ratios;        // [ 1, 1.1224620483089, 1.2599210498937, 1.3348398541685, etc. ]

Pbind(\scale, a, \degree, Pseq((0..7) ++ (6..0) ++ [\rest], 1), \dur, 0.25).play;

// tests
(
{
var trigger, audio;

trigger = Impulse.kr(freq: 4);

audio = PlayBuf.ar(
  numChannels: 2,
  bufnum: ~buffer,
    rate: BufRateScale.kr(~buffer)*MouseX.kr(1,1.1,0,1),
  trigger: trigger,
  startPos: TRand.kr(0.0,1.0,trigger) * BufFrames.kr(~buffer)
);
  audio = Balance2.ar(audio[0], audio[1],LFNoise0.kr(4));
Out.ar(0, audio);
}.play;
)

{LFNoise2.ar(1)}.plot(10)

b = ~buffer;
{ BufRd.ar(1, b, LFNoise2.ar(1) * BufFrames.ir(b)) }.play;


