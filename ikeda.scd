(
~synthIkeda={
	~fundamentalFreqMul=rrand(0.5,2.0); ~pulseRate=[rrand(1,10),rrand(1,10)];
	~a={SinOsc.ar([33,32]*~fundamentalFreqMul)*HenonN.ar(~pulseRate*0.5)*0.1};
	~b={SinOsc.ar([3333,3222]*~fundamentalFreqMul)*HenonN.ar(~pulseRate*2.0)*0.1};
	~c={SinOsc.ar([333,322]*~fundamentalFreqMul)*HenonN.ar(~pulseRate*1.0)*0.1};
	Out.ar(0, Pan2.ar(~a+~b+~c));
}
)
(
~tiagoIkedaRoutine = Routine(
	{
		loop {
			Server.freeAll;
			{ Mix.fill(3, ~synthIkeda) }.play; rrand(10,10*3).wait;
		}
	}
);
~tiagoIkedaRoutine.play;
)
~tiagoIkedaRoutine.stop; Server.freeAll;
