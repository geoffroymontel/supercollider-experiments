s.waitForBoot({
	"player3".postln;

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
		}.play(target: ~groupPlayer3, outbus: ~busPlayer3, fadeTime: 0, args: [amp: ~busPlayer3Volume.asMap, freq: ~busPlayer3Freq, duration: ~busPlayer3Duration]);
	};

	~player3Stop = {
		~groupPlayer3.release;
	};


	// VARS

	~busPlayer3Volume = Bus.control(s,1);
	~busPlayer3Freq = 200;
	~busPlayer3Duration = 0.2;

	// OSC

	OSCdef.new(\launch3, { |msg, time, addr, recvPort|
		postf("launch3 : %\n",msg);
		~player3Play.value();
	}, '/departition/launch3', ~iPadNetAddr);
	OSCdef.new(\stop3, { |msg, time, addr, recvPort|
		postf("stop3 : %\n",msg);
		~player3Stop.value();
	}, '/departition/stop3', ~iPadNetAddr);
	OSCdef.new(\multifader3_1, { |msg, time, addr, recvPort|
		postf("multifader3_1 : %\n",msg);
		~busPlayer3Volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader3/1', ~iPadNetAddr);
	OSCdef.new(\multifader3_2, { |msg, time, addr, recvPort|
		postf("multifader3_2 : %\n",msg);
		~busPlayer3Freq = msg[1].lincurve(0.0,1.0,200,8000,-2);
		~busPlayer3Duration = msg[1].lincurve(0.0,1.0,0.1,10,-2);
	}, '/departition/multifader3/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle3_1, { |msg, time, addr, recvPort|
		postf("multitoggle3_1 : %\n",msg);
	}, '/departition/multitoggle3/1/1', ~iPadNetAddr);
	OSCdef.new(\multitoggle3_2, { |msg, time, addr, recvPort|
		postf("multitoggle3_2 : %\n",msg);
	}, '/departition/multitoggle3/1/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle3_3, { |msg, time, addr, recvPort|
		postf("multitoggle2_3 : %\n",msg);
	}, '/departition/multitoggle3/1/3', ~iPadNetAddr);

});