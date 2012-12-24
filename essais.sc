(
SynthDef(\wavPlayer1, { |out = 0, bufnum = 0, trigger = 1, length = 1|
	var audio, rate, speed, pos, env, attack, sustain, release, speeds;
	// randomize speed
	speeds = [-1,-0.5,0.5,1];
	speed = TChoose.kr(trigger,speeds);
	// randomize position
	pos = TRand.kr(0,1,trigger)*BufFrames.kr(bufnum);
	// randomize enveloppe
	attack = TRand.kr(0.01,min(1,length),trigger);
	release = TRand.kr(0.01,length-attack,trigger);
	sustain = length - attack - release;
	env = EnvGen.ar(Env.linen(attack,sustain,release),trigger);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(trigger) >= 1);
	audio = PlayBuf.ar(2, bufnum, rate, trigger, pos, doneAction:0);
	// randomize pan
	audio = Balance2.ar(audio[0], audio[1], EnvGen.kr(Env.new([TRand.kr(-1,1,trigger),TRand.kr(-1,1,trigger)], [length]),trigger));
	Out.ar(out, audio * env);
}).add;
)

Server.local.boot;

~wavPath = "/Users/geoffroy/Music/pym - documents sonores/*.aif";
~wavFiles = ~wavPath.pathMatch;

// test wavPlayer1
// read a soundfile from disk
b = Buffer.read(s, ~wavFiles.choose);
x = Synth("wavPlayer1", [out: 0, bufnum: b, trigger: 0, length: 10]);
x.set(\trigger,1);
b.free;
x.free;

(
// try to put them in a group and start them at the same time

~numberOfWaves = 10;
~group = Group.new;

Array.fill(~numberOfWaves, {
	b = Buffer.read(s, ~wavFiles.choose);
	Synth(\wavPlayer1, [out: 0, bufnum: b, trigger: 0, length: 7], ~group);
});
)

~group.set(\trigger,1);
~group.set(\trigger,0);

(
~group.freeAll;
~group.free; // removes also the group itself
)

s.queryAllNodes; // see the nodes on the server
