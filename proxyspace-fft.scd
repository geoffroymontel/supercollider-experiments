(
{
	var in, chain;
	in = VarSaw.ar(SinOsc.ar([1, rrand(1,2)]).range(400, 2000));
	chain = FFT({ LocalBuf(2048,1) } ! 2, in); // encode to frequency domain
	chain = PV_RandComb(chain, 0.95, Impulse.kr(0.4)); // process
	IFFT(chain) // decode to time domain
}.play;
)

p = ProxySpace.new;
p.push;

b = Bus.audio(s, 2);
d = GMultiLooper.new(1, [b]);

~input = { InFeedback.ar(b, 2) };
~input.play;
~input.stop;

(
~fft = {
	var in, chain;
	in = ~input;
	chain = FFT({ LocalBuf(2048,1) } ! 2, in); // encode to frequency domain
  chain = PV_BinShift(chain, MouseX.kr(0.25, 4, \exponential) );
	// chain = PV_RandComb(chain, MouseY.kr, Impulse.kr(0.4));
	chain = PV_RectComb(chain,  MouseX.kr(0, 32), MouseY.kr, 0.2);

	IFFT(chain); // decode to time domain
};
)

(
~fft2 = {
var harmonic, percussive;
var source = ~input;
var fft = FFT(LocalBuf(1024),source);

#harmonic,percussive = MedianSeparation(fft,FFTTrigger(LocalBuf(1024)),FFTTrigger(LocalBuf(1024)),1024,17);

[IFFT(harmonic),IFFT(percussive)];    //reconstruct harmonic to left ear, percussive to right
}
)

~fft.play;
~fft.stop;


