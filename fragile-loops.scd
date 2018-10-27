(
~wavPath = "/Users/geoffroy/Music/**/*.wav";
~wavFiles = ~wavPath.pathMatch;
~wavFiles.do({|e|
	e.postln;
});
)

(
SynthDef(\wavStereoPlayer, { |out = 0, bufnum = 0, gate = 1, speed = 1, pos = 0, pan = 0, amp = 1, loop = 0, speedWow = 0, ampWow = 0, panWow = 0|
	var audio, rate, env;
	pos = pos * BufFrames.kr(bufnum);
	rate = BufRateScale.kr(bufnum)*speed + LFNoise2.kr(LinRand(0.01, 10.0), speedWow);
	env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
	audio = PlayBuf.ar(numChannels: 2, bufnum: bufnum, rate: rate, startPos: pos, loop: loop, doneAction:2);
	audio = Balance2.ar(audio[0], audio[1], pan + LFNoise2.kr(LinRand(0.01, 10.0), panWow), amp + LFNoise2.kr(LinRand(0.01, 10.0), ampWow));
	Out.ar(out, audio * env);
}).add;
)

(
~buffer = Buffer.read(s, "/Users/geoffroy/Desktop/test-micro.wav");
)

(
~numberOfFiles = 2;
~buffers = ~wavFiles.scramble[0..~numberOfFiles-1].collect({|f| Buffer.read(s,f)});
)
(
~buffers.do({ |buffer|
  Pbind(*[
    instrument: \wavStereoPlayer,
		// dur: Prand([1, 2, 4, 8, 12, 20, 32, 52, Rest(1), Rest(4), Rest(8)],50),
	dur: Prand([1, 2, 4, 8, Rest(1), Rest(4)],50),
    pan: rrand(-1.0,1.0),
	legato: 1,
    bufnum: buffer,
	speed: rrand(0.2,1.0),
    pos: Pfunc({rrand(0.0,1.0)}),
	speedWow: linrand(0.001,0.1),
	panWow: linrand(0.001,0.5),
	ampWow: linrand(0.001,0.5)
  ]).play(quant: 1);
});
)

(
e = Synth(\wavStereoPlayer, [
	out: 0,
	bufnum: ~buffer,
	speed: 0.5,
	pos: 0.5,
	pan: 0,
	amp: 1,
	loop: 0,
	speedWow: 0.5,
	panWow: 1,
	ampWow: -20.dbamp
]);
)

