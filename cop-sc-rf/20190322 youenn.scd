(
SynthDef(\distOsc, { |out, degree = 0|
	//
	// OSC
	//
	// Simple stereo sinus oscillator
	var sSin = { |freq=300, mul=1|
		SinOsc.ar([freq - 1, freq + 1], mul)
	};

	// Simple stereo square oscillator with width control
	var sSqu = { |freq=300, width=0.5, mul=1|
		Pulse.ar([freq - 1, freq + 1], width, mul)
	};

	//
	// Sound processing
	//
	// Fold an input with mul coefficient
	var foldr = { |sound, mul=0.2| sound.fold2(1) * mul };

	// Simple Low Pass filter
	var filtr = { |sound, freq| LPF.ar(sound, freq) };

	//
	// Tools
	//
	// Quantize an input signal to a scale, output is a frequency
	var quant = { |input, scale|
		DegreeToKey.kr(scale.as(LocalBuf), input, scale.stepsPerOctave, 1, 60).midicps
	};


	//
	// Patch
	//
	Out.ar(
		out,
		foldr.value(
			filtr.value(
				sound: sSqu.value(
					freq: quant.value(degree, Scale.minor),
					mul: MouseY.kr(0.1, 180, 1)
				),
				freq: MouseX.kr(100, 1000))
		)
	)
}).add;
)

// en utilisant Pbind
(
d=Synth(\distOsc);

p = Pbind(*[
	type: \set,
	id: d.nodeID,
	args: [\degree],
	degree: Pseq([10, 2, 1], inf),
	dur: 0.2
]
).play;
)

// ou avec une routine
(
~synth=Synth(\distOsc);

~seq1 = Routine({
	var seq = Pseq([10, 2, 1], inf).asStream;
	loop({
		~synth.set(\degree, seq.next);
		0.2.wait;
	})
});

~seq1.play;
)

(
SynthDef(\mouseControl, { |out|
	Out.kr(out, MouseX.kr(0, 20));
}).add;
)

(
~synth = Synth(\distOsc);
~bus = Bus.control(s, 1);
~mouse = Synth(\mouseControl, [out: ~bus]);
~synth.map(\degree, ~bus);
)

