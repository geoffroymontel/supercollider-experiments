(
SynthDef(\sine, { |freq = 440, attack = 0.01, sustain = 1.0, release = 0.01, out|
	var sig = Blip.ar(freq: [freq,freq+10], numharm: 3, mul: 1 )
	* EnvGen.ar(Env.linen(attackTime: attack, sustainTime: sustain, releaseTime: release), doneAction: Done.freeSelf)
	* 0.1;
	Out.ar(out, sig);
}).add;
)

(
var duration = 100;
{ SinOsc.ar(freq: [
	SinOsc.kr(freq: Line.kr(start: 200, end: Line.kr(start: 1000, end: 6000, dur: duration), dur: duration), mul: 400, add: 800),
	SinOsc.kr(freq: Line.kr(start: 800, end: Line.kr(start: 6000, end: 2000, dur: duration), dur: duration), mul: 400, add: 800)]
) }.play;
)

x = Synth(\sine, [freq: 800]);
x.free;

TempoClock.default = TempoClock.new(80/60);
(
var pitchRoutine = Routine.new({
	loop({
		var steps = rrand(2,20);
		var start = [400,500,600,700].choose;
		steps.do { |i| (start + (i*100)).yield; }
	})
});


1.do({
	Routine.new({
		var noteLength = 1/8;
		loop({
			Synth(\sine, [freq: pitchRoutine.next, sustain: noteLength]);
			noteLength.wait;
		});
	}).play(quant: 1);
});
)

