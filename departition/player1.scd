s.waitForBoot({
	"player1".postln;

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
	~busPlayer1Volume = Bus.control(s,1);
	~player1LowFreq = 20;
	~player1HighFreq = 500;
	~player1Duration = 0.1;
	~player1Chorus = 0;
	~player1Legato = 0.1;

	// OSC

	OSCdef.new(\stop1, { |msg, time, addr, recvPort|
		postf("stop1 : %\n",msg);
		~tempoClock.schedAbs(~tempoClock.beats.ceil, {
			Pdef(\player1Noir).stop;
		});
	}, '/departition/stop1', ~iPadNetAddr);
	OSCdef.new(\launch1, { |msg, time, addr, recvPort|
		postf("launch1 : %\n",msg);
		Pdef(\player1Noir).play(~tempoClock, quant: 1);
	}, '/departition/launch1', ~iPadNetAddr);
	OSCdef.new(\multifader1_1, { |msg, time, addr, recvPort|
		postf("multifader1_1 : %\n",msg);
		~busPlayer1Volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader1/1', ~iPadNetAddr);
	OSCdef.new(\multifader1_2, { |msg, time, addr, recvPort|
		postf("multifader1_2 : %\n",msg);
		~player1LowFreq = msg[1].lincurve(0,1,20,150,1).debug("~player1LowFreq");
		~player1HighFreq = msg[1].lincurve(0,1,150,800,4).debug("~player1HighFreq");
		~player1Duration = msg[1].lincurve(0,1,3,0.1,2).debug("~player1Duration");
		~player1Chorus = msg[1].lincurve(0,1,0,0.2,4).debug("~player1Chorus");
		~player1Legato = msg[1].lincurve(0,1,0.1,3.0,2).debug("~player1Legato");
	}, '/departition/multifader1/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle1_1, { |msg, time, addr, recvPort|
		postf("multitoggle1_1 : %\n",msg);
	}, '/departition/multitoggle1/1/1', ~iPadNetAddr);
	OSCdef.new(\multitoggle1_2, { |msg, time, addr, recvPort|
		postf("multitoggle1_2 : %\n",msg);
	}, '/departition/multitoggle1/1/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle1_3, { |msg, time, addr, recvPort|
		postf("multitoggle1_3 : %\n",msg);
	}, '/departition/multitoggle1/1/3', ~iPadNetAddr);

	// Patterns

	Pdef.new(\player1Noir, Pbind(*[
		instrument: \player1Noir,
		group: ~groupPlayer1,
		startFreqs: Pn(Plazy({ [ {rrand(~player1LowFreq, ~player1HighFreq)}.dup(3) ] })),
		endFreqs: Pn(Plazy({ [ {rrand(~player1LowFreq,~player1HighFreq)}.dup(3) ] })),
		durations: Pn(Plazy({ [ rrand(0.1,~player1Duration).dup(3) ] })),
		dur: Pfunc({ rrand(0.1, ~player1Duration) }),
		ffreq: Pfunc({ rrand(~player1LowFreq, ~player1HighFreq)}),
		amp: ~busPlayer1Volume.asMap,
		chorus: Pfunc({~player1Chorus}),
		legato: Pfunc({~player1Legato}),
		out: ~busPlayer1
	]));
});