VstPlugin.makeSynthDef.add;
~vst = VstPlugin.new([\nin, 0, \nout, 2, \out, 0, \replace, 0], s, addAction: \addToHead);
~vst.open("/Library/Audio/Plug-Ins/VST/mda ePiano.vst", info: true);
~vst.showGui;
~vst.programs;
~vst.currentProgram;
~vst.midiNoteOn(chan: 0, note: 60, veloc: 64);
~vst.midiNoteOn(chan: 0, note: 64, veloc: 64);

(
SystemClock.sched(1, {
	~vst.midiNoteOn(chan: 0, note: 60, veloc: 64);
	~vst.midiNoteOn(chan: 0, note: 64, veloc: 64);
});
SystemClock.sched(2, {
	~vst.midiNoteOff(chan: 0, note: 60, veloc: 64);
	~vst.midiNoteOff(chan: 0, note: 64, veloc: 64);
});
)

~vst.midiNoteOff(chan: 0, note: 60, veloc: 64);

(
Event.addEventType(\vstPlugin, { |server|
	var notes = [
		~midinote.value,  // 0
		~ctranspose.value,  // 1
		~velocity.value, // 2
		~sustain.value, // 3
		~lag.value, // 4
		~timingOffset.value, //5
		~instrument, // 6
		~midiChannel.value, // 7
	].flop;
	var timeNoteOn, timeNoteOff;

	notes.do { |note|
		// sustain and timingOffset are in beats, lag is in seconds
		timeNoteOn = (thisThread.clock.tempo.reciprocal*note[5])+note[4]+server.latency;
		timeNoteOff = (thisThread.clock.tempo.reciprocal*(note[3]+note[5]))+note[4]+server.latency;

		SystemClock.sched(timeNoteOn, {
			note[6].midiNoteOn(chan: note[7] ? 0, note: (note[0]+note[1]).asInteger, veloc: note[2].asInteger.clip(0,127));
		});
		SystemClock.sched(timeNoteOff, {
			note[6].midiNoteOff(chan: note[7] ? 0, note: (note[0]+note[1]).asInteger, veloc: note[2].asInteger.clip(0,127));
		});
	}
});
)

(
Pbind(*[
	type: \vstPlugin,
	instrument: ~vst,
	dur: 4,
	degree: [0, 4],
	velocity: 64
]).play;
)


// straight timing
(
Pbind(*[
	type: \vstPlugin,
	instrument: ~vst,
	legato: Pgauss(0.2,0.05,inf),
	dur: 0.2,
	degree: [2,5,12],
	ctranspose: Pseq([0,0,0,0,4,4,4,4,5,5,5,5],inf),
	velocity: Pgauss(64,10,inf),
]).play;
)

// loose timing
(
Pbind(*[
	type: \vstPlugin,
	instrument: ~vst,
	legato: 0.1,
	dur: 0.2,
	midinote: [66, 69, 74],
	lag: Pwhite(-0.05!3, 0.05)
]).play;
)
