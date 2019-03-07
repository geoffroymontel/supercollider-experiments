// please install Modality-toolkit quark
Quarks.gui;

(
~number = 10;

// create buses and group
if (~synthsOutputBus == nil) { ~synthsOutputBus = Bus.audio(s, ~number); };
if (~filtersInputBus == nil) {~filtersInputBus = Bus.audio(s, ~number); };
if (~filtersOutputBus == nil) {~filtersOutputBus = Bus.audio(s, ~number); };
~synthsGroup = Group.new;
~matrixGroup = Group.after(~synthsGroup);
~filtersGroup = Group.after(~matrixGroup);
~masterGroup = Group.after(~filtersGroup);

// synth
SynthDef(\synth, { |out=0, freq=440, detune=0, gate=1|
	var signal;
	signal = ~number.collect({
		[SinOsc, FSinOsc, Saw, Pulse].choose.ar(
			freq: (freq.cpsmidi + (LFNoise1.kr(rrand(0.1, 2.0)) * (detune/100))).midicps
		) / ~number * -3.dbamp * EnvGen.kr(Env.asr(), gate, doneAction: Done.freeSelf)
	});
	// signal = Splay.ar(signal); // if you want to test it in stereo
	Out.ar(out, signal); // outputs to ~number channels
}).add;

// filters
SynthDef(\dfm1_HighPass, { |out=0, in=0, freq=440, res=0.1|
	var signal;
	signal = DFM1.ar(In.ar(in), freq, res, 1.0, 1.0);
	Out.ar(out, signal.tanh);
}).add;

SynthDef(\dfm1_LowPass, { |out=0, in=0, freq=440, res=0.1|
	var signal;
	signal = DFM1.ar(In.ar(in), freq, res, 1.0, 0.0);
	Out.ar(out, signal.tanh);
}).add;

SynthDef(\303, { |out=0, in=0, freq=440, res=0.1, dist=0.0|
	var signal;
	signal = RLPFD.ar(In.ar(in), freq, res, dist);
	Out.ar(out, (signal * 6.dbamp).tanh);
}).add;

SynthDef(\string_resonator, { |out=0, in=0, freq=440, res=0.9|
	var signal;
	signal = Streson.ar(In.ar(in), freq.reciprocal, res);
	Out.ar(out, signal.tanh);
}).add;

// Audiomulch like matrix routing but channel per channel
SynthDef(\routing, { |in=0, out=1, fadeTime=1, gate=1|
	var signal;
	signal = In.ar(in, 1) * EnvGen.kr(Env.asr(fadeTime, 1.0, fadeTime),gate, doneAction: Done.freeSelf);
	Out.ar(out, signal);
}).add;

// mix
SynthDef(\mixer, {
	Out.ar(0, Splay.ar(~number.collect({|i| In.ar(~filtersOutputBus.index+i, 1)})).tanh);
}).add;
)

(
// create mixer
~masterGroup.freeAll;
~mixer = Synth(defName: \mixer, target: ~masterGroup);

// generate N filters
~filtersGroup.freeAll;
~filtersPlaying = ~number.collect({ |i|
	Synth(
		// defName: [\dfm1_HighPass, \dfm1_LowPass, \303, \string_resonator].choose,
		defName: [\dfm1_HighPass, \dfm1_LowPass, \303].choose,
		args: [
			freq: rrand(0.0, 1.0).lincurve(0, 1, 100, 2000),
			res: rrand(0.0, 1.0).lincurve(0,1,0,0.6),
			dist:rrand(0.0, 1.0).lincurve(0,1,0,0.8),
			in: ~filtersInputBus.index + i,
			out: ~filtersOutputBus.index + i
		],
		target: ~filtersGroup
	);
});
)

// GUI
(
~win = Window("Synth Matrix Experiment", Rect(0, 100, 1220, 500)).front;

// KEYBOARD
// sort black before white keys so we draw them on top
~layouts = Piano.layout(24, 108).sort { |a, b| a.color > b.color };

~synthsPlaying = Array.newClear(109);

// draw MPadViews as keys
~keys = ~layouts.collect { |ev|
	var color = Color.perform(ev.color);
	var height = ev.h * 60;
	var rect = Rect((ev.x + ((1-ev.w)/2)) * 24 + 4, 4, 24 * ev.w, height);
	var pad = MPadView(~win, rect).mode_(\noteOnOffTouch);
	pad.baseColor_(color).label_(ev.note);
	pad.vShiftLabel_( ev.h * 15);
	pad.action = { |pd|
		"pad %    on: % \n".postf(ev.note, pd.value.round(0.001));
		if (~synthsPlaying[ev.note] == nil) {
			~synthsPlaying[ev.note] = Synth(\synth, [freq: ev.note.midicps, detune: pd.value * 100, out: ~synthsOutputBus], ~synthsGroup);
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

// MATRIX
~matrixPlaying = Array2D.new(~number, ~number);
~matrixGroup.freeAll;
~buttons = Array2D.new(~number, ~number);

~number.do({ |x|
	var startX = 100;
	var startY = 150;
	~number.do({ |y|
		var rect = Rect(startX + (x * 20), startY + (y * 20), 20, 20);
		~buttons[x, y] = Button(~win, rect)
		.states_([
			["", Color.black, Color.white],
			["", Color.white, Color.black]
		])
		.action_({ |butt|
			butt.value.postln;
			if (butt.value == 0) {
				"coucou".postln;
				if (~matrixPlaying[x,y] != nil) {
					"hey".postln;
					~matrixPlaying[x,y].release;
					~matrixPlaying[x,y] = nil;
				}
			} {
				~matrixPlaying[x,y] = Synth(\routing, [in: ~synthsOutputBus.index + x, out: ~filtersInputBus.index + y], ~matrixGroup);
			}
		});
	});
});
)

// automate routing with routines

(
~routine = {
	var i = 0;
	var x;
	loop {
		i = i % ~number;
		x = Synth(\routing, [in: ~synthsOutputBus.index + i, out: ~filtersInputBus.index + i], ~matrixGroup);
		1.0.wait;
		x.release;
		i = i + 1;
	}
}.fork
)

~routine.stop;

// automate routing with patterns
(
~pattern = Pbind(*[
	instrument: \routing,
	in: ~synthsOutputBus.index + Pwhite(0,~number -1),
	out: ~filtersInputBus.index + Pwhite(0,~number -1),
	dur: Pstutter(Prand([1, 2, 4, 8], inf), Pseq([1/8, 1/8, 1/8, Prand([1/8, 1/4, 1/2], inf)], inf)),
	group: ~matrixGroup,
	gui: Pfunc({ |ev|
		var in, out, dur;
		postf("in = %, out = %, dur = %\n", ev['in'].class, ev['out'], ev['dur']);
		in = ev['in'] - ~synthsOutputBus.index;
		out = ev['out'] - ~filtersInputBus.index;
		dur = ev['dur'];
		{
			~buttons[in, out].value = 1;

		}.defer;
		{
			~buttons[in, out].value = 0;
		}.defer(dur);
	})
]).play;
)
~pattern.stop
