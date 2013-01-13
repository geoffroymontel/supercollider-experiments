// free all
Server.all.do(_.freeAll)


~wavPath = "D:/pym/stravinsky - documents sonores/samples/doc*.wav";
~wavFiles = ~wavPath.pathMatch;
~buffers = ~wavFiles.collect( {|buf| Buffer.read(s, buf)} );


// list all buffers
(
["n°","bufnum","path"].postln;
~buffers.do {|item, i|
  [i,item.bufnum, item.path].postln;
}
)

(
SynthDef(\wavStereoPlayer, { |out = 0, bufnum = 0, gate = 1, speed = 1, pos = 0, pan = 0, amp = 1, loop = 0|
	var audio, rate, env;
  SendTrig.kr(gate,0,pos);
  pos = pos * BufFrames.kr(bufnum);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  // env
  env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
  audio = PlayBuf.ar(numChannels: 2, bufnum: bufnum, rate: rate, trigger: gate, startPos: pos, loop: loop, doneAction:2);
  audio = Balance2.ar(audio[0], audio[1], pan, amp);
  Out.ar(out, audio * env);
}).add;
)

// read a soundfile from disk
x = Synth("\wavStereoPlayer", [out: 0, bufnum: ~buffers.at(0), gate: 0]);
x.set(\gate,1);
x.set(\gate,0);
b.free;

// phasing
(
x = Synth("\wavStereoPlayer", [out: 0, bufnum: ~buffers.at(0), gate: 0, speed: 1, pan: -1, loop: 1]);
y = Synth("\wavStereoPlayer", [out: 0, bufnum: ~buffers.at(0), gate: 0, speed: 1.01, pan: 1, loop: 1]);
x.set(\gate,1);
y.set(\gate,1);
)

(
x.set(\gate,0);
y.set(\gate,0);
)

// set tempo
TempoClock.default.tempo = 120/60;

// debugging
o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

// play with rate
(
4.do {
  Pbind(*[
    instrument: \wavStereoPlayer,
    dur: Prand([1,2,3,5,8,13,Rest(1),Rest(2)],50)*4,
    legato: 1,
    pan: Pfunc({rrand(-1.0,1.0)}),
    bufnum: Prand(~buffers,50),
    speed: Prand([-1,-2,-3,-4,-6,0,1,2,3,4,6],50).midiratio,
    pos: Pfunc({rrand(0.0,1.0)})
  ]).play(quant: 1);
}
)

// nice subtle melody
(
Pbind(*[
  instrument: \wavStereoPlayer,
  dur: 8,
  legato: 2,
  pan: Pfunc({rrand(-1.0,1.0)}),
  bufnum: 24,
  speed: Prand([-1,-2,-3,-4,-6,0,1,2,3,4,6],50).midiratio,
  pos: Pfunc({rrand(0.0,1.0)})
]).play(quant: 1);
)

// mix 4 ch
(
4.do {
  Pbind(*[
    instrument: \wavStereoPlayer,
    dur: Prand([1,2,3,5,8,13,Rest(1),Rest(2)],10)*4,
    legato: 1,
    bufnum: Prand(~buffers,10),
    speed: Prand([-1,1],10),
    pos: Pfunc({rrand(0.0,1.0)})
  ]).play(quant: 1);
}
)

// old school stutter
(
SynthDef(\wavStereoPlayerNoEnv, { |out = 0, bufnum = 0, gate = 1, speed = 1, pos = 0, pan = 0, amp = 1, loop = 0|
	var audio, rate, env;
  pos = pos * BufFrames.kr(bufnum);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  // env
  env = EnvGen.ar(Env.asr(0.001,1,0.001), gate, doneAction:2);
  audio = PlayBuf.ar(numChannels: 2, bufnum: bufnum, rate: rate, trigger: gate, startPos: pos, loop: loop, doneAction:2);
  audio = Balance2.ar(audio[0], audio[1], pan, amp);
  SendTrig.kr(gate,0,pos);
  Out.ar(out, audio * env);
}).add;
)

(
p = rrand(0.0,1.0);
p.postln;
1.do {
Pbind(*[
  instrument: \wavStereoPlayerNoEnv,
  dur: Prand([1,2,4,8,12,16],50)*1/8,
  legato: 1,
  pan: Pfunc({rrand(-1.0,1.0)}),
  bufnum: ~buffers.choose,
  speed: 1,
  pos: Pfunc({rrand(p,p+0.01)})
]).play(quant: 1);
}
)

// time stretch
(
var winenv;
// a custom envelope - not a very good one, but you can hear the difference between this
// and the default
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\warp, {arg buffer = 0, envbuf = -1;
var out, pointer, filelength, pitch, env, dir;
// pointer - move from beginning to end of soundfile over 15 seconds
pointer = Line.kr(0, 1, 300);
// control pitch with MouseX
pitch = MouseX.kr(0.5, 2);
env = EnvGen.kr(Env([0.001, 1, 1, 0.001], [0.1, 300, 0.9], 'exp'), doneAction: 2);
out = Warp1.ar(2, buffer, pointer, pitch, 0.1, envbuf, 8, 0.1, 2);
Out.ar(0, out * env);
}).add;

)

// use built-in env
x = Synth(\warp, [\buffer, ~buffers[1], \envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.free;