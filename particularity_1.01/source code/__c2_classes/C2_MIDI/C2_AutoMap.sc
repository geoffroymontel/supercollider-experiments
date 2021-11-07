/*
m = C2_AutoMap.new;
m.startLearn;
m.stopLearn;

m.name_("nanoktrl1");
m.save;
m.dict.postln;
m.assignments.postln;
*/


C2_AutoMap {

	var <>name, <assignments, <dict, responder;
	var assignmentIndex = 0;
	var autosave;


	*new { ^super.new.init }
	
	init {
	
		name = "noname";
		assignments = [];
		dict = Dictionary.new;
		
		autosave = C2_AutoSave2.new("C2AM", "C2_AutoMap");
	
	
	}
	
	prStartResponder {
	
		responder = CCResponder(
			{
			|src,chan,num,value|
			
			this.addAssignment(src,chan,num);
			
			},
		nil, // any source
		nil, // any channel
		nil, // any CC number
		nil // any value
		);
	
	}
	
	prStopResponder {
	
		responder.remove;
	
	}
	
	addAssignment { |uid, channel, ccNo|
	
		var deviceName;
	
		deviceName = C2_MidiDeviceName.getNameByUid(\source, uid);
		
		if(dict.at([deviceName, channel, ccNo]) == nil)
			{
			assignments = assignments.add([uid, channel, ccNo]);
			dict.put([deviceName, channel, ccNo], (assignments.size - 1));
			[("Assignment no. " ++ assignmentIndex.asString), deviceName, channel, ccNo].postln;
			assignmentIndex = assignmentIndex + 1;
			};
	
	}
	
	startLearn { |startIndex|
	
		if(startIndex == nil) {startIndex = 0};
		if(startIndex >= (assignments.size - 1)) {startIndex = 0};
		assignmentIndex = startIndex;
			
		("C2_AutoMap LEARN started at index " ++ assignmentIndex.asString ++ ".").postln;
			
		this.prStartResponder;
	
	}
	
	stopLearn {
	
		this.prStopResponder;
	
	}
	
	getData {
	
		^[
		this.class.asString, "noName", 0,
		name, assignments, dict
		];
	
	}
	
	setData { |args|
	
		args = args.deepCopy;
		name = args[3]; assignments = args[4]; dict = args[5];
	
	}
	
	changeDevice { |d|
	
	
	}
	
	save {
	
		name = autosave.save(name, this.getData);
		("C2_AutoMap name: " ++ name).postln;
	
	}
	
	open { |n|
	
		var openTry;
		
		openTry = autosave.open(n);
		if(openTry != nil)
			{
			name = n;
			this.setData(openTry);
			};
	
	}
	
	


}





