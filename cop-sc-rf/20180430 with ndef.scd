s.reboot;

(
Ndef(\reverb, {
	FreeVerb.ar(in: \in.ar(0!2), mix: 1);
}).play;
)


(
SynthDef(\test, { |out, freq, duration|
	var output;
	output = Saw.ar(freq: ([freq, freq+10]));
	output = output.cubed.cubed;
	output = LeakDC.ar(in: output, mul: 0.2);
	output = EnvGen.ar(Env.perc(releaseTime: duration), doneAction: Done.freeSelf) * output;
	Out.ar(bus: out, channelsArray: output);
}).add;
)

Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({ rrand(300, 700) })) );
Ndef(\sound) <>> Ndef(\reverb);
Ndef(\sound).clear;

(
Ndef(\melody, Prout({
	1000.do {|i|
		var low, hi, freq, duration;
		low = 200;
		hi = 2000;
		freq = low+(i*(hi - low)/1000);
		duration = [1/2, 1, 2, 4].choose;
		Synth(\test, [out: 0, freq: freq, duration: duration]);
		(duration/10).wait;
	}
}));
)

Ndef(\melody) <>> Ndef(\reverb);

Ndef.clear

