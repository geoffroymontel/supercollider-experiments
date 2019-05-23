(
BusPlug.defaultReshaping = \elastic;
Ndef(\x).proxyspace.quant = 1.0;
Ndef.clear;
)
(
Ndef(\sequencer, {
	var gate, freq, amp;

	gate = TDuty.kr(Dseq([1,1,2]/30, inf));
	freq = Demand.kr(gate, 0, Dseq([300, 500, 800], inf));
	amp = Demand.kr(gate, 0, Dseq([1.0, 0.3, 0.5], inf));
	[gate, freq, amp];
});
)

(
Ndef(\synth, {
	var gate = Ndef(\sequencer).ar[0];
	var freq =  Ndef(\sequencer).ar[1];
	var amp =  Ndef(\sequencer).ar[2];

	DelayC.ar(VarSaw.ar(freq * [1, MouseX.kr(1, 2)]) * EnvGen.kr(Env.perc, gate) * amp, 1.0, [0, MouseX.kr(0.01, 1.0)]);
});
)

(
Ndef(\synth2, {
	var gate = Ndef(\sequencer).ar[0];
	var freq =  Ndef(\sequencer).ar[1];
	var amp =  Ndef(\sequencer).ar[2];

	DelayC.ar(SinOsc.ar(freq * [2, MouseX.kr(2, 4)]) * EnvGen.kr(Env.perc, gate) * amp, 1.0, [0, MouseX.kr(0.01, 1.0)]);
});
)

Ndef(\synth).play;
Ndef(\synth2).play;