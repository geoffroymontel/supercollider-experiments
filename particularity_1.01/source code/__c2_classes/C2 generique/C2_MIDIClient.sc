C2_MIDIClient {
	classvar <sources, <destinations;
	classvar <initialized=false;
	classvar deviceDict, nameDict;
	*init { arg inports, outports; // by default initialize all available ports
								// you still must connect to them using MIDIIn.connect
		
		this.prInitClient;
		this.list;
		if(inports.isNil,{inports = sources.size});
		if(outports.isNil,{outports = destinations.size});
//			this.disposeClient;
		
		this.prInit(inports,outports);
		initialized = true;
		// might ask for 1 and get 2 if your device has it
		// or you might ask for a 1 and get 0 of nothing is plugged in
		// so we warn you
		if(sources.size < inports or: {destinations.size < outports},{
			"WARNING:".postln;
			("MIDIClient-init requested " ++ inports ++ " inport(s) and " ++ outports
				++ " outport(s),").postln;
			("but found only " ++ sources.size ++ " inport(s) and " ++ destinations.size
				++ " outport(s).").postln;
			"Some expected MIDI devices may not be available.".postln;
		});

		this.list;
		deviceDict = Dictionary.new;
		nameDict = Dictionary.new;
		
		(sources ++ destinations).do { |item, index|
			if(deviceDict[item.uid] == nil) {deviceDict.put(item.uid, item.device)};
			if(nameDict[item.uid] == nil) {nameDict.put(item.uid, item.name)};
		};
		
		UI.registerForShutdown( { this.disposeClient } );

		Post << "MIDI Sources:" << Char.nl;
		sources.do({ |x| Post << Char.tab << x << Char.nl });
		Post << "MIDI Destinations:" << Char.nl;
		destinations.do({ |x| Post << Char.tab << x << Char.nl });
	}
	
	*getDeviceAndNameByUid { |uid|
	
		^[deviceDict[uid], nameDict[uid]];
	
	}
	
	*match { |uid, device, name|
	
		if((deviceDict[uid] == device) and: (nameDict[uid] == name)) {^true} {^false};
		
	}
	
	*list {
		var list;
		list = this.prList;
		if(list.notNil, {
			sources = list.at(0).collect({ arg id,i;
				MIDIEndPoint(list.at(1).at(i), list.at(2).at(i), id)
			});
			destinations = list.at(3).collect({arg id, i;
				MIDIEndPoint(list.at(5).at(i), list.at(4).at(i), id)
			});
		});
	}
	*prInit { arg inports, outports;
		_InitMIDI
		^this.primitiveFailed
	}
	*prInitClient {
		_InitMIDIClient
		^this.primitiveFailed
	}
	*prList {
		_ListMIDIEndpoints
		^this.primitiveFailed
	}
	*disposeClient {
		_DisposeMIDIClient
		^this.primitiveFailed
	}
	*restart {
		_RestartMIDI
		^this.primitiveFailed
	}
}

