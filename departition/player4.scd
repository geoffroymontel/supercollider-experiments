s.waitForBoot({
	"player4".postln;

	// Synths
	~player4Play = {
		{ |amp = 1.0, duration = 2, freq = 200|
			var snd;
			var bands = 1.rrand(10) * 2;
			var freqs = Array.exprand(bands.debug('bands'), 20, 8000);
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
		}.play(target: ~groupPlayer4, outbus: ~busPlayer4, fadeTime: 0, args: [amp: ~busPlayer4Volume.asMap, freq: ~busPlayer4Freq, duration: ~busPlayer4Duration]);
	};

	~player4Stop = {
		~groupPlayer4.release;
	};


	// VARS
	~busPlayer4Volume = Bus.control(s,1);
	~busPlayer4Freq = 200;
	~busPlayer4Duration = 0.2;

	// OSC

	OSCdef.new(\launch4, { |msg, time, addr, recvPort|
		postf("launch4 : %\n",msg);
		~player4Play.value();
	}, '/departition/launch4', ~iPadNetAddr);
	OSCdef.new(\stop4, { |msg, time, addr, recvPort|
		postf("stop4 : %\n",msg);
		~player4Stop.value();
	}, '/departition/stop4', ~iPadNetAddr);
	OSCdef.new(\multifader4_1, { |msg, time, addr, recvPort|
		postf("multifader4_1 : %\n",msg);
		~busPlayer4Volume.set(msg[1].lincurve(0.0,1.0,0.0,1.0,2));
	}, '/departition/multifader4/1', ~iPadNetAddr);
	OSCdef.new(\multifader4_2, { |msg, time, addr, recvPort|
		postf("multifader4_2 : %\n",msg);
		~busPlayer4Freq = msg[1].lincurve(0.0,1.0,200,8000,-2);
		~busPlayer4Duration = msg[1].lincurve(0.0,1.0,0.1,10,-2);
	}, '/departition/multifader4/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle4_1, { |msg, time, addr, recvPort|
		postf("multitoggle4_1 : %\n",msg);
	}, '/departition/multitoggle4/1/1', ~iPadNetAddr);
	OSCdef.new(\multitoggle4_2, { |msg, time, addr, recvPort|
		postf("multitoggle4_2 : %\n",msg);
	}, '/departition/multitoggle4/1/2', ~iPadNetAddr);
	OSCdef.new(\multitoggle4_3, { |msg, time, addr, recvPort|
		postf("multitoggle4_3 : %\n",msg);
	}, '/departition/multitoggle4/1/3', ~iPadNetAddr);
});