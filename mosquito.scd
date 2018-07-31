(
SynthDef(\mosquito, { |out=0, gate=1|
  var volEnv, pitchEnv, signal;

  volEnv = Env(levels:[-12.dbamp, 0.dbamp, -16.dbamp, 0], times:[3.79, 4.34, 7.16], curve:[0,-5,-5], releaseNode: 2, loopNode:0);
  pitchEnv = Env(levels:[31.midiratio, 23.midiratio, 31.midiratio, 26.midiratio]*0.23, times:[6.59, 2.63, 19.5], curve:[0,-1,-1], releaseNode: 2, loopNode:0);

  signal = Saw.ar(freq:(200*EnvGen.kr(pitchEnv, gate))+LFNoise2.kr(freq:5, mul:10));
  signal = BHiPass.ar(signal, freq: 2600) * EnvGen.kr(volEnv, gate, doneAction: Done.freeSelf);
  Out.ar(out, signal);
}).add;
)

x = Synth(\mosquito);
x.release;
