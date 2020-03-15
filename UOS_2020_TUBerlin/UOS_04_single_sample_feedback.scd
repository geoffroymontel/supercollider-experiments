
//////////////////////
SINGLE SAMPLE FEEDBACK
//////////////////////


s.boot;

s.freqscope;
s.scope;



1) Simple filters - proof of concept

1a) OnePole

SC's OnePole UGen with coefficient c is implemented with this difference equation:

out[n] = (1 - abs(c)) * in[n] + (c * out[n-1])

// written with Fb1
// the difference equation has to be the result of the Function

// in[0] stands for in[n-0] = in[n]
// out[1] stands for out[n-1]

// it's important to note that the passed Function is used several (blockSize) times
// to build the UGen graph
// it formally takes the in signal, which has to be passed as 'in' arg
// and the out signal as 'out' arg which is formally returned by the Function

(
x = {
	Fb1.ar(
		{ |in, out|  (in[0] * 0.05) + (out[1] * 0.95) },
		in: WhiteNoise.ar(0.3),
		blockSize: s.options.blockSize
	) ! 2
}.play
)

x.release

// same with OnePole

{ OnePole.ar(WhiteNoise.ar(0.3), 0.95) ! 2 }.play


// with blockSize 64 the compilation time of the above Fb1 example is quite long,
// the number of ugens high, check with lower blockSize

// the choice of blockSize with Fb1 at audio rate is always a trade-off:
// low blockSize: shorter compilation time, less ugens, but maybe more CPU as kr is more expensive
// high blockSize: longer compilation time, more ugens, but maybe less CPU as kr is less expensive

// recommendation: do testing with low blockSize (e.g. 4, 8, 16),
// use blockSize 64 for finished setups, where you do the compilation of SynthDefs only once

(
s.options.blockSize = 8;
s.quit.reboot;
)

(
x = {
	Fb1.ar(
		{ |in, out|  (in[0] * 0.05) + (out[1] * 0.95) },
		WhiteNoise.ar(0.3),
		blockSize: s.options.blockSize
	) ! 2
}.play
)

x.release



1b) 'inDepth' and 'outDepth' args

// they have to be used for further looking back than in the previous example,
// e.g. a second order filter with feedforward coefficients a0, a1, a2 and
// feedback coefficients b1, b2 needs a value of 3 for both args


out[n] = (-0.6 * in[n]) + (0.5 * in[n-1]) - (0.7 * in[n-2]) + (0.5 * out[n-1]) - (0.1 * out[n-2])


// it's actually not necessary to put the coefficients into arrays
// assigned to a variable as below,
// though this way you easily replace a number by a (kr) Oscillator
// (attention: the filter can become unstable)

(
x = {
	// define coefficients
	// b[0] is not needed here, it's just there to maintain the index convention
	var a = [-0.6, 0.5, -0.7];
	var b = [0, 0.5, -0.1];
	var src = Saw.ar(200, 0.1);
	// out[0] is passed formally
	// to allow taking over index convention
	Fb1.ar({ |in, out|
		(a[0] * in[0]) + (a[1] * in[1]) + (a[2] * in[2]) +
		(b[1] * out[1]) + (b[2] * out[2])
	}, src, inDepth: 3, outDepth: 3, blockSize: s.options.blockSize) ! 2
}.play
)

x.release




2) Non-linear examples, advanced Fb1 options


2a) Selected look-back depth

// there might be gaps in the fb / ffw relation,
// in this case there exists a convention for the depth args
// to make the calculation more efficient

// in the following example we want to look back to sample in[n-56]
// thus we need blockSize 64 – or a lower blockSize with an appropriate factor in Fb1:
// e.g. blockSize 8 and blockFactor 8



// highly non-linear operation: division, max avoids zero denominator
// tanh as sigmoid function limits the fb signal

// by passing [[0, 56]] to inDepth in[0] will refer to in[n] and
// in[0] will refer to in[n-56],
// the double bracket is necessary to distinguish from multichannel differentiation

// also an outInit arg unequal to 0 is necessary to get things running

(
x = {
	var src = SinOsc.ar(500 * LFDNoise3.ar(5));
	Fb1.ar({ |in, out|  (out[1] / max(0.01, (in[0] - in[1]))).tanh },
		in: src, inDepth: [[0, 56]],
		outInit: 1,
		blockSize: s.options.blockSize,
		blockFactor: 64 / s.options.blockSize
	) ! 2 * 0.1
}.play
)

x.release


2b) Multichannel handling

// feedforward and feedback signals can be of arbitrary size, even arrays of arrays,
// a higher fb size has to be passed explicitely with the 'outSize' arg.

// See Ex. 3a of Fb1's help file for more complicated examples of multichannel handling


// in the following example we have stereo feedback and a stereo source is passed as 'in' arg
// the 'inDepth' arg is differentiated per channel and
// in[0], in[1] and out[1] refer to stereo signals


(
x = {
	var src = SinOsc.ar(500 * LFDNoise3.ar(5!2));
	// stereo because of multichannel expansion !
	Fb1.ar({ |in, out|
			(out[1] / max(0.01, (in[1] - in[0]))).tanh

	},
		outSize: 2, in: src,
		inDepth: [[0, 56], [0, 29]], outInit: 1,
		blockSize: s.options.blockSize,
		blockFactor: 64 / s.options.blockSize
	) * 0.1
}.play
)

x.release


// whereas in the previous example the feedback relation was the same
// for both channels (though with different lookback depths),
// the relation can also be defined by refering to single components:


// in[0][0] refers to the first channel of in[n]
// in[0][1] refers to the second channel of in[n]
// in[1][0] refers to the first channel of in[n-56]
// in[1][1] refers to the second channel of in[n-29]

// thus we have a fb cross correlation
(
x = {
	var src = SinOsc.ar(150 * LFDNoise1.ar(1!2).exprange(0.1, 30));
	Fb1.ar({ |in, out| [
			out[1][0] / max(0.01, (in[1][0] * in[0][1])),
			out[1][1] / max(0.01, (in[1][1] * in[0][0]))
		].tanh
		},
		outSize: 2, in: src,
		inDepth: [[0, 56], [0, 29]], outInit: 1,
		blockSize: s.options.blockSize,
		blockFactor: 64 / s.options.blockSize
	) * 0.1
}.play
)

x.release



2c) The Dobson-Ffitch filter

R. Dobson and J. Ffitch, “Experiments with Non-Linear Filters” in Proceedings of the 1996 International Computer Music Conference (ICMC 1996), pp. 405-408. Hong Kong.

// a filter of the form

out[n] = a * out[n-1] + b * out[n-2] + d * out[n-L]^2 + in[n] - c

// in SC syntax we have to use brackets for the multiplications
// because of L/R-precedence

// note the use of Select for dynamic lookback depth and
// the choice of a limiting sigmoid function

// the sigmoid function blurs the "original" behaviour of the filter
// but stabilises it

(
SynthDef(\dobsonFfitch, { |out, freq = 50, freqFactor = 1.01, a = -0.4, b = 0.6, c = 0.2,
	d = 0.75, l = 32, limitType = 1, amp = 0.2|
	var src, sig;
	src = Saw.ar([1, freqFactor] * freq);
	sig = Fb1.ar({ |in, out|
		var x = (a * out[1]) + (b * out[2]) + (d * Select.kr(l, out).squared) + in[0] - c;
        Select.kr(limitType, [x.tanh, x.softclip, x.distort])
		},
		in: src, outSize: 2, outDepth: 50,
		blockSize: s.options.blockSize,
		blockFactor: 64 / s.options.blockSize
	) * amp;
	// cut off some high frequencies
	Out.ar(0, LPF.ar(sig, 15000))
}, metadata: (
	specs: (
		freqFactor: [1, 1.1, 3, 0, 1.01],
		freq: [20, 7000, \exp, 0, 50],
		a: [-1, 1, \lin, 0, -0.4],
		b: [-1, 1, \lin, 0, 0.6],
		c: [0, 1, \lin, 0, 0.2],
		d: [-1, 1, \lin, 0, 0.75],
		l: [3, 50, \lin, 1, 32],
		limitType: [0, 2, \lin, 1, 1],
		amp: [0, 1, \lin, 0, 0.2]
	)
)).add;
)

// plain vanilla SC gui

SynthDescLib.global[\dobsonFfitch].makeGui

// VarGui from miSCellaneous

\dobsonFfitch.sVarGui.gui


// Interesting non-linear behaviour can be defined with a number of unary
// and binary operators. Here the time-varying potential comes into play,
// normally they are applied to time-varying signals, but here their iteration on a
// single-sample base is itself an essential part of producing the variation in time.

// Good candidates are already simple operators and their combinations,
// also with + and -, e.g. *, /, **, %, trigonometric operators etc.


2d) The modulo operator '%'

// simple fb relation with %, whereby the modulo number is a kr ugen,
// defined outside the fb Function

(
x = {
	var inSig = SinOsc.ar([30, 30.1]);
	var lfo = LFDNoise1.kr(1).linexp(-1, 1, 0.5, 1);
    LPF.ar(
        Fb1.ar(
			{ |in, out| in[0] - (out[1] % lfo) },
			inSig, 2, blockSize: s.options.blockSize
    	),
		15000
	) * 0.1 ! 2
}.play
)

x.release


// The same example, not surprising, sounds smoother with an audio rate LFO.
// Technical necessity: an ar input has to be passed via the in arg,
// so we take [inSig, lfo] for that.
// Note: it's a nested array, the first item is an array itself !

// within the Function the stereo inSig is referred by in[i][0]
// within the Function the mono lfo is referred by in[i][1]

(
x = {
	var inSig = SinOsc.ar([30, 30.1]);
	var lfo = LFDNoise1.ar(1).linexp(-1, 1, 0.5, 1);
    LPF.ar(
        Fb1.ar(
			// this line looks a bit weird,
			// but it does the same as in the previous example:
			// in[0][0] is the current stereo sample of inSig
			// in[0][1] is the current mono sample of lfo
			{ |in, out| in[0][0] - (out[1] % in[0][1]) },
			[inSig, lfo], 2, blockSize: s.options.blockSize
    	),
		15000
	) * 0.1 ! 2
}.play
)

x.release


2e) The sine operator

// sin can work as a limiter as well as a nonlinear dynamics engine,
// here a bit of sequencing with changing a fb param and
// changing base frequency every 4 "beats" (every 0.8 sec = LFO freq 1.25)

(
x = {
	var inSig = SinOsc.ar([60, 60.1] * LFDNoise0.ar(1.25).linlin(-1, 1, 1, 2).lag(0.1));
	var lfo = LFDNoise0.ar(5!2).linlin(-1, 1, 5, 20).lag(0.05);
	Fb1.ar({ |in, out|
		// in[0][0] is the current stereo inSig sample
		// in[0][1] is the current stereo LFO sample
		(out[1] + in[0][1]).sin + in[0][0]
	}, [inSig, lfo], 2, blockSize: s.options.blockSize) * 0.1
}.play
)

x.release


2f) The '*' operator

// a more complicated example
// rather irrational concatenation of simple operations in the fb relation
// depth changes cause frequency changes

// attention, rather glitchy !

(
x = {
	// LFTri resposible for low frequencies / rhythms
	var inSig = LFTri.ar(LFDNoise0.ar(5).exprange(1, 100));
	var lfo = { LFDNoise3.ar(0.07).linexp(-1, 1, 1, 5) } ! 2;
	var i = Demand.kr(Dust.kr(0.5), 0, Dxrand((0..2), inf));
	var sig = Fb1.ar({ |in, out|
		// in[0][0] is the current (stereo) sample inSig
		// in[0][1] is the current (stereo) sample lfo
		(
			in[0][1] * (
				in[0][0] * 0.12 + (
					// changes between out[in-23], out[n-41] and
					// out[n-60] cause high frequency changes,
					// Select depends on a signal from outside,
					// not previous samples as in example (2i)
					(in[1][0].squared - Select.kr(i, out).squared).sqrt
				)
			)
		).tanh
		}, [inSig, lfo], 2, [2, 1], [[23, 41, 60]],
		blockSize: s.options.blockSize,
		blockFactor: 64 / s.options.blockSize
	) * 0.3;
	// add frequency modulation by delay modulation
	// lopass filtering with lag
	DelayC.ar(sig, 0.2, LFDNoise3.ar(1!2).range(0.01, 0.1)).lag(0.0006)
}.play
)

x.release


2g) The '/' operator

// The division operator is an underestimated resource for synthesis,
// it's interesting in the time and frequency domain (PV_MagDiv),
// able to produce rich and noisy textures (e.g. used by the composer Benjamin Thigpen).
// ATTENTION: soundwise division is dangerous as small denominators lead to
// large values or infs, this must be avoided (e.g. by using max)

// The example also establishes a cross-feedback of the two channels by using reverse.

(
x = {
	var inSig = SinOsc.ar(LFDNoise3.ar(0.1!2).range(100, 101));
	var lfo = LFDNoise3.ar(1).linexp(-1, 1, 0.2, 10);
	LPF.ar(
		Fb1.ar({ |in, out|
			(in[1][0] * in[0][1] / max(0.001, (in[1][0] - out[1].reverse).abs)).tanh
		}, [inSig, lfo], 2, [2, 1], 2, blockSize: s.options.blockSize
	), 15000) * 0.1
}.play
)

x.release



2h) The '**' operator

// exponentiation can also be interesting
// here an area of instability is crossed by a stereo lfo

(
x = {
	var inSig = LFTri.ar(60);
	var lfo = { LFDNoise3.ar(0.5).linexp(-1, 1, 0.1, 150) } ! 2;

	Fb1.ar({ |in, out|
			in[1][0] * 0.07 +
			// out[0] refers to out[i-2] because of outDepth: [[2]]
			(2 ** (in[1][0] - out[0] * in[0][1]).abs).tanh
	}, [inSig, lfo], 2, [2, 1], [[2]], blockSize: s.options.blockSize) *
	// avoid bump at start
	EnvGen.ar(Env.asr(2))
}.play
)

x.release


2i) Conditional feedback

// defining the next sample depending on some characteristics of the previous one(s)
// This can be done with the if UGen and Select.
// 'if' doesn't support multichannel expansion, so take Select here


// noisy texture with beeps

(
x = {
	var src = LFDNoise3.ar(1, 0.1);
	// ar modulators to be passed (avoid annoying steady tone caused by kr)
	var mod1 = LFDNoise3.ar(1).range(0.01, 0.2);

	// already slight difference results in quite strong stereo decorrelation
	var mod2 = LFDNoise3.ar(1).range([0.0001, 0.0002],  0.0049);

	Fb1.ar({ |in, out|
		// give same names as above for better readability
		var src = in[0][0];
		var mod1 = in[0][1];
		var mod2 = in[0][2];
		softclip(
			Select.kr(
				// as mod2 is stereo we get stereo expansion
				// and in turn different selections

				// outDepth = [[1, 6]]
				// so out[0] refers to out[i-1], out[1] to out[i-6]

				out[0] % 0.005 < mod2,
				[out[1].neg * mod1, out[0] * 0.1]
			) + src + out[0]
		)
    	}, [src, mod1, mod2], 2, 1, [[1, 6]],
		blockSize: s.options.blockSize,
		blockFactor: 8 / s.options.blockSize
		// lopass filtering with lag
	).lag(0.0003) * 0.5
}.play
)

x.release


