BCF2000Mixer {
	var <server = nil;
	var <inBuses = nil;
	var <numChannelsPerTrack = nil;
	var <numTracks = nil;
	var group = nil;
	var trackSynths = nil;
	var limiterSynth = nil;
	var midifunc = nil;
	var volumeCurve = 4;

	*new { |server, numTracks = 8, numChannelsPerTrack = 2|
		^super.new.init(server, numTracks, numChannelsPerTrack);
	}

	init { |server1, numTracks1, numChannelsPerTrack1|
		server = server1;
		numTracks = numTracks1;
		numChannelsPerTrack = numChannelsPerTrack1;
		CmdPeriod.add(this);
		this.createMixerTracks();
	}

	cmdPeriod {
		// cmd period removes all groups, synths and MIDIFunc from the server
		// mark them as nil
		group = nil;
		trackSynths = nil;
		limiterSynth = nil;
		midifunc = nil;

		this.createMixerTracks();
	}

	createMixerTracks {
		forkIfNeeded {
			"[BCF2000Mixer] Creating group and synths.".postln;
			server.sync;
			group = Group.new(server, \addToTail);
			this.createBuses();
			this.createMixerTrackSynthDef();
			server.sync;
			this.createMixerTrackSynths();
			server.sync;
			this.registerMidiFunc();
		};
	}

	free {
		if (midifunc != nil) {
			midifunc.free;
			midifunc = nil;
		};

		if (inBuses != nil) {
			inBuses.collect(_.free);
			inBuses = nil;
		};

		if (trackSynths != nil) {
			trackSynths.collect(_.free);
			trackSynths = nil;
		};

		if (limiterSynth != nil) {
			limiterSynth.free;
			limiterSynth = nil;
		};

		if (group != nil) {
			group.free;
			group = nil;
		};

		CmdPeriod.remove(this);
	}

	createBuses {
		if (inBuses != nil) {
			inBuses.collect(_.free);
		};

		inBuses = numTracks.collect({ Bus.audio(server, numChannelsPerTrack) });
	}

	createMixerTrackSynthDef {
		SynthDef(\bcf2000MixerTrack, { |in = 0, out = 0, amp = 0.0, pan = 0.0|
			Out.ar(out, Balance2.ar(In.ar(in), In.ar(in+1), pan.lag(0.1)) *  amp.lag(0.1));
		}).add;
		SynthDef(\bcf2000MixerLimiter, { |out = 0|
			ReplaceOut.ar(out, In.ar(out).tanh);
		}).add;
	}

	createMixerTrackSynths {
		if (trackSynths != nil) {
			trackSynths.collect(_.free);
		};

		if (limiterSynth != nil) {
			limiterSynth.free;
		};

		trackSynths = numTracks.collect({ |i| Synth(\bcf2000MixerTrack, [in: inBuses[i], out: 0], group) });

		limiterSynth = Synth(\bcf2000MixerLimiter, [out: 0], group, \addToTail);
	}

	registerMidiFunc {
		if (midifunc != nil) {
			midifunc.free;
		};

		midifunc = MIDIFunc.cc({ |value, cc, chan|
			switch (cc,
				7, { trackSynths[chan].set(\amp, value.lincurve(0, 127, 0.0, 1.0, volumeCurve)) }, // faders
				10, { trackSynths[chan].set(\pan, value.linlin(0, 127, -1.0, 1.0)) } // pan pots
			);
		});
	}
}