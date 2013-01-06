~wavPath = "/Users/geoffroy/Music/pym - documents sonores/*.aif";
~wavFiles = ~wavPath.pathMatch;
~buffers = ~wavFiles.collect( {|buf| Buffer.read(s, buf)} );

20.do({ postln(exprand(0.01, 1)); });
1.0.linrand;
Array.fill(500, {  7.0.rand }).plot("Sequence of 500x 7.0.rand");
Array.fill(500, {  7.0.linrand }).plot("Sequence of 500x 7.0.linrand");
Array.fill(500, {  exprand(0.001, 7)}).plot("Sequence of 500x exprand(0.001, 7)");

(
SynthDef(\wavPlayer, { |out = 0, bufnum = 0, gate = 1, speed = 1, cutoff = 200|
	var audio, rate, pos, env;
	// randomize position
	pos = TRand.kr(0,1,gate)*BufFrames.kr(bufnum);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  // env
  env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
  audio = PlayBuf.ar(2, bufnum, rate, gate, pos, doneAction:2);
  audio = BLowPass.ar(in: audio, freq: cutoff);
  SendTrig.kr(gate,0,bufnum);
  Out.ar(out, audio * env);
}).add;
)

TempoClock.default.tempo = 120/60;

// avec des soupirs
(
Pbind(*[
instrument: \wavPlayer,
  dur: Prand([1,2,3,5,8,13],10)*4,
  bufnum: Prand(~buffers,10),
  speed: Prand([-1/32,-1/16,-1/8,-1/4,-1/2,1/32,1/16,1/8,1/4,1/2],10),
  cutoff: Pfunc({exprand(150, 300)})
]).play(quant: 1);
)

(
SynthDef(\wavGrainBuf, { |out = 0, bufnum = 0, gate = 1, speed = 1, cutoff = 200|
	var audio, rate, pos, env;
	// randomize position
	pos = TRand.kr(0,1,gate)*BufFrames.kr(bufnum);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  // env
  env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
  audio = GrainBuf.ar(numChannels: 2, trigger: Impulse.kr(TRand.kr(1,1000,gate)), dur: TExpRand.kr(0.001,1,gate), sndbuf: bufnum, rate: speed, pos: pos, interp: 2, pan: 0, envbufnum: -1);
  audio = BLowPass.ar(in: audio, freq: cutoff);
  SendTrig.kr(gate,0,bufnum);
  Out.ar(out, audio * env);
}).add;
)

// avec des soupirs
(
Pbind(*[
instrument: \wavPlayer,
  dur: Prand([1,2,3,5,8,13],10)*4,
  bufnum: Prand(~buffers,10),
  speed: Prand([-1/32,-1/16,-1/8,-1/4,-1/2,1/32,1/16,1/8,1/4,1/2],10),
  cutoff: Pfunc({exprand(150, 300)})
]).play(quant: 1);
)
