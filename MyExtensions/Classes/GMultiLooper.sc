GMultiLooper {
	// PUBLIC
	var <window = nil;
	var <routine = nil;
	var <tempo = 60;
	var <beats = 1;
	var <loopLength = 1;
	var <randomLoopLengthPercentage = 0;
	var <tracks;

	// PRIVATE
	var tempoClock;
	var routine;

	// GUI
	var mainPlayButton;
	var tempoBox;
	var beatsBox;
	var loopLengthBox;
	var randomLoopLengthPercentageSlider;

	*new {
		^super.new.init();
	}

	free {
		window.close;
	}

	// PRIVATE METHODS

	init {
		window = Window.new("Geoffroy Multi Looper", Rect(20, 20, 800, 800), true);
		this.createTracks();
		this.createLayout();
	}

	createTracks {
		tracks = 4.collect({ GMultiLooperTrack.new(window) });
		tempoClock = TempoClock.new(tempo/60);

		SynthDef(\gMultiLooperPlayer, { |out = 0, bufnum = 0, rate = 1.0, gate = 1, wowAndFlutter = 0, amp = 1, startPos = 0|
			var sig;
			var playRate;
			playRate = BufRateScale.kr(bufnum) * rate * (1 + LFNoise2.kr(1, wowAndFlutter / 10));
			sig = PlayBuf.ar(2, bufnum, playRate.lag, gate, startPos);
			sig = Balance2.ar(sig[0], sig[1], LFNoise2.kr(1, wowAndFlutter));
			sig = sig * Env.asr(0.01, 1.0, 0.01).ar(gate: gate, doneAction: Done.freeSelf);
			sig = sig * amp * (1 + LFNoise2.kr(1, wowAndFlutter));
			Out.ar(out, sig.tanh);
		}).add;
	}

	createLayout {
		// play / stop
		mainPlayButton = Button(window);
		mainPlayButton.states = [
			["Play", Color.black, Color.white],
			["Stop",  Color.black, Color.white]
		];

		mainPlayButton.action_({ |butt|
			switch (butt.value,
				0, { this.stop(); },
				1, { this.play(); },
				{ "Unknown play button state".postln; }
			);
		});

		// tempo / beats / time
		tempoBox = GNumberBox(window, spec: [0.001, 1000, \lin].asSpec, initValue: tempo, name: "Tempo").action_({ |obj, value| this.tempo = value });
		beatsBox = GNumberBox(window, spec: [0.001, 1000, \lin].asSpec, initValue: beats, name: "Beats").action_({ |obj, value| this.beats = value });
		loopLengthBox = GNumberBox(window, spec: [0.001, 3600, \lin].asSpec, initValue: loopLength, name: "Length (s)", numberOfDecimals: 3).action_({ |obj, value| this.loopLength = value });
		randomLoopLengthPercentageSlider = GSlider(window, initValue: randomLoopLengthPercentage, spec: ControlSpec(0, 100, CurveWarp([0,100].asSpec, 4)), name: "Randomize length (%)").action_({ |obj, value| this.randomLoopLengthPercentage = value });

		window.layout = VLayout(
			// tempo, tempo variation, play / stop
			HLayout(mainPlayButton, tempoBox, beatsBox, loopLengthBox),
			randomLoopLengthPercentageSlider
		);

		4.do({ |i| window.layout.add(tracks[i]); });

		window.front;
	}

	tempo_ { |value|
		tempo = value;
		tempoBox.value = tempo;
		loopLength = beats * 60 / tempo;
		loopLengthBox.value = loopLength;
	}

	beats_ { |value|
		beats = value;
		beatsBox.value = beats;
		loopLength = beats * 60 / tempo;
		loopLengthBox.value = loopLength;
	}

	loopLength_ { |value|
		loopLength = value;
		loopLengthBox.value = loopLength;
		tempo = beats * 60 / loopLength;
		tempoBox.value = tempo;
	}

	randomLoopLengthPercentage_ { |value|
		randomLoopLengthPercentage = value;
	}

	play {

		routine = Routine.new({
			loop {
				tempoClock.tempo = tempo / 60;
				tracks.do { |track|
					track.play;
				};
				(beats * (1 + (randomLoopLengthPercentage / 100).bilinrand)).wait;
				tracks.do { |track|
					track.release;
				};
			}
		});
		routine.play(tempoClock);
	}

	stop {
		routine.stop;
		tracks.do { |track|
			track.stop;
		};
	}
}