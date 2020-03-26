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
	var numberOfTracks;
	var group;
	var outputBuses;
	var tempoClock;
	var routine;

	// GUI
	var mainPlayButton;
	var tempoBox;
	var beatsBox;
	var loopLengthBox;
	var randomLoopLengthPercentageSlider;

	*new { |numberOfTracks = 3, outputBuses = #[0]|
		^super.new.init(numberOfTracks, outputBuses);
	}

	free {
		window.close;
		this.stop;
		tracks.do({ |track| track.free });
		group.free;
	}

	// PRIVATE METHODS

	init { |argNumberOfTracks, argOutputBuses|
		numberOfTracks = argNumberOfTracks;
		outputBuses = argOutputBuses;
		window = Window.new("Geoffroy Multi Looper",  Rect(0, 400, 800, 400), resizable: true);
		window.onClose = {
			this.free;
		};
		this.createTracks;
		this.createLayout;
	}

	createTracks {
		group = Group.new;
		tracks = numberOfTracks.collect({ |i| GMultiLooperTrack.new(window, group: group, bus: outputBuses.foldAt(i)) });
		tempoClock = TempoClock.new(1);

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

		numberOfTracks.do({ |i| window.layout.add(tracks[i]); });

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
		beats = tempo * loopLength / 60;
		beatsBox.value = beats;
	}

	randomLoopLengthPercentage_ { |value|
		randomLoopLengthPercentage = value;
	}

	play {
		routine = Routine.new({
			var loopDuration;
			loop {
				tracks.do { |track|
					track.play;
				};
				loopDuration = max(0.025, loopLength * (1 + (randomLoopLengthPercentage / 100).bilinrand));
				loopDuration.wait;
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