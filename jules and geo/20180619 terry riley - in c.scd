(
~numberOfPlayers = 2;
~tempo = 120/60;
~minPatternDuration = 5;
~maxPatternDuration = 10;
TempoClock.default.tempo = ~tempo;

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
	//11
	Pbind(*[note: Pseq([5, 7, 11, 7, 11, 7], 1), dur: Pseq([0.25], 6), octave: 5]),
	//12
	Pbind(*[note: Pseq([5, 7, 11, 12], 1), dur: Pseq([0.5, 0.5, 4, 1], 1), octave: 5]),
	//13
	Pbind(*[note: Pseq([11, 7, 7, 5, 7, Rest(), 7], 1), dur: Pseq([0.25, 0.75, 0.25, 0.25, 0.5, 0.75, 3.25], 1), octave: 5]),
	//14
	Pbind(*[note: Pseq([12, 11, 7, 6], 1), dur: Pseq([4], 4), octave: 5]),
	//15
	Pbind(*[note: Pseq([7, Rest()], 1), dur: Pseq([0.25,3.75], 1), octave: 5]),
	//16
	Pbind(*[note: Pseq([7, 11, 12, 7], 1), dur: Pseq([0.25], 4), octave: 5]),
	//17
	Pbind(*[note: Pseq([11, 12, 11, 12, 11, Rest()], 1), dur: Pseq([0.25], 6), octave: 5]),
	//18
	Pbind(*[note: Pseq([4, 6, 4, 6, 4, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.75, 0.25], 1), octave: 5]),
	//19
	Pbind(*[note: Pseq([Rest(), 7], 1), dur: Pseq([1.5, 1.5], 1), octave: 6]),
	//20
	Pbind(*[note: Pseq([4, 6, 4, 6, -5, 4, 6, 4, 6, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.75, 0.25, 0.25, 0.25, 0.25, 0.25], 1), octave: 5]),
	//21
	Pbind(*[note: Pseq([6], 1), dur: Pseq([3], 1), octave: 5]),
	//22
	Pbind(*[note: Pseq([4, 4, 4, 4, 4, 6, 7, 9, 11], 1), dur: Pseq([1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 0.5], 1), octave: 5]),
	//23
	Pbind(*[note: Pseq([4, 6, 6, 6, 6, 6, 7, 9, 11], 1), dur: Pseq([0.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1], 1), octave: 5]),
	//24
	Pbind(*[note: Pseq([4, 6, 7, 7, 7, 7, 7, 9, 11], 1), dur: Pseq([0.5, 0.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 0.5], 1), octave: 5]),
	//25
	Pbind(*[note: Pseq([4, 6, 7, 9, 9, 9, 9, 9, 11], 1), dur: Pseq([0.5, 0.5, 0.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5], 1), octave: 5]),
	//26
	Pbind(*[note: Pseq([4, 6, 7, 9, 11, 11, 11, 11, 11], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5, 1.5, 1.5, 1.5, 1.5, 1.5], 1), octave: 5]),

    //40
	Pbind(*[note: Pseq([11, 5], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
    //41
	Pbind(*[note: Pseq([11, 5], 1), dur: Pseq([0.25, 0.25], 1), octave: 5]),
    //42
	Pbind(*[note: Pseq([12, 11, 9, 12], 1), dur: Pseq([2], 4), octave: 5]),
    //43
	Pbind(*[note: Pseq([5, 4, 5, 4, 4, 4, 4, 5, 4], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 1, 1, 0.5, 0.25, 0.25], 1), octave: 6]),
    //44
	Pbind(*[note: Pseq([5, 4, 4, 4, 0], 1), dur: Pseq([0.5, 0.5, 0.5, 0.5, 1], 1), octave: 6]),
    //45
	Pbind(*[note: Pseq([2, 2, -5], 1), dur: Pseq([1, 1, 1], 1), octave: 6]),
    //46
	Pbind(*[note: Pseq([7, 14, 16, 14, Rest(), 7, Rest(), 7, Rest(), 7, 7, 14, 16, 14], 1), dur: Pseq([0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25, 0.25], 1), octave: 5]),
    //47
	Pbind(*[note: Pseq([14, 16, 14], 1), dur: Pseq([0.25, 0.25, 0.5], 1), octave: 5]),
    //48
	Pbind(*[note: Pseq([7, 7, 5], 1), dur: Pseq([3, 2, Pwhite(4,20,1)], 1), octave: 5]),
    //49
	Pbind(*[note: Pseq([5, 7, 10, 7, 10, 7], 1), dur: Pseq([0.25], 6), octave: 5]),

]
)

~patterns[~patterns.size() - 1].play;

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


