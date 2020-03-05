// ORIGINAL
play{ar(Splay,o=ar(BPF,ar(Normalizer,ar(v=SinOsc,(b=(tanh(pi)..f=tab(Char).ascii)*pi*pi)*f,c=b.reciprocal,ar(v,c).max)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f));ar(LocalOut,o.rotate);o).sin};s.scope(e).style=e// #SuperCollider

// 1
{
	ar(Splay,o=ar(BPF,ar(Normalizer,ar(v=SinOsc,(b=(tanh(pi)..f=tab(Char).ascii)*pi*pi)*f,c=b.reciprocal,ar(v,c).max)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f));ar(LocalOut,o.rotate);o).sin
}.play;

s.scope(e).style=e// #SuperCollider

// 2
{
	Splay.ar(o=ar(BPF,ar(Normalizer,ar(v=SinOsc,(b=(tanh(pi)..f=tab(Char).ascii)*pi*pi)*f,c=b.reciprocal,ar(v,c).max)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f));ar(LocalOut,o.rotate);o).sin
}.play;

// 3
{
	Splay.ar(
		o=ar(BPF,ar(Normalizer,ar(v=SinOsc,(b=(tanh(pi)..f=tab(Char).ascii)*pi*pi)*f,c=b.reciprocal,ar(v,c).max)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f));
		ar(LocalOut,o.rotate);
		o
	).sin
}.play;

// 4
{
	Splay.ar(
		o=BPF.ar(
			Normalizer.ar(ar(v=SinOsc,(b=(tanh(pi)..f=tab(Char).ascii)*pi*pi)*f,c=b.reciprocal,ar(v,c).max)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f)
		);
		LocalOut.ar(o.rotate);
		o
	).sin
}.play;

// 5
{
	o=BPF.ar(
		Normalizer.ar(ar(v=SinOsc,(b=(tanh(pi)..f=tab(Char).ascii)*pi*pi)*f,c=b.reciprocal,ar(v,c).max)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;

// 6
{
	v=SinOsc;
	o=BPF.ar(
		Normalizer.ar(
			v.ar(
				(b=(tanh(pi)..f=tab(Char).ascii)*pi*pi)*f,
				c=b.reciprocal,
				ar(v,c).max
		)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;

// 7
{
	v=SinOsc;
	b=(tanh(pi)..f=tab(Char).ascii)*pi*pi;
	c=b.reciprocal;
	o=BPF.ar(
		Normalizer.ar(
			v.ar(
				b*f,
				c,
				v.ar(c).max
		)+ar(AllpassC,ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;

// 8
{
	v=SinOsc;
	b=(tanh(pi)..f=tab(Char).ascii)*pi*pi;
	c=b.reciprocal;
	o=BPF.ar(
		Normalizer.ar(
			v.ar(b*f,c,v.ar(c).max)+
			AllpassC.ar(ar(LocalIn,f),e=floor(f%pi),ar(v,c/f)/f+e/e,e,e),e/e,c),ar(v,c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;

// 9
{
	v=SinOsc;
	b=(tanh(pi)..f=tab(Char).ascii)*pi*pi;
	c=b.reciprocal;
	o=BPF.ar(
		Normalizer.ar(
			v.ar(b*f,c,v.ar(c).max)
			+ AllpassC.ar(
				ar(LocalIn,f),
				e=floor(f%pi),ar(v,c/f)/f+e/e,e,e
			),
			e/e,
			c
		),
		ar(v,c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;

// 10
{
	v=SinOsc;
	f=tab(Char).ascii;
	b=(tanh(pi)..f)*pi*pi;
	c=b.reciprocal;
	e=floor(f%pi);
	o=BPF.ar(
		Normalizer.ar(
			v.ar(b*f,c,v.ar(c).max)
			+ AllpassC.ar(
				LocalIn.ar(f),
				e,
				v.ar(c/f)/f+e/e,
				e,
				e
			),
			e/e,
			c
		),
		ar(v,c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;


// 11
{
	v=SinOsc;
	f=tab(Char).ascii;
	b=(tanh(pi)..f)*pi*pi;
	c=b.reciprocal;
	e=floor(f%pi);

	postf("f = %, b = %, c = %, e = %\n", f, b, c, e);

	o=BPF.ar(
		Normalizer.ar(
			v.ar(b*f,c,v.ar(c).max)
			+ AllpassC.ar(
				LocalIn.ar(f),
				e,
				v.ar(c/f)/f+e/e,
				e,
				e
			),
			e/e,
			c
		),
		ar(v,c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;


// Interesting
(0.2..9)
(tanh(pi)..9)
pi*pi

// 11
{
	f=9;
	b=(tanh(pi)..f)*pi*pi;
	c=b.reciprocal;
	e=floor(f%pi);

	postf("tanh(pi) = %\nf = %\nb = %\nc = %\ne = %\n", tanh(pi), f, b, c, e);

	o=BPF.ar(
		in: Normalizer.ar(
			in: SinOsc.ar(
				freq: b*f,
				phase: c,
				mul: SinOsc.ar(c).max
			) + AllpassC.ar(
				in: LocalIn.ar(f),
				maxdelaytime: e,
				delaytime: SinOsc.ar(c/f)/f+e/e,
				decaytime: e,
				mul: e
			),
			level: e/e,
			dur: c
		),
		freq: SinOsc.ar(c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;

// 12
(
{
	f=9;
	b=(tanh(pi)..f)*pi*pi;
	c=b.reciprocal;
	e=floor(f%pi);

	postf("tanh(pi) = %\nf = %\nb = %\nc = %\ne = %\n", tanh(pi), f, b, c, e);

	o=BPF.ar(
		in: Normalizer.ar(
			in: SinOsc.ar(
				freq: b*f,
				phase: c,
				mul: SinOsc.ar(c).max
			) + AllpassC.ar(
				in: LocalIn.ar(f),
				maxdelaytime: e,
				delaytime: (SinOsc.ar(c/f)/f+e/e),
				decaytime: e,
				mul: e
			),
			level: 1.0,
			dur: c
		),
		freq: SinOsc.ar(c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;
s.scope(e).style=e// #SuperCollider
)

// undestanding .max
{
	SinOsc.ar(400).max
}.plot


// understanding .sin
{
	[
		SinOsc.ar(440),
		SinOsc.ar(440).sin,
		SinOsc.ar(440).tanh
	]
}.plot


// Now with Pulse instead of Sin

(
{
	f=9;
	b=(1..9)*10;
//	b=(tanh(pi)..f)*pi*pi;
	c=b.reciprocal;
	e=floor(f%pi);

	postf("tanh(pi) = %\nf = %\nb = %\nc = %\ne = %\n", tanh(pi), f, b, c, e);

	o=BPF.ar(
		in: Normalizer.ar(
			in: Pulse.ar(
				freq: b*f,
				width: c,
				mul: SinOsc.ar(c).max
			) + AllpassC.ar(
				in: LocalIn.ar(f),
				maxdelaytime: e,
				delaytime: (SinOsc.ar(c/f)/f+e/e),
				decaytime: e,
				mul: e
			),
			level: 1.0,
			dur: c
		),
		freq: SinOsc.ar(c).exprange(f,e**f*f)
	);
	LocalOut.ar(o.rotate);
	Splay.ar(o).sin
}.play;
s.scope(e).style=e// #SuperCollider
)

// LFPulse instead of Pulse for more aliasing

(
f=200;
{
	t = Impulse.ar(MouseX.kr(1, 10000));
	LFPulse.ar(Demand.ar(t,0, Dseq([f, f*3], inf)));
}.play;
)

// no sound....

(
{
	f=9;
	b=(1..9)*200;
	c=b.reciprocal;
	t=Impulse.ar(10);
	d={ |trig, array| Demand.ar(trig,0, Dseq(array, inf)) };

	o=BPF.ar(
		in: Normalizer.ar(
			in: LFPulse.ar(
				freq: d.value(t, b),
				width: d.value(t,c),
				mul: 1
			) + AllpassC.ar(
				in: LocalIn.ar(1),
				maxdelaytime: 2,
				delaytime: 1,
				// delaytime: SinOsc.ar(d.value(t, c)),
				decaytime: 2,
				mul: 1
			),
			level: 1.0,
			dur: 2
		),
		// freq: SinOsc.ar(d.value(t, c)).exprange(d.value(t, b))
		freq: 400
	);
	LocalOut.ar(o);
	o.tanh;
}.scope;
)

// aaaaaah :)
(
{
	f=9;
	b=(1..9)*200;
	c=b.reciprocal;
	t=Impulse.ar(SinOsc.ar(0.1).exprange(1, 10000));
	// t=Impulse.ar(MouseX.kr(1, 10000));
	d={ |trig, array| Demand.ar(trig,0, Dseq(array, inf)) };

	o=Normalizer.ar(
			in: LFPulse.ar(
				freq: d.value(t, b),
				width: d.value(t,c),
				mul: 1
	));
	LocalOut.ar(o);
	o = o + AllpassC.ar(
		in: DFM1.ar(LocalIn.ar(1), freq: d.value(t, b*2), type: 0.0),
		maxdelaytime: 2,
		delaytime: 1,
		decaytime: 2
	);
	(o*10).tanh;
}.scope;
)

// in stereo

(
{
	f=9;
	b=(1..9)*200;
	c=b.reciprocal;
	// t=Impulse.ar(SinOsc.ar(0.1).exprange(1, 10000));
	t=[Impulse.ar(MouseX.kr(1, 10000)),Impulse.ar(MouseY.kr(1, 10000))];
	d={ |trig, array| Demand.ar(trig,0, Dseq(array, inf)) };

	o=Normalizer.ar(
			in: LFPulse.ar(
				freq: d.value(t, b),
				width: d.value(t,c),
				mul: 1
	));
	LocalOut.ar(o);
	o = o + AllpassC.ar(
		in: DFM1.ar(LocalIn.ar(2), freq: d.value(t, b*2), type: 0.0),
		maxdelaytime: 2,
		delaytime: 1,
		decaytime: 2
	);
	(o*10).tanh;
}.scope;
)
