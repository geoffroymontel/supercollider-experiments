(
SynthDef.new(\fantasy, {
    arg freq=440, timbre=0.5;
    var env;
    env = EnvGen.kr(Env.linen(0.1, 0.1, 4));

    Out.ar(0,     (SinOsc.ar(
        freq: SinOsc.ar(5, mul: 50) + freq + SinOsc.ar(
            freq: freq!2,
            mul: env * 4.5*freq
        ),
        mul: 1
    ) + SinOsc.ar(
        freq: freq/2 +  SinOsc.ar(
            freq: freq/2,
            mul:  SinOsc.ar(
                freq: freq/4,
                mul:   SinOsc.ar(
                    freq: freq/4,
                    mul: env * 34 * freq
                )
            )
        ),
        mul: 1
    ) + SinOsc.ar(freq/4)) * env
    );
}).add;
)

(
SynthDef.new(\metalpiano, {
	arg freq, dur;
	var env, env2;
    env = EnvGen.kr(Env.linen(0.1, 0.1, dur));
    env2 = EnvGen.kr(Env.linen(0.01, 0.1, dur));
	Out.ar(0, SinOsc.ar(
		freq: freq + SinOsc.ar(
			freq: freq + SinOsc.ar(3*freq, mul: env*3*freq),
			mul: env2*4.545454*freq
		),
		mul: env2
	) + SinOsc.ar(
		freq: freq +SinOsc.ar(
			freq: freq + 100 + SinOsc.ar(3*freq, mul: env*3*freq),
			mul: env2*4.545454*freq
		),
		mul: env2
	))
}).add
)

(
SynthDef.new(\metalpiano2, {
	arg freq, dur;
	var env, env2;
    env = EnvGen.kr(Env.linen(0.1, 0.1, dur));
    env2 = EnvGen.kr(Env.linen(0.01, 0.1, dur));
	Out.ar(0, SinOsc.ar(
		freq: freq + SinOsc.ar(
			freq: freq + SinOsc.ar(3*freq, mul: env*3*freq),
			mul: env2*4.545454*freq
		),
		mul: env2
	) + SinOsc.ar(
		freq: freq +SinOsc.ar(
			freq: freq + 1000 + SinOsc.ar(3*freq, mul: env*3*freq),
			mul: env2*4.545454*freq
		),
		mul: env2
	))
}).add
)

(
SynthDef.new(\strings, {
	arg freq, dur;
	var env, env2;
    env = EnvGen.kr(Env.linen(0.1, 0.1, dur));
    env2 = EnvGen.kr(Env.linen(1, 0.1, dur));
	Out.ar(0, SinOsc.ar(
		freq: freq + SinOsc.ar(
			freq: 2*freq + SinOsc.ar(3*freq, mul: env*3*freq),
			mul: env2*freq
		),
		mul: env2
	) + SinOsc.ar(
		freq: freq +SinOsc.ar(
			freq: 2*freq + 10 + SinOsc.ar(3*freq, mul: env*3*freq),
			mul: env2*freq
		),
		mul: env2
	))
}).add
)

(
SynthDef.new(\coolpiano, {
	arg freq, dur;
	var env, env2;
    env = EnvGen.kr(Env.linen(0.1, 0.1, dur));
    env2 = EnvGen.kr(Env.linen(0.01, 0.1, dur));
	Out.ar(0, SinOsc.ar(
		freq: freq + SinOsc.ar(
			freq: freq + SinOsc.ar(3*freq, mul: env*3*freq),
			mul: env2*4.545454*freq
		),
		mul: env2
	) )
}).add
)
(
SynthDef.new(\coolpiano2, {
	arg freq, dur;
	var env, env2;
    env = EnvGen.kr(Env.linen(0.01, 0.1, dur));
    env2 = EnvGen.kr(Env.linen(0.01, 0.01, dur));
	Out.ar(0, SinOsc.ar(
		freq: freq + SinOsc.ar(
			freq: freq,
			mul: env2*freq
		),
		mul: env2
	) )
}).add
)

Synth(\coolpiano, [freq: 440, dur: 1]);


(
SynthDef.new(\bass, {
	arg carHz=440, modHz=110;
	var car, mod, env, carEnv;
	env = EnvGen.kr(Env.linen(0.01, 0.1, 1, 3), doneAction: 2);
	carEnv = EnvGen.kr(Env.linen(0.01, 0.1, 1), doneAction: 2);
	//env = EnvGen.kr(Env.adsr(0.01, 0.2, 0.5, 1), doneAction: 2);
	//env = EnvGen.kr(Env.perc(0.01, 2), doneAction:4);
	mod = SinOsc.ar(freq: modHz, mul: carEnv*2000);
	car = SinOsc.ar(freq: (carHz + mod)!2 ) * env;
	Out.ar(0, car);
}).add
)
(
SynthDef.new(\bell, {
	arg freq=440;
	var car, mod, env, carEnv;
	env = EnvGen.kr(Env.linen(0.01, 0.1, 1, 3), doneAction: 2);
	carEnv = EnvGen.kr(Env.linen(0.01, 0.1, 1), doneAction: 2);
	//env = EnvGen.kr(Env.adsr(0.01, 0.2, 0.5, 1), doneAction: 2);
	//env = EnvGen.kr(Env.perc(0.01, 2), doneAction:4);
	mod = SinOsc.ar(freq: freq/4, mul: carEnv*40);
	car = SinOsc.ar(freq: (freq + mod)!2 ) * env;
	Out.ar(0, car);
}).add
)

(
SynthDef.new(\magicpiano, {
	arg freq, dur;
	var env;
	env = EnvGen.kr(Env.linen(0.01, 0.1, dur, 1, 'sine'));

	Out.ar(0, SinOsc.ar(
		freq: freq + SinOsc.ar(
			freq: freq,
			mul: SinOsc.ar(
				freq: freq/2,
				mul:  env*2000
			)
		)!2,
		mul: env
	) + SinOsc.ar(
		freq: freq + SinOsc.ar(
			freq: freq,
			mul: SinOsc.ar(
				freq: freq/2 + freq*4,
				mul:  env*2000
			)
		)!2,
		mul: env
	)
	)
}).add;
)

(
SynthDef.new(\magnetic, {
	arg freq, dur;
	var env, env2;
	env = EnvGen.kr(Env.linen(0.01, dur, 1, 1, 'lin'));
	//env = EnvGen.kr(Env.triangle(dur));
	env2 = EnvGen.kr(Env.linen(3, 0.1, dur, 1, 'lin'));
	Out.ar(0, SinOsc.ar(
		freq: freq/8 + SinOsc.ar(
			freq: freq,
			mul: SinOsc.ar(
				freq: freq/8,
				mul:  SinOsc.ar(
					freq: freq/4,
					mul: (env)*2000
				)
			)
		)!2,
		mul: env2
	) + SinOsc.ar(
		freq: freq/8 + SinOsc.ar(
			freq: freq/2,
			mul: SinOsc.ar(
				freq: freq/8,
				mul:  SinOsc.ar(
					freq: freq/4,
					mul: (env2)*2000
				)
			)
		)!2,
		mul: env2
	));
}).add
)


(
SynthDef.new(\retro, {
	arg freq, dur;
	var env = EnvGen.kr(Env.linen(0.05, 0.1, dur));

	Out.ar(0, SinOsc.ar(
		freq: 220 + SinOsc.ar(
			freq: 220,
			mul: SinOsc.ar(
				freq: 110,
				mul:  SinOsc.ar(
					freq: 550,
					mul: 2000
				)
			)
		)!2,
		mul: env
	) + SinOsc.ar(
		freq: 222 + SinOsc.ar(
			freq: 223,
			mul: SinOsc.ar(
				freq: 110,
				mul:  SinOsc.ar(
					freq: 550,
					mul: 2000
				)
			)
		)!2,
		mul: env
	))
}).add
)
(
SynthDef.new(\blast, {
	arg freq, dur;
	var env = EnvGen.kr(Env.linen(0.01, 0.01, dur));
	Out.ar(0, SinOsc.ar(
		freq: freq/2 + SinOsc.ar(
			freq: freq/2,
			mul: SinOsc.ar(
				freq: freq/4,
				mul:  SinOsc.ar(
					freq: (freq/8)*env*20,
					mul: env*20000
				)
			)
		)!2,
		mul: env
	) );
}).add
)
(
SynthDef.new(\spacebell, {
	arg freq, dur;
	var env = EnvGen.kr(Env.linen(0.01, 0.01, dur));
	Out.ar(0, SinOsc.ar(
		freq: freq/2 + SinOsc.ar(
			freq: freq/2,
			mul: SinOsc.ar(
				freq: freq/4,
				mul:  SinOsc.ar(
					freq: (freq/8)*env*100,
					mul: env*20000
				)
			)
		)!2,
		mul: env
	) );
}).add
)
Synth(\blast, [\freq: 440, \dur, 4]);
Synth(\retro, [\freq: 440, \dur, 2]);
Synth(\magnetic, [\freq: 440, \dur, 2]);
Synth(\magicpiano, [\freq: 440, \dur, 2]);
Synth(\bass, [\freq: 220], 1);
Synth(\fantasy, [freq: 440]);
Synth(\coolpiano, [freq: 440, dur: 2]);
Synth(\coolpiano2, [freq: 440, dur: 2]);
Synth(\metalpiano, [freq: 440, dur: 2]);
Synth(\metalpiano2, [freq: 440, dur: 1]);
Synth(\strings, [freq: 440, dur: 2]);
Synth(\bell, [\freq: 440], 1);
Synth(\spacebell, [\freq: 440, \dur, 4]);

(
Pbind(
    \instrument, \fantasy,
    \freq, [440,334],
    \dur, 10
).play;
)


// 2 op
({
	SinOsc.ar(
		freq: 440 + SinOsc.ar(
			freq: 440 + SinOsc.ar(1320, mul: MouseY.kr(1, 1320, 1)),
			mul: MouseX.kr(1, 2000, 1)
		)!2,
		mul: 1
	)
}.play)

// 3 op
({
	SinOsc.ar(
		freq: 220 + SinOsc.ar(
			freq: 220,
			mul: SinOsc.ar(
				freq: 440,
				mul:  MouseX.kr(1, 2000, 1)
			)
		)!2,
		mul: 1
	)
}.play)

// 4 op
({
	SinOsc.ar(
		freq: 55 + SinOsc.ar(
			freq: 440,
			mul: SinOsc.ar(
				freq: 55,
				mul:  SinOsc.ar(
					freq: 110,
					mul: MouseX.kr(1, 2000, 1)
				)
			)
		)!2,
		mul: 1
	)
}.play)

// 4 op
// notamment au max à droite
({
	SinOsc.ar(
		freq: 220 + SinOsc.ar(
			freq: 220,
			mul: SinOsc.ar(
				freq: 110,
				mul:  SinOsc.ar(
					freq: 55*MouseX.kr(1, 20, 1),
					mul: MouseX.kr(1, 20000, 1)
				)
			)
		)!2,
		mul: 1
	) + SinOsc.ar(
		freq: 220 + SinOsc.ar(
			freq: 222,
			mul: SinOsc.ar(
				freq: 110,
				mul:  SinOsc.ar(
					freq: 55*MouseX.kr(1, 20, 1).poll,
					mul: MouseX.kr(1, 20000, 1).poll
				)
			)
		)!2,
		mul: 1
	)
}.play)

({
	SinOsc.ar(
		freq: 440 + SinOsc.ar(
			freq: 440,
			mul: MouseX.kr(1, 2000, 1)
		)!2,
		mul: 1
	)
}.play)


