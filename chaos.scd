(
a = 200;
{ [((ChaosGen.allSubclasses.choose.ar(freq: exprand(20,22050))  * a).tanh) * -24.dbamp,
	((ChaosGen.allSubclasses.choose.ar(freq: exprand(20,22050)) * a).tanh) * -24.dbamp]
}.play;
)

(
Ndef(\test, { |freq1 = 200, freq2 = 200|
	var a = ChaosGen.allSubclasses.choose;
	var b = ChaosGen.allSubclasses.choose;
	var sig;
	sig = a.ar(freq1 + b.ar(freq2)) + b.ar(freq2 + a.ar(freq1));
	sig = (sig ! 2);
	sig = sig + (GVerb.ar(sig, revtime: 1) * -6.dbamp);
	sig.tanh;
});
)
Spec.add(\freq1, ControlSpec( 20.0, 14000.0, \exp, 0, 70, "Hz") );
Spec.add(\freq2, ControlSpec( 20.0, 14000.0, \exp, 0, 70, "Hz") );

Ndef(\test).mold(2)

Ndef(\test).gui;
