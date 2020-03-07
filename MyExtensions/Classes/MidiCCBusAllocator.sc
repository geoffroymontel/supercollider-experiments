MidiCCBusAllocator {
	var <server = nil;
	var <ccNumber = nil;
	var <bus = nil;
	var <minValue = 0.0;
	var <maxValue = 1.0;
	var <curve = 0.0;
	var midifunc = nil;
	var learnCCFunc = nil;

	*new { |server, ccNumber = 0, minValue = 0.0, maxValue = 1.0, curve = 0|
		^super.new.init(server, ccNumber, minValue, maxValue, curve);
	}

	init { |server1, ccNumber1, minValue1, maxValue1, curve1|
		server = server1;
		ccNumber = ccNumber1;
		minValue = minValue1;
		maxValue = maxValue1;
		curve = curve1;
		bus = Bus.control(server, 1);
		bus.set(minValue1);
		this.registerMidiFunc();
	}

	learnCC {
		learnCCFunc = MIDIFunc.cc({ |value, cc|
			learnCCFunc.free;
			ccNumber = cc;
			this.registerMidiFunc();
			postf("Mapped to CC #%\n", ccNumber);
		});
	}

	asBus {
		^bus;
	}

	registerMidiFunc {
		if (midifunc != nil) {
			midifunc.free;
		};

		midifunc = MIDIFunc.cc({ |value, cc|
			bus.set(value.lincurve(0, 127, minValue, maxValue, curve));
		}, ccNumber);
	}

	ccNumber_ { |value|
		ccNumber = value;
		this.registerMidiFunc();
	}

	minValue_ { |value|
		minValue = value;
		this.registerMidiFunc();
	}

	maxValue_ { |value|
		minValue = value;
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