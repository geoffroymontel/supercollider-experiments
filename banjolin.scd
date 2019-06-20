/*
Instrument inspired from Rob Hordijk's Benjolin, it requires sc3-plugins (PulseDPW, SVF and DFM1)

outSignal:
1-triangle osc1,
2-square osc1,
3-triangle osc2,
4-pulse osc2,
5-XOR output,
6-Filter output

Enjoy! Alejandro Olarte

https://scsynth.org/t/benjolin-inspired-instrument/1074
https://www.emusician.com/gear/mod-squad-qu-bit-electronix-nebulae
*/
(
Ndef(\benjolis,{arg freq1= 40, freq2=4, scale=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, q=0.82, gain=1, filterType=0, outSignal=6, amp=1;
	var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, output;
	var sr;
	var osc2freq, buf, bufR;

	bufR = LocalIn.ar(2,0);
	rungler = bufR.at(0);
	buf = bufR.at(1);

	sr = SampleDur.ir;
	//sr = ControlDur.ir;
	tri1 = LFTri.ar((rungler*rungler1)+freq1);
	tri2 = LFTri.ar((rungler*rungler2)+freq2);
	osc1 = PulseDPW.ar((rungler*rungler1)+freq1);
	osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

	//pwm = tri1 > tri2;
	pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

	osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
	sh0 = BinaryOpUGen('>', osc1, 0.5);
	sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
	sh0 = (sh0 * -1) + 1;

	sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
	sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
	sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
	sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
	sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
	sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
	sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
	sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

	//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
	//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

	rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

	buf = rungler;
	rungler = (rungler * scale.linlin(0,1,0,127));
	rungler = rungler.midicps;

	LocalOut.ar([rungler,buf]);



	filt = Select.ar(filterType, [
		RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
		//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,q,0,gain),
		RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
		SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,q,1,0,0,0,0,gain),
		DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,q,gain,1)
	]);


	output = Select.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output * amp ! 2

}
).play

);

// add ranges for controlling with a GUI
(
Spec.add(\freq1, ControlSpec( 20.0, 14000.0, \exp, 0, 70, "Hz") );
Spec.add(\freq2, ControlSpec( 0.1, 14000.0, \exp, 0, 4, "Hz") );
Spec.add(\filtFreq, ControlSpec( 20.0, 20000.0, \exp, 0, 40, "Hz") );
Spec.add(\q, ControlSpec( 0.0, 1.0, \lin, 0, 0.82) );
Spec.add(\gain, ControlSpec( 0.0, 3.0, \lin, 0, 1) );
Spec.add(\filterType, ControlSpec( 0.0, 3.0, \lin, 1, 0) );
Spec.add(\rungler1, ControlSpec( 0.0, 1.0, \lin, 0, 0.16) );
Spec.add(\rungler2, ControlSpec( 0.0, 1.0, \lin, 0, 0) );
Spec.add(\runglerFilt, ControlSpec( 0.0, 1.0, \lin, 0, 9) );
Spec.add(\loop, ControlSpec( 0.0, 1.0, \lin, 0, 1) );
Spec.add(\scale, ControlSpec( 0.0, 1.0, \lin, 0, 1) );
Spec.add(\outSignal, ControlSpec( 0.0, 6.0, \lin, 1, 6) );
);
// playing using the GUI
NdefMixer(s);
Ndef(\benjolis).gui;

Ndef(\benjolis).pause;
Ndef(\benjolis).resume;
Ndef(\benjolis).play;
Ndef(\benjolis).clear;

Ndef.clear
