
(
Ndef(\test, { |freq1 = 200, freq2 = 200, freq3 = 200, res = 0.1|
	var a = ChaosGen.allSubclasses.choose;
	var b = ChaosGen.allSubclasses.choose;
	var sig, sig1, sig2;
	sig1 = a.ar(freq1 + b.ar(freq2)) + b.ar(freq2 + a.ar(freq1));
	sig2 = a.ar(freq1 + b.ar(freq2)) - b.ar(freq2 + a.ar(freq1));
	sig = [sig1, sig2];
	sig = DFM1.ar(sig, freq3, res);
	// sig = sig + (GVerb.ar(sig, revtime: 1) * -6.dbamp);
	sig.tanh;
});
)
Spec.add(\freq1, ControlSpec( 20.0, 14000.0, \exp, 0, 70, "Hz") );
Spec.add(\freq2, ControlSpec( 20.0, 14000.0, \exp, 0, 70, "Hz") );
Spec.add(\freq3, ControlSpec( 20.0, 14000.0, \exp, 0, 70, "Hz") );
Spec.add(\res, ControlSpec( 0.0, 1.0, \lin, 0, 1, "res") );

Ndef(\test).mold(2);
s
Ndef(\test).gui;

MIDIClient.init;
MIDIIn.connectAll;


(
MIDIFunc.cc({ |value, cc, chan|
	postf("% % %\n", value, cc, chan);
	switch(chan,
		0, { Ndef(\test).set(\freq1, value.linexp(0, 127, 20, 14000)) },
		1, { Ndef(\test).set(\freq2, value.linexp(0, 127, 20, 14000)) },
		2, { Ndef(\test).set(\freq3, value.linexp(0, 127, 20, 14000)) },
		3, { Ndef(\test).set(\res, value.linlin(0, 127, 0, 1)) }
	);
}, 7);
)