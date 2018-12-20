(
SynthDef(\testNrtSynth, { |out, freq = 440|
	Out.ar(out, SinOsc.ar([freq, freq * 1.0001]) * -10.dbamp);
}).add;
)

(
p = Pspawner.new({ |sp|
	var first, second;
	sp.seq(
		Prout({
			first = Synth(\testNrtSynth, [\freq, 200]);
			3.wait;
			second = Synth(\testNrtSynth, [\freq, 400]);
			1.wait;
			first.free;
			1.wait;
			second.free;
		});
	);
	sp.wait(1);
});
)

// realtime
p.play;

p.render("/tmp/test.wav");

{Out.ar(0, SinOsc.ar(freq: 440, phase: 0, mul: 0.1, add: 0))}.play()

a = Out.ar(0, SinOsc.ar(freq: 440, phase: 0, mul: 0.1, add: 0));

{ a }.class

play{a=LFNoise2.kr(15)**0.33;RLPF.ar(Saw.ar(180+(150*a.lag(2.0)),),280+(250*a),0.33).dup}