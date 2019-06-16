(
{
	x=Dseq((5..20)*20.midicps,inf);
	y={ |a|
		SinOsc.ar(Demand.kr(Dust.kr(a),0,x))
	};
	// y.(MouseY.kr(1,7))*y.(MouseX.kr(1,7))
	// * SinOsc.ar([990,600])
	LeakDC.ar(SinOsc.ar([1000 * y.(1) * y.(1/2),2000 * y.(1) * y.(1/4)]).fold2) * -6.dbamp;
}.play;
)
(
{
	x=Dseq((5..20)*50,inf);
	y={ |a|
		SinOsc.ar(Demand.kr(Impulse.kr(a),0,x))
	};
	// y.(MouseY.kr(1,7))*y.(MouseX.kr(1,7))
	// * SinOsc.ar([990,600])
	SinOsc.ar([500,501]) * y.(1) * y.(3)
}.play;
)