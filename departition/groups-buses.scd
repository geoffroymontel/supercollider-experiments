s.waitForBoot({
	"setup groups & buses".postln;

	~playersGroup = Group.tail(s);
	~players = Array.newClear(8);
	8.do { |i|
		~players[i] = IdentityDictionary.new(know: true);
		~players[i].group =  Group.tail(~playersGroup);
		~players[i].bus =  Bus.audio(s,2);
	};

	~mixerGroup = Group.tail(s);
	~tempoClock = TempoClock.new(60/60);

	SynthDef(\mixer, {
		var snd;
		snd = Mix.fill(8, { |i|
			In.ar(~players[i].bus, 2);
		});
		snd = snd + (NHHall.ar(snd, rt60: 0.5) * -6.dbamp);
		snd = snd.tanh;
		Out.ar(0, snd);
	}).add;

	s.sync;
	Synth(\mixer, target: ~mixerGroup);
});
