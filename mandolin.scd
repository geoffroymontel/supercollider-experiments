// a group of angry fretless mandolin players
(
{
  var freq, numparts;
  numparts = 2;
  freq = SinOsc.kr(
    Array.fill(numparts, {Rand(0.05, 0.2)}),
    Array.fill(numparts, {Rand(0, 1.0)})
  ).range(1000, 3000);
  LeakDC.ar(
    Pan2.ar(
      Pluck.ar(
        in: WhiteNoise.ar(0.1).dup(numparts),
        trig: Impulse.kr(Array.fill(numparts, {Rand(10, 12)})),
        maxdelaytime: 100.reciprocal,
        delaytime: freq.reciprocal,
        decaytime: 2,
        coef: Rand(0.01, 0.2),
        mul: 1
      ),
      Array.fill(numparts, {Rand.new(-1.0, 1.0)})
    ).sum
  );
}.play(s);
)