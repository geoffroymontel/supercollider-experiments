(
s.boot;
s.makeGui;
MIDIClient.init;
MIDIIn.connectAll;
~midiOut = MIDIOut(0);
)

(
Pbind(*[
	type: \midi,
	midiout: ~midiOut,
	midinote: Prand(("c3".notemidi.."d#4".notemidi), inf),
	dur: Pwhite(0.01, 3, inf)
]).play;
)
"c4".notemidi


