(
SynthDef(\wavPlayer, { |out = 0, bufnum = 0, trig = 1, sustain = 1|
	var audio, rate, speed, pos, env, attack, sus, release, speeds;
	// randomize speed
	speeds = [-1,-0.5,0.5,1];
	speed = TChoose.kr(trig,speeds);
	// randomize position
	pos = TRand.kr(0,1,trig)*BufFrames.kr(bufnum);
	// randomize enveloppe
	attack = TRand.kr(0.01,min(1,sustain),trig);
	release = TRand.kr(0.01,sustain-attack,trig);
	sus = sustain - attack - release;
	env = EnvGen.ar(Env.asr(attack,sus,release),trig);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(trig) >= 1);
	audio = PlayBuf.ar(2, bufnum, rate, trig, pos, doneAction:2);
	// randomize pan
	audio = Balance2.ar(audio[0], audio[1], EnvGen.kr(Env.new([TRand.kr(-1,1,trig),TRand.kr(-1,1,trig)], [sustain]),trig));
	Out.ar(out, audio * env);
}).add;
)

(
SynthDef(\wavPlayer, { |out = 0, bufnum = 0, gate = 1, speed = 1|
	var audio, rate, pos, env;
	// randomize position
	pos = TRand.kr(0,1,gate)*BufFrames.kr(bufnum);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  // env
  env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
  audio = PlayBuf.ar(2, bufnum, rate, gate, pos, doneAction:2);
  SendTrig.kr(gate,0,bufnum);
  Out.ar(out, audio * env);
}).add;
)

~wavPath = "/Users/geoffroy/Music/pym - documents sonores/*.aif";
~wavFiles = ~wavPath.pathMatch;
~buffers = ~wavFiles.collect( {|buf| Buffer.read(s, buf)} );

// test wavPlayer1
// read a soundfile from disk
x = Synth("wavPlayer", [out: 0, bufnum: ~buffers.at(0), gate: 0]);
x.set(\gate,1);
x.set(\gate,0);
b.free;
x.free;

TempoClock.default.tempo = 120/60;

// launch 4 players at the same time with fibonnacci lengths
(
4.do {
  Pbind(*[
    instrument: \wavPlayer,
    dur: Prand([1,2,3,5,8,13,21]*4,10),
    bufnum: Prand(~buffers,10),
    speed: Prand([-1,1],10)
  ]).play(quant: 1);
}
)

// avec des soupirs
(
Pbind(*[
instrument: \wavPlayer,
  dur: Pseq([1,2,3,5,8,13,Rest(1),Rest(2),Rest(3),Rest(5),Rest(8),Rest(13)],10),
  bufnum: ~buffers[0].bufnum,
  speed: 1
]).play(quant: 1);
)

(
4.do {
  Pbind(*[
    instrument: \wavPlayer,
    dur: Prand([1,2,3,5,8,13,Rest(1),Rest(2),Rest(3),Rest(5),Rest(8),Rest(13)],10)*4,
    bufnum: Prand(~buffers,10),
    speed: Prand([-1,1],10)
  ]).play(quant: 1);
}
)

// debugging
o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);

// remove all buffers
Buffer.freeAll();

///////////

// read a mono soundfile
b = Buffer.readChannel(s, ~buffers[0].path, channels: 0);
b.play;

(
var customEnv;

// a custom envelope
// customEnv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
customEnv = Env.perc(attackTime: 0.01, releaseTime: 1);
z = Buffer.sendCollection(s, customEnv.discretize, 1);

SynthDef(\buf_grain_test, {arg gate = 1, amp = 1, sndbuf, envbuf;
    var pan, env, freqdev;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: 2);
    Out.ar(0,GrainBuf.ar(numChannels: 2, trigger: Impulse.kr(MouseY.kr(100,1,1)), dur: 1, sndbuf: sndbuf, rate: 1, pos: LFNoise2.kr(0.1).range(0, 1), interp: 2, pan: pan, envbufnum: envbuf) * env)
    }).add;
)

// use built-in env
x = Synth(\buf_grain_test, [\sndbuf, b, \envbuf, -1]);
// use custom env
x.set(\envbuf, z);
x.set(\envbuf, -1);

x.set(\gate, 0);
