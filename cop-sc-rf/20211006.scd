
(
{
	SinOsc ar: 440
}.play
)



play{q=SinOsc;a={|x...y|perform(x,\ar,*y)};Splay ar:a.(CombN,c=a.(q,0,a.(Blip,1/f=(1..8),888/a.(q,1/88,0,2,3).ceil*a.(Duty,a.(q,1/8)>0+2*1/8,0,Dseq([8,88,888],inf)))*188),1,8-f/8,8)/8+a.(CombN,a.(GVerb,a.(BPF,8*e=c.mean,88,1/8),88),1,1)+a.(q,88,0,a.(q,0,e)<0/88)}

(
{
	q=SinOsc;
	a={ |x...y|
		perform(x,\ar,*y)
	};

	Splay.ar(a.(CombN,c=a.(q,0,a.(Blip,1/f=(1..8),888/a.(q,1/88,0,2,3).ceil*a.(Duty,a.(q,1/8)>0+2*1/8,0,Dseq([8,88,888],inf)))*188),1,8-f/8,8)/8+a.(CombN,a.(GVerb,a.(BPF,8*e=c.mean,88,1/8),88),1,1)+a.(q,88,0,a.(q,0,e)<0/88))
}.play
)

(
{
	a={ |x...y|
		perform(x,\ar,*y)
	};

	Splay.ar(
		CombN.ar(
			c=SinOsc.ar(0,a.(Blip,1/f=(1..8),888/a.(SinOsc,1/88,0,2,3).ceil*a.(Duty,a.(SinOsc,1/8)>0+2*1/8,0,Dseq([8,88,888],inf)))*188),1,8-f/8,8)/8+a.(CombN,a.(GVerb,a.(BPF,8*e=c.mean,88,1/8),88),1,1)+a.(SinOsc,88,0,a.(SinOsc,0,e)<0/88))
}.play
)

(
{
	a={ |x...y|
		perform(x,\ar,*y)
	};


	Splay.ar(
		CombN.ar(
			c = SinOsc.ar(
				freq: 0,
				phase: Blip.ar(
					1/f=(1..8),
					888 / SinOsc.ar(1/88,0,2,3).ceil * Duty.ar(SinOsc.ar(1/8)>0+2*1/8,0,Dseq([8,88,888],inf))
				) *188
			),
			1,
			8-f/8,
			8
		) / 8
		+ CombN.ar(
			GVerb.ar(
				BPF.ar(
					8*e=c.mean,
					88,
					1/8
				),
			88),
			1,
			1
		)
		+ SinOsc.ar(88,0,SinOsc.ar(0,e)<0/88)
	)
}.play
)

(
{
	SinOsc.ar(
		freq: 0,
		phase: Blip.ar(
			1/f=(1..8),
			888 / SinOsc.ar(1/88,0,2,3).ceil * Duty.ar(SinOsc.ar(1/8)>0+2*1/8,0,Dseq([8,88,888],inf))
		) *188
	)
}.play
)


(
{
	Blip.ar(
		1/f=(1..8),
		888 / SinOsc.ar(1/88,0,2,3).ceil * Duty.ar(SinOsc.ar(1/8)>0+2*1/8,0,Dseq([8,88,888],inf))
	) *188
}.play
)
(
{
	SinOsc.ar(0, SinOsc.ar(10))
}.plot(0.1)
)

(
{
	SinOsc.ar(10)
}.plot(0.1)
)


(
{
	f=(1..8);
	c = SinOsc.ar(
		freq: 0,
		phase: Blip.ar(
			1/f,
			888 / SinOsc.ar(1/88,0,2,3).ceil * Duty.ar(SinOsc.ar(1/8)>0+2*1/8,0,Dseq([8,88,888],inf))
		) *188
	);
	e = c.mean;

	Splay.ar(
		CombN.ar(
			in: c,
			maxdelaytime: 1,
			delaytime: 8-f/8,
			decaytime: 8
		) / 8
		+ CombN.ar(
			in: GVerb.ar(
				BPF.ar(
					8*e,
					88,
					1/8
				),
				88
			),
			maxdelaytime: 1,
			delaytime: 1
		)
		+
		SinOsc.ar(
			freq: 88,
			phase: 0,
			mul: SinOsc.ar(0,e)<0/88
		).scope
	)
}.play
)

(
{
	f=(1..8);
	c = Blip.ar(
			1/f,
			888 / SinOsc.ar(1/88,0,2,3).ceil * Duty.ar(SinOsc.ar(1/8)>0+2*1/8,0,Dseq([8,88,888],inf))
		) *188;
	e = c.mean;

	Splay.ar(
		CombN.ar(
			in: c,
			maxdelaytime: 1,
			delaytime: 8-f/8,
			decaytime: 8
		) / 8
		+ CombN.ar(
			in: GVerb.ar(
				BPF.ar(
					8*e,
					88,
					1/8
				),
				88
			),
			maxdelaytime: 1,
			delaytime: 1
		)
		+
		SinOsc.ar(
			freq: 88,
			phase: 0,
			mul: e<0/88
		).scope
	)
}.play
)