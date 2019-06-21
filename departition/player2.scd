s.waitForBoot({
	var p = 2;
	("player"++p).postln;

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
		snd = LeakDC.ar(snd.fold2) * amp * EnvGen.kr(Env.linen(sustainTime: duration, releaseTime: 0.01), doneAction: Done.freeSelf) * -12.dbamp;
		Out.ar(out, snd);
	}).add;

	// VARS

	~players[p].volume = Bus.control(s,1);

	// OSC

	OSCdef.new((\launch++p).asSymbol, { |msg, time, addr, recvPort|
		postf("launch% : %\n",p,msg);
		Synth(\player2Noir, [
			freq: rrand(30,60).midicps,
			modFreq: rrand(0.5,10),
			timbre: rrand(300,10000),
			duration: rrand(0.5,5),
			amp: ~players[p].volume.asMap,
			out: ~players[p].bus
		], target: ~players[p].group);
	}, '/departition/launch'++p, ~iPadNetAddr);
	OSCdef.new((\stop++p).asSymbol, { |msg, time, addr, recvPort|
		postf("stop% : %\n",p,msg);
	}, '/departition/stop'++p, ~iPadNetAddr);
	OSCdef.new((\multifader++p++'_1').asSymbol, { |msg, time, addr, recvPort|
		postf("multifader%_1 : %\n",p,msg);
		~players[p].volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader'++p++'/1', ~iPadNetAddr);
	OSCdef.new((\multifader++p++'_2').asSymbol, { |msg, time, addr, recvPort|
		postf("multifader%_2 : %\n",p,msg);
	}, '/departition/multifader'++p++'/2', ~iPadNetAddr);
	OSCdef.new((\multitoggle++p++'_1').asSymbol, { |msg, time, addr, recvPort|
		postf("multitoggle%_1 : %\n",p,msg);
	}, '/departition/multitoggle'++p++'/1/1', ~iPadNetAddr);
	OSCdef.new((\multitoggle++p++'_2').asSymbol, { |msg, time, addr, recvPort|
		postf("multitoggle%_2 : %\n",p,msg);
	}, '/departition/multitoggle'++p++'/1/2', ~iPadNetAddr);
	OSCdef.new((\multitoggle++p++'_3').asSymbol, { |msg, time, addr, recvPort|
		postf("multitoggle%_3 : %\n",p,msg);
	}, '/departition/multitoggle'++p++'/1/3', ~iPadNetAddr);
});