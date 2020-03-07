MidiCCBusAllocator {
	var <server = nil;
	var <ccNumber = nil;
	var <bus;
	var <minVal = 0.0;
	var <maxVal = 1.0;
	var <curve = 0.0;
	var midifunc = nil;
	var learnCCFunc = nil;

	*new { |server, ccNumber = 0, minVal = 0.0, maxVal = 1.0, curve = 0|
		^super.new.init(server, ccNumber, minVal, maxVal, curve);
	}

	init { |server1, ccNumber1, minVal1, maxVal1, curve1|
		server = server1;
		ccNumber = ccNumber1;
		minVal = minVal1;
		maxVal = maxVal1;
		curve = curve1;
		bus = Bus.control(server, 1);
		this.registerMidiFunc();
	}

	asBus {
		^bus;
	}

	learnCC {
		learnCCFunc = MIDIFunc.cc({ |value, cc|
			learnCCFunc.free;
			ccNumber = cc;
			this.registerMidiFunc();
			postf("Mapped to CC #%\n", ccNumber);
		});
	}

	registerMidiFunc {
		if (midifunc != nil) {
			midifunc.free;
		};

		midifunc = MIDIFunc.cc({ |value, cc|
			bus.set(value.lincurve(0, 127, minVal, maxVal, curve));
		}, ccNumber);
	}

	ccNumber_ { |value|
		ccNumber = value;
		this.registerMidiFunc();
	}

	minVal_ { |value|
		minVal = value;
		this.registerMidiFunc();
	}

	maxVal_ { |value|
		minVal = value;
		this.registerMidiFunc();
	}

	curve_ { |value|
		curve = value;
		this.registerMidiFunc();
	}

	free {
		if (midifunc != nil) {
			midifunc.free;
		};

		if (bus != nil) {
			bus.free;
		};
	}
}