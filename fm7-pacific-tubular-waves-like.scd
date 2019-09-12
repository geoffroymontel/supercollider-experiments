(
{
	while (true) {
		Ndef(\fm7, {
			var ctls, mods, chans, freq, freqs;
			freq = rrand(48, 55);
			freqs = 6.collect { |i|
				Demand.kr(Impulse.kr([2,2.1,4,4.1,8, 8.1].choose), TDuty.kr(Drand([1,2,4], inf)), Dseries(Drand([freq, freq+1, freq+2, 2*freq, 2*freq+1, 2*freq+2, 3*freq, 3*freq+1, 3*freq+2, 3*freq+3], inf), 50, 40));
			};
			ctls = 6.collect { |i|
				[freqs[i], rrand(0,pi), rrand(0,1)]
			};
			mods = 6.collect { |i|
				6.collect { |j|
					if (0.1.coin) {
						LFNoise1.kr(0.1).range(0, 1)
					} {
						0
					}
				};
			};
			chans = Splay.ar(FM7.ar(ctls, mods)) * -12.dbamp;
		}).play;
		(1..10).choose.wait;
	}
}.fork
)

