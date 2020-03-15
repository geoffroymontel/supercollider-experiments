MidiCCBusAllocator {
	var <server = nil;
	var <ccNumber = nil;
	var <bus = nil;
	var <minValue = 0.0;
	var <maxValue = 1.0;
	var <curve = 0.0;
	var <surviveCmdPeriod = false;
	var midifunc = nil;
	var learnCCFunc = nil;
	var currentValue = nil;

	*new { |server, ccNumber = 0, minValue = 0.0, maxValue = 1.0, curve = 0, surviveCmdPeriod = false|
		^super.new.init(server, ccNumber, minValue, maxValue, curve, surviveCmdPeriod);
	}

	init { |server1, ccNumber1, minValue1, maxValue1, curve1, surviveCmdPeriod1|
		server = server1;
		ccNumber = ccNumber1;
		minValue = minValue1;
		maxValue = maxValue1;
		curve = curve1;
		surviveCmdPeriod = surviveCmdPeriod1;
		bus = Bus.control(server, 1);
		currentValue = minValue1;
		bus.set(currentValue);
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

	asMap {
		^bus.asMap;
	}

	value {
		^currentValue;
	}

	registerMidiFunc {
		if (midifunc != nil) {
			midifunc.free;
		};

		midifunc = MIDIFunc.cc({ |value, cc|
			currentValue = value.lincurve(0, 127, minValue, maxValue, curve);
			bus.set(currentValue);
		}, ccNumber);

		if (surviveCmdPeriod, {
			midifunc.permanent = true;
		}, {
			midifunc.permanent = false;
		});
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

	surviveCmdPeriod_ { |value|
		surviveCmdPeriod = value;
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