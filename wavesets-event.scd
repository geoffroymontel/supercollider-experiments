// Quarks.install("https://github.com/musikinformatik/WavesetsEvent");

WavesetsEvent.tutorial

// more elaborate GUI
(

~wavesets = ~wavesets ?? {
	WavesetsEvent.read(Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff")
};

WavesetsEvent.prepareSynthDefs;


// edit me while playing
Tdef(\u, {
	inf.do { |i|
		var event;
		event = (
			start: ~start ? 0,
			num: rrand(100, 1000),
			rate: 1.0,
			rate2: 1.0,
			repeats:1,
			amp: 0.1
		);
		event = ~wavesets.asEvent(event);
		event.play;
		event[\dur].wait;
	}
}).play;
)


// search for interesting offsets

/*
keyboard:
space: 	start Tdef(\u)
f		post current file path
*/

(
var w = Window("time bandit", Rect(100, 100, 820, 50)).front;
var sl = Slider(w).orientation_(\horizontal);
var b = Button(w).states_([["open"]]);
b.action = {
	Dialog.openPanel({ |path|
		var ws = WavesetsEvent.new;
		ws.readChannel(path, onComplete: { ~wavesets = ws; ~path = path })
	})
};
sl.action = { |view| ~start = view.value.linlin(0, 1, 0, ~wavesets.size) };
sl.keyDownAction = { |view, char|
	switch(char,
		$f, { ~path.postcs },
		$ , { Tdef(\u).play },
		{ ~start.post; ",".postln }
	)
};
w.layout = HLayout(sl, b);
)