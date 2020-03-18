BCF2000Mixer {
	var <server = nil;
	var <inBuses = nil;
	var <numChannelsPerTrack = nil;
	var <numTracks = nil;
	var <group = nil;
	var trackSynths = nil;
	var limiterSynth = nil;
	var midifunc = nil;
	var midiout = nil;
	var volumeCurve = 4;

	*new { |server, numTracks = 8, numChannelsPerTrack = 2|
		^super.new.init(server, numTracks, numChannelsPerTrack);
	}

	init { |server1, numTracks1, numChannelsPerTrack1|
		server = server1;
		numTracks = numTracks1;
		numChannelsPerTrack = numChannelsPerTrack1;
		midiout =  MIDIOut.newByName("BCF2000","BCF2000");
		CmdPeriod.add(this);
		this.createMixerTracks();
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

	// PRIVATE

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
			this.moveFadersToInit();
			this.registerMidiFunc();
		};
	}

	createBuses {
		if (inBuses != nil) {
			inBuses.collect(_.free);
		};

		inBuses = numTracks.collect({ Bus.audio(server, numChannelsPerTrack) });
	}

	moveFadersToInit {
		// reset volume faders
		numTracks.do({ |i|
			midiout.control(i,7,0);
			// reset pan pots
			if (numChannelsPerTrack == 1, {
				// pan left for even tracks and right for odd tracks
				midiout.control(i,10,(i%2)*127);
			}, {
				// pan center
				midiout.control(i,10,64);
			});
		});
	}

	createMixerTrackSynthDef {
		switch (numChannelsPerTrack,
			1, {
				SynthDef(\bcf2000MixerTrack, { |in = 0, out = 0, amp = 0.0, pan = 0.0|
					Out.ar(out, Pan2.ar(In.ar(in,numChannelsPerTrack), pan.lag(0.1)) *  amp.lag(0.1));
				}).add;
			},
			2, {
				SynthDef(\bcf2000MixerTrack, { |in = 0, out = 0, amp = 0.0, pan = 0.0|
					Out.ar(out, Balance2.ar(In.ar(in,1), In.ar(in+1,1), pan.lag(0.1)) *  amp.lag(0.1));
				}).add;
			},
			{
				// no pan for now for more than 2 channels per track
				SynthDef(\bcf2000MixerTrack, { |in = 0, out = 0, amp = 0.0, pan = 0.0|
					Out.ar(out, In.ar(in, numChannelsPerTrack) *  amp.lag(0.1));
				}).add;
			}
		);

		SynthDef(\bcf2000MixerLimiter, { |out = 0|
			ReplaceOut.ar(out, In.ar(out, numChannelsPerTrack).tanh);
		}).add;
	}

	createMixerTrackSynths {
		if (trackSynths != nil) {
			trackSynths.collect(_.free);
		};

		if (limiterSynth != nil) {
			limiterSynth.free;
		};

		if (numChannelsPerTrack == 1, {
			trackSynths = numTracks.collect({ |i|
				var pan;
				if (i%2 == 0, { pan = -1.0 }, { pan = 1.0 });
				Synth(\bcf2000MixerTrack, [in: inBuses[i], amp: 0.0, pan: pan, out: 0], group)
			});
		}, {
			trackSynths = numTracks.collect({ |i|
				Synth(\bcf2000MixerTrack, [in: inBuses[i], amp: 0.0, pan: 0.0, out: 0], group)
			});
		});

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