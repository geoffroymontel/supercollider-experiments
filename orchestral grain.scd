(
~file = "/Users/geoffroy/Music/pym - documents sonores/passage orchestral doc 1.wav";
~buffer = Buffer.readChannel(s, ~file, channels: [0]);
)

(
{
  var myenv, envBuffer, trigenv, length;

  length = 120;

//  myenv = Env.perc(attackTime: 0.001, releaseTime: 1);
  myenv = Env.linen(attackTime: 0.5, sustainTime: 0, releaseTime: 0.001, curve: \sin);
  envBuffer = Buffer.sendCollection(s, myenv.discretize, 1);
  trigenv = Env.new(levels: [0, 1, 0], times: [90, 30]);

  LPF.ar(
    in: GrainBuf.ar(
      numChannels: 2,
      trigger: Impulse.kr(EnvGen.kr(envelope: trigenv, levelScale: 50)),
      rate: [0.25, 0.5, 1],
      dur: XLine.kr(start: 5, end: 0.01, dur: length, doneAction: 2),
      sndbuf: ~buffer,
      pos: Line.kr(start: 1, end: BufFrames.kr(~buffer), dur: length),
      pan: 0,
      mul: 3.reciprocal,
      envbufnum: -1
    ),
    freq: XLine.kr(start: 50, end: 18000, dur: length)
  );
}.play;
)

Env.linen(attackTime: 0.5, sustainTime: 0, releaseTime: 0.001, curve: \sin).test.plot;
{XLine.kr(start: 50, end: 18000, dur: 10)}.plot(10);
