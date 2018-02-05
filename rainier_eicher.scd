(
MIDIClient.init;    // if not already done
m = MIDIOut.newByName("Gestionnaire IAC", "Bus IAC 1").latency_(Server.default.latency);
)

(
// piano
a = Pbind(
    \type, \midi,
    \midicmd, \noteOn,
	\scale, Scale.hirajoshi,
    \midiout, m,
    \chan, 0,
	\degree, Pwrand([Pwhite(0, 12, inf), \rest], [0.8, 0.2]),
	\dur, Pwrand([4, 2, 1, Pseq([0.5, 0.5, 0.25, 1, 0.25, 0.5], 2), Pseq([1, 0.5, 0.5], 1)], #[0.2, 0.2, 0.2, 0.2, 0.2], inf),
    \amp, Pexprand(0.7, 0.9, inf),
	\legato, 0.7,
);

// xylo
b = Pbind(
    \type, \midi,
    \midicmd, \noteOn,
	\scale, Scale.hirajoshi,
    \midiout, m,
    \chan, 1,
	\degree, Pwrand([Pwhite(0, 12, inf), \rest], [0.8, 0.2]),
	\dur, Pwrand([4, 2, 1, Pseq([0.5, 0.5, 0.25, 1, 0.25, 0.5], 2), Pseq([1, 0.5, 0.5], 1)], #[0.2, 0.2, 0.2, 0.2, 0.2], inf)*2,
    \amp, Pexprand(0.7, 0.9, inf),
	\legato, 0.7,
);

// orgue
c = Pbind(
    \type, \midi,
    \midicmd, \noteOn,
	\scale, Scale.hirajoshi,
    \midiout, m,
    \chan, 2,
	\degree, Pwrand([Pwhite(-12, 0, inf), \rest], [0.6, 0.4]),
	\dur, Pwrand([4, 2, 1, Pseq([0.5, 0.5, 0.25, 1, 0.25, 0.5], 2), Pseq([1, 0.5, 0.5], 1)], #[0.2, 0.2, 0.2, 0.2, 0.2], inf)*4,
    \amp, Pexprand(0.7, 0.9, inf),
	\legato, 0.9
);

// accordeon
d = Pbind(
    \type, \midi,
    \midicmd, \noteOn,
	\scale, Scale.hirajoshi,
    \midiout, m,
    \chan, 3,
	\degree, Pwrand([Pwhite(-12, 0, inf), \rest], [0.8, 0.2]),
	\dur, Pwrand([4, 2, 1, Pseq([0.5, 0.5, 0.25, 1, 0.25, 0.5], 2), Pseq([1, 0.5, 0.5], 1)], #[0.2, 0.2, 0.2, 0.2, 0.2], inf)*4,
    \amp, Pexprand(0.7, 0.9, inf),
	\legato, 0.9
);

z = Ppar([a,b,c,d]).play(quant: 1);

)

z.stop;
z.play;
