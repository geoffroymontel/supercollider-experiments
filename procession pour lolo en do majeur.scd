(
MIDIClient.init;

~loopMidi1 = MIDIOut.newByName("loopMIDI Port", "loopMIDI Port").latency_(Server.default.latency);
~loopMidi2 = MIDIOut.newByName("loopMIDI Port 1", "loopMIDI Port 1").latency_(Server.default.latency);
~loopMidi3 = MIDIOut.newByName("loopMIDI Port 2", "loopMIDI Port 2").latency_(Server.default.latency);
)

(
~tempo = 60/60;
TempoClock.default.tempo = ~tempo;

// ~commonPattern = Pbind(*[lag: Pwhite(0, 0.01, inf), amp: Pwhite(0.5,0.6,inf)]);
// ~commonPattern = Pbind(*[lag: Pwhite(0, 0.01, inf), trace: Pfunc({|ev| postf("lag: %, amp: %, velocity: %\n", ev[\lag], ev[\amp]);})]);
~commonPattern = Pbind(*[lag: Pwhite(0, 0.01, inf)]);

~durationToBeats = { |duration|
	duration * ~tempo;
};

~voices = [
	(name: 'cc', midiout: ~loopMidi2, chan: 0),
	(name: 'chrystelle', midiout: ~loopMidi2, chan: 1),
	(name: 'claude', midiout: ~loopMidi2, chan: 2),
	(name: 'corinne', midiout: ~loopMidi2, chan: 3),
	(name: 'geo', midiout: ~loopMidi2, chan: 4),
	(name: 'nicolas', midiout: ~loopMidi2, chan: 5),
	(name: 'joelle', midiout: ~loopMidi2, chan: 6),
	(name: 'laurent', midiout: ~loopMidi2, chan: 7),
	(name: 'leila', midiout: ~loopMidi2, chan: 8),
	(name: 'samia', midiout: ~loopMidi2, chan: 9),
	(name: 'floflo', midiout: ~loopMidi2, chan: 10),
	(name: 'kamel', midiout: ~loopMidi2, chan: 11),
	(name: 'arthur', midiout: ~loopMidi2, chan: 12),
	(name: 'sylvie', midiout: ~loopMidi2, chan: 13),
];

~flutes = [
	(name: 'flute alto', midiout: ~loopMidi1, chan: 4),
	(name: 'flute soprano', midiout: ~loopMidi1, chan: 5),
];

~saxophones = [
	(name: 'sax karine', midiout: ~loopMidi1, chan: 6),
	(name: 'sax thonam', midiout: ~loopMidi1, chan: 7)
];

~instruments = (
	pulse: (midiout: ~loopMidi3, chan: 0),
	kick: (midiout: ~loopMidi3, chan: 1),
	snare: (midiout: ~loopMidi3, chan: 1),
	stick: (midiout: ~loopMidi3, chan: 1),
	organ: (midiout: ~loopMidi1, chan: 0),
	bass: (midiout: ~loopMidi1, chan: 8),
	dulcimer: (midiout: ~loopMidi1, chan: 10),
);

~songSections = [
	// 0
	(
		duration: 10,
		voices: Pbind(*[note: Pseq([0,0], inf), dur: Pseq([1,4], inf), legato: 0.95, octave: 3])
	),
	// 1
	(
		duration: 10,
		voices: Pbind(*[note: Pseq([0,0], inf), dur: Pseq([1,4], inf), legato: 0.95, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)])
	),
	// 2
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([0,0]), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,0]), dur: Pseq([1,5]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,0,Prand([-2,4],1)]), dur: Pseq([1,4,2]), legato: 0.95, octave: 3])
		], inf),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pn(Pbjorklund2(2, 32, inf)/4), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 3
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([0,0]), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-2,0]), dur: Pseq([1,5]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,0,Prand([-2,3],1)]), dur: Pseq([1,4,2]), legato: 0.95, octave: 3, db: Pseq([-20,-20,-30])])
		], inf),
		pulse: Pn(Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)])),
		kick: Pbind(*[dur: Pbjorklund2(2, 32, inf)/4, octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(3, 32, inf)/4)]), octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 4
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([0,0]), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-2,0]), dur: Pseq([1,5]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,0,Prand([-2,3],1)]), dur: Pseq([1,4,2]), db: Pseq([-20,-20,-30]), legato: 0.95, octave: 3])
		], inf),
		flutes: Pbind(*[note: Pseq([7, Prand([7,5],inf)]), dur: Prand([4,6], inf), db: Pwhite(-30,-20), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(2, 32, inf)/4, octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(3, 32, inf)/4)]), octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(4, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 5
	(
		duration: 60,
		voices: Prand([
			Pbind(*[note: Pseq([0,0]), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-2,0]), dur: Pseq([1,5]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,0,Prand([-2,3],1)]), dur: Pseq([1,4,2]), legato: 0.95, octave: 3])
		], inf),
		flutes: Pbind(*[note: Pseq([7, Prand([7,5],inf)]), dur: Prand([4,6], inf), db: Pseq([-20,-30],inf), legato: 0.9, octave: 3]),
		organ: Pbind(*[note: Prand([Pseq([0,3]),Pseq([0,3,7]),Pseq([0,3,7,10])], inf), dur: 1/4, legato: 0.95, octave: 4]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(3, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(4, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(5, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 6
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([-4,0]), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-4,0]), dur: Pseq([1,5]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-4,0,Prand([0,3],1)]), dur: Pseq([1,4,2]), legato: 0.95, octave: 3])
		], inf),
		flutes: Pbind(*[note: Pseq([8, Prand([8,7,3],inf)]), dur: Prand([1,4,6], inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pbind(*[note: Prand([Pseq([-4,0]),Pseq([-4,0,3]),Pseq([-4,0,3,8])], inf), dur: 1/4, legato: 0.95, octave: 4]),
		bass: Pbind(*[note: Pseq([-4], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(3, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(4, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(3),Pn(Pbjorklund2(5, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 7
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([-4,0]), dur: Pseq([1,4])/2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-4,0]), dur: Pseq([1,5])/2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-4,0,Prand([0,3],1)]), dur: Pseq([1,4,2])/2, legato: 0.95, octave: 3])
		], inf),
		flutes: Pbind(*[note: Pseq([8, Prand([8,7,3],inf)]), dur: Prand([1,4,6], inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-4,0], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0,3], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0,3,8], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0,3], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0,3,8], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0,3], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,0,3,8], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-4,0], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-4,0,3], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-4,0], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-4,0,3], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-4,0], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-4,0,3], 8), dur: 1/8, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([-4], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(4, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(5, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(3),Pn(Pbjorklund2(6, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 8
	(
		duration: 60,
		voices: Prand([
			Pbind(*[note: Pseq([-3,0]), dur: Pseq([1,4])*2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,5]), dur: Pseq([1,5])*2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,5,Prand([5,4],1)]), dur: Pseq([1,4,2])*2, legato: 0.95, octave: 3])
		], inf),
		flutes: Pbind(*[note: Pseq([9, Prand([9,7,5],inf)]), dur: Prand([1,4,6], inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-7,-3], 2), dur: 1, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0], 2), dur: 1, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0,4], 2), dur: 1, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3], 4), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0], 4), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0,4], 4), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3], 1), dur: 2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0], 1), dur: 2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0,4], 1), dur: 2, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([-7], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(2, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(3, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(3),Pn(Pbjorklund2(5, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 9
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([-3,0]), dur: Pseq([1,4])*1.5, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,3]), dur: Pseq([1,5])*1.5, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([0,5,Prand([5,3],1)]), dur: Pseq([1,4,2])*1.5, legato: 0.95, octave: 3])
		], inf),
		flutes: Pbind(*[note: Pseq([9, Prand([9,7,5,3],inf)]), dur: Prand([1,4,6], inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-7,-3], 2), dur: 1 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0], 2), dur: 1 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0,3], 2), dur: 1 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3], 4), dur: 1/2 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0], 4), dur: 1/2 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0,3], 4), dur: 1/2 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3], 1), dur: 2 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0], 1), dur: 2 * 0.75, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-7,-3,0,3], 1), dur: 2 * 0.75, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([-7], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(1, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(2, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(3),Pn(Pbjorklund2(4, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 10
	(
		duration: 60,
		voices: Prand([
			Pbind(*[note: Pseq([-2,2]), dur: Pseq([1,1])/2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-2,2]), dur: Pseq([1,1]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([2,5]), dur: Pseq([1,1])/2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([2,5]), dur: Pseq([1,1]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-2,2,5]), dur: Pseq([1,1]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([5, Prand([5,3,2],inf)]), dur: 1/4, legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-2,2], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,2,5], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,2], 1), dur: 1, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,2,5], ), dur: 1, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([-2], inf), dur: Pseq([1,4], inf)/2, legato: 0.9, octave: 3]),
		dulcimer: Pn(Pbind(*[
			degree: Plazy({
				var repeat, length;
				var pitches = List.new(20);
				Array.series(14,0,1).do { |start|
					length = rand(5) + 2;
					repeat = rand(30) + 1;
					pitches.add(Array.series(length,start,1).mirror1.dup(repeat));
				};
				Pseq(pitches.flatten(3));
			}),
			root: 10,
			scale: Scale.major,
			octave: 4,
			dur: 1/8,
			legato: 0.9,
			db: Pkey(\degree).linexp(0,30,-2,-20)
		])),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(8, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(10, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(4),Pn(Pbjorklund2(14, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 11
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([-4,2]), dur: Pseq([1,1])/2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-4,2]), dur: Pseq([1,1])/4, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([2,5]), dur: Pseq([1,1])/2, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([2,5]), dur: Pseq([1,1])/4, legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([-4,2,5]), dur: Pseq([1,1])/2, legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([5, Prand([8,5,3],inf)]), dur: 1/8, legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-4,2], 2), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,2,5], 2), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,2], 1), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-4,2,5], ), dur: 1/2, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([-4], inf), dur: Pseq([1,4], inf)/2, legato: 0.9, octave: 3]),
		dulcimer: Pn(Pbind(*[
			degree: Plazy({
				var length;
				length = rand(10) + 2;
				Pseq(Array.series(length, 0, 2));
			}),
			root: 8,
			scale: #[0, 2, 4, 6, 7, 9, 11],
			octave: 4,
			dur: 1/2,
			legato: 0.9,
			db: Pkey(\degree).linexp(0,40,-2,-30)
		])),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(10, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(13, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(16, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 12
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: -5, dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: -1, dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: 2, dur: Pseq([1,4]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([7,5,7],inf), dur: Pseq([1/4,1/4,1],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-5,-1], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1,2], 2), dur: 1/2, legato: 0.95, octave: 4]),
		].choose}), inf),
		dulcimer: Pn(Pbind(*[
			octave: 5,
			note: Pseq([7,14,11,19]),
			dur: Pseq([Prand([2,4]),1,Prand([2,4]),1]),
			db: Pkey(\note).linexp(7,40,-2,-30)
		])),
		bass: Pbind(*[note: Pseq([-5], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(8, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(9, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(4),Pn(Pbjorklund2(11, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 13
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: -5, dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: -1, dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: 2, dur: Pseq([1,4]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([7,5,11],inf), dur: Pseq([1/4,1/4,1],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-5,-1], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1,2], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1,2,5], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1,2,5,7], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1], 2), dur: 1, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1,2], 2), dur: 1, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1,2,5], 2), dur: 1, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-5,-1,2,5,7], 2), dur: 1, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([-5], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		dulcimer: Pn(Pbind(*[
			octave: 5,
			note: Pseq([7,14,11,17,19,23]),
			dur: Pseq([Prand([2,4,6]),1],3),
			db: Pkey(\note).linexp(7,40,-2,-30)
		])),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(8, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(9, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(4),Pn(Pbjorklund2(11, 32, inf)/2)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 14
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([0]), dur: Pseq([1/4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([5]), dur: Pseq([1/4]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([7,5],inf), dur: Prand([1,2,4],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([0,5], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,5,7], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,5], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,5,7], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,5], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,5,7], 8), dur: 1/8, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([0], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		dulcimer: Pn(Plazy({[
			Pbind(*[note: Pseq([0,5], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5,7], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5,7,11], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5,7,11,12], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5,7,11,12,16], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5,7], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5,7,11], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,5,7,11,12], 4), dur: 1/4, legato: 0.95, octave: 5], db: Pkey(\note).linexp(0,40,-2,-30)),
			Pbind(*[note: Pseq([0,5,7,11,12,16], 4), dur: 1/4, legato: 0.95, octave: 5], db: Pkey(\note).linexp(0,40,-2,-30)),
		].choose}), inf),
		kick: Pbind(*[dur: Pbjorklund2(8, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(12, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(1/2),Pn(Pbjorklund2(10, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 15
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([0]), dur: Pseq([1/2]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([3]), dur: Pseq([1/2]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([5]), dur: Pseq([1/2]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([7,5,3],inf), dur: Prand([1,2,4],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([0,3], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,3,5], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,3], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,3,5], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,3], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([0,3,5], 8), dur: 1/8, legato: 0.95, octave: 4]),
		].choose}), inf),
		dulcimer: Pn(Plazy({[
			Pbind(*[note: Pseq([0,3], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5,7], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5,7,10], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5,7,10,12], 2), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5,7], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5,7,10], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([0,3,5,7,10,12], 4), dur: 1/4, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([0], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(7, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(9, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(11, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 16
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([-2],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([3],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([7],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([10,7,5,3],inf), dur: Prand([1,2,4],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-2,3], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3,7], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3,7], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3,7], 8), dur: 1/8, legato: 0.95, octave: 4]),
		].choose}), inf),
		dulcimer: Pbind(*[note: Pseq([3,22,15,10],inf), dur: 1, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
		bass: Pbind(*[note: Pseq([3], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(8, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(10, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(14, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
	),
	// 17
	(
		duration: 32,
		voices: Prand([
			Pbind(*[note: Pseq([-2],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([3],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([5],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([10,7,5,3],inf), dur: Prand([1,2,4],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-2,3], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3,5], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3,5], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-2,3,5], 8), dur: 1/8, legato: 0.95, octave: 4]),
		].choose}), inf),
		dulcimer: Pbind(*[note: Pseq([3,22,15,10],inf), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
		bass: Pbind(*[note: Pseq([3], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(8, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(11, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(14, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
		sax: Pbind(*[note: Pstutter(16, Pseq([3,4,5,6])), dur: Pseq([Pn(1/2,4),Pn(1/4,4),Pn(1/8,8)],inf)*2, octave: 3])
	),
	// 18
	(
		duration: 60,
		voices: Prand([
			Pbind(*[note: Pseq([-1],2), dur: Pseq([1,2]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([3],2), dur: Pseq([1,2]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([7],2), dur: Pseq([1,2]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([11,7,5,3],inf), dur: Prand([1,2,4],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-1,3], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3,7], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3,7], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3,7], 8), dur: 1/8, legato: 0.95, octave: 4]),
		].choose}), inf),
		bass: Pbind(*[note: Pseq([-5], inf), dur: Pseq([1,4], inf)*2, legato: 0.9, octave: 3]),
		dulcimer: Pn(Plazy({[
			Pbind(*[note: Pseq([-1,2,3,5,6,9,10,11],1), dur: 1/2, legato: 0.95, octave: 5, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([-1,2,3,5,6,9,10,11],1), dur: 1/4, legato: 0.95, octave: 5], db: Pkey(\note).linexp(0,40,-2,-30)),
			Pbind(*[note: Pseq([-1,2,3,5,6,9,10,11],1), dur: 1, legato: 0.95, octave: 5]),
		].choose})),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(4, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(5, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(1/2),Pn(Pbjorklund2(7, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
		sax: Pbind(*[note: Pseq([7,5,11,12], inf), dur: Prand([1,2,4], inf), octave: 3])
	),
	// 19
	(
		duration: 30,
		voices: Prand([
			Pbind(*[note: Pseq([-1],2), dur: Pseq([1,1]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([3],2), dur: Pseq([1,1]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([5],2), dur: Pseq([1,1]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([11,7,5,3],inf), dur: Prand([1,2,4],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Plazy({[
			Pbind(*[note: Pseq([-1,3], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3,5], 2), dur: 1/2, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3,5], 4), dur: 1/4, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3], 8), dur: 1/8, legato: 0.95, octave: 4]),
			Pbind(*[note: Pseq([-1,3,5], 8), dur: 1/8, legato: 0.95, octave: 4]),
		].choose}), inf),
		dulcimer: Pn(Plazy({[
			Pbind(*[note: Pseq([-1,2,3,5,6,8,9,10].mirror1,2), dur: 1/8, amp: 0.4, legato: 0.95, octave: 6, db: Pkey(\note).linexp(0,40,-2,-30)]),
			Pbind(*[note: Pseq([-1,2,3,5,6,8,9,10].mirror1,2), dur: 1/8, amp: 0.4, legato: 0.95, octave: 7, db: Pkey(\note).linexp(0,40,-2,-30)]),
		].choose})),
		bass: Pbind(*[note: Pseq([-5], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(2, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(4, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(2),Pn(Pbjorklund2(5, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
		sax: Pbind(*[note: Pseq([7,5,11,12], inf), dur: Prand([1,2,4], inf)/2, octave: 3])
	),
	// 20
	(
		duration: 120,
		voices: Prand([
			Pbind(*[note: Pseq([0],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([4],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
			Pbind(*[note: Pseq([7],2), dur: Pseq([1,4]), legato: 0.95, octave: 3]),
		], inf),
		flutes: Pbind(*[note: Pseq([0,4,7,12],inf), dur: Prand([4,8],inf), legato: 0.9, octave: 3, db: Pseq([-20,-30],inf)]),
		organ: Pn(Pbind(*[
			degree: Plazy({
				var length, repeat;
				length = rand(5)+2;
				repeat = rand(5)+1;
				Pseq(Array.series(length,0,1).mirror1.dup(repeat).flatten(2));
			}),
			root: 0,
			scale: Scale.major,
			octave: 4,
			dur: 1/8,
			legato: 0.9,
		])),
		dulcimer: Pn(Pbind(*[
			degree: Plazy({
				var length, repeat;
				length = rand(10) + 2;
				repeat = rand(5) + 1;
				Pseq(Array.series(length,0,1).mirror1.dup(repeat).flatten(2));
			}),
			root: 0,
			scale: Scale.major,
			octave: 5,
			dur: 1/8,
			legato: 0.9,
			db: Pkey(\degree).linexp(0,40,-2,-30)
		])),
		bass: Pbind(*[note: Pseq([0], inf), dur: Pseq([1,4], inf), legato: 0.9, octave: 3]),
		pulse: Pbind(*[dur: 1/4, octave: 3, note: Pseq([Pwhite(8,11,1), Pxrand((0..7),3)],inf), amp: Pseq([Pwhite(0.7,0.8,1),Pwhite(0.2,0.3,1),Pwhite(0.4,0.5,1),Pwhite(0.2,0.3,1)],inf)]),
		kick: Pbind(*[dur: Pbjorklund2(2, 32, inf)/4, octave: 3, note: Pxrand([0,8], inf), amp: Pwhite(0.8, 1.0, inf)]),
		snare: Pbind(*[dur: Pseq([Rest(1),Pn(Pbjorklund2(3, 32, inf)/4)]), octave: 3, note: Pxrand([3,11], inf), amp: Pwhite(0.8, 1.0, inf)]),
		stick: Pbind(*[dur: Pseq([Rest(1/2),Pn(Pbjorklund2(4, 32, inf)/4)]), octave: 3, note: 12, amp: Pwhite(0.8, 1.0, inf)]),
		sax: Pbind(*[note: Pseq([0,4,7,12], inf), dur: Prand([1,2,4], inf)/2, octave: 3])
	),

];

)



(
var duration;
~song = Pspawner({ |sp|
	//	~songSections.do({ |section, index|
	~songSections[0..].do({ |section, index|
		duration = section.duration;
		postf("Section %, duration %\n",index, duration);
		// voices
		if (section.voices != nil) {
			~voices.do({ |voice|
				sp.par(
					~commonPattern <> (type: \midi, midiout: voice.midiout, chan: voice.chan) <> Pfindur(duration, section.voices)
				);
			});
		};
		// pulse
		if (section.pulse != nil) {
			sp.par(
				~commonPattern <> (type: \midi, midiout: ~instruments['pulse'].midiout, chan: ~instruments['pulse'].chan) <> Pfindur(duration, section.pulse)
			);
		};
		// kick
		if (section.kick != nil) {
			sp.par(
				~commonPattern <> (type: \midi, midiout: ~instruments['kick'].midiout, chan: ~instruments['kick'].chan) <> Pfindur(duration, section.kick)
			);
		};
		// snare
		if (section.snare != nil) {
			sp.par(
				~commonPattern <> (type: \midi, midiout: ~instruments['snare'].midiout, chan: ~instruments['snare'].chan) <> Pfindur(duration, section.snare)
			);
		};
		// stick
		if (section.stick != nil) {
			sp.par(
				~commonPattern <> (type: \midi, midiout: ~instruments['stick'].midiout, chan: ~instruments['stick'].chan) <> Pfindur(duration, section.stick)
			);
		};
		// flutes
		if (section.flutes != nil) {
			~flutes.do({ |voice|
				sp.par(
					~commonPattern <> (type: \midi, midiout: voice.midiout, chan: voice.chan) <> Pfindur(duration, section.flutes)
				);
			});
		};
		// organ
		if (section.organ != nil) {
			sp.par(
				~commonPattern <> (type: \midi, midiout: ~instruments['organ'].midiout, chan: ~instruments['organ'].chan) <> Pfindur(duration, section.organ)
			);
		};
		// bass
		if (section.bass != nil) {
			sp.par(
				~commonPattern <> (type: \midi, midiout: ~instruments['bass'].midiout, chan: ~instruments['bass'].chan) <> Pfindur(duration, section.bass)
			);
		};
		// dulcimer
		if (section.dulcimer != nil) {
			sp.par(
				~commonPattern <> (type: \midi, midiout: ~instruments['dulcimer'].midiout, chan: ~instruments['dulcimer'].chan) <> Pfindur(duration, section.dulcimer)
			);
		};
		// sax
		if (section.sax != nil) {
			~saxophones.do({ |voice|
				sp.par(
					~commonPattern <> (type: \midi, midiout: voice.midiout, chan: voice.chan) <> Pfindur(duration, section.sax)
				);
			});
		};

		// wait
		sp.wait(duration);

	});
}).play(quant: 1);
)

~song.stop;

{ SinOsc.ar(freq: MouseX.kr(20,8000).poll ! 2) * -30.dbamp }.play;

(
Pn(
	Plazy({
		[Pseq([1,2,3],1), Pseq([4,5,6],4)].choose
	}),
	inf
).asStream.nextN(20);
)

(
Pn(
	Plazy({
		var repeat, length;
		var pitches = List.new(20);
		Array.series(20,0,1).do { |start|
			length = rand(6) + 1;
			repeat = rand(5) + 1;
			pitches.add(Array.series(length,start,1).mirror1.dup(repeat));
		};
		Pseq(pitches.flatten(3));
	}),
	inf
).asStream.nextN(20);
)

Plazy({
				var length, repeat;
				length = rand(5) + 1;
				repeat = rand(5) + 1;
				Pseq(Array.series(length,0,1).mirror1.dup(repeat).flatten(2));
}).asStream.nextN(20);

a=List.new();
a.add([1,2,3]);
a.add([4,5,6]);
a.flatten
[1,2,3].mirror.dup