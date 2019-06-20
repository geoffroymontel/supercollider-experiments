s.waitForBoot({
	"player2".postln;

	// Synths
	SynthDef(\player2Noir, {
		var freq = \freq.kr(440);
		var modFreq = \modFreq.kr(1);
		var timbre = \timbre.kr(500);
		var amp = \amp.kr(1.0);
		var out = \out.kr(0);
		var duration = \duration.kr(1);
		var snd, x, y;
		x = Dseq((5..20)*freq,3);
		y = { |a|
			SinOsc.ar(Demand.kr(Dust.kr(a),0,x))
		};
		snd = SinOsc.ar([timbre * y.(modFreq) * y.(modFreq *IRand(1,4)),(timbre + 1) * y.(modFreq) * y.(modFreq * IRand(1,4))]);
		snd = LeakDC.ar(snd.fold2) * amp * EnvGen.kr(Env.linen(sustainTime: duration, releaseTime: 0.01), doneAction: Done.freeSelf);
		Out.ar(out, snd);
	}).add;

	// VARS

	~busPlayer2Volume = Bus.control(s,1);
	~player1LowFreq = 20;
	~player1HighFreq = 500;
	~player1Duration = 0.1;
	~player1Chorus = 0;
	~player1Legato = 0.1;

	// OSC

	OSCdef.new(\launch2, { |msg, time, addr, recvPort|
		postf("launch2 : %\n",msg);
		Synth(\player2Noir, [
			freq: rrand(30,60).midicps,
			modFreq: rrand(0.5,10),
			timbre: rrand(300,10000),
			duration: rrand(0.5,5),
			amp: ~busPlayer2Volume.asMap,
			out: ~busPlayer2
		], target: ~groupPlayer2);
	}, '/departition/launch2', ~iPadNetAddr);
	OSCdef.new(\stop2, { |msg, time, addr, recvPort|
		postf("stop2 : %\n",msg);
	}, '/departition/stop2', ~iPadNetAddr);
	OSCdef.new(\multifader2_1, { |msg, time, addr, recvPort|
		postf("multifader2_1 : %\n",msg);
		~busPlayer2Volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader2/1', ~iPadNetAddr);
	OSCdef.new(\multifader2_2, { |msg, time, addr, recvPort|
		postf("multifader2_2 : %\n",msg);
	}, '/departition/multifader2/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle2_1, { |msg, time, addr, recvPort|
		postf("multitoggle2_1 : %\n",msg);
	}, '/departition/multitoggle2/1/1', ~iPadNetAddr);
	OSCdef.new(\multitoggle2_2, { |msg, time, addr, recvPort|
		postf("multitoggle2_2 : %\n",msg);
	}, '/departition/multitoggle2/1/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle2_3, { |msg, time, addr, recvPort|
		postf("multitoggle2_3 : %\n",msg);
	}, '/departition/multitoggle2/1/3', ~iPadNetAddr);
});