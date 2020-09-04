GMultiGranularizerTrack : SCViewHolder {
	// PUBLIC
	var <soundFile = nil;
	var <buffer = nil;
	var <gain = 1.0;

	// PRIVATE
	var startPos = 0;
	var endPos = 0;
	var tempoClock60;
	var outputBus;
	var group;
	var parentGroup;
	var routine;
	var attack = 0.001;
	var sustain = 1.0;
	var release = 0.001;
	var triggerGrainEveryMin = 0.001;
	var triggerGrainEveryMax = 20;
	var playbackSpeed = 1.0;

	// GUI
	var dragSink;
	var soundFileView;
	var gainSlider;
	var playbackSpeedSlider;
	var triggerGrainEveryRangeSlider;
	var attackSlider;
	var sustainSlider;
	var releaseSlider;

	*new { |parent, bounds, bus = 0, group = nil|
		^super.new.init(parent, bounds, bus, group);
	}

	free {
		if (soundFile != nil) { soundFile.close };
		if (buffer != nil) { buffer.free };
		group.free;
	}

	init { |parent, bounds, bus, argGroup|
		outputBus = bus;
		parentGroup = argGroup;
		group = Group.new(parentGroup);
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

		gainSlider = GSlider(view, initValue: gain.ampdb, spec: ControlSpec(-inf, 12,\db, default: gain.ampdb), name: "Gain (dB)").action_({ |obj, value| gain = value.dbamp; group.set(\amp, gain); });

		triggerGrainEveryRangeSlider = GRangeSlider(view, bounds, triggerGrainEveryMin, triggerGrainEveryMax, ControlSpec(triggerGrainEveryMin, triggerGrainEveryMax, CurveWarp([triggerGrainEveryMin,triggerGrainEveryMax].asSpec, 6)), "trigger (s)").action_({ |obj, value| triggerGrainEveryMin = value[0]; triggerGrainEveryMax = value[1]; });

		playbackSpeedSlider = GSlider(view, initValue: playbackSpeed, spec: ControlSpec(-4, 4,\lin), name: "Speed (x)").action_({ |obj, value| playbackSpeed = value; group.set(\rate, playbackSpeed); });

		attackSlider = GSlider(view, bounds, attack, ControlSpec(0.001, 10, CurveWarp([0.001, 10].asSpec, 6)), "Attack (s)").action_( { |obj, value| attack = value; });
		sustainSlider = GSlider(view, bounds, sustain, ControlSpec(0.001, 10, CurveWarp([0.001, 10].asSpec, 6)), "Sustain (s)").action_( { |obj, value| sustain = value; });
		releaseSlider = GSlider(view, bounds, release, ControlSpec(0.001, 10, CurveWarp([0.001, 10].asSpec, 6)), "Release (s)").action_( { |obj, value| release = value; });

		view.layout = VLayout(soundFileView, gainSlider, playbackSpeedSlider, triggerGrainEveryRangeSlider, attackSlider, sustainSlider, releaseSlider).margins_(0).spacing_(2);
	}

	gain_ { |value|
		gain = value;
		if (gain > 0) {
			soundFileView.yZoom = gain;
		};
	}

	setSelection { |start, end|
		startPos = start;
		endPos = end;
	}

	buffer_ { |b|
		if (buffer != nil, {
			buffer.free;
		});
		buffer = b;
	}

	play {
		if (routine != nil) {
			routine.stop;
		};
		if (buffer != nil) {
			routine = Routine.new({
				loop {
					var pos, duration;
					pos = rrand(startPos, endPos);
					duration = 1;
					Synth(\gMultiGranularizerGrain, [out: outputBus, bufnum: buffer, rate: playbackSpeed, amp: gain, startPos: pos, attackTime: attack, sustainTime: sustain, releaseTime: release, curve: 0, pan: 0], group);
					exprand(triggerGrainEveryMin, triggerGrainEveryMax).wait;
				};
			});
			routine.play(tempoClock60);
		};
	}

	stop {
		if (routine != nil) {
			routine.stop;
		}
	}
}
