{Out.ar(3, SinOsc.ar(mul:0.1))}.play

(
SynthDef(\fmadsr, {
	|freq=400, amp=0.2, pan=0, modfreq=1, delmix=0, decay=2, delfreq=0.0005, freqlag=1, out=0, minR=1, maxR=10,
	v1=1, v2=1, v3=1, v4=1, v5=1, mAmin=30, mAmax=4800|
	var
	car, env, del, del1, del2, del3,
	r1, r2, r3, r4, r1b, r2b, r3b, r4b,
	mod1, mod2, mod3, mod4,
	modAmp1, modAmp2, modAmp3, modAmp4,
	car1, car2, car3, car4,
	mRatio1, mRatio2, mRatio3, mRatio4,
	cRatio1, cRatio2, cRatio3, cRatio4;

	env = EnvGen.kr(Env([0, 0.4, 0.4, 0], [0.05, (freqlag-0.1), 0.05]), doneAction:2);

	r1 = IRand(2, 4);
	r2 = IRand(2, 4);
	r3 = IRand(2, 4);
	r4 = IRand(2, 4);
	r1b = IRand(2, 4);
	r2b = IRand(2, 4);
	r3b = IRand(2, 4);
	r4b = IRand(2, 4);

	// (rrand(1, 12)+rrand(-2, 2)).clipLo(1.0)

	// cinco modulos
	modAmp1 = EnvGen.kr(Env.xyc([[1, IRand(mAmin, mAmax), \sin], [2, IRand(mAmin, mAmax), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	modAmp2 = EnvGen.kr(Env.xyc([[1, IRand(mAmin, mAmax), \sin], [2, IRand(mAmin, mAmax), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	modAmp3 = EnvGen.kr(Env.xyc([[1, IRand(mAmin, mAmax), \sin], [2, IRand(mAmin, mAmax), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	modAmp4 = EnvGen.kr(Env.xyc([[1, IRand(mAmin, mAmax), \sin], [2, IRand(mAmin, mAmax), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);

	mRatio1 = EnvGen.kr(Env.xyc([[1, r1, \sin], [2, r1+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	mRatio2 = EnvGen.kr(Env.xyc([[1, r2, \sin], [2, r2+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	mRatio3 = EnvGen.kr(Env.xyc([[1, r3, \sin], [2, r3+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	mRatio4 = EnvGen.kr(Env.xyc([[1, r4, \sin], [2, r4+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);

	cRatio1 = EnvGen.kr(Env.xyc([[1, r1b, \sin], [2, r1b+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	cRatio2 = EnvGen.kr(Env.xyc([[1, r1b, \sin], [2, r2b+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	cRatio3 = EnvGen.kr(Env.xyc([[1, r3b, \sin], [2, r3b+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);
	cRatio4 = EnvGen.kr(Env.xyc([[1, r4b, \sin], [2, r4b+IRand(-1, 1), \sin]]).delay(freqlag*0.1)).lag(freqlag*0.9);

	mod1 = SinOsc.ar((freq/4) * mRatio1, mul:modAmp1);
	mod2 = SinOsc.ar((freq/4) * mRatio2, mul:modAmp2);
	mod3 = SinOsc.ar((freq/4) * mRatio3, mul:modAmp3);
	mod4 = SinOsc.ar((freq/4) * mRatio4, mul:modAmp4);

	car1 = SinOsc.ar((freq/4) * 1 * cRatio1 + mod1, mul:v1);
	car2 = SinOsc.ar((freq/4) * 2 * cRatio2 + mod2, mul:v2);
	car3 = SinOsc.ar((freq/4) * 3 * cRatio3 + mod3, mul:v3);
	car4 = SinOsc.ar((freq/4) * 4 * cRatio4 + mod4, mul:v4);

	car = car1+car2+car3+car4;
	car = car/4;
	car = HPF.ar(car, (freq/4)*0.9);

	del1 = CombL.ar(car, 1, (1/LFNoise1.ar(delfreq).exprange(((freq/2).cpsmidi)-0.5,	((freq/2).cpsmidi)+0.5).midicps), decay, 0.5);
	del2 = CombL.ar(car, 1, (1/LFNoise1.ar(delfreq).exprange(((freq/2).cpsmidi)+11.5, ((freq/2).cpsmidi)+12.5).midicps), decay, 0.5);
	del3 = CombL.ar(car, 1, (1/LFNoise1.ar(delfreq).exprange(((freq/2).cpsmidi)+6.5, ((freq/2).cpsmidi)+7.5).midicps), decay, 0.1);

	del = (del1+del2+del3)/4;
	car = XFade2.ar(car, del, delmix);

	Out.ar(out, car!2 * env * amp * 0.2);
}).add;

SynthDef(\dist, {
	|in, out, distmix|
	var sig, entrada;
	entrada= In.ar(in, 2);
	sig =Decimator.ar(In.ar(in, 2), LFNoise1.ar(0.1).exprange(6000, 44100), LFNoise1.ar(0.1).exprange(10, 31), mul:1);
	sig =XFade2.ar(entrada, sig, distmix);
	Out.ar(0, sig);
}).add;

//buscar Gverb!!!!!!!!!!!!!!
SynthDef(\reverb, {
	arg in, out, mix=0, damp, room, gate=0, revvol=1;
	var sig, env;
	env = EnvGen.kr(Env.asr(0.1, 2, 2, curve:-8), gate, doneAction:0);
	sig = FreeVerb.ar(In.ar(in, 2), mix, room, damp);
	Out.ar(out, sig*revvol);
}).add;

SynthDef(\saw1, {
	|freq=100, hicut=1.5,
	amp=0.1, rel=50, atk=1, dtune=1.1, locut=2000, delmix=(-1), decay=4, delaytime=0.2, delvol=0.5, out1, out2, out3, amin=1, amhz=20, gate=1, panmode=0, freqlag = 0.1, detlag=0.1, amhzlag=0.1, aminlag= 0.1, amplag=0.1, tremin=0.1, treminlag=0.1, hicutlag=0.1|
	var sig, lpf, env, paning, amod;
	amod =SinOsc.ar(amhz.lag(amhzlag)).exprange(amin.lag(aminlag), 1);
	env = EnvGen.kr(Env.adsr(atk, releaseTime: rel), gate, doneAction:2);
	sig =
	SinOsc.ar(freq.lag(freqlag)*rrand(1, dtune.lag(detlag)))+
	SinOsc.ar(freq.lag(freqlag)*rrand(1, dtune.lag(detlag)))+
	SinOsc.ar(freq.lag(freqlag)*rrand(1, dtune.lag(detlag)))+
	SinOsc.ar(freq.lag(freqlag)*rrand(1, dtune.lag(detlag)))+
	SinOsc.ar(freq.lag(freqlag)*rrand(1, dtune.lag(detlag)));
	lpf = LPF.ar(sig/4.5, freq.lag(freqlag)*hicut.lag(hicutlag))*amod;
	paning = Pan4.ar(lpf,
		Select.kr(panmode, [
			LFNoise1.kr(LFNoise1.kr().exprange(0.1, 5)).range(-1.0, 1.0),
			LFNoise0.kr(LFNoise0.kr().exprange(0.1, 5)).range(-1.0, 1.0)]),
		Select.kr(panmode, [
			LFNoise1.kr(LFNoise1.kr().exprange(0.1, 5)).range(-1.0, 1.0),
			LFNoise0.kr(LFNoise0.kr().exprange(0.1, 5)).range(-1.0, 1.0)]));
	paning = paning*SinOsc.ar(LFNoise1.ar(12).exprange(2, 30)).exprange(tremin.lag(treminlag), 1);

	Out.ar(out1, paning!2*amp.lag(amplag)*env);
	Out.ar(out2, paning!2*amp.lag(amplag)*env);
	Out.ar(out3, paning!2*amp.lag(amplag)*env);
}).add;

SynthDef(\delay, {
	|mix=(-1), in, freq=400, decay=2, amp=1, minDt=100, maxDt=800, amhz=20, amin=1, mixlag=0.5, maxDtlag=0.1, amhzlag=0.1, aminlag=0.1, tremin=1, treminlag=0.1|
	var sig;
	in = In.ar(in, 2);
	sig = CombC.ar(in, delaytime: 1/LFNoise1.ar(LFNoise1.kr(12).exprange(0.1, 0.2)).exprange(minDt.lag(maxDtlag), maxDt.lag(maxDtlag)), decaytime:decay, mul:0.1);
	sig = XFade2.ar(in, sig*SinOsc.ar(amhz.lag(amhzlag)).exprange(amin.lag(aminlag), 1), mix.lag(mixlag));
	sig = sig*SinOsc.ar(LFNoise1.ar(12).exprange(2, 30)).exprange(tremin.lag(treminlag), 1);
	Out.ar(0, sig!2*amp);
}).add;
)



s.record

// se puede ser mas preciso aún con los detalles de la transformación del sonido
//hast el momento todos los procesos son lentos, quizas algunos pueden ser mas pasajeros de poca duración como ir i volver a un estado de seteo
//cosiderar uso de granular y pitchifter


(
~nota=54;
~fm=Synth(\fmadsr, [\freq, ~nota.midicps, \freqlag, 10, \gate2, 1, \out, 0, \mAmin, 1, \mAmax, 6]);
)




(
~delGrupo=Group.new;
    ~delay13 = Synth(\delay, [\in, 20], ~delGrupo);
	~delay14 = Synth(\delay, [\in, 22], ~delGrupo);
	~delay15 = Synth(\delay, [\in, 24], ~delGrupo);
	~delay13.set(\amin, 0.00000001, \amhz, 5020, \decay, 1, \mix, 1, \minDt, 100*1, \maxDt, 110*1, \maxDtlag, 14, \amhzlag, 14);
	~delay14.set(\amin, 0.00000001, \amhz, 5040, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1, \maxDtlag, 14, \amhzlag, 14);
	~delay15.set(\amin, 0.00000001, \amhz, 5080, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1, \maxDtlag, 14, \amhzlag, 14);
	~saw=Synth(\saw1, [\out1, 20, \out2, 22, \out3, 24, \freq, 50.midicps, \freqlag, 10, \dtune, 1.14563546, \atk, 60, \atkc, -10, \amp,
		0.4, \amin, 0.000000002, \aminlag, 14, \amhz, 3000, \amhzlag, 54, \hicut, 5, \detlag, 24, \amplag, 14, \tremin, 0.000000000001,
		\treminlag, 30]);
)


(
~saw.set(\tremin, 0.01);
)

(
~delay13.set(\amin, 0.0001, \amhz, rrand(5000, 5100), \decay, 1, \mix, 1, \minDt, 100*1, \maxDt, 110*1.1);
~delay14.set(\amin, 0.0001, \amhz, rrand(5000, 5100), \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.1);
~delay15.set(\amin, 0.0001, \amhz, rrand(5000, 5100), \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.1);
	~saw.set(
		\dtune, rrand(1.5, 2.2),
		\amp, 0.3,
		\amin, 0.0000002,
		\amhz, 2500,
		\tremin, 0.4);
)

(
~delGrupo.set(\aminlag, 120, \amhzlag, 100);
~delay13.set(\amin, 0.0001, \amhz, 5020, \decay, 1, \mix, 1, \minDt, 100*1, \maxDt, 110*1.3);
~delay14.set(\amin, 0.0001, \amhz, 5040, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.3);
~delay15.set(\amin, 0.0001, \amhz, 5080, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.3);
~saw.set(\freqlag, 800, \freq, 50.midicps, \dtune, rrand(3, 4.0), \amp, 0.15, \aminlag, 80, \amin, 0.002, \amhzlag, 120, \amhz, 800, \tremin, 0.5);
)


s.meter
s.volume.gui
s.record
{SinOsc.ar}.play

(
c = TempoClock.new;

fork {
	loop {(c.beats+(1)).postln;
		(1).wait}};
~t1=TempoClock.new;

{
	~delGrupo=Group.new;
    ~delay13 = Synth(\delay, [\in, 20], ~delGrupo);
	~delay14 = Synth(\delay, [\in, 22], ~delGrupo);
	~delay15 = Synth(\delay, [\in, 24], ~delGrupo);
	~delay13.set(\amin, 0.00000001, \amhz, 5020, \decay, 1, \mix, 1, \minDt, 100*1, \maxDt, 110*1, \maxDtlag, 14, \amhzlag, 14);
	~delay14.set(\amin, 0.00000001, \amhz, 5040, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1, \maxDtlag, 14, \amhzlag, 14);
	~delay15.set(\amin, 0.00000001, \amhz, 5080, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1, \maxDtlag, 14, \amhzlag, 14);
	~saw=Synth(\saw1, [\out1, 20, \out2, 22, \out3, 24, \freq, 50.midicps, \freqlag, 10, \dtune, 1.14563546, \atk, 60, \atkc, -10, \amp,
		0.4, \amin, 0.000000002, \aminlag, 14, \amhz, 3000, \amhzlag, 54, \hicut, 5, \detlag, 24, \amplag, 14, \tremin, 0.000000000001,
		\treminlag, 30]);

	5.wait;
	"paso 1".postln;
	~saw.set(\tremin, 0.01);

	3.wait;
	"paso 2".postln;
	~delay13.set(\amin, 0.0001, \amhz, rrand(5000, 5100), \decay, 1, \mix, 1, \minDt, 100*1, \maxDt, 110*1.1);
	~delay14.set(\amin, 0.0001, \amhz, rrand(5000, 5100), \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.1);
	~delay15.set(\amin, 0.0001, \amhz, rrand(5000, 5100), \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.1);
	~saw.set(
		\dtune, rrand(1.5, 2.2),
		\amp, 0.3,
		\amin, 0.0000002,
		\amhz, 2500,
		\tremin, 0.4);

	3.wait;
	"paso 3".postln;
	~delGrupo.set(\aminlag, 120, \amhzlag, 100);
	~delay13.set(\amin, 0.001, \amhz, 5020, \decay, 1, \mix, 1, \minDt, 100*1, \maxDt, 110*1.3);
	~delay14.set(\amin, 0.001, \amhz, 5040, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.3);
	~delay15.set(\amin, 0.001, \amhz, 5080, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1.3);
	~saw.set(\freq, 50.midicps, \freqlag, 100, \dtune, rrand(3, 4.0), \amp, 0.15, \amin, 0.002, \amhz, 800, \tremin, 0.5, \aminlag, 80, \amhzlag, 120);
	2.wait;
	~delGrupo.set(\aminlag, 10);
	~saw.set(\tremin, 0.05, \treminlag, 32, \amhz, rrand(100, 400));
	~delay13.set(\amin, 0.01, \amhz, 5020/rrand(1.7, 2.4), \amhzlag, 16);
	~delay14.set(\amin, 0.01, \amhz, 5040/rrand(1.7, 2.4), \amhzlag, 16);
	~delay15.set(\amin, 0.01, \amhz, 5080/rrand(1.7, 2.4), \amhzlag, 16);
	1.wait;
	~delGrupo.set(\tremin, 0.5, \treminlag, 10);
	1.wait;
	"paso4".postln;
	~saw.set(\tremin, 0.8, \treminlag, 12);
	~delGrupo.set(\aminlag, 20, \amin, 0.1, \decay, 0.7);

	1.wait;
	"paso5".postln;
	~delGrupo.set(\aminlag, 50);
	~delay13.set(\amin, 0.9, \amhz, 5020/rrand(3.8, 4.5), \amhzlag, 22.4);
	~delay14.set(\amin, 0.9, \amhz, 5040/rrand(3.8, 4.5), \amhzlag, 22.8);
	~delay15.set(\amin, 0.9, \amhz, 5080/rrand(3.8, 4.5), \amhzlag, 22.4);

	2.wait;
	~delGrupo.set(\tremin, 0.05, \treminlag, 10, \decay, 1);

	3.wait;
	~saw.set(\amp, 0.2);
	~delay13.set(\amin, 0.1, \amhz, 5020/rrand(3.8, 4.5), \amhzlag, 22.4);
	~delay14.set(\amin, 0.1, \amhz, 5040/rrand(3.8, 4.5), \amhzlag, 22.8);
	~delay15.set(\amin, 0.1, \amhz, 5080/rrand(3.8, 4.5), \amhzlag, 22.4);

	1.wait;
	"paso6".postln;
	~delGrupo.set(\tremin, 0.5, \treminlag, 20);
	~saw.set(\freq, 40.midicps, \freqlag, 22, \tremin, 0.9, \treminlag, 12);

	3.wait;

	~delGrupo.set(\aminlag, 24);
	~delay13.set(\amin, 0.01, \amhz, 5020/rrand(3.8, 4.5), \amhzlag, 7.4);
    ~delay14.set(\amin, 0.01, \amhz, 5040/rrand(3.8, 4.5), \amhzlag, 7.8);
    ~delay15.set(\amin, 0.01, \amhz, 5080/rrand(3.8, 4.5), \amhzlag, 7.4);

	9.wait;
	//seg 34
	~delGrupo.set(\aminlag, 40, \minDt, rrand(200, 150), \maxDt, rrand(260, 410), \maxDtlg, 35);
	~delay13.set(\amhz, 5020/rrand(7.1, 8.5), \amhzlag, 24.4);
	~delay14.set(\amhz, 5040/rrand(7.1, 8.5), \amhzlag, 24.8);
	~delay15.set(\amhz, 5080/rrand(7.1, 8.5), \amhzlag, 24.4);

	6.wait;
	//seg 40
	~delGrupo.set(\aminlag, 8, \minDt, rrand(20, 40), \maxDt, rrand(50, 80), \maxDtlag, 50);
	~saw.set(\amin, 0.000002, \freq, 30.midicps, \freqlag, 12, \amp, 0.4, \amplag, 10);

	4.wait;
	//seg 44
	~delGrupo.set(\aminlag, 8, \minDt, rrand(80, 150), \maxDt, rrand(160, 210), \maxDtlag, 50);
	~delay13.set(\amin, 0.0000001, \amhz, 5020/rrand(8*1.5, 8.5*1.5), \amhzlag, 14.4);
	~delay14.set(\amin, 0.0000001, \amhz, 5040/rrand(8*1.5, 8.5*1.5), \amhzlag, 14.8);
	~delay15.set(\amin, 0.0000001, \amhz, 5080/rrand(8*1.5, 8.5*1.5), \amhzlag, 16.4);

	5.wait;
	//seg 49
	~delGrupo.set(\aminlag, 100, \minDt, rrand(80*1.5, 150*1.5), \maxDt, rrand(160*2, 210*2));///////
	~delay13.set(\amin, 0.01, \amhz, rrand(180, 220.0), \amhzlag, 34.4);
	~delay14.set(\amin, 0.01, \amhz, rrand(180, 220.0), \amhzlag, 34.8);
	~delay15.set(\amin, 0.01, \amhz, rrand(180, 220.0), \amhzlag, 34.4);

	11.wait;
	//seg 60
	~delGrupo.set(\aminlag, 8, \minDt, rrand(80, 150), \maxDt, rrand(160, 210));
	~saw.set(\amin, 0.000002, \freq, 30.midicps, \freqlag, 180, \treminlag, 20, \tremin, 0.01, \amplag, 30, \amp, 0.8);
	~delay13.set(\amin, 0.0000000001, \amhz, 20, \amhzlag, 50.4);
	~delay14.set(\amin, 0.0000000001, \amhz, 40, \amhzlag, 50.8);
	~delay15.set(\amin, 0.0000000001, \amhz, 80, \amhzlag, 50.4);

	9.wait;
	~delGrupo.set(\tremin, 0.8, \treminlag, 10);
	2.wait;
	//seg 71
	~saw.set(\amin, 0.01, \amhz, 300, \amhzlag, 100,  \hicut, 10, \dtune, 7, \freq, 55.midicps, \tremin, 0.1, \amp, 0.5);

	5.wait;
	//seg 76
	~delay13.set(\amin, 0.00000000001, \amhz, 20, \decay, 1, \mix, 1, \minDt, 80*1, \maxDt, 210*1);
	~delay14.set(\amin, 0.00000000001, \amhz, 40, \decay, 1, \mix, 1, \minDt, 80*1, \maxDt, 160*1);
	~delay15.set(\amin, 0.00000000001, \amhz, 80, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1);
	~saw.set(\freq, 65.midicps, \dtune, 7, \amin, 0.01, \amhz, 150, \hicut, 10, \amp, 0.5);

	5.wait;
	~saw.set(\freq, 5.midicps, \dtune, 1,\amin, 0.01, \amhz, 150, \hicut, 10, \amp, 0.9);
	1.wait;
	~saw.set(\freq, 5.midicps, \dtune, 1, \amin, 0.06, \amhz, 80, \hicut, 10);
	1.wait;
	~saw.set(\tremin, 0.0000001, \treminlag, 20);

	7.wait;
	//seg 90
	~saw.set(\amp, 1.5);
	~delay13.set(\amin, 0.001, \amhz, 20, \decay, 1, \mix, 1, \minDt, 80*1, \maxDt, 210*1);
	~delay14.set(\amin, 0.001, \amhz, 40, \decay, 1, \mix, 1, \minDt, 80*1, \maxDt, 160*1);
	~delay15.set(\amin, 0.001, \amhz, 80, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1);

	6.wait;
	//seg 96
	~delay13.set(\amin, 0.1, \amhz, 20, \decay, 1, \mix, 1, \minDt, 80*1, \maxDt, 210*1);
	~delay14.set(\amin, 0.1, \amhz, 40, \decay, 1, \mix, 1, \minDt, 80*1, \maxDt, 160*1);
	~delay15.set(\amin, 0.1, \amhz, 80, \decay, 1, \mix, 1, \minDt, 150*1, \maxDt, 160*1);

	12.wait;
	~delGrupo.set(\tremin, 0.00001, \treminlag, 20);
	~saw.set(\tremin, 0.00001, \treminlag, 20);

	20.wait;
	~saw.set(\release, 60, \gate, 0)

}.fork(~t1);
)