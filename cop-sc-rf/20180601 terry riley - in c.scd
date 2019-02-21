(
~numberOfPlayer = 1;
~tempo = 120/60;

TempoClock.default.tempo = ~tempo;
)

(
~durationToBeats = { |duration|
	duration * ~tempo;
}
)

(
~patterns = [
	// 1
	Pbind(*[note: Pseq([0,4], 3), dur: Pseq([0.1, 0.9], 3), octave: 5])
]
)

~patterns[0].play;

// joueur de la pulse
(
Pbind(*[degree: 0, dur: 1/2, octave: 5,db: Pseq([-20, -24, -22, -24], inf)]).play(quant:1);
)


// 1 seul joueur
(
Pspawner({ |sp|
	// attend
	// sp.wait(rand(32)/2);
	// jouer le pattern 1 entre 45s et 1,30 min
	sp.seq(Pfindur(~durationToBeats.value(10), Pn(~patterns[0], inf)));
}).play;
)


