(
~root = -13;
~revSend = Bus.audio(s, 2);
)
(
s.waitForBoot(
	{

		SynthDef(\bell, {
			|
			freq=556, findex=0, frate=2,
			dur=5, pos=0,
			amp=0.25,
			out=0
			|
			var sigA, sigB, sigC, sig, env, fmod;
			env = EnvGen.ar(Env.triangle(5), doneAction:2);
			fmod = findex * SinOsc.kr(frate, mul:0.5, add:0.5) * Line.kr(0, 1, 7);
			sigA = Pulse.ar(freq + fmod, LFNoise2.kr(1).range(0.2, 0.8) );
			sigB = VarSaw.ar(freq + fmod);
			sigC = WhiteNoise.ar() * 0.125;
			sig = SelectX.ar(LFNoise2.kr(2).range(0, 2), [sigA, sigB, sigC]);
			sig = LPF.ar(sig, freq*4 );
			sig = sig * env * amp;
			Out.ar(out, Pan2.ar(sig, pos));
		}).add;

		s.sync;

		SynthDef(\rev, {
			arg in=0, out=0, mix=0.5, room=2;
			var sig;
			sig = In.ar(in, 2);
			sig = (sig * (1 - mix)) + (NHHall.ar(sig, room) * mix);
			Out.ar(out, sig);
		}).add;

		s.sync;

		~rev = Synth(\rev, [\in, ~revSend]);

		x = Pbind(
			\instrument, \bell,
			\out, ~revSend,
			\root, Pfunc({~root}),
			\octave, Pwrand([4, 5, 6, 7], [6,8,3,1].normalizeSum, inf),
			\degree, Prand(Scale.lydian.degrees, inf),
			\ctranspose, Pwhite( -0.05, 0.05, inf),
			\amp, 1.1 * Pexprand(0.001, 0.7) * (1/(Pkey(\octave)+1)),
			\findex, Pexprand(2, 20),
			\frate, Pwhite(1, 25, inf),
			\pos, Pwhite(-0.8, 0.8, inf),
			\dur, Pwhite(0.1, 0.5),
		).asEventStreamPlayer;
		x.play;

		wait(15);
		r = Routine({
			"starting".postln;
			loop({
				~root = [-13, -1, 4, 7].choose;
				wait( 10.rrand(25) );
			});
		});
		r.play;
});
)

SynthDescLib.global[\bell].makeGui;

~rev.set(\room, 10, \mix, 0.2);

[1, 3, 5].normalizeSum