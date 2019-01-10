x = Pslide.new([1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0], len: 12, start: 0);
x.asStre

(
SynthDef(\clap1, { |amp = 1.0|
	var sig;
	sig = WhiteNoise.ar;
	sig = EnvGen.ar(
		envelope: Env.new(levels: [0, 0.01, 1, 0], times: [0, 0.005, 0.080], curve: [\lin, 3, -3]),
		doneAction: Done.freeSelf
	) * sig;
	sig = HPF.ar(in: sig, freq: 100);
	sig = sig + BPF.ar(in: sig, freq: 1000, rq: 1.26);
	sig = sig + HPF.ar(in: sig, freq: 6000);
	sig = sig * amp * -12.dbamp;
	Out.ar(0, sig);
}).add;

// adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\clap2, {
    |out = 0, amp = 0.5, dur = 1|
    var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(1, snd * amp * -12.dbamp);
}).add;
)


x = Synth.new(\clap1, [amp: 1.0]);

TempoClock.default.tempo = 80/60;

(
p = Pbind(*[
	instrument: \clap1,
	amp: Pslide.new([1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0], len: 12, start: 0),
	dur: 0.25
]);
)
p.play

(
Pspawner({ |sp|
	(0..11).do({ |i|
		4.do({
			sp.par(Pbind(*[
				instrument: \clap1,
				amp: Pslide.new([1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0], len: 12, start: 0),
				dur: 0.25
			]));
			sp.seq(Pbind(*[
				instrument: \clap2,
				amp: Pslide.new([1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0], len: 12, start: i),
				dur: 0.25
			]));
		});
	});
}).play;
)

(
Routine.new({
	var pattern;

	pattern = Pslide.new([1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0], len: 12, start: 0).asStream;

	12.do({ |i|
		var isPlaying;
		isPlaying = pattern.next;
		isPlaying.postln;
		if(isPlaying ==1, {
			Synth.new(\clap1);
		});
		0.25.wait;
	});
}).play;
)


(
Routine.new({
	(0..11).do({ |i|
		4.do({
			var pattern1, pattern2;

			pattern1 = Pslide.new([1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0], len: 12, start: 0).asStream;
			pattern2 = Pslide.new([1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0], len: 12, start: i).asStream;

			12.do({ |i|
				var isPlaying1, isPlaying2;
				isPlaying1 = pattern1.next;
				isPlaying2 = pattern2.next;
				if(isPlaying1 ==1, {
					Synth.new(\clap1);
				});
				if(isPlaying2 ==1, {
					Synth.new(\clap2);
				});
				0.25.wait;
			});
		});
	});
}).play;
)