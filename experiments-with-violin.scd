b = Buffer.alloc(s, s.sampleRate * 10, 1);


(
Ndef(\test, {
	var snd, tapPhase, tap1, tap2, tap3;
	snd = SoundIn.ar(0);
	snd = GrainIn.ar(2,Dust.kr(15),0.2,snd)+GrainIn.ar(2,Dust.kr(10),0.5,snd*0.5);
	//snd = AllpassC.ar(snd, 5, MouseX.kr(0.01,5.0, lag: 1));
	snd = DFM1.ar(snd, MouseY.kr(8000, 100, lag: 2));
	//snd = BufGrain.ar(Impulse.kr(10),1,b, rate: 0.5);
	tapPhase = DelTapWr.ar(b, snd);
	#tap1, tap2, tap3 = DelTapRd.ar(b, tapPhase,
		[2, 1, 0.5],      // tap times
		1,                      // no interp
		[1.0, 0.4, 0.2]         // muls for each tap
	);
	snd+tap1+tap2+tap3;
});
)

Ndef(\test).play