s.reboot;
(
~bus1 = Bus.audio(s, 2);
~bus2 = Bus.audio(s, 2);
)
(
SynthDef(\limiter, { |out, in|
	Out.ar(out, Limiter.ar(in: In.ar(in,2)));
}).add;
)

(
SynthDef(\reverb, { |out, in|
	Out.ar(out, FreeVerb.ar(in: In.ar(in,2), mix: MouseY.kr(0,0.5)));
}).add;
)

(
SynthDef(\hecker, { |out, freq, t_trig, duration|
	var output;
	output = Saw.ar(freq: ([freq, freq+1] * SinOsc.ar(freq: MouseX.kr(0, 10))));
	output = output.cubed.cubed.scaleneg(1).tanh;
	output = EnvGen.ar(Env.perc(releaseTime: duration), gate: t_trig, doneAction: Done.freeSelf) * output;
	Out.ar(bus: out, channelsArray: output);
}).add;
)

(
{
	~limiter = Synth.tail(s, \limiter, [out: 0, in: ~bus2]);
	~reverb = Synth.before(~limiter, \reverb, [out: ~bus2, in: ~bus1]);
	1000.do {|i|
		var low, hi, freq, duration;
		low = 200;
		hi = 2000;
		freq = low+(i*(hi - low)/1000);
		duration = [1/2, 1, 2, 4].choose;
		freq.postln;
		duration.postln;
		Synth.before(~reverb,\hecker, [out: ~bus1, freq: freq, t_trig: 1, duration: duration]);
		(duration/10).wait;
	}
}.fork;
)
