(
SynthDef(\test, { |myFreq, amp|
	Out.ar(0, SinOsc.ar(myFreq, 0, amp))
}, metadata: (
	specs: (
		myFreq: [20, 10000, \exp, 0, 400]
	)
)
).add
)


SynthDescLib.global[\test].makeGui

\test.sVarGui.gui // with miSCellaneous quark