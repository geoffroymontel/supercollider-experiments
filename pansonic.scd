// https://sccode.org/1-4TP
// Pan Sonic emulation - Katodivaihe - lahetys
(
{
	var a, b, c, d, n, e, f,  out;

	a = b = c = d = e = f = 0;

	a = Impulse.ar(8)*1.5;

	b = WhiteNoise.ar * Env([1.0,1.0,0.0],[0.01,0.01],\step).ar(0, Impulse.ar(1 )) ;
	b = FreeVerb.ar(b, 0.5, 0.4)*2.5;

	c = SinOsc.ar(40) * Env.perc(0.01,0.2).ar(0, TDuty.ar(Dseq([1/4,1/2,1/8,1/8],inf)));
	5.do{ c = (c.distort + c)*0.75};
	c = c * 1.5;

	d = LPF.ar(Saw.ar([20,47]).sum , XLine.ar(4000,200,0.5)) * Env.perc(releaseTime: 1).ar(0, Impulse.ar(1/16)) * 0.5;
	d = (GVerb.ar( d , roomsize:10, revtime:6) * 200).clip(-1.0,1.0) * 0.3;
	//
	n = 12;
	e = ( Saw.ar( 40*(1..n) * ({ LFNoise1.ar(0.1).range(1,1.01) } ! n) ) *
	({ LFNoise1.ar(0.1).range(0.0,1.0) }!n)).sum * 10;
	e = CombC.ar(e, 0.1, 0.1, 4) + e;
	e = e.tanh * 0.3 * SinOsc.ar(0.05).range(0.5,1.0);
	e = e.dup;
	e = e * SinOsc.ar(0.03).range(0.2,1.0) * 0.5;

	f = Blip.ar(100) * Blip.ar(100) * Env([0.0,0.0,1.0],[8,8],[\step,\linear,\step])
	.ar(0, Impulse.ar(1/16)) * 2 ;

	out = ((a + b + c + f) ! 2) + d + e;
	out = out * 0.2

}.play
)