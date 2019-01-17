// see NodeProxy roles document
a = NodeProxy(s);
a[0] = { |freq = 440, dt=0.1, rate=2| Ringz.ar(Impulse.ar(rate * [1, 1.2]), freq, dt)*0.1 };
a.play;
(
a[1] = \set -> Pbind(
    \dur, Prand([1, 0.5], inf),
    \freq, Pwhite(200.0, 1000, inf),
    \rate, Pstutter(4, Prand([1, 3, 6, 10], inf)),
    \dt, Pwhite(0.01, 0.1, inf)
)
);
// modify the source in the meanwhile:
a[0] = { |freq = 440, dt=0.1, rate=2| Ringz.ar(Dust.ar(rate * 10.dup), freq, dt)*0.1 };

a.nodeMap.postln; // the values are not set in the node map.
a.clear(3);