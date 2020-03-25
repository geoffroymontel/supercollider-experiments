// ************************************
// Granular Synthesis Demo (GUI)
// Patch 1 - Granular Sampling
// Bruno Ruviaro, 2013-08-20
// ************************************

/*

Use the "Open New File" button to load a WAVE or AIFF file.
This granulator needs a mono file. If you open a stereo file,
only the left channel will be actually used (though you will
see both channels displayed on the Sound File View).

Trigger: number of grains being triggered per second.
Transp: rate of transposition in semitones.
grainDur: duration of individual grains.
Pan: distribution of grains in the stereo field (left / right).
grainAmp: amplitude of individual grains.
Reverse: probability of a grain to be played backwards (0-100%).

Grains will be chosen randomly from anywhere within
the selected portion of the sound file. You can select
portions of the sound file in two different ways:
a) directly on the waveform (click and drag);
b) using the Selection Slider just below the waveform display.

You can also zoom in and out the waveform
with Shift + Right Click + Mouse Up/Down
(Note: the selection slider will not follow the zoom.
The slider always reflects the position of current
selection in regard to the total duration of the file)

How to start: select all (ctrl + A), then evaluate (ctrl + enter).
(on a Mac, use the command key instead of control)

If you want to have several windows open to granulate different sounds,
comment out the lines Window.closeAll and Buffer.freeAll

*/

s.waitForBoot({
	var win, soundFile, soundFileView, subwin, centerPosSlider, centerPosInSeconds, triggerSlider, transpSlider, transpToRate, durSlider, panSlider, ampSlider, reverseSlider, buffer, synth, startButton, openButton, selectionSpec;


	// FUNCTIONS

	// Convert transpSlider values (in semitones)
	// to rate values for TGrains (1 = no transp):
	transpToRate = {arg transp; transp.linexp(-24, 24, 0.25, 4)};

	// Convert from centerPosSlider values (0-1)
	// to actual sound file position in seconds:
	centerPosInSeconds = {
		[
			centerPosSlider.lo.linlin(0, 1, 0, soundFile.duration),
			centerPosSlider.hi.linlin(0, 1, 0, soundFile.duration)
		] // returns an array [lo, hi]
	};

	Window.closeAll;
	Buffer.freeAll;

	// Main window
	win = Window.new("Granular Sampling", Rect(50, 50, 600, 580), false).front;
	win.background = Color.grey(0.1, 0.9);
	win.onClose = {s.freeAll};

	// Sound File View
	soundFileView = SoundFileView.new(win, Rect(30, 20, 540, 200))
	// .soundfile_(soundFile)
	// .read(0, soundFile.numFrames)
	.gridOn_(false);

	// What to do when user selects portion of sound file directly
	// (i.e., on waveform, not using slider)
	soundFileView.mouseUpAction = {arg view;
		var loFrames, hiFrames, loSlider, hiSlider;
		loFrames = view.selection(0)[0];
		hiFrames = view.selection(0)[1] + loFrames;
		postf("lo = %, hi = %\n", loFrames, hiFrames);
		loSlider = selectionSpec.unmap(loFrames);
		hiSlider = selectionSpec.unmap(hiFrames);
		2.do{centerPosSlider.setSpanActive(loSlider, hiSlider)}; // 2.do = hack...
	};

	// Open Button
	openButton = Button.new(win, Rect(460, 20, 110, 30))
	.states_([["open new file", Color.black, Color.gray]])
	.action_({

		"HELLO".postln;
		// Stop whatever is playing
		s.freeAll;

		startButton.value = 0;

		Dialog.openPanel(
			okFunc: { |path|
				soundFile = SoundFile.new;
				soundFile.openRead(path);
				// Load sound into buffer
				buffer = Buffer.readChannel(s, path, channels: [0]);
				// Display sound on View
				soundFileView.soundfile_(soundFile);
				soundFileView.read(0, soundFile.numFrames);
				// ControlSpec (slider 0-1 <=> numFrames)
				selectionSpec = ControlSpec(0, soundFile.numFrames);
				// selectionSpec.postln;
				// Set initial selection on View
				soundFileView.setSelection(0, selectionSpec.map([0.1, 0.2]));
				// Update slider
				soundFileView.mouseUpAction.value(soundFileView);
			},
			cancelFunc: {"cancelled"}
		);



	});


	// Sub view to group all sliders
	subwin = CompositeView.new(win, Rect(20, 225, 560, 360))
	// .background_(Color.red(0.4))
	;
	subwin.decorator = FlowLayout(subwin.bounds, margin: 0@0, gap: 5@10);

	centerPosSlider = RangeSlider(subwin, 560@50)
	.lo_(0.1)
	.hi_(0.3)
	.action_({ |v|
		var lo, hi, size;
		lo = selectionSpec.map(v.lo);
		hi = selectionSpec.map(v.hi);
		size = hi - lo;
		soundFileView.setSelection(0, [lo, size]);
		if(startButton.value==1, {synth.set(
			\centerPosLo, centerPosInSeconds.value[0],
			\centerPosHi, centerPosInSeconds.value[1])});
		// ["uau", v.lo, v.hi, lo, hi].postln;
	});

	triggerSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Trigger  ",
		controlSpec: ControlSpec(
			minval:	0.5,
			maxval: 50,
			warp: 'exp',
			step: 0.1,
			units: " t/s"),
		action: {|v|
			if(startButton.value==1, {synth.set(\triggerLo, v.lo, \triggerHi, v.hi)})},
		initVal: [1, 2],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	transpSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Transp  ",
		controlSpec: ControlSpec(
			minval:	-24, // two octaves below
			maxval: 24, // two octaves above
			warp: 'lin',
			step: 1, // step by semitones
			units: " ST"),
		action: {|v|
			if(startButton.value==1, {
				synth.set(
					\rateLo, transpToRate.value(v.lo),
					\rateHi, transpToRate.value(v.hi))})},
		initVal: [0, 0],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	durSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "grainDur  ",
		controlSpec: ControlSpec(
			minval:	0.1,
			maxval: 2,
			warp: 'lin',
			step: 0.1,
			units: "sec"),
		action: {|v|
			if(startButton.value==1, {synth.set(\durLo, v.lo, \durHi, v.hi)})},
		initVal: [0, 0],
		labelWidth: 70,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	panSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "Pan     ",
		controlSpec: ControlSpec(
			minval:	-1,
			maxval: 1,
			warp: 'lin',
			step: 0.1,
			units: "L/R"),
		action: {|v|
			if(startButton.value==1, {synth.set(\panLo, v.lo, \panHi, v.hi)})},
		initVal: [0, 0],
		labelWidth: 60,
		unitWidth: 30)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	ampSlider = EZRanger(
		parent: subwin,
		bounds: 560@30,
		label: "grainAmp ",
		controlSpec: ControlSpec(
			minval:	0.0,
			maxval: 1,
			warp: 'lin',
			step: 0.01,
			units: "amp"),
		action: {|v|
			if(startButton.value==1, {synth.set(\ampLo, v.lo, \ampHi, v.hi)})},
		initVal: [0.2, 0.4],
		labelWidth: 73,
		unitWidth: 35)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	reverseSlider = EZSlider(
		parent: subwin,
		bounds: 560@30,
		label: "Reverse  ",
		controlSpec: ControlSpec(
			minval:	0,
			maxval: 100,
			warp: 'lin',
			step: 1,
			units: "%"),
		action: {|v|
			if(startButton.value==1, {synth.set(\reverseProb, v.value/100)});
		},
		initVal: 0.0,
		labelWidth: 63,
		unitWidth: 35)
	.setColors(Color.grey,Color.white, Color.grey(0.7),Color.grey, Color.white, Color.yellow);

	startButton = Button.new(subwin, 560@40)
	.states_([["START"], ["STOP", Color.black, Color.gray]])
	.action_({arg button;
		if(button.value==1,
			{
				synth = Synth("granular-sampling", [
					\triggerLo, triggerSlider.lo,
					\triggerHi, triggerSlider.hi,
					\rateLo, transpToRate.value(transpSlider.lo),
					\rateHi, transpToRate.value(transpSlider.hi),
					\centerPosLo, centerPosInSeconds.value[0],
					\centerPosHi, centerPosInSeconds.value[1],
					\durLo, durSlider.lo,
					\durHi, durSlider.hi,
					\panLo, panSlider.lo,
					\panHi, panSlider.hi,
					\ampLo, ampSlider.lo,
					\ampHi, ampSlider.hi,
					\reverseProb, reverseSlider.value,
					\bufnum, buffer.bufnum]);
			},
			{synth.free});
	});


	// SynthDef
	SynthDef("granular-sampling", {
		arg triggerLo, triggerHi, rateLo, rateHi, centerPosLo, centerPosHi, durLo, durHi, panLo, panHi, ampLo, ampHi, reverseProb, bufnum;

		var trig, trigFreqMess, rate, centerPos, dur, pan, amp, coin, reverse, snd;
		// var bufdur = BufDur.kr(buffer);

		trigFreqMess = LFNoise2.kr(12).range(0.5, 1);
		trig = Impulse.kr(LFNoise0.kr(trigFreqMess).range(triggerLo, triggerHi));

		rate = Dwhite(rateLo, rateHi);
		centerPos = Dwhite(centerPosLo, centerPosHi);
		dur = Dwhite(durLo, durHi);
		pan = Dwhite(panLo, panHi);
		amp = Dwhite(ampLo, ampHi);
		coin = CoinGate.kr(reverseProb, trig);
		reverse = Select.kr(coin, [1, -1]);
		// reverse.poll(trig);

		Demand.kr(trig, 0, [rate, centerPos, dur, pan, amp]);

		snd = TGrains.ar(
			numChannels: 2,
			trigger: trig,
			bufnum: bufnum,
			rate: rate * reverse,
			centerPos: centerPos,
			dur: dur,
			pan: pan,
			amp: amp);

		Out.ar(0, snd);

	}).add;

}); // end of block