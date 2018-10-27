(
SynthDef(\mosquito, { |out=0, gate=1|
  var volEnv, pitchEnv, signal;

  volEnv = Env(levels:[-12.dbamp, 0.dbamp, -16.dbamp, 0], times:[3.79, 4.34, 7.16], curve:[0,-5,-5], releaseNode: 2, loopNode:0);
  pitchEnv = Env(levels:[31.midiratio, 23.midiratio, 31.midiratio, 26.midiratio]*0.23, times:[6.59, 2.63, 19.5], curve:[0,-1,-1], releaseNode: 2, loopNode:0);

  signal = Saw.ar(freq:(400*EnvGen.kr(pitchEnv, gate))+LFNoise2.kr(freq:20, mul:10));
  signal = BHiPass.ar(signal, freq: 2600) * EnvGen.kr(volEnv, gate, doneAction: Done.freeSelf);
  Out.ar(out, signal);
}).add;
)

(
SynthDef(\mosquito2, { |out=0, gate=1, freq=400|
  var volEnv, pitchEnv, signal;
	volEnv = Env.asr(0.01,1,0.01);

	signal = Saw.ar(freq:LFNoise2.kr(freq:LFNoise1.kr(1).range(1,10)).range(0.9*freq,1.1*freq));
  signal = BHiPass.ar(signal, freq: 2600) * LFNoise1.kr(freq:LFNoise1.kr(1).range(1,10)).range(-10.dbamp,1.0) * EnvGen.kr(volEnv, gate, doneAction: Done.freeSelf);
	signal = Pan2.ar(signal, LFNoise1.kr(freq: LFNoise1.kr(1).range(0.5,2)).lag(0.2));
  Out.ar(out, signal);
}).add;
)

(
Pbind(*[
	instrument: \mosquito2,
	freq: Pwrand([270, Rest()],[0.8,0.2], inf),
	dur: Pwhite(0.1,5)
]).play;
)

x = Synth(\mosquito2, [\freq, 270]);
x.release;
