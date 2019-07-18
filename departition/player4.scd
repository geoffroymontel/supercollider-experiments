s.waitForBoot({
	var p = 4;
	("player"++p).postln;

	// Synths
	~player4Play = {
		var freq = ~players[p].freq.debug("freq");
		{ |amp = 1.0, duration = 2|
			var snd;
			var bands = 1.rrand(10) * 2;
			var freqs = Array.exprand(bands.debug('bands'), freq/10, freq);
			snd = Pan2.ar(
				in: SinOsc.ar(
					freq: freqs,
					phase: Array.rand(bands, 0, pi),
					mul: AmpCompA.kr(freqs, freqs.sort.first)
				),
				pos: SinOsc.kr(
					freq: Array.exprand(bands, 0.01, 15),
					phase: Array.rand(bands, 0, pi),
				),
				level: bands.reciprocal
				* LFGauss.kr(duration: SinOsc.kr(Array.rand(bands, 0.05, 0.1)).range(1,5), width: 0.3)
				* SinOsc.kr(freq: Array.exprand(bands, 0.1, 15), phase: pi/4).range(0,1)
			).sum;
			snd = snd * amp * EnvGen.kr(Env.linen(attackTime: 0.1, sustainTime: duration, releaseTime: 0.5), doneAction: Done.freeSelf) * 12.dbamp;
			snd = snd.fold2;
		}.play(target: ~players[p].group, outbus: ~players[p].bus, fadeTime: 0, args: [amp: ~players[p].volume.asMap, duration: ~players[p].duration]);
	};

	~player4Stop = {
		~players[p].group.release;
	};

	// VARS
	~players[p].volume = Bus.control(s,1);
	~players[p].freq = 200;
	~players[p].duration = 0.2;

	// OSC

	OSCdef.new((\launch++p).asSymbol, { |msg, time, addr, recvPort|
		postf("launch% : %\n",p,msg);
		~player4Play.value();
	}, '/departition/launch'++p, ~iPadNetAddr);
	OSCdef.new((\stop++p).asSymbol, { |msg, time, addr, recvPort|
		postf("stop% : %\n",p,msg);
		~player4Stop.value();
	}, '/departition/stop'++p, ~iPadNetAddr);
	OSCdef.new((\multifader++p++'_1').asSymbol, { |msg, time, addr, recvPort|
		postf("multifader%_1 : %\n",p,msg);
		~players[p].volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader'++p++'/1', ~iPadNetAddr);
	OSCdef.new((\multifader++p++'_2').asSymbol, { |msg, time, addr, recvPort|
		postf("multifader%_2 : %\n",p,msg);
		~players[p].freq = msg[1].lincurve(0.0,1.0,200,4000,-2);
		~players[p].duration = msg[1].lincurve(0.0,1.0,0.1,10,-2);
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