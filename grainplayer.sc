(
SynthDef(\grainPlayer, { |out = 0, bufnum = 0, root, range_min = 50, range_max = 2000|
	var audio, range, in, amp, freq, hasFreq, myEnv, myEnvBuffer, grain_dur;

	in = SoundIn.ar(0);
	amp = Amplitude.ar(in);
	# freq, hasFreq = Pitch.kr(in);
	freq.poll(trig: 2, label: "in freq");
	amp.poll(trig: 2, label: "in amp");

	grain_dur = 2;
	myEnv = Env.perc(attackTime: 0.001, releaseTime: grain_dur);
	myEnvBuffer = Buffer.sendCollection(s, myEnv.discretize, 1);

	audio = GrainBuf.ar(
		numChannels: 2, 
		trigger: Impulse.kr(30), 
		rate: freq/root, 
		dur: grain_dur, 
		sndbuf: bufnum, 
		pos: K2A.ar(((freq-range_min)/(range_max-range_min)+LFNoise0.kr(freq:5, mul:0.00000001))*BufFrames.kr(bufnum)),
		pan: LFNoise0.kr(10).range(-0.2,0.2),
		envbufnum: myEnvBuffer
	);

	Out.ar(out, audio * amp * hasFreq);
}).add;
)

(
~file = "d:/supercollider/mandoline.wav";
~buffer = Buffer.readChannel(s, ~file, channels: [0]);
)


// with audio in
(
	"b5".notemidi.postln;
	"b5".notemidi.midicps.postln;

	x = Synth("grainPlayer", [out: 0, 
		bufnum: ~buffer, 
		root: "b5".notemidi.midicps, 
		range_min: "c#2".notemidi.midicps,
		range_max: "c8".notemidi.midicps]);
)


// TESTS

(
	{ 
		var myenv, envBuffer;

		myenv = Env.perc(attackTime: 0.001, releaseTime: 1);
		envBuffer = Buffer.sendCollection(s, myenv.discretize, 1);

		GrainBuf.ar(
		numChannels: 2, 
		trigger: Impulse.kr(10), 
		rate: 1, 
		dur: 0.1, 
		sndbuf: ~buffer, 
		pos: K2A.ar(LFNoise0.kr()*BufFrames.kr(~buffer)),
		pan: LFNoise0.kr(10).range(-0.2,0.2),
		envbufnum: envBuffer
		);
	}.play;

)

Env.perc(attackTime: 0.0001, releaseTime: 1).test.plot;