// http://sccode.org/1-4mJ

(
fork {
	Ndef(\ttwnd).play;//(d,2,addAction:\addToHead);
	loop {
		var seed = thisThread.randSeed = 100000000.rand.debug('seed');
		Ndef(\ttwnd, {
			var freq = [20, 7500];
			Splay.ar(
				{
					var bands = 2.rrand(10);
					var sig = { [BPF,RLPF,RHPF].choose.ar(
						LFNoise2.ar(freq[0].rrand(freq[1]), LFNoise2.kr(0.1.exprand(10))),
						Array.rand(bands, freq[0], freq[1]),
						Array.rand(bands, 0.2, 1.8)
					).mean } ! 2;
					Rotate2.ar(sig[0], sig[1], LFSaw.kr(0.1.exprand(10)));
				} ! 4.rrand(6).debug('source'),
                                0.5.rrand(1)
			);
		}).fadeTime_(1.rrand(4.0));
		10.0.rrand(40).debug('wait(bts)').wait;
	}
}
)