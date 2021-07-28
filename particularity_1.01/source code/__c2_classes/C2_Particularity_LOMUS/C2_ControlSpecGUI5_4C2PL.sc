C2_ControlSpecGUI5_4C2PL{

// !!! at the moment, this class does not care from which device the cc is being recieved from

	var <w, cv, sv, controlSpecs, controlNames;
	var <>action, <>paramSelectAction, <>midiCtrlChangeAction;
	var slider, num_linValue, num_actualValue, but_playMovementsStatus;
	var st_name, st_units, but_midiControl, st_device, st_midiChannel, st_ccNumber;
	var synthDefName, idNo, st_idNo;
	var sl_startNo;
	var ccResponder, midiDeviceIDString, midiDeviceIDNo, midiToParamDict, nameToIndexDict;
	var but_midiMode, midiMode = 0, midiStatus, midiLearnIndex, midiChannelAndNo;
	// midiMode: 0 - midi input, 1 - midi learn
	
	var <vals, selfWindowFlag = 0, focusFlag = 0, parent;
	var autosave, pressBag;
	var recordStatus = 0, routine, whichRoutine = 0, nextTime = 0.01;
	var valSequence;
	var playMovementsStatus, playMovementsTakeNo;
	var automapName, automapOffset;
	var background, knobColor;
	
	var <windowPresentFlag = 0;
	
	var startNo = 0;
	
	var <>grouping;
	
	var oscResponder, oscAddr;
	

	

	*new { |synthDefName, controlNames, specs, grouping| ^super.new.init(synthDefName, controlNames, specs, grouping) }
	
	init { |synthDefNameArg, controlNamesArg, specsArg, groupingArg|
	
	
		if(specsArg == nil) {^nil};
		if(specsArg.size == 0) {^nil};
		
		background = C2_Color(\grey88);
		
		synthDefName = synthDefNameArg;
		controlNames = controlNamesArg;
		controlSpecs = specsArg.deepCopy;
		grouping = groupingArg.deepCopy;
		
		nameToIndexDict = Dictionary.new;
		midiToParamDict = Dictionary.new;
		
		vals = Array.newClear(controlSpecs.size);
		midiStatus = Array.newClear(controlSpecs.size);
		playMovementsStatus = Array.newClear(controlSpecs.size);
		playMovementsTakeNo = Array.newClear(controlSpecs.size);
		midiChannelAndNo = Array.newClear(controlSpecs.size);
		
		controlNames.do { |item, index|
		
			nameToIndexDict.put(item, index);
			vals[index] = controlSpecs[index].default;
			midiStatus[index] = 0;
			playMovementsStatus[index] = 0;
			playMovementsTakeNo[index] = 0;
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
					
		this.ccResponder_start;
	
	}
	
	name_ { |n|
		
		synthDefName = n;
		this.guiUpdate;
		
	}
	
	idNo_ { |n|
	
		idNo = n;
		this.guiUpdate;
		
	}
	
	rebuildDictionary {
	
		midiToParamDict = Dictionary.new;
	
		midiChannelAndNo.do { |item, index|
			midiToParamDict.put( item, index );
		};
	
	}
	
	getData_midi {
	
		^[midiStatus, midiChannelAndNo]
	
	}
	
	setData_midi { |args|
	
		#midiStatus, midiChannelAndNo = args;
		this.rebuildDictionary;
		{this.guiUpdate}.defer; 
	
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
		vals = args[6]; 
		midiStatus = args[7];
		midiChannelAndNo = args[8];
		controlNames = args[9];
		playMovementsStatus = args[10];
		
	
		this.rebuildDictionary;
		
		{this.guiUpdate}.defer; 
	
	}
	post {
	
		vals.postln;
		
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
	
	oscResponder_start {
	
		oscResponder = OSCresponder(nil, "/C2_GUI", { |t, r, msg, addr| oscAddr = addr; this.oscRespond(msg)}; ).add;
	
	}
	
	oscResponder_stop {
	
		oscResponder.remove;
	
	}
	
	oscRespond { |msg|
	
					
	
	}
	
	ccResponder_start {
	
//	"ccResponder_start".postln;
		
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
				midiCtrlChangeAction.value(this);
				{this.guiUpdate}.defer;
				};
			
			};
	
	
	}
	
	noteOn { |midinote = 60, vel = 0.5|
	
		pressBag.add(midinote);

	}
	
	noteOff { |midinote = 60|
	
		pressBag.remove(midinote);
	
	}
	
	guiDraw { |parentArg, startX = 5, startY = 5, height = 22, fontSize = 11|
	
		var x, y, guiHeight, nameWidthLimit = 30, fontString = "Monaco";
		var yLimit, groupCount = 0, groupPointer = 0;
		
		if(cv != nil) {^nil};
		
		if(grouping == nil) {grouping = [999]};
		grouping = grouping ++ [999];
		
		windowPresentFlag = 1;
		
		parent = parentArg;
		
		guiHeight = 40 + (controlSpecs.size * (height + 2)) + (3 * grouping.size);
	
		yLimit = parent.bounds.height;		

		cv = CompositeView(parent, Rect(startX, startY, 625, guiHeight));

		cv.background_(background);
		
		if(selfWindowFlag == 1)
			{
			parent.setResizeView(sv);
			parent.enableResize(1);
			};
				
		x = 10; y = 0;
		
		st_idNo = StaticText(cv, Rect(x, y, 120, 20));
		
		but_midiMode = Button(cv, Rect(x + 400 + 125 + 10 - 10, y, 85, 20));
		but_midiMode.states = 
			[
			["Midi Ctrl", Color.white, Color.blue],
			["Midi Learn", Color.white, C2_Color('red')]
			];
			
		but_midiMode.font_(Font("Helvetica", 12));
	
		st_name = Array.newClear(controlSpecs.size);
		st_units = Array.newClear(controlSpecs.size);
		slider = Array.newClear(controlSpecs.size);
		num_linValue = Array.newClear(controlSpecs.size);
		num_actualValue = Array.newClear(controlSpecs.size);
		but_playMovementsStatus = Array.newClear(controlSpecs.size);
		but_midiControl = Array.newClear(controlSpecs.size); 
		st_midiChannel = Array.newClear(controlSpecs.size);
		st_ccNumber = Array.newClear(controlSpecs.size);
		
		st_name.do { |item, index|
		
			var colPointer, stringColor, background;
			
			colPointer = groupPointer.wrap(0, 1);
			
			stringColor = [C2_Color(\white), C2_Color(\white)][colPointer];
			background = [\grey24, \grey34][colPointer];
		
			x = 0;
		
			y = 25 + ((height + 2) * index) + (5 * groupPointer);
			groupCount = groupCount + 1;
			if(groupCount > grouping[groupPointer])
				{
				groupCount = 0; groupPointer = groupPointer + 1;
				};
		
			st_name[index] = StaticText(cv, Rect(x, y, 120, height));
			st_name[index].background_(background).stringColor_(stringColor)
				.align_(\center).font_(Font(fontString, fontSize));
			st_name[index].string = controlNames[index].asString;
			
			x = x - 125;
			
			num_linValue[index] = C2_ScrollNumberBox(cv, Rect(x + 125 + 125, y, 40, height), 0.01, 0, 1);
			num_linValue[index].font_(Font(fontString, fontSize));
			num_linValue[index].background_(background).normalColor_(stringColor);
			
			slider[index] = Slider(cv, Rect(x + 170 + 125, y, 285, height));
			slider[index].background_(background);
			x = x + 135;
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
			num_actualValue[index].background_(background).normalColor_(stringColor);
				
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
			st_midiChannel[index].align_(\center).font_(Font(fontString, fontSize));
			st_midiChannel[index].background_(background).stringColor_(stringColor);
			
			st_ccNumber[index] = StaticText(cv, Rect(x + 455 + 125, y, 30, height));
			st_ccNumber[index].align_(\center).font_(Font(fontString, fontSize));
			st_ccNumber[index].background_(background).stringColor_(stringColor);

		};
			
		this.guiMakeActions;
		this.guiUpdate;
	
	}
	
	guiMakeActions {
	
		but_midiMode.action = 
			{ 
			|but| 
			midiMode = but.value; 
			if(midiMode == 0) { midiLearnIndex = nil }; 
			this.guiUpdate;
			};
	
		st_name.do { |item, index|
		
//			but_playMovementsStatus[index].action = 
//				{
//				|but|
//				playMovementsStatus[index] = but.value;
//				};
		
			num_actualValue[index].action = 
				{
				|num|
				vals[index] = num.value;
				this.guiAction(index);
				};
				
			num_linValue[index].action = 
				{
				|num|
				vals[index] = controlSpecs[index].map(num.value);
				this.guiAction(index);
				};
				
			slider[index].action = 
				{
				|slider|
				vals[index] = controlSpecs[index].map(slider.value);
				this.guiAction(index);
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
	
	guiAction { |valIndex|
	
		this.guiUpdate;
		this.doAction(valIndex);
		
	
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

	
//	["vals", vals].postln;
	
		for(start, end,
			{
			arg index;
		
			num_actualValue[index].value = vals[index];
			num_linValue[index].value = controlSpecs[index].unmap(vals[index]).round(0.01);
			slider[index].value = controlSpecs[index].unmap(vals[index]);
			slider[index].knobColor_(knobColor);
		//	but_playMovementsStatus[index].value = playMovementsStatus[index];
		
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
	
	setValsWithArray { |valsArg, winFrontFlag = 0|
	
		vals = valsArg.deepCopy;
		if(winFrontFlag == 1) 
			{
			if(selfWindowFlag == 1)
				{parent.front};
				
			};
			
		//["setValsWithArray", vals].postln;
		{this.guiUpdate}.defer;
	
	}
	
	guiRemove {
	
//	"guiRemove".postln;
	
		if(cv != nil)
			{
			cv.remove;
			cv = nil;
			windowPresentFlag = 0;
			};
		if(sv != nil)
			{
			sv.remove;
			sv = nil;
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
	
	knobColor_ { |color|
	
		knobColor = color;
	
		if(cv != nil) {this.guiUpdate};
		
	}



}
