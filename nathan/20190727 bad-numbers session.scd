(
w=1;h=0.5;q=0.25;e=0.125;t=1/3;
c = TempoClock.default;
)

c.tempo = 1.8;

(
SynthDef(\dm_kick_1,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmlevel = 0.5, noiselevel = 0.5, thumplevel=0.5,revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmenvatttime=0.001,fmenvattcurve=0,fmenvdectime=0.1,fmenvdeccurve=0.3,
		noiseenvatttime=0.001,noiseenvattcurve=1,noiseenvdectime=0.1,noiseenvdeccurve=0.3,
		thumpenvatttime=0.001,thumpenvattcurve=1,thumpenvdectime=0.1,thumpenvdeccurve=0.3,
		fm1freq=292,fm2freq=838,fm3freq=393,fm1amt = 0.8,fm2amt=0.8,fmenvtofreq=0,
		noiselpf=20000,noisehpf=400,thumpenvtofreq=1,thumpcutoffmin=80,thumpcutoffmax=300,thumpfreqmultiplier=25,thumpfreqoffset=18|
		var audio, switch, fmenv, fm1, fm2, fm3, noise, noiseenv, thump, thumpenv;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmenv = Env([0,1,0],[fmenvatttime,fmenvdectime],[fmenvattcurve,fmenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmlevel);
		fm1 = SinOsc.ar(fm1freq) * fm1amt.clip(0,1);
		fm2 = SinOsc.ar(fm2freq * fm1.exprange(0.1,10)) * fm2amt.clip(0,1);
		fm3 = SinOsc.ar(fm3freq * (fmenv * fmenvtofreq + 1) * fm2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvatttime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		thumpenv = Env([0,1,0],[thumpenvatttime,thumpenvdectime],[thumpenvattcurve,thumpenvdeccurve]).kr(Done.none, t_trig, 1, amp * thumplevel);
		thump = Mix((1..5).collect({
			|num|
			SinOsc.ar(0, Phasor.ar(t_trig, (thumpfreqmultiplier * num * 2 * pi + thumpfreqoffset) * (thumpenv * thumpenvtofreq + 1)/SampleRate.ir, 0, 2*pi));
		}));
		thump = LPF.ar(thump, thumpenv * (thumpcutoffmax - thumpcutoffmin) + thumpcutoffmin);
		audio = (fm3 * fmenv) + noise + (thump * thumpenv);
		audio = (audio * boost).tanh * attenuation;
		audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
SynthDef(\dm_snare_1,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmAlevel=0.5,fmBlevel=0.5,fmAfreqscale=1,fmBfreqscale=1,noiselevel=0.5,revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmAenvatttime=0.001,fmAenvattcurve=0,fmAenvdectime=0.1,fmAenvdeccurve= -3,
		fmA1freq=292,fmA2freq=838,fmA3freq=393,fmA1amt = 0.8,fmA2amt=0.8,
		fmBenvatttime=0.001,fmBenvattcurve=0,fmBenvdectime=0.1,fmBenvdeccurve= -3,
		fmB1freq=292,fmB2freq=838,fmB3freq=393,fmB1amt = 0.8,fmB2amt=0.8,
		noiseenvatttime=0.001,noiseenvattcurve=0,noiseenvdectime=0.1,noiseenvdeccurve= -3,
		noiselpf=20000,noisehpf=400,fmenvtofreq=0|
		var audio, switch, fmAenv, fmBenv, fmA1, fmA2, fmA3, fmB1, fmB2, fmB3, noise, noiseenv;
		fmA1freq = fmA1freq * fmAfreqscale;fmA2freq = fmA2freq * fmAfreqscale;fmA3freq = fmA3freq * fmAfreqscale;
		fmB1freq = fmB1freq * fmBfreqscale;fmB2freq = fmB2freq * fmBfreqscale;fmB3freq = fmB3freq * fmBfreqscale;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmAenv = Env([0,1,0],[fmAenvatttime,fmAenvdectime],[fmAenvattcurve,fmAenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmAlevel);
		fmA1 = SinOsc.ar(fmA1freq) * fmA1amt.clip(0,1);
		fmA2 = SinOsc.ar(fmA2freq * fmA1.exprange(0.1,10)) * fmA2amt.clip(0,1);
		fmA3 = SinOsc.ar(fmA3freq * (fmAenv * fmenvtofreq + 1) * fmA2.exprange(0.1,10));
		fmBenv = Env([0,1,0],[fmBenvatttime,fmBenvdectime],[fmBenvattcurve,fmBenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmBlevel);
		fmB1 = SinOsc.ar(fmB1freq) * fmB1amt.clip(0,1);
		fmB2 = SinOsc.ar(fmB2freq * fmB1.exprange(0.1,10)) * fmB2amt.clip(0,1);
		fmB3 = SinOsc.ar(fmB3freq * (fmBenv * fmenvtofreq + 1) * fmB2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvatttime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		audio = (fmA3 * fmAenv) + (fmB3 * fmBenv) + noise;
		audio = (audio * boost).tanh * attenuation;
		audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
SynthDef(\dm_hat_1,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmlevel = 0.5, fmfreqscale=1,noiselevel = 0.5, revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmenvatttime=0.001,fmenvattcurve=0,fmenvdectime=0.1,fmenvdeccurve= -3,
		noiseenvattime=0.001,noiseenvattcurve=0,noiseenvdectime=0.1,noiseenvdeccurve= -3,
		fm1freq=292,fm2freq=838,fm3freq=393,fm1amt = 0.8,fm2amt=0.8,
		noiselpf=20000,noisehpf=400|
		var audio, switch, fmenv, fm1, fm2, fm3, noise, noiseenv;
		fm1freq = fm1freq * fmfreqscale;fm2freq = fm2freq * fmfreqscale;fm3freq = fm3freq * fmfreqscale;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmenv = Env([0,1,0],[fmenvatttime,fmenvdectime],[fmenvattcurve,fmenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmlevel);
		fm1 = SinOsc.ar(fm1freq) * fm1amt.clip(0,1);
		fm2 = SinOsc.ar(fm2freq * fm1.exprange(0.1,10)) * fm2amt.clip(0,1);
		fm3 = SinOsc.ar(fm3freq * fm2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvattime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		audio = (fm3 * fmenv) + (noise * noiseenv);
		audio = (audio * boost).tanh * attenuation;
		audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
)

(
x = ();
x.kick = (fmenvtofreq: 0.84301443935562, fm1freq: 66.936911237538 , fm1amt: 0.45445999503136, attenuation: 0.48709431290627, fmenvdeccurve: -3.4705626964569, noiseenvatttime:  0.001, noisehpf: 1216.2510825656, fmlevel: 0.64498054981232, noiselevel: 1.0, thumpenvtofreq: 0.01, fmenvdectime: 0.46091017920677, revlevel: 0.11377695947886, noiseenvdeccurve:  -4.2204939574003, fm2freq: 67.868102987223, noiselpf: 641.74907911448, noiseenvdectime: 0.17291889061929, thumpenvdectime: 0.31239662455794, fm3freq: 54.503187098784, thumplevel: 0.89491975307465, thumpfreqoffset: 14.256193637848, fm2amt: 0.39919656515121, thumpenvdeccurve: -2.8920954465866, boost: 7.6384646402227, thumpfreqmultiplier: 20.764670372009);
x.snare = (fmBlevel: 0.5691534280777, fmBenvdectime: 0.42162063529255, noiseenvdeccurve: -3.1634406745434, fmB3freq: 52.761794594116, revlevel: 0.21827705204487, noiseenvdectime: 0.16483261986227, fmA1freq: 79.288526923351, fmenvtofreq: 0.54319637188263, fmA1amt: 0.37440413236618, fmAlevel: 1.0, fmA2amt: 0.6152748465538, fmBfreqscale: 0.98900905731381, fmB2amt: 0.8813049197197, fmAenvdeccurve: -3.196610212326, noiselevel: 0.31535694003105, boost: 7.0578825841309, fmB1amt: 0.56244814395905, fmAfreqscale: 1.0746760673385, fmB2freq: 110.54529292188, fmA2freq: 565.27860481307, noiseenvatttime: 0.001, attenuation: 0.71783000230789, fmBenvdeccurve: -5.0, fmB1freq: 810.86934232895, fmA3freq:112.80282065261, fmAenvdectime: 0.095404835883226);
x.hat = (fm1amt: 0.79910409450531, fmfreqscale: 16, noiselpf: 20000.0, fmlevel: 0.05096410214901, noisehpf: 200.0, revroomsize: 0.72707033157349, fm2freq: 61.625580364668, boost: 16.219775393639, attenuation: 0.39416718482971, fmenvdeccurve: -4.8314886726439, noiseenvdectime: 0.25306500766073, fm1freq: 666.66175777091, fm3freq: 177.3147486951, fmenvatttime: 0.0038490585894402, noiseenvatttime: 0.001074538264072, noiseenvdeccurve: -2.5217714905739, fm2amt: 0.85377413034439, noiselevel: 1.0, fmenvdectime: 0.56585919245966, revlevel: 0.48780202865601);
)

(
Pdef(\kick,
	Pmono(\dm_kick_1,
		\velocity, Pseq([100,0,80,0, 0,0,0,0, 100,0,80,0, 0,0,0,0],inf) * 0.01 * Pgauss(1,0.1,inf),
		\amp, Pkey(\velocity) / 10,
		\trig, Pif(Pkey(\amp) > 0, 1, 0),
		\dur, q,
		\timingOffset, Pseg(Pseq([0,0.05],inf),Pseq([h,h],inf),\sine,inf)
	)
);
Pdef(\snare,
	Pmono(\dm_snare_1,
		\velocity, Pseq([0,10,0,10, 100,0,0,10, 0,10,0,10, 100,10, 25,10,16,12, 30,14,22,16],inf) * 0.01 * Pgauss(1,0.1,inf),
		\amp, Pkey(\velocity) / 10,
		\trig, Pif(Pkey(\amp) > 0, 1, 0),
		\dur, Pseq([q,q,q,q, q,q,q,q, q,q,q,q, q,q, q/4,q/4,q/4,q/4, q/4,q/4,q/4,q/4],inf),
		\timingOffset, Pseg(Pseq([0,0.05],inf),Pseq([h,h],inf),\sine,inf)
	)
);
Pdef(\hat,
	Pmono(\dm_hat_1,
		\velocity, Pseq([9,4,81,4, 81,4,25,16, 81,4,64,4, 9,4,25,4,],inf) * 0.01 * Pgauss(1,0.1,inf),
		\amp, Pkey(\velocity) / 10,
		\trig, Pif(Pkey(\amp) > 0, 1, 0),
		\dur, q,
		\timingOffset, Pseg(Pseq([0,0.05],inf),Pseq([h,h],inf),\sine,inf)
	)
);
[\kick,\snare,\hat].do({|pat|Pdef(pat).play(protoEvent: x[pat]);});
)
[\kick,\snare,\hat].do({|pat|Pdef(pat).stop;});