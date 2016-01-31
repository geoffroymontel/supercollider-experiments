// filtering patterns with collect
(
var a;
a = Pbind(*[
  \degree, Pseq([0,7],inf),
  \dur, 1
]);
b = a.collect({|ev|
  ev.postln;
  if (ev[\degree] == 7) {
    ev[\degree] = \rest;
    ev;
  } {
    ev;
  }
});
b.play;
)


// filtering patterns with pchain
(
var a;
a = Pbind(*[
  \degree, Pseq([0,7],inf),
  \dur, 1
]);
b = Pfunc({|ev|
  ev.postln;
  if (ev[\degree] == 7) {
    ev[\degree] = \rest;
    ev;
  } {
    ev;
  }
});
Pchain(b,a).play;
)

// Prout ?

Quark.gui