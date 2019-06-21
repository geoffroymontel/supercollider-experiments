s.waitForBoot({
	var p = 3;
	("player"++p).postln;

	// Synths
	~player3Play = {
		{ |amp = 1.0, duration = 2, freq = 200|
			Splay.ar(
				Mix.fill(rrand(4,6), {
					var bands = rrand(2,10);
					var sig = { [BPF,RLPF,RHPF].choose.ar(
						in: LFNoise2.ar(freq: freq) *  LFNoise2.kr(exprand(0.1,10)),
						freq: Array.rand(bands, 50, 8000),
						rq: Array.rand(bands, 0.2, 1.8)
					).mean } ! 2;
					Rotate2.ar(sig[0], sig[1], LFSaw.kr(0.1.exprand(10)));
				}),
				0.5.rrand(1)
			) * amp * EnvGen.kr(Env.linen(attackTime: 0.1, sustainTime: duration, releaseTime: 0.5), doneAction: Done.freeSelf);
		}.play(target: ~players[p].group, outbus: ~players[p].bus, fadeTime: 0, args: [amp: ~players[p].volume.asMap, freq: ~players[p].freq, duration: ~players[p].duration]);
	};

	~player3Stop = {
		~players[p].group.release;
	};


	// VARS

	~players[p].volume = Bus.control(s,1);
	~players[p].freq = 200;
	~players[p].duration = 0.2;

	// OSC

	OSCdef.new((\launch++p).asSymbol, { |msg, time, addr, recvPort|
		postf("launch% : %\n",p,msg);
		~player3Play.value();
	}, '/departition/launch'++p, ~iPadNetAddr);
	OSCdef.new((\stop++p).asSymbol, { |msg, time, addr, recvPort|
		postf("stop% : %\n",p,msg);
		~player3Stop.value();
	}, '/departition/stop'++p, ~iPadNetAddr);
	OSCdef.new((\multifader++p++'_1').asSymbol, { |msg, time, addr, recvPort|
		postf("multifader%_1 : %\n",p,msg);
		~players[p].volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader'++p++'/1', ~iPadNetAddr);
	OSCdef.new((\multifader++p++'_2').asSymbol, { |msg, time, addr, recvPort|
		postf("multifader%_2 : %\n",p,msg);
		~players[p].freq = msg[1].lincurve(0.0,1.0,200,8000,-2);
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