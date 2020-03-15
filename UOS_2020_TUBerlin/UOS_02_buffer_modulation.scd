
/////////////////
BUFFER MODULATION
/////////////////

s.boot;

s.freqscope;
s.scope;



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

// Check with your own buffers !

// Examples are written for mono buffers
// To extract a mono buffer from a stereo file do this:


(
p = "..."; // your path, drag file to Document to get path
b = Buffer.readChannel(s, p, channels: [0]);
)


// Playback is also easy with PlayBuf

{ PlayBuf.ar(1, b, rate: 1, loop: 1) ! 2 }.play

// Modulating playback can be done by modulating the rate,
// but this choice is a bit limited, better control is possible with BufRd.

// modulation of rate, in fact phase modulation

{ PlayBuf.ar(1, b, rate: SinOsc.ar(100).range(0.8, 1.2), loop: 1) ! 2 }.play


// Bufrd is the most versatile tool to perform buffer modulation

// "normal" usage of BufRd, take a phasor as read pointer ('phase' input)
// note that the phase input needs the sample ("frame") index between 0 and b.numFrames - 1

(
{
	var sig = BufRd.ar(
        1,
        b,
		phase: Phasor.ar(
			rate: 1,
			start: 0,
			end: BufFrames.ir(b)
		)
    );
    sig ! 2
}.play
)

// BUT: ANY signal can be a phase input for BufRd !

// WIth BufRd you can choose the interpolation type,
// 4 (cubic) is smoothest but a bit more CPU-demanding
// compare with 2 (linear), the difference might or might not be audible

1) SinOsc as phase input

(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: (
			MouseX.kr(0, 1) + // global movement
			SinOsc.ar(50).range(0, 0.003) // local movement
		) * BufFrames.ir(b),
		interpolation: 4
    ) * 0.5;
    // as local oscillation can stick with positive or negative values
	// a dc leaker is recommended
    LeakDC.ar(sig ! 2)
}.play
)



// replace static MouseX by LFO
// here the global movement is slightly decorrelated
// note that by moving to stereo source we don't need to dup in last line (... ! 2)

(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: (
			LFDNoise3.ar(0.02).range(0, [1, 1.005]) + // global movement
			SinOsc.ar(50).range(0, 0.003) // local movement
		) * BufFrames.ir(b),
		interpolation: 4
    ) * 0.5;
    // as local oscillation can stick with positive or negative values
	// a dc leaker is recommended
    LeakDC.ar(sig)
}.play
)


// here the local movement is slightly decorrelated
// rather different effect

(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: (
			LFDNoise3.ar(0.02).range(0, 1) + // global movement
			SinOsc.ar(50).range(0, [0.003, 0.0032]) // local movement
		) * BufFrames.ir(b),
		interpolation: 4
    ) * 0.5;
    LeakDC.ar(sig)
}.play
)



// global movement slightly decorrelated, faster movement
// local movement strongly decorrelated

(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: (
			LFDNoise3.ar(0.15).range(0, [1, 1.005]) + // global movement
			SinOsc.ar([50, 75]).range(0, [0.003 * 1.5, 0.003]) // local movement
		) * BufFrames.ir(b),
		interpolation: 4
    ) * 0.5;
    LeakDC.ar(sig)
}.play
)


2) Zig-zag movements as phase input


// slightly smoothened zig-zag for local movement
// use Sweep (linear raise) and SmoothFold to generate zig-zag
(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: (
			// global movement
			LFDNoise3.ar(0.3).range(0, [1, 1.01]) +
			// local movement
			SmoothFoldS.ar(Sweep.ar(0, 0.7), -0.01, 0.01, smoothAmount: 0.1)
		) * BufFrames.ir(b),
		interpolation: 4
    ) * 0.5;
    LeakDC.ar(sig)
}.play
)

// plot local movement

{ SmoothFoldS.ar(Sweep.ar(0, 0.7), -0.01, 0.01, smoothAmount: 0.1) }.plot(1)


// vary zig-zag by taking two raise rates
// they are switched with LFPulse

(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: (
			LFDNoise3.ar(0.3).range(0, [1, 1.01]) + // global movement
			SmoothFoldS.ar(
				Sweep.ar(
					0,
					LFPulse.ar(
						LFDNoise3.ar(2).range(0.2, 15)
					).range(0.2, 1)
				),
				-0.01, 0.01,
				smoothAmount: 0.1
			) // local movement
		) * BufFrames.ir(b),
		interpolation: 4
    ) * 0.5;
	LeakDC.ar(sig)
}.play
)

// plot local movement
(
{
	SmoothFoldS.ar(
		Sweep.ar(0, LFPulse.ar(LFDNoise3.ar(2).range(0.2, 15)).range(0.5, 1)),
		-0.01, 0.01,
		smoothAmount: 0.2
	)
}.plot(1)
)


// more extreme zig-zag changes by LFDNoise0 (step noise) for arbitrary rates
// frequency of step noise is also changing

(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: (
			LFDNoise3.ar(0.3).range(0, [1, 1.1]) + // global movement
			SmoothFoldS.ar(
				Sweep.ar(
					0,
					LFDNoise0.ar(
						LFDNoise3.ar(0.3).exprange(0.3, 35)
					).exprange(0.1, 5)
				),
				-0.01, 0.01,
				smoothAmount: 0.2
			) // local movement
		) * BufFrames.ir(b),
		interpolation: 4
    ) * 0.5;
	LeakDC.ar(sig)
}.play
)

// plot local movement
(
{
	SmoothFoldS.ar(
		Sweep.ar(0, LFDNoise0.ar(LFDNoise3.ar(0.3).exprange(0.3, 35)).exprange(0.1, 5)),
		-0.01, 0.01,
		smoothAmount: 0.2
	)
}.plot(2)
)



3) Arbitrary waveforms as phase input for BufRd

// Instead of the model global and local movement you could think of
// normal playback phase and disturbance

// jumps in the phase input generally cause jumps in the waveform (clicks).
// By lagging the phase these clicks turn to warp effects.

// Alternatively the resulting waveform can be lagged (lopass filtered) to


(
{
	var sig = BufRd.ar(
        1,
        b.bufnum,
		phase: Phasor.ar(
			rate: -0.7,
			start: 0,
			end: BufFrames.ir(b)
		) + LFPulse.ar({ rrand(0.3, 0.7) } ! 10, mul: 200).sum.lag(0.2), // disturbance
		interpolation: 4
    ) * 0.5;
	LeakDC.ar(sig ! 2)
}.play
)




// plot disturbance
// LFPulse is a 10 channel signal mixed down to 1 channel and lagged
// (to smoothen jumps)

// plot 5 seconds (needs 5 seconds)
(
{
	LFPulse.ar({ rrand(0.3, 0.7) } ! 10, mul: 200).sum.lag(0.2)
}.plot(5, minval: 0, maxval: 3000)
)

















