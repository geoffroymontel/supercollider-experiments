BCF2000Mixer {
	var <server = nil;
	var <inBuses = nil;
	var <numChannelsPerTrack = nil;
	var <numTracks = nil;
	var <group = nil;
	var <trackSynths = nil;
	var midifunc = nil;
	var volumeCurve = -4;

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
			Out.ar(out, Balance2.ar(In.ar(in), In.ar(in+1), pan, amp));
		}).add;
	}

	createMixerTrackSynths {
		if (trackSynths != nil) {
			trackSynths.collect(_.free);
		};

		trackSynths = numTracks.collect({ |i| Synth(\bcf2000MixerTrack, [in: inBuses[i], out: 0], group) });
	}

	registerMidiFunc {
		if (midifunc != nil) {
			midifunc.free;
		};

		midifunc = MIDIFunc.cc({ |value, cc|
			switch (cc,
				0, { trackSynths[0].set(\amp, value.lincurve(0, 127, 0.0, 1.0, volumeCurve)) }, // fader 1
				1, { }, // fader 2
				2, { }, // fader 3
				3, { }, // fader 4
				4, { }, // fader 5
				5, { }, // fader 6
				6, { }, // fader 7
				7, { }, // fader 8
				8, { }, // pan 1
				9, { }, // pan 2
				10, { }, // pan 3
				11, { }, // pan 4
				12, { }, // pan 5
				13, { }, // pan 6
				14, { }, // pan 7
				15, { }, // pan 8
			);
		});
	}
}