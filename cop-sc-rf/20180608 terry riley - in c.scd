(
~numberOfPlayers = 2;
~tempo = 120/60;
~minPatternDuration = 5;
~maxPatternDuration = 10;
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
	Pbind(*[note: Pseq([0,4], 3), dur: Pseq([0.1, 0.9], 3), octave: 5]),
	// 2
	Pbind(*[note: Pseq([0,4,5,4], 1), dur: Pseq([0.1, 0.45, 0.45, 1], 1), octave: 5]),
	// 3
	Pbind(*[note: Pseq([Rest(),4,5,4], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5], 1), octave: 5]),
	// 4
	Pbind(*[note: Pseq([Rest(),4,5,7], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5], 1), octave: 5]),
	// 5
	Pbind(*[note: Pseq([4,5,7,Rest()], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5], 1), octave: 5]),
	// 6
	Pbind(*[note: 0, dur: Pwhite(4,20,1), octave: 6]),
	// 7
	Pbind(*[note: Pseq([Rest(),0,0,0,Rest()], 1), dur: Pseq([3.5, 0.25, 0.25, 0.5, 4.5], 1), octave: 5]),
	// 8
	Pbind(*[note: Pseq([7,5], 1), dur: Pseq([3, Pwhite(4,20,1)], 1), octave: 5]),
	//9
	Pbind(*[note: Pseq([11,7, Rest()], 1), dur: Pseq([0.25, 0.25, 3.5], 1), octave: 5]),
	//10
	Pbind(*[note: Pseq([11,7], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
]
)

~patterns[0].play;
~patterns[1].play;
~patterns[2].play;
~patterns[3].play;
~patterns[4].play;

// joueur de la pulse
(
Pbind(*[degree: 0, dur: 1/2, octave: 5,db: Pseq([-20, -24, -22, -24], inf)]).play(quant:1);
)

// 1 seul joueur
(
~numberOfPlayers.do({ |player|
	Pspawner({ |sp|
		// attend
		("player "+player+" : ").post;
		sp.wait(~durationToBeats.value(rrand(~minPatternDuration,~maxPatternDuration).postln));
		~patterns.do ({ |i|
			("player "+player+" : ").post;
			// jouer le pattern i entre 45s et 1,30 min
			sp.seq(Pfindur(~durationToBeats.value(rrand(~minPatternDuration,~maxPatternDuration).postln), Pn(i, inf)));
		});
	}).play(quant: 1);
});
)


