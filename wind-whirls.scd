// http://sccode.org/1-4mJ
(
fork {
	Ndef(\ttwnd).play;//(d,2,addAction:\addToHead);
	loop {
		var seed = thisThread.randSeed = 100000000.rand.debug('seed');
		Ndef(\ttwnd, {
			var freq = [20, 7500];
			Splay.ar(
				Mix.fill(rrand(4,6).debug('source'), {
					var bands = rrand(2,10);
					var sig = { [BPF,RLPF,RHPF].choose.ar(
						in: LFNoise2.ar(freq: rrand(freq[0],freq[1])) *  LFNoise2.kr(exprand(0.1,10)),
						freq: Array.rand(bands, freq[0], freq[1]),
						rq: Array.rand(bands, 0.2, 1.8)
					).mean } ! 2;
					Rotate2.ar(sig[0], sig[1], LFSaw.kr(0.1.exprand(10)));
				}),
				0.5.rrand(1)
			);
		}).fadeTime_(rrand(1,4.0).debug('fadeTime'));
		rrand(10.0,40).debug('wait(bts)').wait;
	}
}
)


// pour comprendre...

(
{
	BPF.ar(
		in: LFNoise2.ar(freq: 500) * LFNoise2.kr(1),
		freq: [200, 800, 1200],
		rq: [0.5,1.5,1.0]
	).mean
}.plot
)

(
{
	rrand(0.6,2)
} ! 2
)
