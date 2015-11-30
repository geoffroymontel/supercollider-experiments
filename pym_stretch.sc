s.boot;

(

~path = "/Users/geoffroy/dev/supercollider-experiments/DM_extrait_to_stretch.wav";
~stereoBuf = Buffer.read(s, ~path);
~monoBuf = Buffer.readChannel(s, ~path, channels: 0);

y = Env([0, 1, 1, 0], [0.0001, 1, 0.0001], 'cub');
z = Buffer.sendCollection(s, y.discretize, 1);

SynthDef(\warp, {arg buffer = 0, envbuf = -1, start_speed = 1, end_speed = 5;
  var out, rate, pointer;
  rate = Line.kr(start_speed,end_speed,BufDur.kr(buffer));
  pointer = LFSaw.kr(BufDur.kr(buffer).reciprocal * rate,1,0.5,0.5);
  out = Warp1.ar(numChannels: 2, bufnum: buffer, envbufnum: envbuf, pointer: pointer, overlaps:4, windowSize: 1, interp: 4, windowRandRatio: 0.1);
  Out.ar(0, out);
}).add;

SynthDef(\warp2, {arg buffer = 0, envbuf = -1, start_speed = 1, end_speed = 5;
  var out, rate, pointer;
  rate = Line.kr(start_speed,end_speed,BufDur.kr(buffer));
  pointer = LFSaw.kr(BufDur.kr(buffer).reciprocal * rate,1,0.5,0.5);
  out = GrainBuf.ar(
    numChannels: 2,
    trigger: Impulse.kr(freq: 10),
    rate: 1,
    dur: 0.26,
    sndbuf: buffer,
    pos: pointer,
    pan: 0,
    mul: 3.reciprocal,
    envbufnum: -1
  );
  Out.ar(0, out);
}).add;
)

// use built-in env
x = Synth(\warp, [buffer: ~stereoBuf, envBuf: z, start_speed: 1, end_speed: 0.2]);
x = Synth(\warp2, [buffer: ~monoBuf, envBuf: z, start_speed: 1, end_speed: 5]);
x.free;
