s.waitForBoot{
	{

		~rhythmGates = 257.collect({|i|i.asBinaryDigits});
		~pulseDivisions = [1,2,3,4,5,6,7,8,10,11,12,13,14,16,17,18,20,24,26,30,32,36,40,48,50, 56, 64, 100, 120, 140, 200, 240];


		s.sync;

		//MasterClock
		Ndef(\clock, {LFPulse.kr(LFPulse.kr(1, 0, 0.5, LFSaw.kr(5, 0, 2, 2), LFSaw.kr(0.3, pi, 4, 5)))})
		.play;

		/*
		Ndef(\clock).clear(0);
		*/

		s.sync;

		4.do({|i|
			Ndef((\gate ++ i).asSymbol, {|array=#[0,0,0,0,0,0,0,0]| PulseDivider.kr(Changed.kr(Ndef(\clock))) * Select.kr(Stepper.kr(Ndef(\clock)), array); }).play;
		});

		/*
		Ndef(\gate0).clear(0);
		Ndef(\gate1).clear(0);
		Ndef(\gate2).clear(0);
		Ndef(\gate3).clear(0);
		*/

		Ndef(\gate0).set(\array, ~rhythmGates[255]);
		Ndef(\gate1).set(\array, ~rhythmGates[5]);
		Ndef(\gate2).set(\array, ~rhythmGates[15]);
		Ndef(\gate3).set(\array, ~rhythmGates[149]);

		s.sync;

		4.do({|i|
			Ndef((\puld ++ i).asSymbol, {|d1=8, d2=12|{ PulseDivider.kr(Ndef(\clock), d1) + PulseDivider.kr(Ndef(\clock), d2) }}).play;
		});

		/*
		Ndef(\puld0).clear(0);
		Ndef(\puld1).clear(0);
		Ndef(\puld2).clear(0);
		Ndef(\puld3).clear(0);
		*/

		Ndef(\puld0).set(\d1, ~pulseDivisions[7]);
		Ndef(\puld0).set(\d2, ~pulseDivisions[6]);
		Ndef(\puld1).set(\d1, ~pulseDivisions[23]);
		Ndef(\puld1).set(\d2, ~pulseDivisions[1]);
		Ndef(\puld2).set(\d1, ~pulseDivisions[31]);
		Ndef(\puld2).set(\d2, ~pulseDivisions[10]);
		Ndef(\puld3).set(\d1, ~pulseDivisions[2]);
		Ndef(\puld4).set(\d2, ~pulseDivisions[4]);

		s.sync;

		Ndef(\snd, {|amp=0.05| BLowPass4.ar(LeakDC.ar(CombL.ar(LeakDC.ar(CombL.ar(LeakDC.ar(Ringz.ar(PinkNoise.ar(EnvGen.ar(Env.perc(TRand.kr(0.001, 0.004, Ndef(\gate1)), TRand.kr(0.001, 0.25, Ndef(\gate2))), Ndef(\gate0))), TExpRand.kr(40, 550, Ndef(\gate1)).lag(0.5), TRand.kr(0.001, 0.1, Ndef(\gate3)), 0.12)))), 0.05, (TRand.kr(0.00145, 0.025, Ndef(\gate3))-Linen.kr(Ndef(\gate0), TRand.kr(0.0001, 0.00195, Ndef(\gate1)), TRand.kr(0.015, 0.023, Ndef(\gate0)), TRand.kr(0.0001, 0.15, Ndef(\gate3)))).clip(0.0001, 0.05).lag(0.013), TRand.kr(0.05, 2, Ndef(\gate2)), EnvGen.ar(Env.perc(TRand.kr(0.00001, 0.04, Ndef(\gate0)), TRand.kr(0.007, 0.15, Ndef(\gate0)), amp, -5), Ndef(\gate0)))), 18000).tanh})
		.play(0,2);

		/*
		Ndef(\snd).clear(0);
		*/

		s.sync;

		Ndef(\drone, {|amp=0.5|var trem, freq; trem = SinOsc.ar([0.001, 0.0012], 0, 5.5, SinOsc.ar(0.001, 0, [5.0002, 5], 12)); freq = [Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\puld0), 2)), [12.52, 25]), Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\puld1),2)), [12.5, 24.96])].lag(0.01) * [Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\puld2),8)), [2, 4]), Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\puld3),4)), [5, 2])].lag(0.03) * [Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\puld1),8)), [12, 5]), Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\puld0),4)), [4, 12])].lag(0.003) * [Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\gate0),8)), [1, 6]), Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\gate1),4)), [6, 1])].lag(0.01) * [Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\gate2),8)), [8, 1.49]), Select.kr(ToggleFF.kr(PulseDivider.kr(Ndef(\gate3),2)), [1.51, 8])].lag(0.03) * 0.5; FreeVerb.ar(LeakDC.ar(BLowPass.ar(CombL.ar(CombL.ar(Ringz.ar(BHiPass.ar(BrownNoise.ar(EnvGen.ar(Env.sine(0.03, amp), Dust.kr(7))), 30, 1, amp), freq, 0.3, SinOsc.ar(trem, 0, amp*0.95, amp)), 1, trem.reciprocal.lag(0.3), 0.6, (freq*0.01).reciprocal) * amp, 0.6, (0.0025*freq).reciprocal, 4, amp), 1500, 1, amp)), 0.8, 0.7, 1).tanh * SinOsc.ar(trem*2, 0, amp*0.995, amp).lag(2)})
		.play;

		/*
		Ndef(\drone).clear(10);
		*/

	}.fork;
};