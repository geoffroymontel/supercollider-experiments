
//////////////////////////////
FUNCTIONAL ITERATION SYNTHESIS
//////////////////////////////


References

Di Scipio, Agostino (1999). "Synthesis Of Environmental Sound Textures by Iterated Nonlinear Functions" in: Proceedings of the 2nd COST G-6 Workshop on Digital Audio Effects (DAFx99), NTNU, Trondheim, December 9-11, 1999.

Di Scipio, Agostino (2001). "Iterated Nonlinear Functions as a Sound-Generating Engine" Leonardo, Vol. 34, No. 3 (2001), pp. 249-254, MIT Press.


s.boot;

s.freqscope;
s.scope;


1) The sine map model


f(x) = sin(r * x)  //  r is interesting between 2 and 4

// some plots without sound
// 3rd iteration, vary r, x0 fixed

(
~x0 = 5;

f = { |r| sin(r * sin(r * sin(r * ~x0))) };

f.plotGraph(500, 0, 4);
)


// some plots without sound
// 3rd iteration, vary x0, r fixed

(
~r = 3;

g = { |x0| sin(~r * sin(~r * sin(~r * x0))) };

g.plotGraph(500, 0, 10);
)


1a) Time-varying the factor r

// with LF oscillation of r we get noisy textures

// try with less and more iterations (e.g. n = 7 or 12)


(
y = {
    var r = LFDNoise3.ar(10).range(3.5, 4);
	// the function for iteration has to be passed as first arg to GFIS
    GFIS.ar({ |x| sin(r * x) }, init: 0.3, n: 9) * 0.1 ! 2
}.play
)

y.release


// this is not "classical" FIS:
// for each iteration a different parametrization is taken !
// As LFDNoise UGens aren't coupled, pulsations are less unique

(
y = {
    GFIS.ar({ |x| sin(LFDNoise3.ar(10).range(3.5, 4) * x) }, 0.3, 9) * 0.1 ! 2
}.play
)

y.release



1b) Time-varying init values


// stereo init is propagated to a stereo signal

(
y = {
    var i = LFDNoise3.ar(7).range(0.2, 0.9) * [1, 1.01];
    GFIS.ar({ |x| sin(3.2 * x) }, i, 10) * 0.1
}.play
)

y.release



1c) Init values and r can be varied simultanously

... up to the reader ...




1d) Producing pitch by periodically oscillating parameters


// phase glitter
// note that here again the "lazy" FIS with different oscillators per iteration is used


(
y = {
    var osc = SinOsc.ar([30, 30.5]); // stereo source
    GFIS.ar({ |x|
		// r gets a diferent deviation ugen for every iteration
		var src = osc + LFDNoise3.ar(0.15);
		// map to an interesting range [2, 4]
		sin(src.linlin(-2, 2, 3.2, 4) * x)
	}, 0.5, 9) * 0.1
}.play
)

y.release


1e) Taking a recording as variation of r


(
p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
b = Buffer.read(s, p);
)

b.play

// FIS / GFIS is adding partials, by taking low playback rates this can be balanced

(
y = {
	var p = PlayBuf.ar(1, b,
		// playback toggles between rates -0.55 and 0.25
		rate: ToggleFF.ar(Dust.ar(15)).linlin(0, 1, -0.55, 0.25),
		loop: 1
	);
	// playback signal is mapped to a region of the critical sine map range
	GFIS.ar({ |x| sin(x * p.linlin(-1, 1, 3.73, 3.9)) }, [0.2, 0.203], 6) * 0.2
}.play
)

y.release

// varying init value

(
y = {
	var p = PlayBuf.ar(1, b,
		rate: ToggleFF.ar(Dust.ar(15)).linlin(0, 1, -0.55, 0.25),
		loop: 1
	);
	GFIS.ar({ |x| sin(x * [3.2, 3.21]) }, p / 10 + 0.8, 6) * 0.1
}.play
)

y.release



2) The logistic map model

The logistic map (Verhulst) is of the form:

f(x) = r * x * (1 - x)

The mapping has a very interesting and much researched behaviour of fixed points

ATTENTION: be careful with amplitudes, due to the quadratic term blowups can easily occur !!!



2a) Time-varying the factor r

// maximum of partials at x0 = 0.5 (mouse control)
// attention: blowups with r > 4 !

(
y = {
	var r = SinOsc.ar(100).range(3, 4);
	var x0 = MouseX.kr(0, 1).poll;
	GFIS.ar({ |x| r * x * (1 - x) }, x0, 6) * 0.1 ! 2
}.play
)

y.release


2b) Time-varying the init value x0

// attention: blowups with r > 4 !

(
y = {
	var r = MouseX.kr(3, 4).poll;
	var x0 = SinOsc.ar(100).range(0.1, 0.9);
	GFIS.ar({ |x| r * x * (1 - x) }, x0, 6) * 0.1 ! 2
}.play
)


3) The waveshaping model - iteration via buffered data

// a Buffer can be filled with an arbitrary mathematical function or audio data

// load audio

(
p = Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff";
b = Buffer.read(s, p);
)


// load to array

b.loadToFloatArray(action: { |array| a = array; "done".postln });


// take short snippet, normalize between 0 and 1
// that's most practical when we map to buffer index later on

// the sound of the snippet is quite irrelevant
// more oscillations in general produce more noise with iteration
// start trying with sine-like forms

d = a[3550..3750].normalize;

d.plot;


// fill new buffer for iteration

c = Buffer.loadCollection(s, d)



// result of BufRd is used as index for the next BufRd
// needs Buffer c prepared above

// move init value offset with mouse, harsh noisy textures

// interpolation type makes difference (4: cubic)

(
y = {
	var range = LFDNoise3.ar(LFDNoise3.ar(0.2).exprange(50, 3000)).range(0, [0.05, 0.06]);
    GFIS.ar(
        { |x| BufRd.ar(1, c, c.numFrames * x, interpolation: 4) },
		range + MouseX.kr(0, 0.9),
		7
    ) * 0.3
}.play
)

y.release


// control with LFOs
// in addition switch between different iteration levels

(
y = {
	var range = LFDNoise3.ar(LFDNoise3.ar(0.2).exprange(50, 5000)).range(0, [0.05, 0.06]);
    var sig = GFIS.ar(
        { |x| BufRd.ar(1, c, c.numFrames * x, interpolation: 4) },
		range + LFDNoise3.ar(1).range(0, 0.9),
		7,
		nOut: [2, 6]  // return iterations 3 and 7
	);
	// switch between iteration levels
	Select.ar(ToggleFF.ar(Dust.ar(5)), sig) * 0.5
}.play
)

y.release



