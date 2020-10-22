MIDIClient.init;

~ob6 = MIDIOut.newByName("OB-6", "OB-6");
// ~ob6.latency = Server.default.latency;

(
p = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, ~ob6,
	\chan, 0,
	\degree, Pwhite(-7, 12, inf),
	\dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
	\legato, sin(Ptime(inf) * 0.5).linexp(-1, 1, 1/10, 1),
	\amp, Pexprand(0.5, 1.0, inf)
).play(quant: 1);
)

~ob6.allNotesOff(0);

(
Event.addEventType(\OB6_NRPN, {
	var midiout = ~midiout.value;
	var chan = ~chan.value;
	var nrpnNum = ~nrpnNum.value;
	var nrpnValue = ~nrpnValue.value;

	if (nrpnValue.class == String) {
		if (nrpnValue.beginsWith("c")) {
			nrpnValue = Bus.new('control', nrpnValue[1..].asInteger, 1, s).getSynchronous();
		};
	};

	nrpnValue = nrpnValue.asInteger;

	midiout.control(chan, 0x63, nrpnNum >> 7);
	midiout.control(chan, 0x62, nrpnNum & 0x7F);
	midiout.control(chan, 0x06, nrpnValue >> 7);
	midiout.control(chan, 0x26, nrpnValue & 0x7F);
});
)

// randomize filter cutoff

(
p = Pbind(
	\type, \OB6_NRPN,
	\midiout, ~ob6,
	\chan, 0,
	\nrpnNum, 45,
	\nrpnValue, Pwhite(0, 164),
	\dur, 1
).play(quant: 1);
)

// randomize filter cutoff with a LFO from a Node bus

(
p = Pbind(
	\type, \OB6_NRPN,
	\midiout, ~ob6,
	\chan, 0,
	\nrpnNum, 45,
	\nrpnValue, Ndef(\bla, { SinOsc.kr(1/10).range(0,164) }).asMap,
	\dur, 0.1
).play(quant: 1);
)

// do crazy stuff

(
p = Pbind(
	\type, \OB6_NRPN,
	\midiout, ~ob6,
	\chan, 0,
	\nrpnNum, Pwhite(0, 150),
	\nrpnValue, Pwhite(0,255),
	\dur, 1
).play(quant: 1);
)
