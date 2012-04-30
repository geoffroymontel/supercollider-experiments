(
SynthDef(\wavPlayer1, { |out = 0, bufnum = 0, trigger = 1, length = 1|
	var audio, rate, speed, pos, env, attack, sustain, release, speeds;
	// randomize speed
	speeds = [-8,-7,-6,-5,-4,-3,-2,-1,-0.5,-0.25,-0.125,0.125,0.25,0.5,1,2,3,4,5,6,7,8];
	speed = TChoose.kr(trigger,speeds);
	// randomize position
	pos = Rand.new(0,1)*BufFrames.kr(bufnum);
	// randomize enveloppe
	attack = Rand.new(0.01,min(1,length));
	release = Rand.new(0.01,length-attack);
	sustain = length - attack - release;
	env = EnvGen.ar(Env.linen(attack,sustain,release),trigger);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(trigger) >= 1);
	audio = PlayBuf.ar(2, bufnum, rate, trigger, pos, doneAction:0);
	// randomize pan
	audio = Balance2.ar(audio[0],audio[1],EnvGen.ar(Line.ar(Rand(-1,1),Rand(-1,1),length),trigger));
	Out.ar(out, audio * env);
}).add;
)


~wavPath = "d:/stromboli/puit/*.wav";
~wavFiles = ~wavPath.pathMatch;

// test wavPlayer1
// read a soundfile from disk
b = Buffer.read(s, ~wavFiles.choose);
x = Synth("wavPlayer1", [out: 0, bufnum: b, trigger: 0, length: 10]);
x.set(\trigger,1);
b.free;
x.free;

// try to put them in a group and start them at the same time

~numberOfWaves = 30;
~group = Group.new;

Array.fill(~numberOfWaves, {
	b = Buffer.read(s, ~wavFiles.choose);
	Synth(\wavPlayer1, [out: 0, bufnum: b, trigger: 0, length: 60], ~group);
});


~group.set(\trigger,1);
~group.set(\trigger,0);

~group.freeAll;
~group.free; // removes also the group itself

s.queryAllNodes; // see the nodes on the server
