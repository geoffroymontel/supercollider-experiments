// Synthdefs

(
SynthDef(\bass, { |baseNote = 40, tempo = 1, out = 0|
	var snd;

	var beats = [1, 1, 1, 0.5, 0.5] / tempo;
	var notes = [0, 0, 0, 3, 5];

	var trigger = TDuty.kr(Dseq(beats, inf));
	var note = Demand.kr(trigger, 0, baseNote + Dseq(notes, inf));
	snd = LFTri.ar([note.midicps, (note + 0.1).midicps]) * EnvGen.kr(Env.perc, trigger);
	Out.ar(0, snd);
}).add;

SynthDef(\arpeggio, { |baseNote = 40, tempo = 1, out = 0|
	var snd;

	var beats = [1, 0.5, 0.5, 2, 1, 2, 0.5, 0.5] / 8 / tempo;
	var notes = [0, 3, 7, 12, 14, 15, 19, 20];

	var trigger = TDuty.kr(Dseq(beats, inf));
	var note = Demand.kr(trigger, 0, baseNote + Dseq(notes, inf));
	snd =LFPulse.ar(note.midicps ! 2, width: LFNoise0.kr(tempo.reciprocal).range(0.2, 0.8)) * EnvGen.kr(Env.perc, trigger);
	snd = (snd * 0.4)+ (NHHall.ar(snd) * 0.2);
	Out.ar(0, snd);
}).add;
)

// Instanciate synths but don't start playing
(
~group = Group.new;
~bass = Synth.newPaused(\bass, target: ~group);
~arpeggio = Synth.newPaused(\arpeggio, target: ~group);
)

// Set TempoBusClock
~clock = TempoBusClock.new(~group);

// Play a pattern to control the whole thing
(
~bass.run;
~arpeggio.run;
Pbind(*[
	type: \set,
	id: ~group.nodeID,
	args: #[baseNote],
	baseNote: Pseq([40, 42, 44, 38], inf),
	dur: 4
]).play(~clock);
)

// change tempo
~clock.tempo = 20/60;
~clock.tempo = 45/60;
~clock.tempo = 59/60;

