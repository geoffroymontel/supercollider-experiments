// Midi init
MIDIClient.init;    // if not already done
~midiOut = MIDIOut.newByName("Gestionnaire IAC", "Bus IAC 1").latency_(Server.default.latency);

// Tempo : 120 BPM
~tempoClock = TempoClock.new(tempo: 90.0/60);

// http://tonalitysystemspress.co.uk/?p=212

(
var motif = ["a#4","a4","c5","b4"].notemidi;

// A list of transpositions applied to the 12 repeats
Pbind(*[
  type: \midi,
  midiout: ~midiOut,
  chan: 0,
  midinote: Pn(Pshuf(motif),12),
  ctranspose: Pstutter(motif.size, Pseq([0,3,2,6,12,4,2,0,3,6,12])),
  dur: 1,
  legato: 1,
  amp: 1
]).play(clock: ~tempoClock);
)

//Koch Snowflake
(
a = LSys("F--F--F", ["F" -> "F+F--F+F"]);
k = a.applyRules(4);
LSPlant(80@170, 90, argAngle: 60).drawSize_(4).draw(k);
)

(
var a;
a = Prout({|ev|
  var pat, refPat;
  refPat = Pbind(*[dur: 0.2, note: Pseq([0,0,0,7,0,7])]);
  loop {
    ev = refPat.embedInStream(ev);
    pat = Pbind(*[
      dur: [0.2, 0.4].choose,
      note: Pseq(Array.fill(5, {10.rand}),1)
    ]);
    ev = pat.embedInStream(ev);
  }
});
a.trace.play;
)

(
var a;
a = Prout({ loop { 1.yield; 2.yield; 7.yield; 10.do { 1.0.rand.yield } }});
a.asStream.nextN(100);
)