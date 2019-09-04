(
var grainEnv, grainEnvBuffer;
// a custom envelope
grainEnv = Env([0, 1, 1, 0], [0.2, 0.6, 0.2] * 0.1, [0, 0, 0]);
grainEnvBuffer = Buffer.sendCollection(s, grainEnv.discretize, 1);

SynthDef.new(\ourSynth, { |out = 0, freq = 440, amp = 1.0, gate = 1, pan = 0|
	var snd, env, vibrato, pitchShift;

	snd = Mix(VarSaw.ar([1,1.9953843530485,3.0139733629359]*freq,Rand(0.0,1.0)!3,Rand(0.3,0.5)!3,[1.0,0.7,0.3])) ! 2 *0.5;
	snd = Pulse.ar(freq*[1,1.01],0.5);
	snd = DFM1.ar(snd, 12000);
	env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.5),gate,doneAction:2);
	snd = snd*env*amp;
	pitchShift = PitchShift.ar(in: snd, windowSize: 0.5, pitchRatio: 2.0, pitchDispersion: 0.02, timeDispersion: 10);
	pitchShift = pitchShift + PitchShift.ar(in: snd, windowSize: 0.5, pitchRatio: 2.1, pitchDispersion: 0.05, timeDispersion: 5) * 0.4;
	pitchShift = SwitchDelay.ar(pitchShift);
	snd = snd + GrainIn.ar(numChannels: 2, trigger: Dust.kr(20), dur: 0.05, in: pitchShift, envbufnum: grainEnvBuffer);
	snd = (snd * 0.5) + (snd * 0.5);
	Out.ar(out,Pan2.ar(snd, pan));
}).add;
)

(
Pbind(*[
	instrument: \ourSynth,
	midinote: Pseq([80, 76, 75], inf),
	dur: Pseq([2, 1, 1], inf)
]).play;
)