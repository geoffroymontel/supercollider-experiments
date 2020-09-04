GMultiGranularizer {
	// PUBLIC
	var <window = nil;
	var <tracks;

	// PRIVATE
	var numberOfTracks;
	var group;
	var outputBuses;
	var routine;

	// GUI
	var mainPlayButton;

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
		window = Window.new("Geoffroy Multi Granularizer",  Rect(0, 400, 800, 400), resizable: true);
		window.onClose = {
			this.free;
		};
		this.createTracks;
		this.createLayout;
	}

	createTracks {
		group = Group.new;
		tracks = numberOfTracks.collect({ |i| GMultiGranularizerTrack.new(window, group: group, bus: outputBuses.foldAt(i)) });

		SynthDef(\gMultiGranularizerGrain, { |out = 0, bufnum = 0, rate = 1.0, amp = 1, startPos = 0, attackTime = 0.001, sustainTime = 0.1, releaseTime = 0.001, curve = 0, pan = 0|
			var sig;
			var playRate;
			playRate = BufRateScale.kr(bufnum) * rate;
			sig = PlayBuf.ar(2, bufnum, playRate.lag, 1, startPos);
			sig = Balance2.ar(sig[0], sig[1], pan);
			sig = sig * Env.linen(attackTime, sustainTime, releaseTime, 1.0, curve).ar(doneAction: Done.freeSelf);
			sig = sig * amp;
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

		window.layout = VLayout(
			mainPlayButton
		);

		numberOfTracks.do({ |i| window.layout.add(tracks[i]); });

		window.front;
	}

	play {
		tracks.do { |track|
			track.play;
		};
	}

	stop {
		tracks.do { |track|
			track.stop;
		};
	}
}