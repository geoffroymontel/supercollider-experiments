
(//booting a sever and connect to midi
s.boot;
MIDIIn.connectAll;
)

//option
s.options.outDevice_("Soundflower (2ch)");//"audio device you use"
s.reboot;


(//lauch sc808

//////////////////////////////////////////SOUND DESIGN/////////////////////////////////////////////


SynthDef.new(\bd, {
	arg decay=30, amp=2, gate=0, tone=56;
	var fenv, env, trienv, sig, sub, punch, pfenv;
	env = EnvGen.kr(Env.new([0.11, 1, 0], [0, decay], -225),doneAction:2);
	trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, decay], -230),doneAction:0);
	fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
	pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
	sig = SinOsc.ar(fenv, pi/2) * env;
	sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
	punch = SinOsc.ar(pfenv, pi/2) * env * 2;
	punch = HPF.ar(punch, 350);
	sig = (sig + sub + punch) * 2.5;
	sig = Limiter.ar(sig, 0.5) * amp;
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\sn, {
	arg amp=2, tone=340, tone2=189, snappy=0.3, gate=0, amp2=1;
	var noiseEnv, atkEnv, sig, noise, osc1, osc2, sum;
	noiseEnv = EnvGen.kr(Env.perc(0.001, 4.2, 1, -115), doneAction:2);
	atkEnv = EnvGen.kr(Env.perc(0.001, 0.8,curve:-95), doneAction:0);
	noise = WhiteNoise.ar;
	noise = HPF.ar(noise, 1800);
	noise = LPF.ar(noise, 8850);
	noise = noise * noiseEnv * snappy;
	osc1 = SinOsc.ar(tone2, pi/2) * 0.6;
	osc2 = SinOsc.ar(tone, pi/2) * 0.7;
	sum = (osc1+osc2) * atkEnv * amp2;
	sig = Pan2.ar((noise + sum) * amp * 2.5, 0);
	sig = HPF.ar(sig, 340);
	Out.ar(0, sig);
}).add;

SynthDef.new(\cpRaw, {
	arg amp=1, gate=0;
	var atkenv, atk, decay, sum, denv;
	atkenv = EnvGen.kr(Env.new([0.5,1,0],[0, 0.3], -160), doneAction:2);
	denv = EnvGen.kr(Env.dadsr(0.026, 0, 6, 0, 1, 1, curve:-157), doneAction:0);
	atk = WhiteNoise.ar * atkenv * 1.4;
	decay = WhiteNoise.ar * denv;
	sum = atk + decay * amp;
	sum = HPF.ar(sum, 500);
	sum = BPF.ar(sum, 1062, 0.5);
	Out.ar(0, Pan2.ar(sum * 1.5, 0));
}).add;

SynthDef.new(\cpReverb, {
	arg amp=1, gate=0;
	var reverb, revgen;
	revgen = EnvGen.kr(Env.perc(0.1, 4, curve:-9), gate, doneAction:2);
	reverb = WhiteNoise.ar * revgen * 0.02;
	reverb = HPF.ar(reverb, 500);
	reverb = LPF.ar(reverb, 1000);
	Out.ar(0, Pan2.ar(reverb * amp, 0));
}).add;

SynthDef.new(\LT, {
	arg amp=1, freq=80;
	var sig, fenv, env, pnoise, penv;
	env = EnvGen.kr(Env.new([0.4, 1, 0], [0, 20], -250),doneAction:2);
	penv = EnvGen.kr(Env.new([0.6, 1, 0], [0, 30], -225),doneAction:2);
	fenv = Env([freq*1.25, freq*1.125, freq], [0.1, 0.5], -4).kr;
	sig = SinOsc.ar(fenv, pi/2) * env;
	sig = Pan2.ar(sig * amp * 3, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\MT, {
	arg amp, freq=120;
	var sig, fenv, env;
	env = EnvGen.kr(Env.new([0.4, 1, 0], [0, 16], -250),doneAction:2);
	fenv = Env([freq*1.33333, freq*1.125, freq], [0.1, 0.5], -4).kr;
	sig = SinOsc.ar(fenv, pi/2);
	sig = Pan2.ar(sig * env * amp * 2, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\HT, {
	arg amp, freq=165;
	var sig, fenv, env;
	env = EnvGen.kr(Env.new([0.4, 1, 0], [0, 11], -250),doneAction:2);
	fenv = Env([freq*1.333333, freq*1.121212, freq], [0.1, 0.5], -4).kr;
	sig = SinOsc.ar(fenv, pi/2);
	sig = Pan2.ar(sig * env * amp * 2, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\LC, {
	arg amp=1, freq=165;
	var sig, fenv, env, pnoise, penv;
	env = EnvGen.kr(Env.new([0.15, 1, 0], [0, 18], -250),doneAction:2);
	penv = EnvGen.kr(Env.new([0.6, 1, 0], [0, 30], -225),doneAction:2);
	fenv = Env([freq*1.333333, freq*1.121212, freq], [0.1, 0.5], -4).kr;
	sig = SinOsc.ar(fenv, pi/2) * env;
	sig = Pan2.ar(sig * amp * 3, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\MC, {
	arg amp=1, freq=250;
	var sig, fenv, env;
	env = EnvGen.kr(Env.new([0.15, 1, 0], [0, 9], -250),doneAction:2);
	fenv = Env([freq*1.24, freq*1.12, freq], [0.1, 0.5], -4).kr;
	sig = SinOsc.ar(fenv, pi/2);
	sig = Pan2.ar(sig * env * amp * 2, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\HC, {
	arg amp=1, freq=370;
	var sig, fenv, env;
	env = EnvGen.kr(Env.new([0.15, 1, 0], [0, 6], -250),doneAction:2);
	fenv = Env([freq*1.22972, freq*1.08108, freq], [0.1, 0.5], -4).kr;
	sig = SinOsc.ar(fenv, pi/2);
	sig = Pan2.ar(sig * env * amp * 2, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\rimshot, {
	arg amp=1;
	var fenv, env, sig, punch, tri1, tri2;
	env = EnvGen.kr(Env.new([1, 1, 0], [0.00272, 0.07], -42), doneAction:2);
	tri1 = LFTri.ar(1667 * 1.1, 1) * env;
	tri2 = LFPulse.ar(455 * 1.1, width:0.8) * env;
	punch = WhiteNoise.ar * env * 0.46;
	sig = tri1 + tri2 + punch;
	sig = BPeakEQ.ar(sig, 464, 0.44, 8);
	sig = HPF.ar(sig, 315);
	sig = LPF.ar(sig, 7300);
	sig = Pan2.ar(sig * amp, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\claves, {
	arg amp=1;
	var  env, sig;
	env = EnvGen.kr(Env.new([1, 1, 0], [0, 0.1], -20), doneAction:2);
	sig = SinOsc.ar(2500, pi/2) * env * amp;
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;



SynthDef.new(\maracas, {
	arg amp=1, gate=0;
	var env, sig;
	env = EnvGen.kr(Env.new([0.3, 1, 0], [0.027, 0.07], -250), gate, doneAction:2);
	sig = WhiteNoise.ar * env * amp;
	sig = HPF.ar(sig, 5500);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;

SynthDef.new(\cowbell, {
	arg amp=1;
	var sig, pul1, pul2, env, atk, atkenv, datk;
	atkenv = EnvGen.kr(Env.perc(0, 1, 1, -215),doneAction:0);
	env = EnvGen.kr(Env.perc(0.01, 9.5, 1, -90),doneAction:2);
	pul1 = LFPulse.ar(811.16);
	pul2 = LFPulse.ar(538.75);
	atk = (pul1 + pul2) * atkenv * 6;
	datk = (pul1 + pul2) * env;
	sig = (atk + datk) * amp;
	sig = HPF.ar(sig, 250);
	sig = LPF.ar(sig, 4500);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;


SynthDef.new(\hat, {
	arg decay=0.42, amp=1, pan=0;
	var sig, sighi,siglow, sum, env, osc1, osc2, osc3, osc4, osc5, osc6;
	env = EnvGen.kr(Env.perc(0.005, decay, 1, -30),doneAction:2);
	osc1 = LFPulse.ar(203.52);
	osc2 = LFPulse.ar(366.31);
	osc3 = LFPulse.ar(301.77);
	osc4 = LFPulse.ar(518.19);
	osc5 = LFPulse.ar(811.16);
	osc6 = LFPulse.ar(538.75);
	sighi = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
    siglow = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
    sighi = BPF.ar(sighi, 8900, 1);
    sighi = HPF.ar(sighi, 9000);
    siglow = BBandPass.ar(siglow, 8900, 0.8);
    siglow = BHiPass.ar(siglow, 9000, 0.3);
    sig = BPeakEQ.ar((siglow+sighi), 9700, 0.8, 0.7);
    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(0, sig);
}).add;


SynthDef.new(\openhihat, {
	arg decay=0.5, amp=4, pan=0;
	var sig, siga, sigb, env1, env2, osc1, osc2, osc3, osc4, osc5, osc6, sum;
	env1 = EnvGen.kr(Env.perc(0.1, decay, curve:-3), doneAction:2);
	env2 = EnvGen.kr(Env.new([0, 1, 0], [0, decay*5], curve:-150), doneAction:0);
	osc1 = LFPulse.ar(203.52) * 0.6;
	osc2 = LFPulse.ar(366.31) * 0.6;
	osc3 = LFPulse.ar(301.77) * 0.6;
	osc4 = LFPulse.ar(518.19) * 0.6;
	osc5 = LFPulse.ar(811.16) * 0.6;
	osc6 = LFPulse.ar(538.75) * 0.6;
	sig = osc1 + osc2 + osc3 + osc4 + osc5 +osc6;
	sig = BLowShelf.ar(sig, 990, 2, -3);
	sig = BPF.ar(sig, 7700);
	sig = BPeakEQ.ar(sig, 7200, 0.5, 5);
	sig = BHiPass4.ar(sig, 8100, 0.7);
	sig = BHiShelf.ar(sig, 9400, 1, 5);
	siga = sig * env1 * 0.6;
	sigb = sig * env2;
	sum = siga + sigb;
	sum = LPF.ar(sum, 4000);
	sum = Pan2.ar(sum, 0);
	sum = sum * amp * 2;
	Out.ar(0, sum);
}).add;

SynthDef.new(\cymbal, {
	arg decay=2, amp=20, pan=0, gate=0, tone=0.002;
	var sig, sig1,sig2, sig2a, sig2b, sig3, env1, env2, env2b, env3, osc1, osc2, osc3, osc4, osc5, osc6, sum;
	env1 = EnvGen.kr(Env.perc(0.3, decay, curve:-3), doneAction:2);
	env2 = EnvGen.kr(Env.new([0, 0.6, 0], [0.1, decay*0.7], -5), doneAction:0);
	env2b = EnvGen.kr(Env.new([0, 0.3, 0], [0.1, decay*20], -120), doneAction:0);
	env3 = EnvGen.kr(Env.new([0, 1, 0], [0, decay*5], curve:-150), doneAction:0);
	osc1 = LFPulse.ar(203.52) * 0.6;
	osc2 = LFPulse.ar(366.31) * 0.6;
	osc3 = LFPulse.ar(301.77) * 0.6;
	osc4 = LFPulse.ar(518.19) * 0.6;
	osc5 = LFPulse.ar(811.16) * 0.6;
	osc6 = LFPulse.ar(538.75) * 0.6;
	sig = osc1 + osc2 + osc3 + osc4 + osc5 +osc6;
	sig1 = BLowShelf.ar(sig, 2000, 1, 5);
	sig1 = BPF.ar(sig1, 3000);
	sig1 = BPeakEQ.ar(sig1, 2400, 0.5, 5);
	sig1 = BHiPass.ar(sig1, 1550, 0.7);
	sig1 = LPF.ar(sig1, 3000);
	sig1 = BLowShelf.ar(sig1, 1000, 1, 0);
	sig1 = sig1 * env1 * tone;
	sig2 = BLowShelf.ar(sig, 990, 2, -5);
	sig2 = BPF.ar(sig2, 7400);
	sig2 = BPeakEQ.ar(sig2, 7200, 0.5, 5);
	sig2 = BHiPass4.ar(sig2, 6800, 0.7);
	sig2 = BHiShelf.ar(sig2, 10000, 1, -4);
	sig2a = sig2 * env2 * 0.3;
	sig2b = sig2 * env2b * 0.6;
	sig3 = BLowShelf.ar(sig, 990, 2, -15);
	sig3 = BPF.ar(sig3, 6500);
	sig3 = BPeakEQ.ar(sig3, 7400, 0.35, 10);
	sig3 = BHiPass4.ar(sig3, 10500, 0.8, 2);
	sig3 = sig3 * env3;
	sum = sig1 + sig2a + sig2b + sig3;
	sum = LPF.ar(sum, 4000);
	sum = Pan2.ar(sum, 0);
	sum = sum * amp;
	Out.ar(0, sum);
}).add;


////////////////////////////////////////////////MIDI//////////////////////////////////////////////////





~bd = Array.fill(128,{nil});
~bdGUI = Array.fill(128,{nil});
~sn = Array.fill(128,{nil});
~snGUI = Array.fill(128,{nil});
~lowtom = Array.fill(128,{nil});
~lowtomGUI = Array.fill(128,{nil});
~midtom = Array.fill(128,{nil});
~midtomGUI = Array.fill(128,{nil});
~hitom = Array.fill(128,{nil});
~hitomGUI = Array.fill(128,{nil});
~lowconga = Array.fill(128,{nil});
~lowcongaGUI = Array.fill(128,{nil});
~midconga = Array.fill(128,{nil});
~midcongaGUI = Array.fill(128,{nil});
~hiconga = Array.fill(128,{nil});
~hicongaGUI = Array.fill(128,{nil});
~claves = Array.fill(128,{nil});
~clavesGUI = Array.fill(128,{nil});
~rimshot = Array.fill(128,{nil});
~rimshotGUI = Array.fill(128,{nil});
~maracas = Array.fill(128,{nil});
~maracasGUI = Array.fill(128,{nil});
~cpRaw = Array.fill(128,{nil});
~clapRaw = Array.fill(128,{nil});
~cpReverb = Array.fill(128,{nil});
~clapReverbGUI = Array.fill(128,{nil});
~cowbell = Array.fill(128,{nil});
~cowbellGUI = Array.fill(128,{nil});
~hihat = Array.fill(128,{nil});
~hihatGUI = Array.fill(128,{nil});
~openhihat = Array.fill(128,{nil});
~openhihatGUI = Array.fill(128,{nil});
~cymbal = Array.fill(128,{nil});
~cymbalGUI = Array.fill(128,{nil});


////////// BD  /////////


MIDIdef.noteOn(\bdON, {
	arg vel, nn;
	[vel, nn].postln;
	~bdamp = vel.linexp(0, 127, 0.3, 2);
	~bd[nn] = Synth.new(\bd,
		[
			\amp, ~bdamp,
			\decay, ~decaybd,
			\tone, ~toneBD,
			\gate, 1
		]
	);
},36);

MIDIdef.noteOff(\bdOFF, {
	arg vel, nn;
	~bd[nn].set(\gate, 0);
	~bd[nn] = nil;
},36);

MIDIdef.cc(\bdDECAY, {
	arg val, cnum,nn;
	[val, cnum].postln;
	~decaybd = val.linlin(0, 127, 6, 110);
	~bd.do({
		arg bdcc;
		bdcc.set(\decay, ~decaybd);
	});
},1);

MIDIdef.cc(\bdTONE, {
	arg val, cnum,nn;
	[val, cnum].postln;
	~toneBD = val.linexp(0, 127, 50, 70);
	~bd.do({
		arg bdcc;
		bdcc.set(\tone, ~toneBD);
	});
},11);



/////// Snare ///////////


MIDIdef.noteOn(\snON, {
	arg vel, nn;
	[vel, nn].postln;
	~snamp = vel.linexp(0, 127, 0.08, 2);
	~sn[nn] = Synth.new(\sn,
		[
			\amp, ~snamp,
			\tone, ~tonesn,
			\tone2, ~tone2sn,
			\snappy, ~snappy,
			\amp2, ~amp2SN,
			\gate, 1
		]
	);
},38);

MIDIdef.noteOff(\snOFF, {
	arg nn;
	~sn[nn].set(\gate, 0);
	~sn[nn] = nil;
},38);

MIDIdef.cc(\snTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~tonesn = val.linlin(0, 127, 340*0.62, 340*1.15);
	~tone2sn = val.linlin(0, 127, 189*0.62, 189*1.15);
	~sn.do({
		arg tone;
		tone.set(\tone, ~tonesn, \tone2, ~tone2sn)
	});
},21);


MIDIdef.cc(\snappy, {
	arg val, cnum;
	[val, cnum].postln;
	~snappy = val.linlin(0, 127, 0.002, 0.45);
	~amp2SN = val.linexp(0, 127, 1, 0.6);
	~sn.do({
		arg snappy;
		snappy.set(\snappy, ~snappy, \amp2, ~amp2SN)
	});
},22);



////////////// Clap ///////////////


MIDIdef.noteOn(\cpRawON, {
	arg vel, nn;
	[vel, nn].postln;
	~cpRawamp = vel.linexp(0, 127, 0.1, 3);
	~cpRaw[nn] = Synth.new(\cpRaw,
		[
			\amp, ~cpRawamp,
			\gate, 1
		]
	);
},[37, 39]);

MIDIdef.noteOff(\cpRawOFF, {
	arg nn;
	~cpRaw[nn].set(\gate, 0);
	~cpRaw[nn]=nil;
},[37, 39]);

MIDIdef.noteOn(\cpReverbON, {
	arg vel, nn;
	[vel, nn].postln;
	~cpReverbamp = vel.linexp(0, 127, 0.1, 2);
	~cpReverb[nn] = Synth.new(\cpReverb,
		[
			\amp, ~cpReverbamp,
			\gate, 1
		]
	);
},37);

MIDIdef.noteOff(\cpReverbOFF, {
	arg vel, nn;
	~cpReverb[nn]=nil;
},37);



////////// rim shot ///////////


MIDIdef.noteOn(\rmON, {
	arg vel, nn;
	[vel, nn].postln;
	~rsamp = vel.linexp(0, 127, 0.08, 0.9);
	~rimshot[nn] = Synth.new(\rimshot,
		[
			\amp, ~rsamp
		]
	);
},40);

MIDIdef.noteOff(\rmOFF, {
	arg nn;
	~rimshot[nn]=nil;
},40);



//////// cow bell /////////////


MIDIdef.noteOn(\cowbellON, {
	arg vel, nn;
	[vel, nn].postln;
	~cbamp = vel.linexp(0, 127, 0.01, 0.2);
	~cowbell[nn] = Synth.new(\cowbell,
		[
			\amp, ~cbamp
		]
	);
},49);

MIDIdef.noteOff(\cowbellOFF, {
	arg nn;
	~cowbell[nn]=nil;
},49);



////////// maracas /////////////


MIDIdef.noteOn(\maracasON, {
	arg vel, nn;
	[vel, nn].postln;
	~maracasamp = vel.linexp(0, 127, 0.01, 0.3);
	~maracas[nn] = Synth.new(\maracas,
		[
			\amp, ~maracasamp,
			\gate, 1
		]
	);
},51);

MIDIdef.noteOff(\maracasOFF, {
	arg nn;
	~maracas[nn]=nil;
},51);



//////// Low Tom ///////////////////


MIDIdef.noteOn(\lowtomON, {
	arg vel, nn;
	[vel, nn].postln;
	~lowtomamp = vel.linexp(0, 127, 0.01, 1);
	~lowtom[nn] = Synth.new(\LT,
		[
			\amp, ~lowtomamp,
			\freq, ~lowtomFreq
		]
	);
},41);

MIDIdef.noteOff(\lowtomOFF, {
	arg nn;
	~lowtom[nn]=nil;
},41);

MIDIdef.cc(\LTTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~lowtomFreq = val.linexp(0, 127, 80*0.9, 80*1.25);
	~lowtom.do({
		arg ltcc;
		ltcc.set(\freq, ~lowtomFreq);
	});
},102);



//////// Mid Tom ///////////////////



MIDIdef.noteOn(\midtomON, {
	arg vel, nn;
	[vel, nn].postln;
	~midtomamp = vel.linexp(0, 127, 0.01, 1);
	~midtom[nn] = Synth.new(\MT,
		[
			\amp, ~midtomamp,
			\freq, ~midtomFreq
		]
	);
},43);

MIDIdef.noteOff(\midtomOFF, {
	arg nn;
	~midtom[nn]=nil;
},43);


MIDIdef.cc(\MTTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~midtomFreq = val.linexp(0, 127, 128*0.65, 120*1.1);
	~midtom.do({
		arg mtcc;
		mtcc.set(\freq, ~midtomFreq);
	});
},103);



//////// Hi Tom ///////////////////


MIDIdef.noteOn(\hitomON, {
	arg vel, nn;
	[vel, nn].postln;
	~hitomamp = vel.linexp(0, 127, 0.01, 1);
	~hitom[nn] = Synth.new(\HT,
		[
			\amp, ~hitomamp,
			\freq, ~hitomFreq
		]
	);
},45);

MIDIdef.noteOff(\hitomOFF, {
	arg nn;
	~hitom[nn]=nil;
},45);


MIDIdef.cc(\HTTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~hitomFreq = val.linexp(0, 127, 165*0.7, 165*1.2);
	~hitom.do({
		arg htcc;
		htcc.set(\freq, ~hitomFreq);
	});
},104);




//////// Low Conga ///////////////////


MIDIdef.noteOn(\lowcongaON, {
	arg vel, nn;
	[vel, nn].postln;
	~lowcongaamp = vel.linexp(0, 127, 0.01, 1);
	~lowconga[nn] = Synth.new(\LC,
		[
			\amp, ~lowcongaamp,
			\freq, ~lowcongaFreq
		]
	);
},47);

MIDIdef.noteOff(\lowcongaOFF, {
	arg nn;
	~lowconga[nn]=nil;
},47);

MIDIdef.cc(\LCTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~lowcongaFreq = val.linexp(0, 127, 165*0.7, 165*1.15);
	~lowconga.do({
		arg lccc;
		lccc.set(\freq, ~lowcongaFreq);
	});
},105);




//////// Mid Conga ///////////////////


MIDIdef.noteOn(\midcongaON, {
	arg vel, nn;
	[vel, nn].postln;
	~midcongaamp = vel.linexp(0, 127, 0.01, 1);
	~midconga[nn] = Synth.new(\MC,
		[
			\amp, ~midcongaamp,
			\freq, ~midcongaFreq
		]
	);
},48);

MIDIdef.noteOff(\midcongaOFF, {
	arg nn;
	~midconga[nn]=nil;
},48);


MIDIdef.cc(\MCTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~midcongaFreq = val.linexp(0, 127, 250*0.7, 250*1.1);
	~midconga.do({
		arg mccc;
		mccc.set(\freq, ~midcongaFreq);
	});
},106);




//////// Hi Conga ///////////////////


MIDIdef.noteOn(\hicongaON, {
	arg vel, nn;
	[vel, nn].postln;
	~hicongaamp = vel.linexp(0, 127, 0.01, 1);
	~hiconga[nn] = Synth.new(\HC,
		[
			\amp, ~hicongaamp,
			\freq, ~hicongaFreq
		]
	);
},50);

MIDIdef.noteOff(\hicongaOFF, {
	arg nn;
	~hiconga[nn]=nil;
},50);

MIDIdef.cc(\HCTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~hicongaFreq = val.linexp(0, 127, 370*0.7, 370*1.2);
	~hiconga.do({
		arg hccc;
		hccc.set(\freq, ~hicongaFreq);
	});
},107);




//////// Claves ///////////////////


MIDIdef.noteOn(\clavesON, {
	arg vel, nn;
	[vel, nn].postln;
	~clavesamp = vel.linexp(0, 127, 0.01, 1);
	~claves[nn] = Synth.new(\claves,
		[
			\amp, ~clavesamp
		]
	);
},52);

MIDIdef.noteOff(\clavesOFF, {
	arg nn;
	~claves[nn]=nil;
},52);



//////// Hihat ////////////


MIDIdef.noteOn(\hihatON, {
	arg vel, nn;
	[vel, nn].postln;
	~champ = vel.linexp(0, 127, 0.1, 1.5);
	~hihat[nn] = Synth.new(\hat,
		[
			\amp, ~champ
		]
	);
},42);

MIDIdef.noteOff(\hihatOFF, {
	arg nn;
	~hihat[nn]=nil;
},42);



///////// Open Hihat ///////////////


MIDIdef.noteOn(\openhihatON, {
	arg vel, nn;
	[vel, nn].postln;
	~ohamp = vel.linexp(0, 127, 1, 6);
	~openhihat[nn] = Synth.new(\openhihat,
		[
			\amp, ~ohamp,
			\decay, ~ohdecay
		]
	);
},44);

MIDIdef.noteOff(\openhihatOFF, {
	arg nn;
	~openhihat[nn]=nil;
},44);

MIDIdef.cc(\OHDecay, {
	arg val, cnum;
	[val, cnum].postln;
	~ohdecay = val.linexp(0, 127, 0.1, 1);
	~openhihat.do({
		arg ohcc;
		ohcc.set(\decay, ~ohdecay);
	});
},108);



///////// Cymbal  /////////////


MIDIdef.noteOn(\cymbalON, {
	arg vel, nn;
	[vel, nn].postln;
	~cyamp = vel.linexp(0, 127, 1, 22);
	~cymbal[nn] = Synth.new(\cymbal,
		[
			\amp, ~cyamp,
			\decay, ~cydecay,
			\tone, ~cytone
		]
	);
},46);

MIDIdef.noteOff(\cymbalOFF, {
	arg nn;
	~openhihat[nn]=nil;
},46);

MIDIdef.cc(\CYTONE, {
	arg val, cnum;
	[val, cnum].postln;
	~cytone = val.linexp(0, 127, 0.005, 0.0002);
	~cymbal.do({
		arg cycc;
		cycc.set(\tone, ~cytone);
	});
},109);

MIDIdef.cc(\CYDecay, {
	arg val, cnum;
	[val, cnum].postln;
	~cydecay = val.linexp(0, 127, 0.5, 4);
	~cymbal.do({
		arg cycc;
		cycc.set(\decay, ~cydecay);
	});
},110);




////////////////////////////////////////GUI///////////////////////////////////////////




Window.closeAll;
~gui = Window("SC-808",
		Rect(
		Window.screenBounds.width/2-640,
		Window.screenBounds.height/2-360,
		1222.5,
		720
),false)
.front;


~gui.view.decorator_(FlowLayout(~gui.bounds, 700@227.5, 0@0));
~colorknobView = Array.fill(1, {
	arg view;
	view = CompositeView(~gui, 135@135);
	view.decorator_(FlowLayout(view.bounds, 0@0, 0@0));
});

Knob(~colorknobView[0], 135@135)
.color_(
	[
		Color.new(1, 0.45),
		Color.gray(0.85),
		Color.grey,
		Color.black
	]
)
.action_({
	arg obj;
	~red = obj.value.linlin(0, 1, 0.22, 0.27);
	~green = obj.value.linlin(0, 1, 0.22, 0.4);
	~blue = obj.value.linlin(0, 1, 0.22, 0.46);
	~gui.background_(Color.new(~red, ~green,~blue));
})
.valueAction_(0);

~gui.view.decorator.reset;

~gui.view.decorator_(FlowLayout(~gui.bounds, 435@395, 0@0));

~logo = Array.fill(1, {
	arg view;
	view = CompositeView(~gui, 480@50);
	view.decorator_(FlowLayout(view.bounds, 0@0, 0@0));
});

Array.fill(1, {
	StaticText(~logo[0], 155@50);
	StaticText(~logo[0], 200@50);
	StaticText(~logo[0], 105@45);
});

~logo[0].children[0]
.string_(\Rhythm)
.stringColor_(Color.new(1, 0.4))
.font_(Font(\Arial,40));

~logo[0].children[1]
.string_(\Composer)
.stringColor_(Color.new(1, 0.4))
.font_(Font(\Arial,40));

~logo[0].children[2]
.string_("SC-808")
.stringColor_(Color.new(1, 0.4))
.font_(Font(\Arial,30))
.align_(\bottomRight);

~gui.view.decorator.reset;

~gui.view.decorator_(FlowLayout(~gui.bounds, 660@455, 0@0));

~logo2 = Array.fill(1, {
	arg view;
	view = CompositeView(~gui, 240@30);
	view.decorator_(FlowLayout(view.bounds, 0@0, 0@0));
});
Array.fill(1, {
	StaticText(~logo2[0], 130@30);
	StaticText(~logo2[0], 110@30);
});

~logo2[0].children[0]
.string_(\SuperCollider)
.stringColor_(Color.gray(0.7))
.font_(Font(\Arial,20,true))
.align_(\center);

~logo2[0].children[1]
.string_(\Controlled)
.stringColor_(Color.gray(0.7))
.font_(Font(\Arial,20, true))
.align_(\center);

~gui.view.decorator.reset;

~gui.view.decorator_(FlowLayout(~gui.bounds, 111.25@80, 0@100));

~knobs = Array.fill(3, {
	arg view;
	view = CompositeView(~gui, 1000@50);
	view.decorator_(FlowLayout(view.bounds, 5@0, 12.5@0));
});

Array.fill(16, {
	Knob(~knobs[0], 50@50)
	.color_([
	Color(1, 0.45, 0),
	Color.gray(0.113, 0),
	Color.gray(0.113, 0),
	Color.black])
	.value_(0.5)
});

Array.fill(16,{
	Knob(~knobs[1], 50@50)
	.color_([
	Color.white,
	Color.gray(0.113, 0),
	Color.gray(0.113, 0),
	Color.black])
	.value_(0.5)
});

Array.fill(16,{
	Knob(~knobs[2], 50@50)
	.color_([
	Color.white,
	Color.gray(0.113, 0),
	Color.gray(0.113, 0),
	Color.black])
	.value_(0.5)
});

for(12, 8, {
	arg i;
	~knobs[1].children[i].remove;
});

for(10, 9, {
	arg i;
	~knobs[1].children[i].remove;
});

for(12, 2, {
	arg i;
	~knobs[2].children[i].remove;
});

~knobs[2].children[4].action_({
	arg obj, trans;
	~trans =obj.value.linlin(0, 1, 1, 0);
	~gui.background_(Color.new(~red, ~green,~blue,~trans));
})
.valueAction_(0);


~gui.view.decorator.reset;
~gui.view.decorator_(FlowLayout(~gui.bounds, 111.25@205, 0@125));

~knobslabels = Array.fill(2, {
	arg view;
	view = CompositeView(~gui, 1000@25);
	view.decorator_(FlowLayout(view.bounds, 0@0, 2.5@0));
});

16.do{
	arg i;
	var name;
	StaticText(~knobslabels[0], 60@25);
	name = List[
		\TONE, \TONE, \TUNE, \TUNE, \TUNE, \TUNE, \TUNE, \TUNE, \, \, \, \, \, \TONE, \, \
	];
	~knobslabels[0].children[i].string_(name.at(i)).stringColor_(Color.white).font_(Font(\Arial, 15, false)).align_(\center);
};

16.do{
	arg i;
	var name;
	StaticText(~knobslabels[1], 60@25);
	name = List[
		\DECAY, \SNAPPY, \, \, \, \, \, \, \, \, \, \, \, \DECAY, \DECAY, "?"
	];
	~knobslabels[1].children[i].string_(name.at(i)).stringColor_(Color.white).font_(Font(\Arial, 15, false)).align_(\center);
};
~gui.view.decorator.reset;

~gui.view.decorator_(FlowLayout(~gui.bounds, 111.25@485, 0@100));

~instruments = Array.fill(1, {
	arg view;
	view = CompositeView(~gui, 1000@40);
	view.decorator_(FlowLayout(view.bounds, 6.25@7.5, 12.5@0));
});

16.do{
	arg i;
	var name;
	StaticText(~instruments[0], 50@25).background_(Color.new(1, 0.96, 0.28, 0.8));
	name = List[
		\BD, \SD, \LT, \MT, \HT, \LC, \MC, \HC, \CL, \RS, \MA, \CP, \CB, \CY, \OH, \CH
	];
	~instruments[0].children[i].string_(name.at(i)).font_(Font(\Arial, 15, true)).align_(\center);
};

~gui.view.decorator.reset;

~gui.view.decorator_(FlowLayout(~gui.bounds, 101.25@575, 0@100));

~buttons = Array.fill(1, {
	arg view;
	view = CompositeView(~gui, 1020@75);
	view.decorator_(FlowLayout(view.bounds, 0@0, 20@0));
});

for(0, 3, {
	Button(~buttons[0], 45@75).states_([[nil, nil, Color.new(1, 0.13,0.13)]]);
});

for(4, 7, {
	Button(~buttons[0], 45@75).states_([[nil, nil, Color.new(1, 0.45)]]);
});

for(8, 11, {
	Button(~buttons[0], 45@75).states_([[nil, nil, Color.new(1, 0.88, 0.2)]]);
});

for(12, 15, {
	Button(~buttons[0], 45@75);
});
//
~gui.view.decorator.reset;


~gui.view.decorator_(FlowLayout(~gui.bounds, 102.25@575, 0@0));

~buttons2 = Array.fill(1, {
	arg view;
	view = CompositeView(~gui, 1019@25).alpha_(0);
	view.decorator_(FlowLayout(view.bounds, 0@0, 22@0));
});

for(0, 3, {
	arg i;
	Button(~buttons2[0], 43@25)
	.states_([["•", Color.black, Color.red(0.97)]])
	.font_(Font(\default, 25, true));
});

for(4, 7, {
	arg i;
	Button(~buttons2[0], 43@25)
	.states_([["•", Color.black, Color.new(1, 0.4)]])
	.font_(Font(\default, 25, true));
});

for(8, 11, {
	arg i;
	Button(~buttons2[0],43@25)
	.states_([["•", Color.black, Color.new(1, 0.85, 0.2)]])
	.font_(Font(\default, 25, true));
});

for(12, 15, {
	arg i;
	Button(~buttons2[0], 43@25)
	.states_([["•", Color.black, Color.gray(0.9)]])
	.font_(Font(\default, 25, true));
});

~gui.view.decorator.reset;

~gui.view.decorator_(FlowLayout(~gui.bounds, 111.25@449, 0@100));

~line1 = CompositeView(~gui, 1000@5)
.background_(Color.new(1, 0.4));

~gui.view.decorator.reset;

~gui.view.decorator_(FlowLayout(~gui.bounds, 111.25@543, 0@100));

~line2 = CompositeView(~gui, 1000@7)
.background_(Color.gray(0.7));





////////////////////////////////////////////GUI ACTIONS////////////////////////////////////////////





//////////////BD////////////////

~knobs[0].children[0].action_({
	arg obj;
	~bdamp = obj.value.linexp(0, 1, 1, 2.1);
	~bdGUI.do({
		arg amp;
		amp.set(\amp, ~bdamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[0].action_({
	arg obj;
	~toneBD = obj.value.linexp(0, 1, 50, 70);
	~bdGUI.do({
		arg tone;
		tone.set(\tone, ~toneBD);
	});
})
.valueAction_(0);

~knobs[2].children[0].action_({
	arg obj;
	~decaybd = obj.value.linlin(0, 1, 6, 110);
	~bdGUI.do({
		arg decay;
		decay.set(\decay, ~decaybd);
	});
})
.valueAction_(0.5);

~buttons[0].children[0].mouseDownAction_({
	~bdGUI = Synth.new(\bd,
		[
			\amp, ~bdamp,
			\decay, ~decaybd,
			\tone, ~toneBD,
			\gate, 1
		]
	);
	~buttons2[0].children[0].states = [["•", Color.red, Color.red(0.85)]];
})
.action_({
	~bdGUI = nil;
	~buttons2[0].children[0].states = [["•", Color.black, Color.red(0.97)]];
});



///////////SN////////////////

~knobs[0].children[1].action_({
	arg obj;
	~snamp = obj.value.linexp(0, 1, 0.5, 2.5);
	~snGUI.do({
		arg amp;
		amp.set(\amp, ~snamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[1].action_({
	arg obj;
	~tonesn = obj.value.linlin(0, 1, 340*0.62, 340*1.15);
	~tone2sn = obj.value.linlin(0, 1, 189*0.62, 189*1.15);
	~snGUI.do({
		arg tone;
		tone.set(\tone, ~tonesn, \tone2, ~tone2sn)
	});
})
.valueAction_(0.5);

~knobs[2].children[1].action_({
	arg obj;
	~snappy = obj.value.linlin(0, 1, 0.002, 0.45);
	~amp2SN = obj.value.linexp(0, 1, 1, 0.6);
	~snGUI.do({
		arg snappy;
		snappy.set(\snappy, ~snappy, \amp2, ~amp2SN)
	});
})
.valueAction_(0.5);

~buttons[0].children[1].mouseDownAction_({
	~snGUI = Synth.new(\sn,
		[
			\amp, ~snamp,
			\tone, ~tonesn,
			\tone2, ~tone2sn,
			\snappy, ~snappy,
			\amp2, ~amp2SN,
			\gate, 1
		]
	);
	~buttons2[0].children[1].states = [["•", Color.red, Color.red(0.85)]];
})
.action_({
	~snGUI = nil;
	~buttons2[0].children[1].states = [["•", Color.black, Color.red(0.97)]];
});

//////////LOW TOM/////////

~knobs[0].children[2].action_({
	arg obj;
	~lowtomamp = obj.value.linexp(0, 1, 0.1, 1.5);
	~lowtomGUI.do({
		arg amp;
		amp.set(\amp, ~lowtomamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[2].action_({
	arg obj;
	~lowtomFreq = obj.value.linlin(0, 1, 80*0.9, 80*1.25);
	~lowtomGUI.do({
		arg tone;
		tone.set(\freq, ~lowtomFreq)
	});
})
.valueAction_(0.5);

~buttons[0].children[2].mouseDownAction_({
	~lowtomGUI = Synth.new(\LT,
		[
			\freq, ~lowtomFreq,
			\amp, ~lowtomamp
		]
	);
	~buttons2[0].children[2].states = [["•", Color.red, Color.red(0.85)]];
})
.action_({
	~lowtomGUI = nil;
	~buttons2[0].children[2].states = [["•", Color.black, Color.red(0.97)]];
});

////////MID TOM////////////////

~knobs[0].children[3].action_({
	arg obj;
	~midtomamp = obj.value.linexp(0, 1, 0.1, 1.5);
	~midtomGUI.do({
		arg amp;
		amp.set(\amp, ~midtomamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[3].action_({
	arg obj;
	~midtomFreq = obj.value.linlin(0, 1, 120*0.65, 120*1.1);
	~midtomGUI.do({
		arg tone;
		tone.set(\freq, ~midtomFreq);
	});
})
.valueAction_(0.5);

~buttons[0].children[3].mouseDownAction_({
	~midtomGUI = Synth.new(\MT,
		[
			\freq, ~midtomFreq,
			\amp, ~midtomamp
		]
	);
	~buttons2[0].children[3].states = [["•", Color.red, Color.red(0.85)]];
})
.action_({
	~midtomGUI = nil;
	~buttons2[0].children[3].states = [["•", Color.black, Color.red(0.97)]];
});


//////HI TOM/////////

~knobs[0].children[4].action_({
	arg obj;
	~hitomamp = obj.value.linexp(0, 1, 0.1, 1.5);
	~hitomGUI.do({
		arg amp;
		amp.set(\amp, ~hitomamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[4].action_({
	arg obj;
	~hitomFreq = obj.value.linlin(0, 1, 165*0.7, 165*1.2);
	~hitomGUI.do({
		arg tone;
		tone.set(\freq, ~hitomFreq);
	});
})
.valueAction_(0.5);

~buttons[0].children[4].mouseDownAction_({
	~hitomGUI = Synth.new(\HT,
		[
			\freq, ~hitomFreq,
			\amp, ~hitomamp
		]
	);
	~buttons2[0].children[4].states = [["•", Color.red, Color.new(1, 0.3)]];
})
.action_({
	~hitomGUI = nil;
	~buttons2[0].children[4].states = [["•", Color.black, Color.new(1, 0.4)]];
});


//////////LOW Conga/////////

~knobs[0].children[5].action_({
	arg obj;
	~lowcongaamp = obj.value.linexp(0, 1, 0.1, 1.5);
	~lowcongaGUI.do({
		arg amp;
		amp.set(\amp, ~lowcongaamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[5].action_({
	arg obj;
	~lowcongaFreq = obj.value.linlin(0, 1, 165*0.7, 165*1.15);
	~lowcongaGUI.do({
		arg tone;
		tone.set(\freq, ~lowcongaFreq)
	});
})
.valueAction_(0.5);

~buttons[0].children[5].mouseDownAction_({
	~lowcongaGUI = Synth.new(\LC,
		[
			\freq, ~lowcongaFreq,
			\amp, ~lowcongaamp
		]
	);
	~buttons2[0].children[5].states = [["•", Color.red, Color.new(1, 0.3)]];
})
.action_({
	~lowcongaGUI = nil;
	~buttons2[0].children[5].states = [["•", Color.black, Color.new(1, 0.4)]];
});

////////MID Conga////////////////

~knobs[0].children[6].action_({
	arg obj;
	~midcongaamp = obj.value.linexp(0, 1, 0.1, 1.5);
	~midcongaGUI.do({
		arg amp;
		amp.set(\amp, ~midcongaamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[6].action_({
	arg obj;
	~midcongaFreq = obj.value.linlin(0, 1, 250*0.7, 250*1.1);
	~midcongaGUI.do({
		arg tone;
		tone.set(\freq, ~midcongaFreq);
	});
})
.valueAction_(0.5);

~buttons[0].children[6].mouseDownAction_({
	~midcongaGUI = Synth.new(\MC,
		[
			\freq, ~midcongaFreq,
			\amp, ~midcongaamp
		]
	);
	~buttons2[0].children[6].states = [["•", Color.red, Color.new(1, 0.3)]];
})
.action_({
	~midcongaGUI = nil;
	~buttons2[0].children[6].states =[["•", Color.black, Color.new(1, 0.4)]];
});


//////HI Conga/////////

~knobs[0].children[7].action_({
	arg obj;
	~hicongaamp = obj.value.linexp(0, 1, 0.1, 1);
	~hicongaGUI.do({
		arg amp;
		amp.set(\amp, ~hicongaamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[7].action_({
	arg obj;
	~hicongaFreq = obj.value.linlin(0, 1, 370*0.7, 370*1.2);
	~hicongaGUI.do({
		arg tone;
		tone.set(\freq, ~hicongaFreq);
	});
})
.valueAction_(0.5);

~buttons[0].children[7].mouseDownAction_({
	~hicongaGUI = Synth.new(\HC,
		[
			\freq, ~hicongaFreq,
			\amp, ~hicongaamp
		]
	);
	~buttons2[0].children[7].states = [["•", Color.red, Color.new(1, 0.3)]];
})
.action_({
	~hicongaGUI = nil;
	~buttons2[0].children[7].states = [["•", Color.black, Color.new(1, 0.4)]];
});



///////Claves//////////

~knobs[0].children[8].action_({
	arg obj;
	~clamp = obj.value.linexp(0, 1, 0.2, 1.5);
	~clGUI.do({
		arg amp;
		amp.set(\amp, ~clamp);
	});
})
.valueAction_(0.5);

~buttons[0].children[8].mouseDownAction_({
	~clGUI = Synth.new(\claves,
		[
			\amp, ~clamp
		]
	);
	~buttons2[0].children[8].states = [["•", Color.red, Color.new(1, 0.75, 0.2)]];
})
.action_({
	~clGUI = nil;
	~buttons2[0].children[8].states = [["•", Color.black, Color.new(1, 0.85, 0.2)]];
});


////////////Rim Shot///////////////

~knobs[0].children[9].action_({
	arg obj;
	~rsamp = obj.value.linexp(0, 1, 0.2, 1.2);
	~rimshotGUI.do({
		arg amp;
		amp.set(\amp, ~rsamp);
	});
})
.valueAction_(0.5);

~buttons[0].children[9].mouseDownAction_({
	~rimshotGUI = Synth.new(\rimshot,
		[
			\amp, ~rsamp
		]
	);
	~buttons2[0].children[9].states = [["•", Color.red, Color.new(1, 0.75, 0.2)]];
})
.action_({
	~rimshotGUI = nil;
	~buttons2[0].children[9].states = [["•", Color.black, Color.new(1, 0.85, 0.2)]];
});



/////////Maracas////////////

~knobs[0].children[10].action_({
	arg obj;
	~maracasamp = obj.value.linexp(0, 1, 0.1, 1.5);
	~maracasGUI.do({
		arg amp;
		amp.set(\amp, ~maracasamp);
	});
})
.valueAction_(0.5);

~buttons[0].children[10].mouseDownAction_({
	~maracasGUI = Synth.new(\maracas,
		[
			\amp, ~maracasamp,
			\gate, 1
		]
	);
	~buttons2[0].children[10].states = [["•", Color.red, Color.new(1, 0.75, 0.2)]];
})
.action_({
	~maracasGUI = nil;
	~buttons2[0].children[10].states = [["•", Color.black, Color.new(1, 0.85, 0.2)]];
});





/////////Clap///////////////

~knobs[0].children[11].action_({
	arg obj;
	~cpRawamp = obj.value.linexp(0, 1, 1.2, 5);
	~cpReverbamp = obj.value.linexp(0, 1, 1.2, 4.2);
	~clapRawGUI.do({
		arg amp;
		amp.set(\amp, ~cpRawamp);
	});
	~clapReverbGUI.do({
		arg amp;
		amp.set(\amp, ~cpReverbamp);
	});
})
.valueAction_(0.5);

~buttons[0].children[11].mouseDownAction_({
	~clapRawGUI = Synth.new(\cpRaw,
		[
			\amp, ~cpRawamp,
			\gate, 1
		]
	);
	~clapReverbGUI = Synth.new(\cpReverb,
		[
			\amp, ~cpReverbamp,
			\gate, 1
		]
	);
	~buttons2[0].children[11].states = [["•", Color.red, Color.new(1, 0.75, 0.2)]];
})
.action_({
	~clapRawGUI = nil;
	~clapReverbGUI = nil;
	~buttons2[0].children[11].states = [["•", Color.black, Color.new(1, 0.85, 0.2)]];
});




////////Cow Bell/////////////

~knobs[0].children[12].action_({
	arg obj;
	~cbamp = obj.value.linexp(0, 1, 0.05, 0.3);
	~cowbellGUI.do({
		arg amp;
		amp.set(\amp, ~cbamp);
	});
})
.valueAction_(0.5);

~buttons[0].children[12].mouseDownAction_({
	~cowbellGUI = Synth.new(\cowbell,
		[
			\amp, ~cbamp
		]
	);
	~buttons2[0].children[12].states = [["•", Color.red, Color.gray(0.8)]];
})
.action_({
	~cowbellGUI = nil;
	~buttons2[0].children[12].states = [["•", Color.black, Color.gray(0.9)]];
});


/////Cymbal////////

~knobs[0].children[13].action_({
	arg obj;
	~cyamp = obj.value.linexp(0, 1, 5, 22);
	~cymbalGUI.do({
		arg amp;
		amp.set(\amp, ~cyamp);
	});
})
.valueAction_(0.5);

~knobs[1].children[8].action_({
	arg obj;
	~cytone = obj.value.linexp(0, 1, 0.005, 0.0002);
	~cymbalGUI.do({
		arg tone;
		tone.set(\tone, ~cytone);
	});
})
.valueAction_(0.5);

~knobs[2].children[2].action_({
	arg obj;
	~cydecay = obj.value.linexp(0, 1, 0.5, 4);
	~cymbalGUI.do({
		arg decay;
		decay.set(\decay, ~cydecay);
	});
})
.valueAction_(0.5);

~buttons[0].children[13].mouseDownAction_({
	~cymbalGUI = Synth.new(\cymbal,
		[
			\amp, ~cyamp,
			\decay, ~cydecay,
			\tone, ~cytone
		]
	);
	~buttons2[0].children[13].states = [["•", Color.red, Color.gray(0.8)]];
})
.action_({
	~cymbalGUI = nil;
	~buttons2[0].children[13].states = [["•", Color.black, Color.gray(0.9)]];
});




/////Open Hihat////////


~knobs[0].children[14].action_({
	arg obj;
	~ohamp = obj.value.linexp(0, 1, 4, 6);
	~openhihatGUI.do({
		arg amp;
		amp.set(\amp, ~ohamp);
	});
})
.valueAction_(0.5);

~knobs[2].children[3].action_({
	arg obj;
	~ohdecay = obj.value.linexp(0, 1, 0.1, 1);
	~openhihatGUI.do({
		arg decay;
		decay.set(\decay, ~ohdecay);
	});
})
.valueAction_(0.5);

~buttons[0].children[14].mouseDownAction_({
	~openhihatGUI = Synth.new(\openhihat,
		[
			\amp, ~ohamp,
			\decay, ~ohdecay
		]
	);
	~buttons2[0].children[14].states = [["•", Color.red, Color.gray(0.8)]];
})
.action_({
	~openhihatGUI = nil;
	~buttons2[0].children[14].states = [["•", Color.black, Color.gray(0.9)]];
});



/////Close Hihat////////


~knobs[0].children[15].action_({
	arg obj;
	~champ = obj.value.linexp(0, 1, 0.3, 3.5);
	~closehihatGUI.do({
		arg amp;
		amp.set(\amp, ~champ);
	});
})
.valueAction_(0.5);

~buttons[0].children[15].mouseDownAction_({
	~closehihatGUI = Synth.new(\hat,
		[
			\amp, ~champ
		]
	);
	~buttons2[0].children[15].states = [["•", Color.red, Color.gray(0.8)]];
})
.action_({
	~closehihatGUI = nil;
	~buttons2[0].children[15].states = [["•", Color.black, Color.gray(0.9)]];
});
)
