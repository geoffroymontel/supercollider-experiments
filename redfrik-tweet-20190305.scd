// tweet original

play{a=LFSaw;ar(Splay,c=ar(VarSaw,round(1+ar(a,1/b=(1..9))/19+1.9**b+91*if(ar(a,1/19)+1>1,1,1.9).lag,91+ar(a,b/9+1)).lag,b/9,1/19);c+ar(CombN,ar(RHPF,c*ar(a,1/91,b/9).lag,91*1.9*b,9/19),1,b/9,9)+ar(RLPF,(f=ar(a,9.1))+1<ar(a,91)+c*f,19*19,ar(a,f)+1.9/9)/1.9).tanh}// #SuperCollider

// réécriture

(
{
	Splay.ar(
		c=VarSaw.ar(
			freq: round(
				1+LFSaw.ar(1/(1..9))/19+1.9**(1..9)+91*if(LFSaw.ar(1/19)+1>1,1,1.9).lag,
				91+LFSaw.ar((1..9)/9+1)
			).lag,
			iphase: (1..9)/9,
			width: 1/19
		);
		c
		+ CombN.ar(
			in: RHPF.ar(
				in: c*LFSaw.ar(1/91,(1..9)/9).lag,
				freq: 91*1.9*(1..9),
				rq: 9/19
			),
			maxdelaytime: 1,
			delaytime: (1..9)/9,
			decaytime: 9
		)
		+ RLPF.ar(
			in: LFSaw.ar(9.1)+1<LFSaw.ar(91)+c*LFSaw.ar(9.1),
			freq: 19*19,
			rq: LFSaw.ar(LFSaw.ar(9.1))+1.9/9
		)
		/ 1.9
	).tanh;
}.play;
)

// intéressante l'utilisation des booléens pour faire du séquencing côté serveur !
(
{
	[LFSaw.ar(9.1)+1, LFSaw.ar(91), LFSaw.ar(9.1)+1<LFSaw.ar(91)]
}.plot(0.2)
)

// sans le multichannel expansion : remplacement des (1..9) par un simple 1
(
{
	Splay.ar(
		c=VarSaw.ar(
			freq: round(
				1+LFSaw.ar(1/1)/19+1.9**1+91*if(LFSaw.ar(1/19)+1>1,1,1.9).lag,
				91+LFSaw.ar(1/9+1)
			).lag.poll,
			iphase: 1/9,
			width: 1/19
		);
		c
		+ CombN.ar(
			in: RHPF.ar(
				in: c*LFSaw.ar(1/91,1/9).lag,
				freq: 91*1.9*1,
				rq: 9/19
			),
			maxdelaytime: 1,
			delaytime: 1/9,
			decaytime: 9
		)
		+ RLPF.ar(
			in: LFSaw.ar(9.1)+1<LFSaw.ar(91)+c*LFSaw.ar(9.1),
			freq: 19*19,
			rq: LFSaw.ar(LFSaw.ar(9.1))+1.9/9
		)
		/ 1.9
	).tanh;
}.play;
)
