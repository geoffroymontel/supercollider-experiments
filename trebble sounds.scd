~wavPath = "/Users/geoffroy/Music/pym - documents sonores/*.aif";
~wavFiles = ~wavPath.pathMatch;
~buffers = ~wavFiles.collect( {|buf| Buffer.readChannel(s, buf, channels: 0); } );

(
SynthDef(\wavGrainBuf, { |out = 0, bufnum = 0, gate = 1, speed = 1, cutoff = 200|
	var audio, rate, pos, env;
	// randomize position
	pos = TRand.kr(0,1,gate)*BufFrames.kr(bufnum);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  // env
  env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
  audio = GrainBuf.ar(numChannels: 2, trigger: Impulse.kr(TRand.kr(1,1000,gate)), dur: TRand.kr(0.001,1,gate), sndbuf: bufnum, rate: speed, pos: pos + LFNoise0.kr(freq: 100).range(-44100,44100), interp: 2, pan: LFNoise0.kr(freq: 100).range(-1,1), envbufnum: -1);
  audio = BHiPass.ar(in: audio, freq: cutoff);
  SendTrig.kr(gate,0,bufnum);
  Out.ar(out, audio * env);
}).add;
)

TempoClock.default.tempo = 120/60;


// avec des soupirs
(
Pbind(*[
instrument: \wavGrainBuf,
  dur: Prand([1,2,3,5,8,13],10)*4,
  bufnum: Prand(~buffers,10),
  speed: Prand([2,4,8,16,32],10),
  cutoff: Pfunc({exprand(600, 2000)})
]).play(quant: 1);
)

// debugging
o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);
