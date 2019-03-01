BusPlug.defaultReshaping = \elastic;

// Définition des "nodes" dans le serveur qui vont accueillir les modules
// 1 Ndef par "module" de synthé modulaire
// chaque Ndef joue dès qu'il est créé, mais on ne l'entend sur les enceintes de monitoring
// que si on Ndef(\bla).play

(
Ndef(\osc01, {
	SinOsc.ar(freq: \freq.kr(220), phase: \phase.kr(0));
});

Ndef(\env01, {
	EnvGen.ar(envelope: Env.asr(), gate: \gate.kr(0)) * \in.ar;
});

Ndef(\seq01_gate, {
	Impulse.kr(freq: \freq.kr(1));
});

Ndef(\seq01_freq, {
	Duty.kr(dur: Dseq(list: [0.5, 1], repeats: inf), level: Dseq([290, 440], inf));
});
)

// on écoute la sortie de l'enveloppe, mais comme rien n'est connecté à rien, on n'entend rien
Ndef(\env01).play;

// on connecte :
// seq01_gate au gate de l'enveloppe env01
// osc01 à l'entrée "in" de l'enveloppe
// seq01_freq à l'entrée "freq" de l'oscillateur osc01

(
Ndef(\env01) <<>.gate Ndef(\seq01_gate);
Ndef(\env01) <<>.in Ndef(\osc01);
Ndef(\osc01) <<>.freq Ndef(\seq01_freq);
)

// on change la fréquence du séquenceur à 2 hz
Ndef(\seq01_gate).set(\freq, 0.5);

// on change la fréquence de l'oscillateur à 330 hz
Ndef(\osc01).set(\freq, 330);

// plus sioux, on fait jouer un pattern à l'oscillateur osc01
// dur est un paramètre du pbind, pas de osc01 !

(
Ndef(\osc01).set(\freq, nil);
Ndef(\osc01)[1]=\set->Pbind(
	\dur, Pseq(list: [0.25, 0.25], repeats: inf),
	\freq, Pseq(list: [300, 400], repeats: inf)
);
)

// stop
Ndef(\env01).stop;

// on efface tout
Ndef.clear;

// changeons la mélodie via le séquenceur
Ndef(\seq01_freq, {
	Duty.kr(dur: Dseq(list: [0.25, 0.25, 0.5, 1], repeats: inf), level: Dseq([40, 42, 44, 46, 48].midicps * 2, inf));
});

// ou directement au niveau de l'oscillo
(
Ndef(\osc01).set(\freq, nil);
Ndef(\osc01)[1]=\set->Pbind(
	\dur, 1,
	\degree, Prand([0, 2, 4], inf),
	\scale, Scale.major,
	\root, 2
);
)

// maintenant on change le synthé en lui-même
Ndef(\osc01).fadeTime = 5;

(
Ndef(\osc01)[0] = {
	var freq = \freq.kr(220);
	var signal = 0;
	50.do( { |i|
		// signal = signal + (Saw.ar(freq + Rand(-freq/100, freq/100)) / i * -10.dbamp);
		signal = signal + (LFPulse.ar(
			freq: freq * (i+1) + Rand((freq/100).neg, freq/100),
			iphase: Rand(0, 1),
			width: Rand(0.01,1)
	) / (i+1) * -10.dbamp);
	});
	signal;
};
)