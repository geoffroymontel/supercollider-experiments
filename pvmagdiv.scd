(
~noise3 = SynthDef(\noise3, {
	arg out=0, amp=0.01, freq=25, chaos=0.6;
    var inA, chainA, inB, chainB, chain;
    inA = Crackle.ar(chaos, 1000).softclip * amp;
    inB = Pulse.ar(freq, 0.2, amp);
    chainA = FFT(LocalBuf(2048), inA);
    chainB = FFT(LocalBuf(2048), inB);
    chain = PV_MagDiv(chainA, chainB);
	chain = 0.1 * IFFT(chain).clip.dup;
	chain = Splay.ar(chain);
	chain = Rotate2.ar(chain[0], chain[1], SinOsc.kr(1/16, Rand(-1, 1)).range(-1, 1));
	chain = chain + NHHall.ar(chain, 0.4);
	chain = (chain * -10.dbamp).tanh;
    Out.ar(out, chain);
}).add;
)

(
r = Routine({
~rythm1 = Synth(\noise3);

MIDIdef.cc(\freq, {

	| val, num, chan, src |
	var freq, chaos;

	freq = val.linlin(0, 127, 25.0, 50.0);
	chaos = val.linlin(0, 127, 0.6, 1.9);
	~rythm1.set(\freq, freq);
	~rythm1.set(\chaos, chaos);

}, 16);
}).play(t, quant:1);
)
