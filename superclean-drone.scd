// use it with SuperClean
(
Pdef(0,
	Pseed(128,
		Ppar(
			16.collect{
				Pspawn(
					Pbind(*[
						method: \seq,
						pattern: Pfunc{|ev|
							Pbind(*[
								type: \cln,
								snd: Pstutter(inf,Prand([\rst,\fmx],inf)),
								snd: \fmx,
								dur: 1/8*Pstutter(inf,Pwrand2((1..7),[1,2,8,4,4,2,1],inf)),
								amp: Pseg([1,1.45,1.45,1],Pexprand(7.5,30),\exp,1)-1,
								hr1: Pstutter(inf,Pexprand(1,4)).round,
								hr2: Pstutter(inf,Pexprand(1,4)).round,
								hr3: Pstutter(inf,Pexprand(1,4)).round,
								hr4: Pstutter(inf,Pexprand(1,4)).round,
								fdb: Pstutter(inf,Pexprand(0.1,4.125)),
								mi2: Pstutter(inf,Pexprand(0.1,4.125)),
								mi3: Pstutter(inf,Pexprand(0.1,4.125)),
								mi4: Pstutter(inf,Pexprand(0.1,4.125)),
								en1: Pstutter(inf,Pexprand(0.1,0.6))-0.1,
								en2: Pstutter(inf,Pkey(\en1)+Pexprand(0.1,0.6)),
								en3: Pstutter(inf,Pkey(\en1)+Pkey(\en2)/Pexprand(0.2,0.7)),
								en4: Pstutter(inf,Pkey(\en1)+Pkey(\en2)/Pkey(\en3)+Pexprand(0.3,0.8)),
								cu1: Pstutter(inf,Pwhite(-8.0,8.0)),
								cu2: Pstutter(inf,Pwhite(-8.0,8.0)),
								cu3: Pstutter(inf,Pwhite(-8.0,8.0)),
								cu4: Pstutter(inf,Pwhite(-8.0,8.0)),
								pan: Pstutter(inf,Pwhite(0.0,1.0)),
								lpf: 20000-Pstutter(inf,Pexprand(20,20000)),
								octave: Pstutter(inf,Pwrand2((1..5),[1,1,2,4,2],inf)),
								scale: Pstutter(inf,Pxshuf([
									Scale.superLocrian.tuning_(Tuning.sept1),
									Scale.whole.tuning_(Tuning.sept1),
									Scale.dorian.tuning_(Tuning.sept2),
									Scale.bartok.tuning_(Tuning.sept1),
									Scale.mixolydian.tuning_(Tuning.sept2)
								],inf)),
								degree: Pstutter(inf,Pxshuf((0..7),inf)),
								gtranspose: Pstutter(inf,Pwhite(0,6)),
								mtranspose: Pstutter(inf,Pexprand(1,5.0).round)-1,
								calcFreq: Pfunc{|ev|ev.use{ev.freq.asStringPrec(48).postln}},
								stretch: Pseg([1,1,2,2,2],Pexprand(15,30),\lin,inf),
								sustain: 1.75,
								legato: 1.75,
								dark: 0.75,
								hpf: 100,
								//aux: Pstutter(inf,Pxshuf((0..63),inf)),
							])
						},
					])
				)
			}
		)
	)
).play(quant:1);
)

Pdef(0).stop;
