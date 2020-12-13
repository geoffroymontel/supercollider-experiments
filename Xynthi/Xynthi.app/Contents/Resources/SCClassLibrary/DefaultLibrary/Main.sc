Main : Process {
	var platform, argv;

	startup {
		super.startup;
		Document.startup;
		interpreter.s = Server.internal;
		Server.default=Server.internal;
		try { "~/scwork/startup.rtf".loadPaths; };
		// Start the application using internal server
		"Booting Server...".postln;
		interpreter.s.waitForBoot({
			Routine({
				0.1.wait;
				"Loading App".postln;
				"Xynthi_Run.rtf".loadPaths;
			}).play;
			Document.closeAll(false);
		}, 25);
	}
	
	shutdown { // at recompile, quit
		Server.quitAll;
		this.platform.shutdown;
		super.shutdown;
	}
	
	run { // called by command-R
	
	}
	
	stop { // called by command-.


		SystemClock.clear;
		AppClock.clear;
		TempoClock.default.clear;
		CmdPeriod.clear;
		
		Server.freeAll; // stop all sounds on local servers
		Server.resumeThreads;
	}
	
	recvOSCmessage { arg time, replyAddr, msg;
		// this method is called when an OSC message is received.
		OSCresponder.respond(time, replyAddr, msg);
	}
	
	recvOSCbundle { arg time, replyAddr ... msgs;
		// this method is called when an OSC bundle is received.
		msgs.do({ arg msg; 
			this.recvOSCmessage(time, replyAddr, msg); 
		});
	}
	
	newSCWindow {
		SCWindow.viewPalette;
		SCWindow.new.front;
	}

	platformClass {
		// override in platform specific extension
		^Platform
	}
	platform {
		^platform ?? { platform = this.platformClass.new }
	}
	argv {
		^argv ?? { argv = this.prArgv }
	}

	// PRIVATE
	prArgv {
		_Argv
		^[]
	}
}
