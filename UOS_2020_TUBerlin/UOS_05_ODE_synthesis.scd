
//////////////////////////////////////////////
ORDINARY DIFFERENTIAL EQUATION (ODE) SYNTHESIS
//////////////////////////////////////////////


// recommendation: as with Fb1 do testing with low blockSize (e.g. 4, 8, 16),
// use blockSize 64 for finished setups, where you do the compilation of
// SynthDefs only once

// in contrast to Fb1 the current default server's blockSize is assumed
//  so you don't have to specify in the examples

(
s.options.blockSize = 8;
s.quit.reboot;
)

s.freqscope;
s.scope;



1) Simple Oscillators - proof of concept

1a) The harmonic oscillator


// y'(t) = w(t)
// w'(t) = -y(t)


// for systems we rather write the functions with index

// y1'(t) = y2(t)
// y2'(t) = -y1(t)


// Now let's define this system with Fb1_ODEdef


// For the corresponding Fb1_ODEdef the Function (F) must take time and
// - as here we have size 2 -
// an array as arguments and output an array of same size,
// which can be implemented by the evaluation of the following code.
// In contrast to math notation indices start from 0.

(
Fb1_ODEdef(\harmonic,
	{ |t, y| [y[1], y[0].neg] },
	// default init values t0, y0
	t0: 0,
	y0: [0, 1]
)
)

// now this ODE is ready to be used in Fb1_ODE

// The stereo output is a pair of 90-degree-shifted sine waves.
// As one wave length would be 2pi seconds we multiply time by
// a factor 500 * 2pi to get 500 Hz.
// Changed blockSize is detected automatically.

x = { Fb1_ODE.ar(\harmonic, tMul: 500 * 2pi) * 0.1 }.play

x.release



// a default frequency could equivalently also be built into the model

(
Fb1_ODEdef(\harmonic_2, { |t, y|
	[y[1], y[0].neg] * 500 * 2pi
}, 0, [0, 1])
)

x = { Fb1_ODE.ar(\harmonic_2) * 0.1 }.play

x.release


1b) Extending the harmonic oscillator to the mass-spring-damper model


// The mass-spring-damper model with externally applied force f(t)
// is described by the second order differential equation

// y''(t) * mass = f(t) - (dampen * y'(t)) - (spring * y(t))

// where dampen means the dampening factor and spring the spring stiffness.
// Again standard substitution

// w(t) = y'(t)

// leads to the system of two first order equations

// y'(t) = w(t)
// w'(t) = (f(t) - (dampen * w(t)) - (spring * y(t))) / mass

// In the source code of Fb1_ODEdef.sc the corresponding Fb1_ODEdef looks like this:
// the Function brackets within the array are not absolutely necessary,
// but compile process is faster.

// don't evaluate, already stored

Fb1_ODEdef(\MSD, { |t, y, f = 0, mass = 1, spring = 1, dampen = 0|
    [
        { y[1] },
        { f - (dampen * y[1]) - (spring * y[0]) / mass }
    ]
}, 0, [0, 0], 1, 1);



// Here the resulting oscillation, which describes the position, is used for FM,
// the deflection converges to a value of 0.004, so take no LeakDC.

// LR difference results from slightly different linear mapping

(
x = {
	// we need extreme values for fast oscillation
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,

		// for t0, y0 default values are taken
		sig = Fb1_ODE.ar(\MSD,
			[f, mass, spring, dampen],
			leakDC: false
		);
	SinOsc.ar(sig[0].linlin(0, 0.005, [100, 101], 700), 0, 0.1)
}.play
)

x.release


// for audible sound production take a time multiplier and a scaling factor
// and get a decaying sine, leakDC now true by default

(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_ODE.ar(\MSD, [f, mass, spring, dampen], tMul: 10);
	Line.kr(dur: 10, doneAction: 2);
	sig[0] ! 2 * 20
}.play
)

x.release


// as MSD is predefined together with the wrapper class Fb1_MSD
// one can equivalently write

(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_MSD.ar(f, mass, spring, dampen, tMul: 10);
	Line.kr(dur: 10, doneAction: 2);
	sig[0] ! 2  * 20
}.play
)

x.release



2) Numeric integration type

// For most cases the symmetric symplectic procedures
// with prefix 'sym' should be used (default 'sym2').
// They deliver best results with regard to long-term stability, see links at top.
// In case you suspect instability coming from numerics
// you can take symplectic variants of higher order:
// \sym2, \sym4, \sym6, \sym8, \sym12, \sym16, \sym32, \sym64.

// Note that already a simple harmonic oscillator can fail with a standard procedure


(
Fb1_ODEdef(\harmonic, { |t, y|
	[y[1], y[0].neg]
}, 0, [0, 1]);
)

// This is decaying after a few seconds with classical Runge-Kutta 3rd order !
// ATTENTION: with other non-symplectic procedures this can lead to immediate blowups !
// Euler variants are especially bad.

(
x = {
	var sig = Fb1_ODE.ar(\harmonic,
		tMul: 1000 * 2pi,
		intType: \rk3
	);
	Limiter.ar(sig) * 0.1 * EnvGen.ar(Env.asr(0.1, curve: 3))
}.play
)

x.release


3a) Argument modulation

// additional oscillation of mass, this is already a quite extreme blurring
// operations of such kind can easily result in derailing the oscillaton

// here it's interesting to hear quite a difference between ar and kr variants

// ar modulation (automatically detected and used as in input of Fb1)

(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_ODE.ar(\MSD,
			[f, mass * LFTri.ar(200).range(0.1, 2), spring, dampen],
			leakDC: false
		);
	SinOsc.ar(sig[0].linlin(0, 0.005, [100, 101], 700), 0, 0.1)
}.play
)

x.release


// much less smooth with kr

(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_ODE.ar(\MSD,
			[f, mass * LFTri.kr(200).range(0.1, 2), spring, dampen],
			leakDC: false
		);
	SinOsc.ar(sig[0].linlin(0, 0.005, [100, 101], 700), 0, 0.1)
}.play
)

x.release


// due to Fb1's design, above kr modulator is not interpolated
// an linearily interpolated kr variant though gives a differently blurred result

(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_ODE.ar(\MSD,
			[f, mass * K2A.ar(LFTri.kr(200).range(0.1, 2)), spring, dampen],
			leakDC: false
		);
	SinOsc.ar(sig[0].linlin(0, 0.005, [100, 101], 700), 0, 0.1)
}.play
)

x.release



3b) Time modulation

// time multiplier can always be modulated, here with kr


(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_ODE.ar(\MSD,
			[f, mass, spring, dampen],
			tMul: SinOsc.kr(0.6).range(0.5, 1.5),
			leakDC: false
		);
	SinOsc.ar(sig[0].linlin(0, 0.005, [100, 101], 700), 0, 0.1)
}.play
)

x.release

// ar modulation of time
// including mainly negative multipliers
// questionable physical sense, but can be fun

(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_ODE.ar(\MSD,
			[f, mass, spring, dampen],
			tMul: SinOsc.ar(5).range(-5, 1.5),
			leakDC: false,
			withTimeChannel: true // include time as third channel
        );
    sig[2].poll;
    SinOsc.ar(sig[0].linlin(0, 0.005, [100, 101], 700), 0, 0.1);
}.play
)

x.release



4) Initial values

// Initial values - system state y0 at time t0: y(t0) = y0 - are essential for an ODE solution.
// In this example with the MSD model (and constant f !) time isn't explicit,
// therefore it makes no difference if we start at t = 0 or t = 10, time is only shifted.

// However the position, described here by y, is time-dependent,
// so it makes a difference to start with different values

// y'(t) = w(t)
// w'(t) = (f(t) - (dampen * w(t)) - (spring * y(t))) / mass

(
x = {
	var f = 0.2, mass = 0.001, spring = 50, dampen = 0.0005,
		sig = Fb1_ODE.ar(\MSD,
			[f, mass, spring, dampen],
			t0: 10,  // this doesn't make a difference to default 0
			y0: [0.2, 0],  // this does ! (compare with default [0, 0])
			leakDC: false
		);
	SinOsc.ar(sig[0].linlin(0, 0.005, [100, 101], 700), 0, 0.1)
}.play
)

x.release


5) The 'compose' argument

// This allows to build an additional Function into the Fb1 feedback loop.
// It is applied to every array of samples that is result and next input of the
// numeric integration procedure.
// Obviously then correct integration of the ODE cannot be performed anymore,
// but the option has still its value.


5a) Handling instable systems

// mass spring damper with extra term y[0] * y[1] -
// out of interest, no physical argument for that

(
Fb1_ODEdef(\MSD_2, { |t, y, f = 0, mass = 1, spring = 1, dampen = 0|
	[
		y[1],
		f - (dampen * y[1]) - (spring * y[0]) + (y[0] * y[1]) / mass
	]
}, 0, [0, 0], 1, 1);
)


// System derails after some seconds and produces nans.

(
x = {
	var f = 0.5, mass = 0.001, spring = 150, dampen = 0.001;
	var sig = Fb1_ODE.ar(\MSD_2, [f, mass, spring, dampen], leakDC: false).poll;
	LeakDC.ar(SinOsc.ar(sig[0].linlin(0, 0.006, [50, 50.1], 700), 0, 0.1))
}.play
)

x.release


// Keeping the system alive with clipping at LFO-controlled frequency.
// Note that the compose Function is passed an array as size of MSD_2 is 2,
// clip2 applied to an array again returns an array which is necessary,
// the Function must preserve the system size.

(
x = {
	var f = 0.5, mass = 0.001, spring = 150, dampen = 0.001;
	var lfo = LFDNoise3.kr(2).exprange(0.2, 1500);
	var sig = Fb1_ODE.ar(\MSD_2,
		[f, mass, spring, dampen],
		leakDC: false,
		compose: { |y| y.clip2(lfo) }
	);
	SinOsc.ar(sig[0].linlin(0, 0.006, [50, 50.1], 700).poll, 0, 0.1)
}.play
)

x.release


// if an operator is passed via a Symbol, it applies to all channels

(
x = {
	var f = 0.5, mass = 0.001, spring = 150, dampen = 0.001;
	var sig = Fb1_ODE.ar(\MSD_2,
		[f, mass, spring, dampen],
		leakDC: false,
		compose: \softclip
	);
	SinOsc.ar(sig[0].linlin(0, 0.006, [50, 50.1], 700).poll, 0, 0.1)
}.play
)

x.release


5b) Other options of the 'compose' argument

// The compose Function can also use audio rate signals as described in Fb1_ODE's help file example 5b

6) Channels with additional information

// Normally Fb1_ODE returns the solution function(s) of the ODE system,
// optionally it can also output the differential and/or the time
// (which is not trivial as time might be modulated, thus also "run backwards")
// See Fb1_ODE's help file examples 6a, 6b


7) Scaling of output

// With Fb1_ODEdef scaling factors can be defined, usually they default to 1,
// but certain ODEs produce a very high amplitude level with usual standard params, like Lorenz.
// So it makes sense to scale their output down by default.
// See Fb1_ODE's help file examples 7


8) ODEs from mechanics

8a) The driven pendulum

// The driven pendulum is interesting as it's a quite simple model
// that includes parameter zones of chaotic behaviour:
// http://lampx.tugraz.at/~hadley/physikm/apps/numerical_integration/pendulum.en.php

// y here denotes the angle

// y''(t) + (y'(t) / q) + sin(y(t)) = a * cos(omega * t)

// which translates to

// y'(t) = w(t)
// w'(t) = (-w(t) / q) - sin(y(t)) + (a * cos(omega * t))


(
Fb1_ODEdef(\DrivenPendulum, { |t, y, q = 1, omega = 0, a = 1|
	[
		{ y[1] },
		{ y[1] / q.neg - sin(y[0]) + (a * cos(omega * t)) }
	]
}, 0, [0, 0], 1, 1);
)


// move the mouse through a zone of chaotic behaviour of q between 0.65 and 0.68

// note that MouseX is converted to ar
// (with kr and changes we get artefacts)

(
x = {
	var sig = Fb1_ODE.ar(\DrivenPendulum,
		[2.3, K2A.ar(MouseX.kr(0.65, 0.68)).lag(2).poll, 1.6],
		2000,
		0, [0, 1],
	);
	sig.poll;
	sig[1] ! 2 * 0.05
}.play
)

x.release


8b) The two-body problem (planet orbits)

// attractive as pure idea but numerically problematic and
// musically (my opinion) not very interesting

// See help file Ex. 8b



9) ODEs from population dynamics

// See help file Ex. 9a Lotka-Volterra (foxes and rabbits) and
// 9b (foxes, rabbits and carrots, more interesting as chaos occurs)


10) Extending simple ODEs

// e.g. the harmonic oscillator (Fb1_ODEdef help Ex. 1a) or exponential decay



10a) Extending exponential decay

// exponential decay is described by the equation
// y'(t) = -y(t)

// an oscillating decay can e.g. be got by
// y'(t) = -y(t) * sin(t)
// the analytic solution includes a log of the sine,
// so we get more partials


(
Fb1_ODEdef(\exp_decay_raw, { |t, y|
	y.neg * sin(t)
}, 0, 1, 1, 1);
)


(
x = {
	var sig = Fb1_ODE.ar(\exp_decay_raw,
		tMul: 100 * 2pi,
		compose: \softclip
	) ! 2;
	Line.kr(dur: 10, doneAction: 2);
	sig
}.play
)

x.release


// multiplication with a second sine with multiplied time leads to
// strange and interesting results

(
Fb1_ODEdef(\exp_decay_extended, { |t, y, k|
	y.neg * (sin(t) * sin(k * t))
}, 0, 1, 1, 1);
)



// ATTENTION: danger of blowup, can be reduced with softclip composition per sample
// constant values lead to ring modulation-like effects ...

(
x = {
	var sig = Fb1_ODE.ar(\exp_decay_extended,
		[2.7], 100 * 2pi, 0, 1,
		compose: \softclip
	);
	Line.kr(dur: 10, doneAction: 2);
	sig ! 2
}.play
)

x.release


// ... whereas modulations produce more complex changing spectra
(
x = {
	var sig = Fb1_ODE.ar(\exp_decay_extended,
		[SinOsc.ar(120).range(3, 3.01)], 100 * 2pi, 0, 1,
		compose: \softclip
	);
	Line.kr(dur: 10, doneAction: 2);
	sig ! 2
}.play
)

x.release


// for decorrelated stereo we can expand to two independent equations
// k should be of size 2

(
Fb1_ODEdef(\exp_decay_extended_2, { |t, y, k|
	[
		y[0].neg * (sin(t) * sin(k[0] * t)),
		y[1].neg * (sin(t) * sin(k[1] * t))
	]
}, 0, [1, 1], 1, 1);
)

(
x = {
	var sig = Fb1_ODE.ar(\exp_decay_extended_2,
		[SinOsc.ar(120).range([3, 3.01], [3.01, 3.02])], 100 * 2pi, 0, [1, 1],
		compose: \softclip
	);
	Line.kr(dur: 10, doneAction: 2);
	sig
}.play
)

x.release


s.scope


11) Wrapper classes for well know-systems

11a) Lorenz

// a 3-dimensional system given by

// u'(t) = s (v(t) - u(t))
// v'(t) = u(t) (r - w(t)) - v(t)
// w'(t) = u(t) v(t) - b w(t)

// Fb1_Lorenz returns a 3-channel signal

// watch 3 channels
// note that waveforms look a bit different with Fb1 as
// LeakDC is applied by default (can be turned off) !

s.scope(3)


// hear two channel audio with default params

x = { Fb1_Lorenz.ar(tMul: MouseX.kr(50, 300).poll) }.play;

x.release


// SC's built-in LorenzL is using less CPU,
// but produces audible aliasing and returns only one channel

{ LorenzL.ar(MouseX.kr(20, SampleRate.ir)) * 0.3 }.freqscope;



// Lorenz as controller / modulator
// frequency and ring modulation
// from rhythmical LFO control to spectral changes (MouseX)


(
x = {
	var s = 10, r = 30, b = 3, tMul = MouseX.kr(0.1, 300, 1), sig, freq;
	// map to [-1, 1] with tanh
	sig = Fb1_Lorenz.ar(s, r, b, tMul, leakDC: false).tanh;
	// map to changing frequency range
	freq = sig.linlin(-1, 1, 50, LFDNoise3.kr(1).exprange(300, 3000));

	SinOsc.ar(freq[0..1], mul: sig[0..1])
}.play;
)

x.release

// with oscillating parameters of the ODE the results can be quite diverse

(
x = {
	var sig, s;
	s = SinOsc.ar(200, 0, 15, 10);
	sig = Fb1_Lorenz.ar(s, 22, 1, 170, y0: [1, 0, 0]);
	Limiter.ar(sig[0..1]) * EnvGen.ar(Env.asr(0.1, curve: 3));
}.play
)

x.release


(
x = {
	var sig, s;
	s = SinOsc.ar(100, 0, 9, 10);
	sig = Fb1_Lorenz.ar(s, 22, 1, 170, y0: [1, 0, 0]);
	Limiter.ar(sig[0..1]) * EnvGen.ar(Env.asr(0.1, curve: 3));
}.play
)

x.release


(
x = {
	var sig, s;
	s = SinOsc.ar(100, 0, 10, 6);
	sig = Fb1_Lorenz.ar(s, 20, 1.5, 170, y0: [1, 1, 0]);
	Limiter.ar(sig[0..1]) * EnvGen.ar(Env.asr(0.1, curve: 3));
}.play
)

x.release


11b) Further wrapper classes

// see Fb1_Hopf, Fb1_VanDerPol, Fb1_Duffing help files


11c) Adaptive variants

// Recent research has investigated "adaptive" variants of ODE systems with
// oscillatory behaviour.
// There are methods to extend the systems in a way that the frequency of an
// external input is kept in the system, even if it stops.
// This can be musically interesting, also -- and maybe especially - if the adaption
// is happening in an inexact manner.

----------------------------------------------------------------------
[1] Righetti, Ludovic; Buchli, Jonas; Ijspeert, Auke Jan (2009):
"Adaptive Frequency Oscillators and Applications".
The Open Cybernetics and Systemics Journal, 3, 64-69.

https://www.researchgate.net/publication/41666931_Adaptive_Frequency_Oscillators_and_Applications_Open_Access
Summary:
https://biorob.epfl.ch/research/research-dynamical/page-36365-en-html
----------------------------------------------------------------------
[2] Nachstedt, Timo; Tetzlaff, Christian; Manoonpong, Poramate (2017):
"Fast Dynamical Coupling Enhances Frequency Adaptation of Oscillators for Robotic Locomotion Control". Frontiers in Neurorobotics. Published online 2017 Mar 21
https://www.frontiersin.org/articles/10.3389/fnbot.2017.00014/full
----------------------------------------------------------------------


// E.g. for Hopf I've implemented Fb1_HopfA [1] and the "improved" Fb1_HopfAFDC [2], which
// uses a refined adaption system. Fb1_HopfAFDC works better in following pitches,
// especially for fast sequencies, however Fb1_HopfA can be also (or even more) interesting
// as a "lazy" follower

// normal Hopf
v'(t) = (mu - v(t)^2 - w(t)^2) v(t) - theta w(t) + f(t)
w'(t) = (mu - v(t)^2 - w(t)^2) w(t) + theta v(t)


// adaptive Hopf
v'(t) = (mu - v(t)^2 - w(t)^2) v(t) - theta(t) w(t) + f(t)
w'(t) = (mu - v(t)^2 - w(t)^2) w(t) + theta(t) v(t)
theta'(t) = -eta f(t) w(t) / sqrt(v(t)^2 + w(t)^2)


// In the source code of Fb1_ODEdef.sc the corresponding Fb1_ODEdef looks like this:
// the Function brackets within the array are not absolutely necessary,
// but compile process is faster.

// don't evaluate, already stored

Fb1_ODEdef(\HopfA, { |t, y, f = 0, mu = 1, eta = 1|
	var u, v;
	u = y[0] * y[0] + (y[1] * y[1]);
	v = mu - u;
	[
		{ v * y[0] - (y[2] * y[1]) + f },
		{ v * y[1] + (y[2] * y[0]) },
		{ f.neg * y[1] * eta / sqrt(u) }
	]
}, 0, [1, 1, 1], 0.3, 0.3);  // scaling, as standard params lead to high level output



// reasonable adaption with sine source, playing a major scale
// mouse left turns source down, but oscillator still keeps frequency
// move mouse to right to turn source on again

(
x = {
	var ratio = Demand.ar(
		Impulse.ar(3), 0,
		Dseq([0, 2, 4, 5, 7, 9, 11, 12], inf)
	).midiratio;
	var muteSrc = (MouseX.kr(0, 1) < 0.1).poll;
	var src = SinOsc.ar(ratio * 200);
	var sig = Fb1_HopfA.ar(src * (1 - muteSrc).lag(0.5), 0.15, 2, 800);
	sig[0] ! 2 * 0.5
}.play
)

x.release


// with Saw the result is less exact, sometimes Hopf jumps to higher partials

(
x = {
	var ratio = Demand.ar(
		Impulse.ar(3), 0,
		Dseq([0, 2, 4, 5, 7, 9, 11, 12], inf)
	).midiratio;
	var muteSrc = (MouseX.kr(0, 1) < 0.1).poll;
	var src = Saw.ar(ratio * 200);
	var sig = Fb1_HopfA.ar(src * (1 - muteSrc).lag(0.5), 0.15, 2, 800);
	sig[0] ! 2 * 0.5
}.play
)

x.release

// fun example:
// an inexact adaption (other values for mu and eta) can be used
// to generate interesting irregular variations, listen for a while

(
x = {
	var ratio = Demand.ar(
		Impulse.ar(3), 0,
		Dseq([0, 2, 4, 5, 7, 9, 11, 12], inf)
	).midiratio;
	var src = Saw.ar(ratio * 200, 0.3);
	var sig = Fb1_HopfA.ar(src, 8, 10.5, 600);
	sig[0] ! 2 * 0.1
}.play
)

x.release
