(
~modulatingFile = "d:/supercollider/sacreintro2.wav";
~modulatedFile = "d:/supercollider/preludeintro.wav";
~modulatingBuffer = Buffer.readChannel(s, ~modulatingFile, channels: [0]);
~modulatedBuffer = Buffer.readChannel(s, ~modulatedFile, channels: [0]);
)

(
~modulatingBuffer.play;
~modulatedBuffer.play;
)

{ Amplitude.kr(SoundIn.ar(0)); }.scope;

(
x = {
	var in, amp, freq, hasFreq, out;
	in = PlayBuf.ar(1, ~modulatingBuffer, doneAction:2);

	// in = SoundIn.ar(0);
	amp = Amplitude.ar(in);
	# freq, hasFreq = Pitch.kr(in);
	freq.poll(trig: 2, label: "freq");
	amp.poll(trig: 2, label: "amp");
	// LFTri.ar(freq !2) * amp;
	// BufRd.ar(2, ~modulatedBuffer, K2A.ar((freq ! 2/4000)*BufFrames.kr(~modulatedBuffer))) * amp;
	GrainBuf.ar(
		numChannels: 2, 
		trigger: Impulse.kr(4), 
		rate: 1.0, 
		dur: 1, 
		sndbuf: ~modulatedBuffer, 
//		pos: K2A.ar(MouseX.kr + LFNoise0.kr(10,0.001)), 
		pos: K2A.ar((freq-200/1000)*BufFrames.kr(~modulatedBuffer)),
		pan: LFNoise0.ar(100).range(-0.2,0.2)
	) * amp;
	}.play
)




s.freeAll;