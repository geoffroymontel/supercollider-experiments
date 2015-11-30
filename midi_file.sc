"curl http://www.bachcentral.com/AOF/reg1.mid -o ~/Desktop/toccata1.mid".unixCmd;

m = SimpleMIDIFile.read( "~/Desktop/toccata1.mid" );
m.p.play; // takes a few seconds to start because this midifile starts with a rest

(
SynthDef( \organ, { |freq = 440, sustain = 1, amp = 0.1|
                var sig;
                sig = LFPar.ar( freq * [1,2,3,5], 0, amp/[2,4,5,7] );
                Out.ar( 0, Env([0,1,1,0], [0.025,sustain,0.025]).kr(2) * sig.dup )
}).add;
);

x = m.p(\organ ).play;

p = Pbind(
  \instrument, \organ,
	\dur, Prand( [0.25,0.5,1], inf ),
	\freq, Pwhite( 440, 880 ),
	\db, Pwhite( -40,-10 ),
	\legato, Pwhite( 0.25, 4 )
);

m = SimpleMIDIFile( "~/Desktop/testPat.mid" );
m.init1( 2, 120, "4/4" );
m.fromPattern( p );

m.plot;
m.p.play; // note numbers are not rounded
p.play; // compare
m.write;

p = Pbind(
  \instrument, \organ,
	\dur, Prand( [0.25,0.5,1], inf ),
  \midinote, Pseq(["bb4","e4","g4"].namemidi, 4),
	\db, Pwhite( -40,-10 ),
	\legato, Pwhite( 0.25, 4 )
);

p.play;

"c#5".namemidi;

// (setf motif ‘(bb4 a4 c5 b4))
// ; theme
//
// (setf m-x12 (gen-repeat 12 (list motif)))
// ; 12 repeats of the theme
//
// (setf  flow (pitch-transpose ‘(0 3 2 6 12 4 2 0 3 6 12) m-x12)
// ; A list of transpositions applied to the 12 repeats

// theme

~motif = ["Bb3","A3","C4","B3"].namemidi;

p = Pbind(
  \instrument, \organ,
  \dur, 1/8,
  \midinote, Pseq(~motif),
);

// 1Z repeats of the theme
Pn(p, 12).play;

// a list of transpositions applied to the 12 repeats
Paddp(\ctranspose, [0,3,2,6,12,4,2,0,3,6,12], p).play;

// change order of notes
Pbind(
  \instrument, \organ,
  \dur, 1/8,
  \midinote, Pshuf(~motif,1),
).play;

// play 12 times and transpose
p = Pbind(
  \instrument, \organ,
  \dur, 1/8,
  \midinote, Pn(Pshuf(~motif,1),1),
);

// play 12 times and transpose, each time a new order
p = Paddp(\ctranspose, [0,3,2,6,12,4,2,0,3,6,12], Pbind(\midinote, Pshuf(~motif,1)));
