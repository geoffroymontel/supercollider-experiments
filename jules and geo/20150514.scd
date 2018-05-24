a = { |i| i * i; }

a.value(4);

(
SynthDef(\synth, { |out = 0, freq = 440|
	var o;

	o = [Pulse, Saw].choose;

	Out.ar(out, o.ar(
		freq: SinOsc.kr(freq: LFNoise1.kr(freq: [1,1.5])).range([freq, freq+1], [(freq*2)+1, (freq*2)+1]),
		mul: 0.2))
}).add;
)


(

Pbind(*[
	instrument: \synth,
	freq: Pseries(start: 10000, step: -100, length: 100),
	delta: 1
]).play;
)

(
{
	g = Group.new;

	50.do ({|i|
		Synth(\synth, [freq: (10*i) + 200], g);
	});
	10.wait;
	g.free;
	b = Synth(\synth, [freq: 4000]);
	3.wait;
	b.free;
}.fork
)