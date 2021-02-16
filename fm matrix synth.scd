// http://sccode.org/1-4SM

///////////////////////////////////////////
// a basic FM Matrix Synth, now with 1to1 feedback.
s.boot;
q = q ? ();
q.numOscs = 10;

// original version

(
Ndef(\fmMatrix, {
	var numOscs = q.numOscs;

	var oscs;
	var freqs = \freqs.kr({|i| 500}!numOscs);
	var modIndex = \modIndex.kr({|i|   0}!(numOscs**2)).clump(numOscs).postln;
	var amps     = \amps    .kr(0!numOscs);
	var tmpOsc;
	var feedbacks = LocalIn.ar(numOscs);


	oscs = freqs.inject([], {|oscArray, freq, i|
		tmpOsc = SinOsc.ar(
			freq
			+ oscArray.inject(0, {|sum, osc, j|
				sum
				// modulators from already instantiated oscs
				//+ (osc * modIndex[i][j] * freq)
				+ (feedbacks[j] * modIndex[i][j] * freq)
			})
			+ (numOscs - 1 - Array.iota(numOscs - (i))).postln.inject(0, {|sum, g|
				sum
				// modulators from to be instantiated oscs
				+ (feedbacks[g] * modIndex[i][g] * freq)
			})
			// self modulation
			//modIndex[i][i]
		);

		oscArray ++ tmpOsc;
	}); // end inject


	LocalOut.ar(oscs);
	//SplayAz.ar(8, oscs * amps, center: LFSaw.kr(0.01));
	Splay.ar(oscs * amps);
})
)

// my version

(
Ndef(\fmMatrix, {
	var numOscs = q.numOscs;

	var oscs = [];
	var freqs = \freqs.kr({500}!numOscs);
	var modIndex = \modIndex.kr({0}!(numOscs**2)).clump(numOscs).postln;
	var amps     = \amps.kr(0!numOscs);
	var tmpOsc;
	var feedbacks = LocalIn.ar(numOscs);

	numOscs.do( { |i|
		oscs = oscs ++ SinOsc.ar(
			freqs[i] +
			Mix.ar(feedbacks.collect { |feedback, j|
				feedback * modIndex[i][j] * freqs[i]
			})
		);
	});

	LocalOut.ar(oscs);
	//SplayAz.ar(8, oscs * amps, center: LFSaw.kr(0.01));
	Splay.ar(oscs * amps);
})
)


// the standard Ndef gui. to hear something, press play.
Ndef(\fmMatrix).gui;
Ndef(\fmMatrix).setn(\modIndex, 0!(q.numOscs**2));


//
(
var specs = (
	freqs: [0, 10000, \lin, 0.1].asSpec,
	modIndex: [0, 4, \lin, 0].asSpec;
);
var modIndex     = Ndef(\fmMatrix).get(\modIndex).clump(q.numOscs);
var freqState = Ndef(\fmMatrix).get(\freqs);
var ampState     = Ndef(\fmMatrix).get(\amps);


var colWidth = 40;
var knobHeight = 50;
var idxKnobColors   = [
	// upper right area
	[Color.gray(0.8), Color.blue, blend(Color.white, Color.blue, 0.5)],
	[Color.gray(0.8), Color.blue, blend(Color.white, Color.blue, 0.2)],
	// lower left area
	[Color.gray(0.8), Color.red, blend(Color.white, Color.red, 0.5)],
	[Color.gray(0.8), Color.red, blend(Color.white, Color.red, 0.2)]
];
var bgColors = [
	Color.gray(0.8), Color.gray(1),
	Color.gray(0.6), Color.gray(0.8),
];
q.win = Window.new("FM Matrix", Rect(100, 100, (q.numOscs+5) * colWidth, 800)).front;
q.win.addFlowLayout;
/////////// INDEXES

StaticText(q.win, Rect(10, 10, q.numOscs * (colWidth + 5) + 150, 20)).string_("-- modulation index ");
q.win.view.decorator.nextLine;
q.higherAmpSliders = q.numOscs.collect{|i|
	var slider;
	//(i+1).do{|j|
	q.numOscs.do{|j|
		var ez;

		ez = EZKnob(q.win, Rect(25, 25, colWidth, knobHeight),
			controlSpec: specs[\modIndex],
			initAction: true,
			initVal: modIndex[i][j]
		)
		.action_{|knob|
			modIndex[i][j] = knob.value;
			Ndef(\fmMatrix).setn(\modIndex, modIndex.flat);
		};
		ez.knobView.mode_(\vert);
		((j) > i).if({
			ez.setColors(knobColors: idxKnobColors[j%2]);
			ez.setColors(background: bgColors     [j%2]);
		}, {
			ez.setColors(knobColors: idxKnobColors[j%2 + 2]);
			ez.setColors(background: bgColors     [j%2 + 2]);
		});

		(i == j).if{
			ez.knobView.color_([Color.gray, Color.blue, Color.green]);
		};
	};
	slider = EZSlider(q.win, Rect(0, 0, 150, knobHeight * 0.5),
		label: i,
		layout: 'horz',
		numberWidth: 0,
		labelWidth: 10,
		initVal: ampState[i]
	)
	.action_{|slider|
		ampState[i] = slider.value;
		q.lowerAmpSliders[i].value = slider.value;
		Ndef(\fmMatrix).setn(\amps, ampState);
	};
	slider.setColors(background: bgColors[i%2 + 2]);

	q.win.view.decorator.nextLine;

	// return
	slider
};
q.win.view.decorator.nextLine;


/////////// FREQS
StaticText(q.win, Rect(10, 10, q.numOscs * (colWidth + 5), 20)).string_("-- freqs ----------");

q.win.view.decorator.nextLine;
q.numOscs.do{|i|
	var ez;
	ez = EZKnob(q.win, Rect(0, 0, colWidth, knobHeight),
		controlSpec: specs[\freqs],
		initAction: true,
		initVal: freqState[i]

	)
	.action_{|knob|
		freqState[i] = knob.value;
		Ndef(\fmMatrix).setn(\freqs, freqState);
	};
	ez.knobView.mode_(\vert);
	ez.setColors(background: bgColors[i%2 + 2]);
};

/////////// AMPS
q.win.view.decorator.nextLine;
StaticText(q.win, Rect(10, 10, q.numOscs * (colWidth + 5), 20)).string_("-- amps ----------");
q.win.view.decorator.nextLine;
q.lowerAmpSliders = q.numOscs.collect{|i|
	var ez;

	ez = EZSlider(q.win, Rect(0, 0, colWidth, 150),
		label: i,
		layout: 'vert',
		initVal: ampState[i]
	)
	.action_{|slider|
		ampState[i] = slider.value;
		Ndef(\fmMatrix).setn(\amps, ampState);
		q.higherAmpSliders[i].value = slider.value;
	};
	ez.setColors(background: bgColors[i%2 + 2]);
}
)