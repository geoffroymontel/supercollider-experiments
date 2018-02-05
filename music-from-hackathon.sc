// Load files from hackathon folder and create buffers

(
// retrieve all files from a folder
~filesInFolder = { |folder|
    var p;
	PathName(folder).filesDo { |x| p = p.add(x) };
	p
};

// convert a binary file in a sound buffer
~bufferFromFile = { |fileName|
	var sign, arraySize, f, t, a, i;
	arraySize = 44100;
	f = File(fileName.fullPath,"rb");
	t = Array.fill(arraySize, {0});
	a = f.getFloatLE;
	sign = -1.0;
	i = 0;

	while { (a.notNil()) && (i<arraySize)} {
		if (a.isNaN, { }, { t[i]=(a * sign) });
		a = f.getFloatLE();
		sign = sign * -1 ;
		i = i+1;
	};

	b = Buffer.loadCollection(s, t, 1, {f.close});
	b.normalize;
	b;
};

// convert all  files from hackathon folder to sound buffers
~arrayOfBuffers = ~filesInFolder.("/Users/geoffroy/dev/hackathon").collect { |f| ~bufferFromFile.(f) };
)

(
SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    bodyFreq = EnvGen.ar(Env([160, 100, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;

    snd = body + pop;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\wavPlayer, { |out = 0, bufnum = 0, trig = 1, sustain = 1|
	var audio, rate, speed, pos, env, attack, sus, release, speeds;
	// randomize speed
	speeds = [-1,-0.5, 0.5,1];
	speed = TChoose.kr(trig,speeds);
	// randomize position
	pos = TRand.kr(0,1,trig)*BufFrames.kr(bufnum);
	// randomize enveloppe
	attack = TRand.kr(0.01,min(1,sustain),trig);
	release = TRand.kr(0.01,sustain-attack,trig);
	sus = sustain - attack - release;
	env = EnvGen.ar(Env.asr(attack,sus,release),trig);
	// use PulseCount because PlayBuf starts right away whatever trigger is
	rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(trig) >= 1);
	audio = PlayBuf.ar(1, bufnum, rate, trig, pos, doneAction:2);
	// randomize pan
	audio = Pan2.ar(audio, EnvGen.kr(Env.new([TRand.kr(-1,1,trig),TRand.kr(-1,1,trig)], [sustain]),trig));
	Out.ar(out, audio * env * 0.2);
}).add;
)

TempoClock.default.tempo = 120/60;

// launch players at the same time with fibonnacci lengths
(
var numberOfVoices = ~arrayOfBuffers.size;
var length = 60;
numberOfVoices.do {
  Pbind(*[
    instrument: \wavPlayer,
    dur: Prand([1,2,3,5,8,13,21],length),
    bufnum: Prand(~arrayOfBuffers,length),
  ]).play(quant: 1);
};
)

(
Pbind(*[
	instrument: \kick,
	dur: Pn(1),
	amp: 1]).play(quant: 1);
)

