// http://sccode.org/1-5dl
(
SynthDef(\pm4, {

	var numops = 4;
	var fb = LocalIn.ar(numops);

	var gate = \gate.kr(1);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.000));
	var detunehz = \detunehz.kr(0);
	var vel = \vel.kr(1);

	var car = numops.collect({arg i;
		var num = i+1;
		var ratio = ('op' ++ num ++ 'ratio').asSymbol;
		var curve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
		var atk = ('op' ++ num ++ 'atk').asSymbol.kr(0.01);
		var dec = ('op' ++ num ++ 'dec').asSymbol.kr(0.01);
		var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
		var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1);
		var env = Env.adsr(
			attackTime:atk,
			decayTime:dec,
			sustainLevel:suslevel,
			releaseTime:rel,
			curve:curve
		).kr(gate:gate);

		[freq * ratio.kr(1) + Rand(detunehz.neg, detunehz), env]
	});

	var mods = numops.collect({arg i;
		var y = i + 1;
		numops.collect({arg j;
			var x = j + 1;
			var key = ('m' ++ y ++ '_' ++ x).asSymbol;
			key.kr(0);
		});
	});

	var sig = numops.collect({arg i;
		var num = i+1;
		var freq = car[i][0].clip(20, 20000);
		var index = mods[i];
		var mod = (fb * index).sum;
		var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
		var coef = ('op' ++ num ++ 'coef').asSymbol.kr(0.5).clip(-1, 1);
		sig = OnePole.ar(sig, coef);
		sig;
	});

	sig = LeakDC.ar(sig);

	LocalOut.ar(sig);

	// set output level
	sig = sig * numops.collect({arg i;
		var num = i + 1;
		var key = ('op' ++ num).asSymbol;
		key.kr(1);
	}).normalizeSum;

	// set panning
	sig = numops.collect({arg i;
		var num = i + 1;
		var key = ('op' ++ num ++ 'pan').asSymbol;
		Pan2.ar(sig[i],	key.kr(0),	1)
	}).sum;

	sig = BLowPass.ar(
		BHiPass.ar(sig,
			\hpf.kr(20).clip(20, 18000),
			\hpfres.kr(0).linlin(0, 1, 1, 0.001)
		),
		\lpf.kr(20000).clip(20, 20000),
		\lpfres.kr(0).linlin(0, 1, 1, 0.001)
	);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.1) * vel;
	sig = sig.softclip;
	DetectSilence.ar(sig, doneAction:Done.freeSelf);

	Out.ar(\out.kr(0), sig);

}).add;
)

(
Ndef(\verb).play;
Ndef(\verb).filter(1, {arg in;
	var sig = HPF.ar(in, 220);
	FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.5);
}).set(\wet1, 0.4);

Pdef(\pm4, Pbind(
	\instrument, \pm4,
	\out, Pfunc({Ndef(\verb).bus}),
	\detunehz, 1,
	\vdepth, 0.003,

	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,

	// melody
	\scale, Scale.dorian,
	\degree, Pshuf([-1, 0, 2, 4, 6, 7], inf),
	\octave, Pbjorklund(5, 8).linlin(0, 1, 3, Pseq([4, 5], inf)),

	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),

	//////////////////////////////
	// operator 1
	\op1, 1,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.1,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Pwhite(-0.3, 0.3),

	// operator 2
	\op2, 0.3,
	\op2ratio, 2,
	\op2atk, 0.01,
	\op2dec, 0.1,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.3,
	\op2pan, Pwhite(-0.3, 0.3),

	// operator 3
	\op3, 0,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 4,
	// one-pole coefficient
	\op3coef, 0.5,
	\op3pan, 0,

	// operator 4
	\op4, 0,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.1,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.7,
	\op4pan, 0,

	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, 0.01pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0pi,
	\m1_4, 0pi,

	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,

	\m3_1, 0pi,
	\m3_2, 0pi,
	\m3_3, 0pi, //feedback
	\m3_4, 0.3pi,

	\m4_1, 1pi,
	\m4_2, 0.1pi,
	\m4_3, 1pi,
	\m4_4, 0.5pi, //feedback

	\lpf, 2000,
	\hpf, 80
));

Pdef(\pm4).play;
)