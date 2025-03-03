s.boot;
(
SynthDef(\wavPlayerStereo, { |out = 0, bufnum = 0, gate = 1, rate = 1, pos = 0|
	var audio, env;
	// env
	env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
	audio = PlayBuf.ar(2, bufnum, rate*BufRateScale.kr(bufnum), gate, pos, doneAction:2);
	Out.ar(out, audio * env);
}).add;

SynthDef(\wavPlayerMono, { |out = 0, bufnum = 0, gate = 1, rate = 1, pos = 0|
	var audio, env;
	// env
	env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
	audio = PlayBuf.ar(1, bufnum, rate*BufRateScale.kr(bufnum), gate, pos, doneAction:2);
	Out.ar(out, audio ! 2 * env);
}).add;
)

(
~wavPath = "/Volumes/LaCie/tournages sonores/*/*.wav";
~wavFiles = ~wavPath.pathMatch;
~wavFiles.size
)

(
var file, buffer, synth, pos, rate;
var seconds, samples;

{
	while { true }
	{
		file = ~wavFiles.choose;
		seconds = 20.rand;

		buffer = Buffer.read(s, file, action: { |b|
			b.normalize;
			samples = seconds * b.sampleRate;
			pos = (b.numFrames - samples).max;
			rate = [0.6,1].choose;

			("now playing" ++ file ++ " at pos="++ (pos/b.sampleRate) + "s for "++ seconds++"s at rate="++rate).postln;
			{
				switch(b.numChannels,
					1, { synth = Synth("wavPlayerMono", [out: 0, bufnum: b, gate: 1, rate: rate, pos: pos]); },
					2, { synth = Synth("wavPlayerStereo", [out: 0, bufnum: b, gate: 1, rate: rate, pos: pos]); }
				);
				seconds.wait;
				synth.set(\gate,0);
				1.wait;
				b.free;
			}.fork;
		});
		(seconds+5).wait;
	};
}.fork;
)