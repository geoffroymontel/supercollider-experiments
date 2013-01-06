// perfect timing
(
p = Pbind(*[
  legato: 0.1,
  dur: 0.2,
  degree: [2,5,12],
  ctranspose: Pseq([0,0,0,0,4,4,4,4,5,5,5,5],inf)
]).play;
)

// more human
(
p = Pbind(*[
  legato: 0.1,
  dur: 0.2,
  midinote: [66, 69, 74],
  lag: Pwhite(-0.05!3, 0.05)
]).play;
)

(
Pbind(*[
    stepsPerOctave:    Pstep(Pseq((2..12).mirror, inf),12),    // 3 - 12 tone e.t. scales
    note:        Pseq((0..12).mirror, inf),        // play full notes up and down
    ctranspose:    Pwhite(-0.2, 0.2),            // detune up to +-20 cents
    detune:        Pwhite(-1.0, 1.0),            // detune up to 1 Hz
    sustain:    Prand([0.2, 0.2, 0.2, 4], inf),     // notes last 0.2 or 4 seconds
                // 1 in 6 chance waits 0.8 seconds:
    dur:        Prand([0.2, 0.2, 0.2, 0.2, 0.2, 0.8], inf),
    db:        Pstep(Pseq([-15, -25, -20, -25], inf), 0.8)// 4 beat accent structure
]).play;
)