
///////////
WAVEFOLDING
///////////


// all examples of these files need miSCellaneous_lib (at least v0.22) to be installed,
// you can install it from the Quarks gui interface (needs git installed) or directly.
// See the installation instructions here:

// https://github.com/dkmayer/miSCellaneous_lib
// https://daniel-mayer.at/software_en.htm


s.boot;

s.freqscope;
s.scope;


// Plot of basic variation possibilities

(
{ [
	// folding with main lib's Fold ugen
	Fold.ar(SinOsc.ar(50) * 10, -1, 1),

	// folding with rather low smoothing
	// wave shaper is partiallly a sine wave
	SmoothFoldS.ar(SinOsc.ar(50) * 10, smoothAmount: 0.3),

	// folding with maximum smoothing
	// wave shaper is full sine wave
	SmoothFoldS.ar(SinOsc.ar(50) * 10, smoothAmount: 1),

	// wave is folded back only to border ranges
	SmoothFoldS.ar(SinOsc.ar(50) * 10, foldRange: 0.3),

	// folding with different sizes of border ranges
	SmoothFoldS2.ar(SinOsc.ar(50) * 10, foldRangeLo: 0.5, foldRangeHi: 0.2)
] }.plot(1/50)
)



1) Simple parameter changes with SmoothFoldS, applied to mono sine source

s.freqscope


// main lib's folding with aliasing

{ Fold.ar(SinOsc.ar(50), -0.1, 0.1) ! 2 }.play


// mouse control of smoothAmount, 0 equals the Fold variant

{ SmoothFoldS.ar(SinOsc.ar(50), -0.1, 0.1, 1, MouseX.kr(0, 1)) ! 2 }.play


// additional control of foldRange, a low foldRange also leads to distortion

{ SmoothFoldS.ar(SinOsc.ar(50), -0.1, 0.1, MouseY.kr(0, 1), MouseX.kr(0, 1)) ! 2 }.play


// no huge difference to the variant with quadratic smoothening

{ SmoothFoldQ.ar(SinOsc.ar(50), -0.1, 0.1, MouseY.kr(0, 1), MouseX.kr(0, 1)) ! 2 }.play



// complementary foldRanges at lo and hi bounds (range, 1-range)

(
{
	var foldRange = MouseY.kr(0, 1);
	SmoothFoldS2.ar(SinOsc.ar(50), -0.1, 0.1, foldRange, 1 - foldRange, MouseX.kr(0, 1)) ! 2
}.play
)


2) Generating rich spectra by folding sine waves (or other simple waveforms) and applying LFOs


// Folding ugens do multichannel expansion, let two independant LFOs control the fold range,
// control smoothing amount with MouseX

(
x = {
	var source = SinOsc.ar(50);
	SmoothFoldS.ar(source, -0.1, 0.1, LFDNoise3.ar(0.3!2).range(0.1, 1), MouseX.kr(0, 1))
}.scope
)

x.release


// same applied to stereo sine source with slightly different frequencies

(
x = {
	var source = SinOsc.ar([50, 50.7]);
	SmoothFoldS.ar(source, -0.1, 0.1, LFDNoise3.ar(0.3!2).range(0.1, 1), MouseX.kr(0, 1))
}.scope
)

x.release


// additionally modulate pre-amplification, also L/R-dependent

(
x = {
	var source = SinOsc.ar([50, 50.7]) * LFDNoise3.ar(0.1!2).range(1, 0.1);
	SmoothFoldS.ar(source, -0.1, 0.1, LFDNoise3.ar(0.3!2).range(0.1, 1), MouseX.kr(0, 1))
}.scope
)

x.release


// additionally modulate base frequency, also L/R-dependent

(
x = {
	var source = SinOsc.ar(50 * LFDNoise3.ar(0.3!2).range(0.97, 1.03)) *
		LFDNoise3.ar(0.1!2).range(1, 0.1);
	SmoothFoldS.ar(source, -0.1, 0.1, LFDNoise3.ar(0.3!2).range(0.1, 1), MouseX.kr(0, 1))
}.scope
)

x.release




// same with triangle wave source

(
x = {
	var source = LFTri.ar(50 * LFDNoise3.ar(0.3!2).range(0.97, 1.03)) *
		LFDNoise3.ar(0.1!2).range(1, 0.1);
	SmoothFoldS.ar(source, -0.1, 0.1, LFDNoise3.ar(0.3!2).range(0.1, 1), MouseX.kr(0, 1))
}.scope
)

x.release




3) Applying modulated folding to LFO sources

// the other way round, take a lfo source and modulate folding parameters, here the relative folding range

(
x = {
    var source = LFDNoise3.ar(0.3!2).range(0.5, 1); // guarantees folding
	var foldRange = SinOsc.ar([50, 50.2]).range(0.25, 1);
    SmoothFoldS.ar(source, -0.1, 0.1, foldRange)
}.scope
)

x.release


// modulating fold bounds

(
x = {
    var source = LFDNoise3.ar(0.3!2).range(0.5, 1);
    var bounds = SinOsc.ar([50, 50.1]).range(0.02, 0.1);
    SmoothFoldS.ar(source, bounds.neg, bounds)
}.scope
)

x.release


// modulating bounds and range

(
x = {
    var source = LFDNoise3.ar(0.3!2).range(0.5, 1);
    var bounds = SinOsc.ar(50 * LFDNoise3.ar(0.3!2).range(0.995, 1.005)).range(0.1, 0.5);
	var foldRange = SinOsc.ar(50).range(0.1, 1);
    SmoothFoldS.ar(source, bounds.neg, bounds, foldRange)
}.scope
)

x.release




4) Applying folding to playback of recorded sources

// SC standard soundfile #1

(
p = Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff";
b = Buffer.read(s, p);
)

b.play

// SC standard soundfile #2
(
p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
b = Buffer.read(s, p);
)

b.play



// wavefolding on simple playback, much distortion
(
x = {
	var source = PlayBuf.ar(1, b, 1, loop: 1) ! 2;
	SmoothFoldS.ar(source, -0.1, 0.1, 1, MouseX.kr(0, 1))
}.scope
)

x.release


// distortion can be reduced by playback with low rates
(
x = {
	var source = PlayBuf.ar(1, b, 0.3, loop: 1) ! 2;
	// different bounds for L and R decorrelate the result
	SmoothFoldS.ar(source, [-0.1, -0.09], [0.09, 0.1], 1, 1) * 3
}.scope
)

x.release


// with directional changes of rate (preview on buffer modulation)
// the changes between forward and backward playback (LFPulse) can slow or fast

(
x = {
	var source = PlayBuf.ar(1, b,
		rate: 0.3 * LFPulse.ar(LFDNoise1.ar(2).exprange(0.1, 70)).range(-1, 1).lag,
		startPos: 0.3 * BufFrames.kr(b),
		loop: 1);
	SmoothFoldS.ar(source, [-0.1, -0.05], [0.05, 0.1], 1, 1) * 3
}.scope
)

x.release



