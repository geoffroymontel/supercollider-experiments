// When The Saints Come Crawling Out
// Tim Walters, 2017

(
Server.default.waitForBoot {

	// Name your poison
	var durationInMinutes = 30;

	var verb, verbBus, master, masterBus, numP, pairs, maxlevel;

	SynthDef(\percolator, {
		|out = 0, gate = 1, decayCurve = -8, pan = 0, amp = 0.5, noiseDecay = 0.25, filterType = 0, filterFreq = 1000,
		filterRQ = 0.05, impactDecay = 0.062, impactFreq = 250, impactWidth = 0.5, impactSweep = 0.5, shellDecay = 0.25,
		shellFreq = 283, shellSweep = 0.25, shellNoiseModSource = 0, trigRate = 0.5, shellNoiseModDepth = 0.5, density = 1,
		accentStrength = 0.5, shellModFreq = 309, shellModOffset = 0, verbSend, bodyMix=0, distance=0.5, wet = 0.25|

		var noise, impact, shell, noiseEnv, impactEnv, shellEnv, shellNoiseMod, attack, triggerLag,
		ampMod, final, trigger, accent, masterEnv, sum, phased, body, impactLevel, driver;
		masterEnv = EnvGen.kr(Env.asr(0.005, 1, 0.05), gate: gate, doneAction: 2);
		driver = Impulse.kr(trigRate);
		trigger = driver * (Demand.kr(driver, 0, Dwhite(0, 1)) < density);
		triggerLag = trigRate.reciprocal * 0.25;
		accent = Demand.kr(trigger, 0, Dwhite(0.0, 1.0));
		attack = LinExp.kr(accent, 0, 1, 0.02, 0.006);
		ampMod = LinLin.kr(accent, 0, 1, LinLin.kr(accentStrength, 0, 1, -6, -18).dbamp, 0).dbamp;
		noiseEnv = EnvGen.kr(Env.perc(attack, noiseDecay * TExpRand.kr(0.8, 1.25, trigger),
			curve: decayCurve), gate: trigger, doneAction: 0);
		noise = WhiteNoise.ar;
		noise = Select.ar(filterType, [BPF.ar(noise, filterFreq, filterRQ), RLPF.ar(noise, filterFreq, filterRQ)]) * noiseEnv;
		impactEnv = EnvGen.kr(Env.perc(attack, impactDecay * TExpRand.kr(0.8, 1.25, trigger),
			curve: decayCurve), gate: trigger, doneAction: 0);
		impact = Pulse.ar(impactEnv.range(impactFreq, impactFreq * impactSweep.midiratio), impactWidth, impactEnv);
		shellEnv = EnvGen.kr(Env.perc(attack, shellDecay * TExpRand.kr(0.8, 1.25, trigger),
			curve: decayCurve), gate: trigger, doneAction: 0);
		shellNoiseMod = Select.ar(shellNoiseModSource, [noise, impact]) * shellFreq * shellNoiseModDepth;
		shell = LFTri.ar(shellEnv.range(shellFreq, shellFreq * shellSweep.midiratio) + shellNoiseMod) *
		(DC.ar(shellModOffset) + LFTri.ar(shellModFreq)) * shellEnv;
		body = XFade2.ar(noise, shell, bodyMix);
		impactLevel = (LinLin.kr(distance, 0, 1, 3, -9) + TRand.kr(-2, 2, trigger)).dbamp;
		//impactLevel = LinLin.kr((LinLin.kr(distance, 0, 1, 0.2, 0.8) + LFNoise2.kr(Rand(0.1, 0.3), 0.2)), 0, 1, 1, 6, -12).dbamp;
		sum = LPF.ar(Mix.ar([impact * impactLevel, body]), LinExp.kr(distance, 0, 1, 18000, 6000), mul: -10.dbamp);
		final = Pan2.ar(BPeakEQ.ar(sum, 1800, 4, -6), TRand.kr(-1, 1, Lag.kr(trigger, triggerLag * 0.125)), masterEnv * amp * ampMod * AmpCompA.kr(shellFreq));
		OffsetOut.ar(verbSend, final * LinLin.kr(distance, 0, 1, -18, -6).dbamp * wet);
		OffsetOut.ar(out, final * LinLin.kr(distance, 0, 1, 0, -6).dbamp);
	}).add;

	SynthDef(\verb, {
		|in, gate=1, out = 0|
		var input = In.ar(in, 2);
		var releaser = DetectSilence.ar(gate + input, doneAction: 2);
		OffsetOut.ar(out, GVerb.ar(input, roomsize: 80, drylevel: 0, earlyreflevel: 1, taillevel: -3.dbamp))
	}).add;

	SynthDef(\master, {
		|in, gate=1, out=0|
		var input = In.ar(in, 2);
		var shaped = Compander.ar(input, input, -12.dbamp, 1, 0.75, 0.1, 0.3);
		var limited = Limiter.ar(shaped, -2.dbamp);
		var releaser = DetectSilence.ar(gate + input, doneAction: 2);
		OffsetOut.ar(out, limited)
	}).add;

	Server.default.sync;

	verbBus = Bus.audio(Server.default, 2);
	masterBus = Bus.audio(Server.default, 2);
	verb = Synth(\verb, [\in, verbBus.index, \out, masterBus.index], Server.default, \addToTail);
	master = Synth(\master, [\in, masterBus.index, \out, 0], Server.default, \addToTail);

	Server.default.sync;
	1.wait;

	numP = 4;

	Ppar({ |i|
		var durationInSeconds = durationInMinutes * 60;
		Pbind(
			\time, Ptime.new,
			\instrument, \percolator,
			\freq, Pfunc({ |e| (e[\time] < durationInSeconds).if {
				110 } {
				(i == 0).if {
					verb.release;
					master.release;
					{
						1.wait;
						verbBus.notNil.if { verbBus.free };
						5.wait;
						masterBus.notNil.if { masterBus.free };
					}.fork;
				};
				nil
			}
			}),
			\agitation, Pfunc({ |e| (e[\time] == 0).if { 0 } { [0, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7].choose } }),
			\agitationMult, Pfunc({ |e| 2 ** (7 - e[\agitation]) }),
			\agitationComp, Pfunc({ |e| e[\agitation].linlin(0, 7, -6.dbamp, 0.dbamp) }),
			\dur, Pfunc({ |e| (rrand(0, 2).nthPrime * [1, 2, 4, 8].choose).min(durationInSeconds - e[\time]) }),
			\legato, (i == 0).if {
				Prand([1.0, 1.25, 1.5], inf)
			} {
				Prand([0.25, 0.5, 0.75, 1.0] / i, inf)
			},
			\noiseDecay, Pfunc({ |e| exprand(0.25, 20.0) * e[\agitationMult] }),
			\filterFreq, Pexprand(40, 5000, inf),
			\filterRQ, Pexprand(0.05, 2.0, inf),
			\impactDecay, Pfunc({ |e| exprand(0.02, 0.08) * e[\agitationMult] }),
			\impactFreq, Pexprand(40, 5000, inf),
			\impactWidth, Pexprand(0.05, 0.95, inf),
			\impactSweep, Pexprand(0.25, 4.0, inf),
			\shellDecay, Pfunc({ |e| exprand(0.25, 20.0) * e[\agitationMult] }),
			\shellFreq, Pexprand(60, 1000, inf),
			\shellNoiseModSource, [0, 1].choose,
			\shellNoiseModDepth, Pexprand(0.1, 1.0, inf),
			\shellModFreq, Pexprand(40, 5000, inf),
			\shellModOffset, Pwhite(0.0, 1.0, inf),
			\shellSweep, Pexprand(0.125, 4.0, inf),
			\amp, Pfunc({ |e| 0.dbamp * e[\agitationComp] }),
			\accentStrength, Pwhite(0.0, 1.0),
			\trigRate, Pfunc({ |e|
				rrand(0, 3).nthPrime
				* [0.25, 1/3, 0.5, 2/3, 1, 4/3, 1.5, 5/3, 2, 7/3, 2.5, 8/3, 3, 10/3, 11/3, 4].choose
				* e[\agitationMult].reciprocal
			}),
			\decayCurve, Pexprand(-12, -4),
			\density, Pfunc({ |e| rrand(e[\agitation].linlin(0, 1, 1, 0.15), 1) }),
			\server, Server.default,
			\verbSend, verbBus.index,
			// -1 is all noise, 1 is all shell
			\bodyMix, Pwhite(-1, 1),
			\distance, Pwhite(0, 1),
			\wet, -6.dbamp,
			\addAction, \addToHead,
			\out, masterBus.index,
		)
	} ! numP).play;
};
)