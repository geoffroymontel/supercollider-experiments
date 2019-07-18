s.waitForBoot({
	var p = 1;
	("player"++p).postln;

	// Synths

	SynthDef(\player1Noir, {
		var out = \out.kr(0);
		var startFreqs = \startFreqs.kr([50,400,600]);
		var endFreqs = \endFreqs.kr([100,500,800]);
		var durations = \durations.kr([100,100,100]);
		var kickInDelays = \kickInDelays.kr([0,0,0]);
		var gate = \gate.kr(1);
		var ffreq = \ffreq.kr(1000);
		var chorus = \chorus.kr(0.1);
		var snd = 1.0;
		var amp = \amp.kr(1.0);
		3.do { |i|
			snd = snd * (1 - LFTri.ar(
				freq: EnvGen.ar(
					Env.new(
						levels: [0,0,startFreqs[i], endFreqs[i],0],
						times: [kickInDelays[i],0.01,durations[i],0.01]
					), gate: gate
				) * [
					1,
					LFNoise1.kr(0.1).range(1, chorus.midiratio)
				]
			));
		};
		snd = (snd * 8.reciprocal).tanh;
		snd = DFM1.ar(snd, ffreq, type: 1.0);
		snd = LeakDC.ar(snd);
		snd = snd * EnvGen.kr(Env.asr(0.005,1.0,0.1), gate, doneAction: Done.freeSelf) * amp;
		Out.ar(out, snd);
	}).add;

	// VARS

	~players[p].volume = Bus.control(s,1);
	~players[p].lowFreq= 20;
	~players[p].highFreq = 500;
	~players[p].duration = 0.1;
	~players[p].chorus = 0;
	~players[p].legato = 0.1;

	// OSC

	OSCdef.new((\stop++p).asSymbol, { |msg, time, addr, recvPort|
		postf("stop% : %\n",p,msg);
		~tempoClock.schedAbs(~tempoClock.beats.ceil, {
			Pdef(\player1Noir).stop;
		});
	}, '/departition/stop'++p, ~iPadNetAddr);
	OSCdef.new((\launch++p).asSymbol, { |msg, time, addr, recvPort|
		postf("launch% : %\n",p,msg);
		Pdef(\player1Noir).play(~tempoClock, quant: 1);
	}, '/departition/launch'++p, ~iPadNetAddr);
	OSCdef.new(\multifader1_1, { |msg, time, addr, recvPort|
		postf("multifader%_1 : %\n",p,msg);
		~players[p].volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader'++p++'/1', ~iPadNetAddr);
	OSCdef.new((\multifader++p++'_2').asSymbol, { |msg, time, addr, recvPort|
		postf("multifader%_2 : %\n",p,msg);
		~players[p].lowFreq = msg[1].lincurve(0,1,20,150,1);
		~players[p].highFreq = msg[1].lincurve(0,1,150,800,4);
		~players[p].duration = msg[1].lincurve(0,1,3,0.1,2);
		~players[p].chorus = msg[1].lincurve(0,1,0,0.2,4);
		~players[p].legato = msg[1].lincurve(0,1,0.1,3.0,2);
	}, '/departition/multifader'++p++'/2', ~iPadNetAddr);
	OSCdef.new((\multitoggle++p++'_1').asSymbol, { |msg, time, addr, recvPort|
		postf("multitoggle%_1 : %\n",p,msg);
	}, '/departition/multitoggle'++p++'/1/1', ~iPadNetAddr);
	OSCdef.new((\multitoggle++p++'_2'), { |msg, time, addr, recvPort|
		postf("multitoggle1_2 : %\n",msg);
	}, '/departition/multitoggle'++p++'/1/2', ~iPadNetAddr);
	OSCdef.new((\multitoggle++p++'_3'), { |msg, time, addr, recvPort|
		postf("multitoggle1_3 : %\n",msg);
	}, '/departition/multitoggle'++p++'/1/3', ~iPadNetAddr);

	// Patterns

	Pdef.new(\player1Noir, Pbind(*[
		instrument: \player1Noir,
		group: ~players[p].group,
		startFreqs: Pn(Plazy({ [ {rrand(~players[p].lowFreq, ~players[p].highFreq)}.dup(3) ] })),
		endFreqs: Pn(Plazy({ [ {rrand(~players[p].lowFreq,~players[p].highFreq)}.dup(3) ] })),
		durations: Pn(Plazy({ [ rrand(0.1,~players[p].duration).dup(3) ] })),
		dur: Pfunc({ rrand(0.1, ~players[p].duration) }),
		ffreq: Pfunc({ rrand(~players[p].lowFreq, ~players[p].highFreq)}),
		amp: ~players[p].volume.asMap,
		chorus: Pfunc({~players[p].chorus}),
		legato: Pfunc({~players[p].legato}),
		out: ~players[p].bus
	]));
});