C2_ControlSpecGUI3 {

// !!! at the moment, this class does not care from which device the cc is being recieved from

	var w, cv, controlSpecs, controlNames;
	var <>action, <>paramSelectAction;
	var slider, num_linValue, num_actualValue, but_playMovementsStatus;
	var st_name, st_units, but_midiControl, st_device, st_midiChannel, st_ccNumber;
	var synthDefName, idNo, st_synthDefName, st_idNo;
	var sl_startNo;
	var ccResponder, midiDeviceIDString, midiDeviceIDNo, midiToParamDict, nameToIndexDict;
	var but_midiMode, midiMode = 0, midiStatus, midiLearnIndex, midiChannelAndNo;
	// midiMode: 0 - midi input, 1 - midi learn
	
	var vals, selfWindowFlag = 0, focusFlag = 0, parent;
	var autosave;
	var arbEvent, pressBag;
//	var <recordMovementsFlag = 0, 
	var recordStatus = 0, routine, whichRoutine = 0, nextTime = 0.01;
//	var <playMovementsFlag = 0, 
	var valSequence;
	var playMovementsStatus, playMovementsTakeNo;
	var automapName, automapOffset;
	var background;
	
	var <windowPresentFlag = 0;
	
	var startNo = 0;
	
	
	
	
//	var but_recordMovementsFlag, but_playMovementsFlag;
	
//	recordMovementsFlag_ { |f| 
//	
//		recordMovementsFlag = f.clip(0, 1);
//		if(playMovementsFlag == 0) {playMovementsFlag = 0};
//		{this.guiUpdate}.defer;
//	
//	}
//	
//	playMovementsFlag_ { |f| 
//	
//		playMovementsFlag = f.clip(0, 1);
//		if(recordMovementsFlag == 0) {recordMovementsFlag = 0};
//		{this.guiUpdate}.defer;
//	
//	}

	
	name_ { |n|
		
		synthDefName = n;
		this.guiUpdate;
		
	}
	
	idNo_ { |n|
	
		idNo = n;
		this.guiUpdate;
		
	}
	
	getData {
	
		^[
		this.class.asString, "noName", 0,
		controlSpecs, nameToIndexDict,
		midiToParamDict, vals,
		midiStatus, midiChannelAndNo,
		controlNames, playMovementsStatus
		];
		
	}
	
	setData { |args|
	
		args = args.deepCopy;
	
		controlSpecs = args[3]; 
		nameToIndexDict = args[4]; 
		midiToParamDict = args[5];
		vals = args[6]; 
		midiStatus = args[7];
		midiChannelAndNo = args[8];
		controlNames = args[9];
		playMovementsStatus = args[10];
		
		"c2 contrlspecgui3".postln;
		args[3].postln;
		
		{this.guiUpdate}.defer; 
	
	}

	*new { |synthDefName, controlNames, specs| ^super.new.init(synthDefName, controlNames, specs) }
	
	init { |synthDefNameArg, controlNamesArg, specsArg|
	
//	["trumpet", synthDefNameArg, controlNamesArg, specsArg].postcs;
	
		if(specsArg == nil) {^nil};
		if(specsArg.size == 0) {^nil};
		
		background = C2_Color(\grey88);
		
		synthDefName = synthDefNameArg;
		controlNames = controlNamesArg;
		controlSpecs = specsArg.deepCopy;
		
	//	controlSpecs.postln;
	
		nameToIndexDict = Dictionary.new;
		midiToParamDict = Dictionary.new;
		
		vals = Array.newClear(controlSpecs.size);
		midiStatus = Array.newClear(controlSpecs.size);
		playMovementsStatus = Array.newClear(controlSpecs.size);
		playMovementsTakeNo = Array.newClear(controlSpecs.size);
		midiChannelAndNo = Array.newClear(controlSpecs.size);
		arbEvent = Array.newClear(controlSpecs.size);
		
		controlNames.do { |item, index|
		
			nameToIndexDict.put(item, index);
			vals[index] = controlSpecs[index].default;
			midiStatus[index] = 0;
			playMovementsStatus[index] = 0;
			playMovementsTakeNo[index] = 0;
			arbEvent[index] = C2_ArbEvent2.new;
			midiChannelAndNo[index] = [nil, nil];		
		};
		
		autosave = C2_AutoSave2.new("C2AM", "C2_AutoMap");
		
		
		routine = Array.newClear(40);
		routine.do { |item, index|
			routine[index] = Routine.new({});
		};

		pressBag = Bag.new;
		
		if(automapName != nil)
			{
			this.automap(automapName, automapOffset);
			};
	
	}
	
	automap { |name, offset = 0|
	
		var openTry, assignments, dict, chan, num, thisIndex;
		
		openTry = autosave.open(name);
		if(openTry != nil)
			{
			automapName = name; automapOffset = offset;
			assignments = openTry[4]; dict = openTry[5];
			
			controlSpecs.do { |item, index|
			
				thisIndex = index + offset;
			
				if( (assignments[index] != nil) and: (thisIndex < controlSpecs.size) )
					{
					chan = assignments[index][1].deepCopy;
					num = assignments[index][2].deepCopy;
					
					midiToParamDict.put( [chan, num], thisIndex );
					midiChannelAndNo[thisIndex] = [chan, num];
					midiStatus[thisIndex] = 1;
					};
				
			};
			{this.guiUpdate}.defer;
			
			};
	
	}
	
	ccResponder_start {
		
		ccResponder = CCResponder(
			{
			|src,chan,num,value|
			
			this.ccRespond(src,chan,num,value);
			
			},
		nil, // any source
		nil, // any channel
		nil, // any CC number
		nil // any value
		);
	
	}
	
	ccResponder_stop {
	
	//	"ccResponder_stop".postln;
	
		ccResponder.remove;
	
	}
	
	ccRespond { |src, chan, num, value|
	
		var paramIndex;
		paramIndex = midiToParamDict.at([chan, num]);
		
	//	cv.dump;
	//	if(cv == nil) {^nil};
	
		case
			{midiMode == 0}
			{
			if(paramIndex != nil)
				{
				if(midiStatus[paramIndex] == 1)
					{
					vals[paramIndex] = 

						controlSpecs[paramIndex].map(
							[0, 127].asSpec.unmap(value)
						);
					this.doAction(paramIndex);	
					arbEvent[paramIndex].inputEvent(vals[paramIndex]);
					{this.guiUpdate}.defer;
					
					};
					
				};
			
			}
			{midiMode == 1}
			{
			if(midiLearnIndex != nil)
				{
				if(paramIndex != nil)
					{
					midiChannelAndNo[paramIndex] = [nil, nil];
					midiToParamDict.removeAt([chan, num]);
					};
				
				midiToParamDict.put( [chan, num], midiLearnIndex );
				midiChannelAndNo[midiLearnIndex] = [chan, num];
				midiStatus[midiLearnIndex] = 1;
				// midi has been learned, now turn off the learn
				midiLearnIndex = nil;
				{this.guiUpdate}.defer;
				};
			
			};
	
	
	}
	
	noteOn { |midinote = 60, vel = 0.5|
	
		pressBag.add(midinote);
//		if(pressBag.size == 1)
//			{
//			routine.do { |item, index| item.stop };
//			this.startRec;
//			this.startPlay;
//			};
	
	}
	
	noteOff { |midinote = 60|
	
		pressBag.remove(midinote);
		
//		if(pressBag.size == 0)
//			{
//			this.stopRec;
//			this.stopPlay;
//			};
	
	}
	
	startRec {
		
		recordStatus = 1;
		
		arbEvent.do { |item, index|
		
			if(playMovementsStatus[index] != 1)
				{
				item.startRec;
				item.inputEvent(vals[index]);
				playMovementsTakeNo[index] = item.takeIndex;
				};
		}; 
	
	}
	
	stopRec {
	
		recordStatus = 0;
		
		arbEvent.do { |item, index|
			item.stopRec;
		};

	}
	
	startPlay {
	
	//	"startPlay".postln;
	
		playMovementsStatus.do { |item, index|
		
			if(item == 1)
				{
				whichRoutine = (whichRoutine + 1).wrap(0, routine.size - 1);
				routine[whichRoutine].stop;
				
			//	arbEvent[index].getTake.postcs;
				
				routine[whichRoutine] = Routine({
				
					arbEvent[index].getTake(playMovementsTakeNo[index]).do { |item|
					
						item[0].wait;
						vals[index] = item[1];
						this.doAction(index);
						{this.guiUpdate(index)}.defer;
					
					};
				
				
					});
			
			
				SystemClock.play(routine[whichRoutine]);
				};
		
		};

	
	}
	
	stopPlay {

	
	}
	

	guiDraw { |parentArg, startX = 5, startY = 5|
	
		var x, y, guiHeight, height = 15, fontSize = 10, nameWidthLimit = 30, fontString = "Monaco";
		var yLimit;
		
		if(cv != nil) {^nil};
		
		yLimit = parentArg.bounds.height;
		
		windowPresentFlag = 1;
		
		parent = parentArg;
		
		guiHeight = 40 + (controlSpecs.size * (height + 2));
		guiHeight = guiHeight.clip(0, yLimit - startY);
	
		if(parent == nil)
			{
			// draw a window and then put the gui onto it...
			// make window and name this parent
			parent = Window("ControlSpecGUI1", Rect(10, 700, 650 + 125, guiHeight + 40));
			parent.front;
			parent.onClose_(
				{
				this.guiRemove;
				}
			);
			startX = 10; startY = 10;
			selfWindowFlag = 1;
			};
			
		cv = CompositeView(parent, Rect(startX, startY, 600 + 125 - 45, guiHeight));
		cv.background_(background);
		
		x = 10; y = 0;
		
		st_idNo = StaticText(cv, Rect(x, y, 120, 20));
		st_synthDefName = StaticText(cv, Rect(x + 25, y, 200, 20));
		st_synthDefName.background_(Color.black).stringColor_(Color.white).align_(\center);
		st_synthDefName.string = synthDefName;
		
		
		but_midiMode = Button(cv, Rect(x + 400 + 125, y, 85, 20));
		but_midiMode.states = 
			[
			["Midi Ctrl", Color.white, Color.blue],
			["Midi Learn", Color.white, C2_Color('red')]
			];
			
//		but_recordMovementsFlag = Button(cv, Rect(x + 170, y, 85, height));
//		but_recordMovementsFlag.states = 
//			[
//			["rec off", Color.black, Color.grey],
//			["REC ON", Color.white, C2_Color('red')]
//			];
//		
//		but_playMovementsFlag = Button(cv, Rect(x + 260, y, 85, height));
//		but_playMovementsFlag.states = 
//			[
//			["play off", Color.black, Color.grey],
//			["PLAY ON", Color.white, C2_Color('green')]
//			];
	
			
		st_name = Array.newClear(controlSpecs.size);
		st_units = Array.newClear(controlSpecs.size);
		slider = Array.newClear(controlSpecs.size);
		num_linValue = Array.newClear(controlSpecs.size);
		num_actualValue = Array.newClear(controlSpecs.size);
		but_playMovementsStatus = Array.newClear(controlSpecs.size);
		but_midiControl = Array.newClear(controlSpecs.size); 
		st_midiChannel = Array.newClear(controlSpecs.size);
		st_ccNumber = Array.newClear(controlSpecs.size);
		
	//	sl_startNo = Slider(cv, Rect(5, 5, 1, 1));
		
		x = 20;
		
		st_name.do { |item, index|
		
			y = 25 + ((height + 2) * index);
		
			st_name[index] = StaticText(cv, Rect(x, y, 120, height));
			st_name[index].background_(C2_Color(\grey88)).align_(\center).font_(Font(fontString, fontSize));
			st_name[index].string = controlNames[index].asString;
			
			st_units[index] = StaticText(cv, Rect(x + 125, y, 120, height));
			st_units[index].background_(C2_Color(\grey88)).align_(\center).font_(Font(fontString, fontSize));
			st_units[index].string = controlSpecs[index].units;

			
			num_linValue[index] = C2_ScrollNumberBox(cv, Rect(x + 125 + 125, y, 40, height), 0.01, 0, 1);
			num_linValue[index].font_(Font(fontString, fontSize));
			slider[index] = Slider(cv, Rect(x + 170 + 125, y, 150, height));
			
			num_actualValue[index] = 
				C2_ScrollNumberBox(
					cv, 
					Rect(x + 325 + 125, y, 70, height), 
					controlSpecs[index].step, 
					controlSpecs[index].minval, 
					controlSpecs[index].maxval
				);
			num_actualValue[index].font_(Font(fontString, fontSize));
				
			num_actualValue[index].value = controlSpecs[index].default;
				
			but_midiControl[index] = Button(cv, Rect(x + 400 + 125, y, 25, height));
			but_midiControl[index].states = 
				[
				["M", Color.white, Color.grey],
				["M", Color.white, Color.blue],
				["L", Color.white, Color.grey],
				["L", Color.white, C2_Color(\red)]
				];
			but_midiControl[index].font_(Font(fontString, fontSize));
			
			st_midiChannel[index] = StaticText(cv, Rect(x + 430 + 125, y, 20, height));
			st_midiChannel[index].background_(C2_Color(\grey88)).align_(\center).font_(Font(fontString, fontSize));
			st_ccNumber[index] = StaticText(cv, Rect(x + 455 + 125, y, 30, height));
			st_ccNumber[index].background_(C2_Color(\grey88)).align_(\center).font_(Font(fontString, fontSize));
			
			but_playMovementsStatus[index] = Button(cv, Rect(x + 495 + 125, y, 25, height));
			but_playMovementsStatus[index].states = 
				[
				["!", Color.black, Color.grey],
				["!", Color.black, Color.yellow]
				];
				
			but_playMovementsStatus[index].font_(Font(fontString, fontSize));

		};
			
		this.guiMakeActions;
		this.guiUpdate;
	
	}
	
	guiMakeActions {
	
//		but_recordMovementsFlag.action = 
//			{
//			|but|
//			this.recordMovementsFlag_(but.value);
//			};
//			
//		but_playMovementsFlag.action = 
//			{
//			|but|
//			this.playMovementsFlag_(but.value);
//			};

	
		but_midiMode.action = 
			{ 
			|but| 
			midiMode = but.value; 
			if(midiMode == 0) { midiLearnIndex = nil }; 
			this.guiUpdate;
			};
	
		st_name.do { |item, index|
		
			but_playMovementsStatus[index].action = 
				{
				|but|
				playMovementsStatus[index] = but.value;
				};
		
			num_actualValue[index].action = 
				{
				|num|
				vals[index] = num.value;
				this.guiAction;
				};
				
			num_linValue[index].action = 
				{
				|num|
				vals[index] = controlSpecs[index].map(num.value);
				this.guiAction;
				};
				
			slider[index].action = 
				{
				|slider|
				vals[index] = controlSpecs[index].map(slider.value);
				this.guiAction;
				};
				
			but_midiControl[index].action =
				{
				|but|
				case
					{midiMode == 0}
					{
					midiStatus[index] = 1 - midiStatus[index];
					}
					{midiMode == 1}
					{
					if(midiLearnIndex != index)
						{
						midiLearnIndex = index
						}
						{
						midiLearnIndex = nil;
						};
					
					
					};
				
				this.guiUpdate;
				};
				
		};
	
	}
	
	guiAction {
	
		this.guiUpdate;
		this.doAction;
		
	
	}
	
	doAction { |valIndex|
	
	//	["valIndex", valIndex].postln;
		
		action.value(vals, valIndex);
	
	}
	
	guiUpdate { |valIndex|
	
		var start, end;
		
		if(cv == nil) {^nil};
		
		cv.background_(background);
		
//		but_recordMovementsFlag.value = recordMovementsFlag;
//		but_playMovementsFlag.value = playMovementsFlag;

		// maybe only one channel needs to be updated (automation playback)
		if(valIndex == nil)
			{
			start = 0; end = controlSpecs.size - 1;
			}
			{
			start = valIndex; end = valIndex;
			};

	
		for(start, end,
			{
			arg index;
		
			num_actualValue[index].value = vals[index];
			num_linValue[index].value = controlSpecs[index].unmap(vals[index]).round(0.01);
			slider[index].value = controlSpecs[index].unmap(vals[index]);
			but_playMovementsStatus[index].value = playMovementsStatus[index];
		
			case
				{midiMode == 0}
				{
				but_midiControl[index].value = midiStatus[index];
				}
				{midiMode == 1}
				{
				if(midiLearnIndex != index)
					{
					but_midiControl[index].value = 2;
					}
					{
					but_midiControl[index].value = 3;
					};
				
				};
				
			if(midiChannelAndNo[index][0] != nil)
				{
				st_midiChannel[index].string = (midiChannelAndNo[index][0] + 1).asString;
				st_ccNumber[index].string = midiChannelAndNo[index][1].asString;
				}
				{
				st_midiChannel[index].string = "";
				st_ccNumber[index].string = "";
				};		
		
			}
		);
			
		
	
	}
	
//	getVals {
//	
//		var vals;
//		
//		vals = Array.newClear(controlSpecs.size);
//		vals.do { |item, index|
//		
//			vals[index] = num_actualValue.value;
//			
//		};
//	
//	}
	
	setVals { |... args|
	
		// \name1, value1, \name2, value2 etc...
	
		var indexOfGUIObject;
	
		args = args.clump(2);
		args.do { |item, index|
		
			indexOfGUIObject = nameToIndexDict[item[0]];
			if(indexOfGUIObject != nil)
				{
				vals[indexOfGUIObject] = item[1];
				};
		
		};
		this.guiUpdate;
	
	}
	
	guiRemove {
	
//	"guiRemove".postln;
	
		if(cv != nil)
			{
			cv.remove;
			cv = nil;
			windowPresentFlag = 0;
			};
	
//	"cv dump in remove".postln;		
//	cv.dump;
	
		if(selfWindowFlag == 1)
			{
			parent.close;
			selfWindowFlag = 0;
			};
			
	//	this.ccResponder_stop;
	}

	
	background_ { |color|
	
		background = color;
	
		if(cv != nil) {cv.background_(color)};
		
	}



}





//	doAction { |valIndex|
//	
//		var sdArgArray;
//		
//		var start, end;
//		
//		// maybe only one channel needs to be updated (automation playback)
//		if(valIndex == nil)
//			{
//			start = 0; end = controlSpecs.size - 1;
//			}
//			{
//			start = valIndex; end = valIndex;
//			};
//	
//		sdArgArray = [];
//		
//		for(start, end, 
//			{
//			arg index;			
//			sdArgArray = sdArgArray.add([controlSpecs[index].units.asSymbol, vals[index]]);
//			}
//		);
//		
//		sdArgArray.flatten.postln;
//		
//		action.value(sdArgArray.flatten);
//	
//	}




//	doAction { |valIndex|
//	
//		var sdArgArray;
//		
//		var start, end;
//	
//		sdArgArray = Array.newClear(vals.size);
//		vals.do { |item, index|
//		
//			sdArgArray[index] = [controlSpecs[index].units.asSymbol, item];
//			
//		};
//		
//		action.value(sdArgArray.flatten);
//	
//	}


