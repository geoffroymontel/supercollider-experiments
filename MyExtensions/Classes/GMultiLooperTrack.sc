GMultiLooperTrack : SCViewHolder {
	// PUBLIC
	var <playbackSpeed = 1.0;
	var <wowAndFlutterPercentage = 0;
	var <randomPlayStartPercentage = 0;
	var <soundFile = nil;
	var <buffer = nil;
	var <gain = 1.0;

	// PRIVATE
	var synth = nil;
	var startPos = 0;
	var endPos = 0;
	var routine;
	var tempoClock60;
	var outputBus;
	var group;

	// GUI
	var dragSink;
	var soundFileView;
	var playbackSpeedSlider;
	var wowAndFlutterSlider;
	var randomPlayStartSlider;
	var gainSlider;

	*new { |parent, bounds, bus = 0, group = nil|
		^super.new.init(parent, bounds, bus, group);
	}

	free {
		if (soundFile != nil) { soundFile.close };
		if (buffer != nil) { buffer.free };
	}

	init { |parent, bounds, bus, argGroup|
		outputBus = bus;
		group = argGroup;
		tempoClock60 = TempoClock.new(1);

		view = CompositeView(parent, bounds);

		soundFileView = SoundFileView(view, bounds);
		soundFileView.gridOn = false;
		soundFileView.timeCursorOn = true;
		soundFileView.drawsBoundingLines = false;
		soundFileView.mouseWheelAction = { |view, x, y, modifiers, xDelta, yDelta|
			var zoomFactor = 0.9;

			if ((soundFile != nil) && (yDelta > 0) && (soundFileView.bounds.width > 0)) {
				soundFileView.xZoom = soundFileView.xZoom * 0.9;
				soundFileView.scroll(x / soundFileView.bounds.width * (1 - zoomFactor));
			};
			if ((soundFile != nil) && (yDelta < 0) && (soundFileView.bounds.width > 0)) {
				soundFileView.xZoom = min(soundFileView.xZoom / zoomFactor, soundFile.numFrames / soundFile.sampleRate);
			};
		};

		// file loading
		soundFileView.canReceiveDragHandler_({
			true
		});
		soundFileView.receiveDragHandler_({
			var path, tempSoundFile, tempBuffer;
			path = View.currentDrag;
			tempSoundFile = SoundFile.new;
			if (tempSoundFile.openRead(path)) {
				if (tempSoundFile.numChannels == 1, {
					tempBuffer = Buffer.readChannel(Server.default, path, channels: [0, 0], action: { |b|
						this.buffer = b;
					});
				}, {
					tempBuffer = Buffer.readChannel(Server.default, path, channels: [0, 1], action: { |b|
						this.buffer = b;
					});
				});
				soundFileView.soundfile_(tempSoundFile);
				soundFileView.readWithTask(0, tempSoundFile.numFrames, doneAction: {
					if (soundFile != nil, { soundFile.close });
					soundFile = tempSoundFile;
				});
			}
		});

		// selection handling
		soundFileView.mouseUpAction = { |v|
			var startPos, endPos;
			startPos = v.selection(0)[0];
			endPos = v.selection(0)[1] + startPos;
			this.setSelection(startPos, endPos);
		};

		gainSlider = GSlider(view, initValue: gain.ampdb, spec: ControlSpec(-inf, 12,\db, default: gain.ampdb), name: "Gain (dB)").action_({ |obj, value| this.gain = value.dbamp });
		playbackSpeedSlider = GSlider(view, initValue: playbackSpeed, spec: ControlSpec(-2, 2,\lin), name: "Speed (x)").action_({ |obj, value| this.playbackSpeed = value });
		wowAndFlutterSlider = GSlider(view, initValue: wowAndFlutterPercentage, spec: ControlSpec(0, 100, CurveWarp([0,100].asSpec, 4)), name: "Wow and Flutter (%)").action_({ |obj, value| this.wowAndFlutterPercentage = value });
		randomPlayStartSlider = GSlider(view, initValue: randomPlayStartPercentage, spec: ControlSpec(0, 50, CurveWarp([0,50].asSpec, 6)), name: "Randomize play start (%)").action_({ |obj, value| this.randomPlayStartPercentage = value });

		view.layout = VLayout(soundFileView, gainSlider, playbackSpeedSlider, wowAndFlutterSlider, randomPlayStartSlider).margins_(0).spacing_(2);
	}

	wowAndFlutterPercentage_ { |value|
		wowAndFlutterPercentage = value;
		wowAndFlutterSlider.value = value;
		if (synth != nil) {
			synth.set(\wowAndFlutter, wowAndFlutterPercentage/100);
		}
	}

	playbackSpeed_ { |value|
		playbackSpeed = value;
		playbackSpeedSlider.value = value;
		if (synth != nil) {
			synth.set(\rate, playbackSpeed);
		}
	}

	randomPlayStartPercentage_ { |value|
		randomPlayStartPercentage = value;
		randomPlayStartSlider.value = value;
	}

	gain_ { |value|
		gain = value;
		if (gain > 0) {
			soundFileView.yZoom = gain;
		};
		if (synth != nil) {
			synth.set(\amp, gain);
		};
	}

	setSelection { |start, end|
		startPos = start;
		endPos = end;
		if (synth != nil) {
			synth.set(\startPos, startPos);
		}
	}

	isTempoSynced {
		^((startPos == endPos) && (playbackSpeed != 0));
	}

	buffer_ { |b|
		if (buffer != nil, {
			if (synth != nil) {
				synth.set(\bufnum, b);
				// retrig
				synth.set(\gate, 0);
				synth.set(\gate, 1);
			};
			buffer.free;
		});
		buffer = b;
	}

	play {
		if (buffer != nil) {
			if (this.isTempoSynced(), {
				// tempo synced
				var pos;
				pos = max(0, startPos + ((randomPlayStartPercentage/100).bilinrand * buffer.numFrames)).round;
				synth = Synth(\gMultiLooperPlayer, [out: outputBus, bufnum: buffer, rate: playbackSpeed, gate: 1, wowAndFlutter: (wowAndFlutterPercentage/100), startPos: pos, amp: gain], group);
			}, {
				// not tempo synced
				if ((routine == nil || routine.isPlaying().not), {
					routine = Routine.new({
						if (synth != nil, {
							synth.set(\gate, 0);
						});
						while({ this.isTempoSynced().not }, {
							var pos, duration;
							pos = max(0, startPos + ((randomPlayStartPercentage/100).bilinrand * buffer.numFrames)).round;
							// approximation of loop duration (could change while playing but do not care)
							duration = (endPos - startPos) / buffer.sampleRate / playbackSpeed.abs;
							duration = max(0.025, duration);
							synth = Synth(\gMultiLooperPlayer, [out: outputBus, bufnum: buffer, rate: playbackSpeed, gate: 1, wowAndFlutter: (wowAndFlutterPercentage/100), startPos: pos, amp: gain], group);
							duration.wait;
							synth.set(\gate, 0);
						});
					});
					routine.play(tempoClock60);
				});
			});
		}
	}

	release {
		if ((this.isTempoSynced() && (synth != nil)), {
			// tempo synced
			synth.set(\gate, 0);
		});
	}

	stop {
		if ((routine != nil) && routine.isPlaying()) {
			routine.stop;
		};
		if (synth != nil) {
			synth.set(\gate, 0);
			synth = nil;
		}
	}
}
