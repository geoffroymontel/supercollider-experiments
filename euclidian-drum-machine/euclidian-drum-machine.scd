// faire un synthé qui joue des samples
// jouer avec les patterns pour faire des rythmes euclidiens en ligne de commande
// créer une interface où en ordonnée, on a les instruments (kick, snare), et en abscisse : k, n des rythmes euclidiens
// réagir au changement de k et n pour influencer les patterns

// notre synthé
(
SynthDef(\samplePlayer, { |out = 0, bufnum = 0|
	Out.ar(out,
		PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: BufRateScale.kr(bufnum), doneAction: Done.freeSelf)
	);
}).add;
)

// bom des fichiers dans le répertoire courant
(
~sampleNames = (
	kick: "MeanBeat 808-Set Bassd_3.wav",
	clap: "MeanBeat 808-Set Clap.wav",
	clave: "MeanBeat 808-Set Claves.wav",
	closedHihat: "MeanBeat 808-Set Closed Hihat.wav",
	cowbell: "MeanBeat 808-Set Cowbell.wav",
	cymbal: "MeanBeat 808-Set Cymbal _2.wav",
	openHihat: "MeanBeat 808-Set Open Hihat.wav",
	rimshot: "MeanBeat 808-Set Rimshot.wav",
	snare: "MeanBeat 808-Set Snare.wav",
	tom: "MeanBeat 808-Set Tom_5.wav"
)
)

// on charge les fichiers dans des buffers
(
~samples = ();

~sampleNames.keysValuesDo { |key, value|
	~samples.put(key, Buffer.read(s, Document.current.dir +/+ value));
}
)

// on teste le kick
Synth(\samplePlayer, [bufnum: ~samples[\kick]])

TempoClock.default.tempo = 120/60;
~beatsPerMesure = 4;

(
Pbind(*[
	instrument: \samplePlayer,
	bufnum: ~samples[\kick],
	dur: Pbjorklund2(3,8) * ~beatsPerMesure / 16
]).play;
Pbind(*[
	instrument: \samplePlayer,
	bufnum: ~samples[\snare],
	dur: Pbjorklund2(1,3) * ~beatsPerMesure / 16
]).play;
Pbind(*[
	instrument: \samplePlayer,
	bufnum: ~samples[\closedHihat],
	dur: Pbjorklund2(11,16) * ~beatsPerMesure / 32
]).play;
)

// on tente de faire une fenêtre
(
~window = Window.new("bar", Rect(Window.screenBounds.width / 2, Window.screenBounds.height / 2, 400, 400));
~window.visible = true;
~window.front;
)

(
~sampleNames.do { |e, i|
	e.postln;
	e.class.postln;
	Pdef(e.key, Pbind(*[
		instrument: \samplePlayer,
		bufnum: ~samples[e.key],
		dur: 1
	]));
}
)


)
(
~sampleNames.do { |e, i|
	EZNumber.new(~window, Rect(0,i*20,40, 20));
	EZNumber.new(~window, Rect(40,i*20,40, 20));
}
)
