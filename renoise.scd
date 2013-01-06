(
~renoiseOscServer = NetAddr("127.0.0.1", 8000);

~renoiseOscFunction = { |notes|
  notes.postln;
  notes.class.postln;
  if (notes.class == Array,
    {
      {notes.do {|note|
        ~renoiseOscServer.sendMsg("/renoise/trigger/note_on", -1, -1, note.asInt, 128);};
      }.defer;
    },
    {
      {~renoiseOscServer.sendMsg("/renoise/trigger/note_on", -1, -1, notes.asInt, 128);}.defer;
  });
};
)

// test Array flop
~notes = [60, 63];
~velocity = [0.8, 0.6];
~tuples = [~notes, ~velocity].flop;
~tuples.do {|a| a[0].postln; a[1].postln; }

~renoiseOscFunction.value(40.0);

(
Pbind(
  \note, Pseq([2, [5, 7], [2, 6]]),
  \sustain, Pseq([1, 0.5, 1]),
  \dur, Pseq([1.5, 0.8, 0.8]),
  \renoise, Pfunc({|e| ~renoiseOscFunction.value(e.use({~midinote.value}))}),
  \play, {}
).play;
)

(
Pbind(
  \note, Pseq([2, [5, 7], [2, 6]]),
  \sustain, Pseq([1, 0.5, 1]),
  \dur, Pseq([1.5, 0.8, 0.8]),
  \renoise, Pfunc({|e| e.use { ~midinote.value.postln } }),
).play;
)

(
Pbind(
  \note, Pseq([2, [5, 7], [2, 6]]),
  \sustain, Pseq([1, 0.5, 1]),
  \dur, Pseq([1.5, 0.8, 0.8]),
  \finish, { ~midinote.value.postln; },
).play;
)

{~renoiseOscServer.sendMsg("/renoise/trigger/note_on", -1, -1, 40, 128);}.defer;

~renoiseOscServer.sendMsg("/renoise/trigger/note_on", -1, -1, 40, 128);
~renoiseOscServer.sendMsg("/renoise/trigger/note_off", -1, -1, 40);




t = Pbind( \freq, Pseq([440,880]) ).asStream;

(
var pattern, stream;

pattern = Pbind(
    \abc, Prand([6, 7, 8, 9], inf ),
    \xyz, Pseq([1, 2, 3], 2 ),
    \uuu, 999, // a constant represents an infinite sequence of itself
  \play, { ~abc.postln; }
);

pattern.play;
)

Event.addEventType(\happyEvent, { ("I am so happy to be silent sometimes, says" + ~who).postln; });
Pbind(\type, \happyEvent, \who, Prand(["Alice", "Bob", "Eve"], inf), \dur, Pwhite(0.1, 1.0, inf)).play;

(
Event.addEventType(\happyEvent, { |server|
    ~octave = [5, 6, 7]; // always play three octaves
    ~detune = 10.0.rand2; // always play a bit out of tune
    ~type = \note; // now set type to a different one
    currentEnvironment.play;
});
Pbind(\type, \happyEvent, \degree, Pseq([0, 1, 2, 3, 4, 4, 5, 5, 5, 5, 4, 2, 3, 2, 3, 1], inf), \dur, Pwhite(0.1, 1.0, inf)).play;
);

(
Pbind(
    \note, Pseq([2, [5, 7], [2, 6]]),
    \sustain, Pseq([1, 0.5, 1]),
    \dur, Pseq([1.5, 0.8, 0.8]),
    \play, { ~type.postln; ~midinote.value.postln; }
).play
)

(
Pbind(
    \note, Pseq([2, [5, 7], [2, 6]]),
    \sustain, Pseq([1, 0.5, 1]),
    \dur, Pseq([1.5, 0.8, 0.8]),
    \finish, { ~renoiseOscServer.sendMsg("/renoise/trigger/note_on", -1, -1, ~midinote.value, 64) }
).play
)