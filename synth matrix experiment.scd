// need Mktl quark

// create a synth that plays on N buses
(
~number = 10;

// synth
SynthDef(\synth, {
	var out = \out.kr(0);
	var freq = \freq.kr(440);
	var detune = \detune.kr(0);
	var gate = \gate.kr(1);
	var signal;
	signal = ~number.collect({
		[SinOsc, FSinOsc, Saw, Pulse].choose.ar(
			freq: (freq.cpsmidi + (LFNoise1.kr(rrand(0.1, 2.0)) * (detune/100))).midicps
		) / ~number * -3.dbamp * EnvGen.kr(Env.asr, gate)
	});
	signal = Splay.ar(signal); // if you want to test it in stereo
	Out.ar(out, signal);
}).add;
)

Synth(\synth, [detune: 15]);

// draw black keys on top of whites, use MPadViews
(
~win = Window("PianoLayout", Rect(0, 200, 400, 150)).front;

// sort black before white keys so we draw them on top
~layouts = Piano.layout(48, 72).sort { |a, b| a.color > b.color };

~synthsPlaying = Array.newClear(73);

// draw MPadViews as keys
~keys = ~layouts.collect { |ev|
	var color = Color.perform(ev.color);
	var height = ev.h * 60;
	var rect = Rect(ev.x + (1-ev.w/2) * 24 + 4, 4, 24 * ev.w, height);
	var pad = MPadView(~win, rect).mode_(\noteOnOffTouch);
	pad.baseColor_(color).label_(ev.note);
	pad.vShiftLabel_( ev.h * 15);
	pad.action = { |pd|
		"pad %    on: % \n".postf(ev.note, pd.value.round(0.001));
		if (~synthsPlaying[ev.note] == nil) {
			~synthsPlaying[ev.note] = Synth(\synth, [freq: ev.note.midicps, detune: pd.value * 100]);
		};
	};
	pad.upAction = { |pd|
		"pad %   off: % \n".postf(ev.note, pd.upValue.round(0.001));
		if (~synthsPlaying[ev.note] != nil) {
			~synthsPlaying[ev.note].release;
			~synthsPlaying[ev.note] = nil;
		};
	};
	pad.moveAction = { |pd| "pad % touch: % \n".postf(ev.note, pd.moveValue.round(0.001));
		if (~synthsPlaying[ev.note] != nil) {
			~synthsPlaying[ev.note].set(\detune, pd.moveValue * 100);
		};
	};
};
)
