(
// you need a start segment, the loop will begin at the target of the first segment
e = Env.new([1, 0, 0.5], [0.1, 0.1] * 0.01, 'lin', nil, 1);
e.plot;
{ EnvGen.ar(e, Impulse.ar(100)) }.plot(0.1);
)


// due to the delay of the Env at start you'd need to
// introduce a delay with the frequency sequence (if you need one at all)

// wrap freq with Clip as Saw with 0 produces a bump

(
{
    var trig, tempo, drone, note, att = 0.1, rel = 0.1;
    tempo = 70/60;

    trig = TDuty.ar(
        Dseq([Dwrand([1/3, 2/3], [0.9, 0.1], 1), 1/3, 1/3, 1],inf) / tempo +
        Dwhite(-0.01, 0.01,inf)
    );
    note = Demand.ar(trig, 0, Dwhite(60, 90));

    drone = Splay.ar((1..10).collect({ |i|
        Saw.ar(
            freq: Clip.ar(DelayL.ar(note.midicps * i, 0.3, rel).poll, 50, 5000),
            mul: 1/i
        )
    }));

    drone = drone * EnvGen.ar(
        envelope: Env.new([0, 0, 1], [att, rel], 'lin', nil, 1),
        gate: trig
    );

    drone
}.play
)