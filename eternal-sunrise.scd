// http://sccode.org/1-57s

(
	// INIT take time
	~t = 185/60;
	33.do { arg x;
		( "creating babass "++x ).postln;

		SynthDef(( \babass++x ).asSymbol, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
			var sig;
			var voices = 8; // CPU control
			sig = SinOsc.ar(freq);
			sig = voices.collect({
				[SinOsc, LFSaw, LFCub, LFPulse].choose.ar(freq * [1,2,1 + rrand(0,0.01)].choose * ( 1 + ( SinOsc.ar(exprand(4,100) * ( 1 + ( SinOsc.ar(exprand(0.1,100)) * 1 ))) * rrand(0,1) )), rrand(0.0,pi))
			});
			sig = sig.collect({ arg sig;
				sig + [SinOsc, LFSaw, LFCub, LFPulse].choose.ar(freq * [1,2,1 + rrand(0,0.01)].choose * ( 1 + ( SinOsc.ar(exprand(4,100) * ( 1 + ( SinOsc.ar(exprand(0.1,100)) * 1 ))) * rrand(0,1) )), rrand(0.0,pi));
			});
			sig = ( sig*\distamp.kr(10) * (1..voices)/4 ).tanh * \distpostamp.kr(1/2);
			sig = sig.collect({ arg sig;
				var line = [
					XLine.kr(0.1,2,exprand(0.02,4)),
					XLine.kr(2,0.1,exprand(0.02,4)),
				];
				RLPF.ar(sig, rrand(100,1000) * line.choose, rrand(0.1,0.5) * line.choose);
			});
			sig = HPF.ar(sig, 50);
			sig = LPF.ar(sig, 2500);
			sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
			pan = pan + SinOsc.kr((1..voices)/21, mul:0.01);
			sig = sig * 2;
			sig = sig * \modamp.kr(1).lag(0.1);
			sig = DelayC.ar(sig, 0.01,0.001) + sig;
			sig = Pan2.ar(sig, pan, amp).mean;
			Out.ar(out, sig);
		}).add;
	};

SynthDef(\kobass, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	freq = freq.lag(\freqlag.kr(0.4));
	sig = LFSaw.ar(freq * [1/2,1,2] *.t [1,1.00001], 0.7);
	sig = RLPF.ar(sig, \lpfratio.kr(1.7)* freq * SinOsc.kr(1/18 * (1..8)).range(0.5,2), \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.01,0.8,0.1,1,-4),gate,doneAction:2);
	sig = sig * SelectX.kr(\ammix.kr(1),[1,SinOsc.ar(\amf.kr(1*~t)).unipolar]);
	sig = SelectX.ar(LFNoise1.kr(1/62.1).unipolar, [sig, sig.fold( LFNoise1.kr(1/53).range(0.5,2) )]);
	sig = sig.mean;
	sig = sig * AmpComp.kr(freq);
	sig = sig * 3;
	sig = sig * amp;
	sig = sig * \modamp.kr(1).lag(0.1);
	Out.ar(out, sig);
}).add;
);


(
	// PLAY!
	Pdef(\chord1, Pmono(\kobass,
		\degree, Pseq([
			[0,4],
			[0,5],
		],inf),
		\lpfratio, 1,
		\amf, Ptuple(Prand(2**(0..5),inf)/4!2).stutter(Prand([2,3,4,6,8],inf))*~t,
		\ammix, Ptuple(Prand(( 0..10 ),inf)/10!2).stutter(Prand([2,3,4,6,8],inf)),
		\octave, Ptuple(Prand([4,3,5,6],inf).stutter(Prand([Prand([2,3,4,6,8]),4,6,8],inf))!2),
		\dur, 4,
		\modamp, Pseq([
			Pn(1,32*3),
			Pn(0,32*1),
		],inf),
		\amp, 0.1/2 * 0.5,
	));

	Pdef(\chord2, Pmono(\kobass,
		\degree, Pseq([
			9, 9, 8, 8,
		],inf)+Pseq([0,1,0,3],inf).stutter(Prand([8,8,8,4,2],inf).stutter(4)),
		\lpfratio, 1,
		\amf, Ptuple(Prand(2**(0..5),inf)/4!2).stutter(3)*~t,
		\ammix, Ptuple(Prand(( 0..10 ),inf)/10!2).stutter(2),
		\modamp, Prand([1,0,0,0],inf).stutter(Prand([8,16,32],inf)),
		\octave, Ptuple(Prand([4,3,5,6],inf).stutter(Prand([Prand([2,3,4,6,8]),4,6,8],inf))!2),
		\dur, 4,
		\amp, 0.1/2 * 0.5,
	));

	Pdef(\far,
		Plazy({
			Ppar([
				Plazy({
					Pfindur([64,32].choose, Ppar([
						rrand(1,8).collect({ arg idx;
							PmonoArtic(( \babass++rrand(0,32) ).asSymbol,
							\degree, Pstep(Pseq([
								9, 9, 8, 8,
							],inf),4)+Pseq([0,1,0,3],inf),
							\modamp, Pseq([
								Pseq([
									Pseq({[
										1,0,
										0,1,
										1,1,
										0,0,
									].clump(2).choose}.dup([2,4,8,16].choose).flat,[2,4,8,16].choose).dup([2,4,8,16].choose)
								].flat,1) * Pstep(Pseq([[1,0].choose],inf),[1,3].choose)
							],inf),
							\legato, Pseq([{ [rrand(0.1,0.8),1].choose }!( 2**rrand(0,3) )].flat,inf),
							\lpfratio, 1,
							\octave, [3,4,5,6].choose,
							\dur, [[1/4,1/16].choose,1/8,1/4,1/2,1,2].choose,
							\amp, 0.1 * [0.8,0.5,Pseq([0.8,0.5],inf)].choose * 0.5,
						)
					}),
				].flat))
			}).loop,
			Plazy({
				Pfindur([64,32,16,8].choose, Ppar([
					rrand(1,8).collect({ arg idx;
						PmonoArtic(( \babass++rrand(0,32) ).asSymbol,
						\degree, Pstep(Pseq([
							9, 9, 8, 8,
						],inf),4)+Pseq([0,1,0,3],inf),
						\modamp, Pseq([
							Pseq([
								Pseq({[
									1,0,
									0,1,
									1,1,
									0,0,
								].clump(2).choose}.dup([2,4,8,16].choose).flat,[2,4,8,16].choose).dup([2,4,8,16].choose)
							].flat,1) * Pstep(Pseq([1,0],inf),Pseq([1,3].scramble,inf) * [1,2,4,8,16].choose)
						],inf),
						\legato, Pseq([{ [rrand(0.1,0.8),1].choose }!( 2**rrand(0,3) )].flat,inf),
						\lpfratio, 1,
						\octave, [3,4,5,6].choose,
						\dur, [1/2,1/4,1/8,1/4,1/2,1,2].choose,
						\amp, 0.1 * [0.8,0.5,Pseq([0.8,0.5],inf)].choose * 0.5,
					)
				}),
			].flat));
		}).loop,
	],inf);
})
);

Pdef(\main, Ptpar([
	0,Pdef(\chord1),
	16,Pdef(\far),
	64,Pdef(\chord2),
])).play;
)