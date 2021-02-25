(
SynthDef("Pdefhelp", { arg out, freq, sustain=1, amp=1, pan;
    var env, u=1;
    env = EnvGen.kr(Env.perc(0.01, sustain), 1, doneAction: Done.freeSelf);
    5.do { var d; d = exprand(0.01, 1); u = SinOsc.ar(d * 300, u, rrand(0.1,1.2) * d, 1) };
    Out.ar(out, Pan2.ar(SinOsc.ar(u + 1 * freq, 0, amp * env), pan));
}).add;
)

// Ndef(\track1).play;

Ndef(\track1).source = Pbindef(\a, \instrument, \Pdefhelp);
Pbindef(\a, \degree, Pseq([0, 2, 5b, 1b], inf));
Ndef(\track1)[1] = \filter -> { |in| CombC.ar(in, 1.0, LFNoise2.kr(1).exprange(0.1, 1.0)) };
Ndef(\track1).set(\wet1, 0.5);
Pbindef(\a, \dur, 0.1);

Ndef(\track1)[2] = \filter -> { |in| GVerb.ar(in, drylevel: 0) };

Ndef(\track2).source = Pbindef(\b, \instrument, \Pdefhelp);
Pbindef(\b, \degree, Pwhite(0, 9, inf), \octave, 6);

Ndef(\master).play;
Ndef(\master)[0] = Ndef(\track1);
Ndef(\master)[1] = Ndef(\track2);
Ndef(\master)[2] = \filter -> { |in| CombC.ar(in, 1.0, 0.5) };
Ndef(\master).set(\wet2, 0.3);
