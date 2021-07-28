C2L_Pulsar_Palette {

	var w, cv, butGrid, but_mode;
	var presets, mode = 0, lastPreset;
	var >getMacroAction, >recallMacroAction;
	var data, midiSources, midiSourceNo = 0, midiChan = 1;
	var blendMode = 0, but_blendMode, blendAmt = 0.0, num_blendAmt;
	var but_midiCtrl, but_monomeCtrl, but_oscCtrl, pop_midiSource, num_midiChan;
	var midiResponderStatus = 0, noteOnResponder, noteOffResponder;
	var midiSrcToPopIndexDict, currentMidiSourceIndex = 0;
	var vols;		// adjust volume for each slot - applied live to whatever has been selected - a multiplier
	var num_vols, lastSelectedSlot;
	var akaResponder, aka_set = 0, aka_no = 0;
	
	*new { ^super.new.init }
	
	init {
	
		presets = Array.newClear(64);
		vols = Array.fill(64, {|i| 1.0});
		
		data = C2_DataDevice3.new;
		data.name_("PG_palette").guiColor_(C2_Color('DarkOliveGreen1')).fileBaseName_("c2pg2010_pal").guiLength_(200);
		data.getDataAction = {[presets, vols]};
		data.setDataAction = 
			{ |args| 
			args = args.deepCopy;
			if(args.size == 64) 
				{
				args = [args] ++ [Array.fill(64, {|i| 1.0})];
				};
				presets = args[0]; vols = args[1]; this.update;
				
			};
		
		midiSources = C2_MidiDeviceName.popSources.deepCopy ++ ["none"];
		
		midiSrcToPopIndexDict = Dictionary.new;
		midiSources.do { |item, index|
		
			midiSrcToPopIndexDict.put(C2_MidiDeviceName.getUid(\source, item), index);
		
		};
		
		this.setupMidiResponder;
		this.setupAka;
		
	}
	
	scaleAllVols { |mul = 1.0|
	
		vols.do { |item, index| vols[index] = vols[index] * mul };
	}
	
	front { w.front }
	
	
	draw { |winX = 20, winY = 80, color|
	
		w = Window("Pulsar Generator 2010 : Palette", Rect(winX, winY, 1200, 110)).front;
		w.userCanClose_(false);
		color = color ? Color.rand;
		w.background_(color);
		cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));
		w.setResizeView(cv);
		w.enableResize(1);
		
		butGrid = C2_ButGridView2(cv, Rect(5, 5, 800, 60), 32, 2, 5);
		
		but_mode = 
			[
			Button(cv, Rect(5, 70, 30, 30)),
			Button(cv, Rect(40, 70, 30, 30)),
			Button(cv, Rect(75, 70, 30, 30))
			];
			
		but_mode.do { |item, index|
		
			but_mode[index].states = 
				[
				[ ["<", "+", "X"][index], Color.black, Color.grey ],
				[ 
					["<", "+", "X"][index], 
					[Color.black, Color.black, Color.white][index], 
					[Color.green, Color.yellow, Color.red][index] 
				]
				];
		
		};
		data.guiDraw(cv, 130, 70);
		
		but_blendMode = Button(cv, Rect(340, 75, 100, 20));
		but_blendMode.states = 
			[
			["Blend", Color.black, C2_Color(\grey77)],
			["RND Blend", Color.black, C2_Color(\grey77)]
			];
		but_blendMode.font_(Font("Helvetica", 12));
		num_blendAmt = C2_ScrollNumberBox(cv, Rect(445, 75, 40, 20), 0.01, 0.0, 1.0, 1);
		
		StaticText(cv, Rect(495, 75, 100, 20)).align_(\right).font_(Font("Helvetica", 12)).string_("Volume Adjust: ");
		num_vols = C2_ScrollNumberBox(cv, Rect(600, 75, 40, 20), 0.01, 0.0, 2.0, 1);

		
		
//		pop_ctrlMethod = PopUpMenu(cv, Rect(500, 75, 120, 20));
//		pop_ctrlMethod.background_(\yellow2);
//		pop_ctrlMethod.items = ["GUI Ctrl", "GUI + MIDI", "GUI + Monome", "GUI + OSC"];

		but_midiCtrl = Button(w, Rect(820, 35, 100, 20));
		but_monomeCtrl = Button(w, Rect(925, 35, 120, 20));
		but_oscCtrl = Button(w, Rect(1050, 35, 100, 20));
		
		[but_midiCtrl, but_monomeCtrl, but_oscCtrl].do { |item, index|
		
			var thisString;
			thisString = ["MIDI Ctrl", "Monome Ctrl", "OSC Ctrl"][index];
			item.states = [ [thisString, Color.black, Color.grey], [thisString, Color.black, Color.yellow] ];
		
		};
		
	//	pop_midiSource, num_midiChan 1105
		
		pop_midiSource = PopUpMenu(cv, Rect(820, 5, 280, 20));
		pop_midiSource.items = midiSources;
		pop_midiSource.background_(C2_Color('DarkSlateGray2'));
		
		num_midiChan = C2_ScrollNumberBox(cv, Rect(1105, 5, 40, 20), 1, 1, 16, 1);
		
		this.makeActions;
		this.update;
		
		
	
	}
	
	makeActions {
		
		pop_midiSource.action = { |pop| midiSourceNo = pop.value };
		num_midiChan.action = { |num| midiChan = num.value };

		butGrid.action = 
			{
			|view, index|
			
			case
				{mode == 0} { this.recallMacro(index) }
				{mode == 1} { this.setMacro(index) }
				{mode == 2} {this.eraseMacro(index) };
				
			};
	
		but_mode.do { |item, index|
		
			but_mode[index].action = { mode = index; this.update };
		
		};
		but_blendMode.action = { |but| blendMode = but.value };
		num_blendAmt.action = { |num| blendAmt = num.value };
		num_vols.action = { |num| if(lastSelectedSlot != nil) {vols[lastSelectedSlot] = num.value; this.recallMacro(lastSelectedSlot)}; };
		
		but_midiCtrl.action = { |but| if(but.value == 1) {this.startMidiResponder} {this.stopMidiResponder}; };
		pop_midiSource.action = { |pop| currentMidiSourceIndex = pop.value };
		
	
	}
	
	update {
	
		pop_midiSource.value = midiSourceNo;
		num_midiChan.value = midiChan;

		butGrid.status_(presets.collect({|i| if(i != nil) {1} {0} }));
		
		but_mode.do { |item, index|
			if(index == mode) {but_mode[index].value = 1} {but_mode[index].value = 0};		};
		but_blendMode.value = blendMode;
		num_blendAmt.value = blendAmt;
		if(lastSelectedSlot != nil) { num_vols.value = vols[lastSelectedSlot] } {num_vols.value = nil};
		pop_midiSource.value = currentMidiSourceIndex;
	
	}
	
	setupMidiResponder {
	
		noteOnResponder =
		
			NoteOnResponder(
				{ 
				|src, chan, num, vel|
				var dev;
				vel = vel.asInt;
				this.noteOn(src, num, vel);
				}, install: false
			);

// do we want it?
	
//		noteOffResponder = 
//		
//			NoteOffResponder(
//				{
//				|src, chan, num, vel|
//				var dev, slot;
//				vel = vel.asInt;
//				dev = midiDict.at(src);
//				slot = midiMap[dev][chan][num];
//				slot.do { |item, index|
//					this.noteOff(item, num);
//				};
//
//				}, install: false
//			);
	
	
	}
	
	startMidiResponder { |index|
	
		if(midiResponderStatus == 1)
			{
			"C2_Pulsar_Palette startResponder: responderStatus is already 1".postln;
			^nil;
			};
			
		midiResponderStatus = 1;
	
		NoteOnResponder.add(noteOnResponder);
//		NoteOffResponder.add(noteOffResponder);
			
	}

	stopMidiResponder {
	
		midiResponderStatus = 0;
	
		NoteOnResponder.remove(noteOnResponder);
//		NoteOffResponder.remove(noteOffResponder);	
	}
	
	setupAka {
	
		akaResponder = C2_akaResponder.new;
		akaResponder.enable;
		akaResponder.addDevice(2061, "10.0.2.2", 5700);
				
		
		for(0, 3)
			{ |c|
			akaResponder.addActionByName(2061, "pad", "button" ++ (c + 1).asString, 
				{ |action, val1|
				aka_set = c;
				for(0, 3)
					{ |c2|
					akaResponder.setValueByName(2061, "pad", "button" ++ (c2 + 1).asString, if(c2 == aka_set) {1} {0}; );
					};
				}
			);
			
			};
		
		for(0, 15)
			{ |c|
			akaResponder.addActionByName(
				2061, "pad", "pad" ++ (c + 1).asString, 
					{
					arg action, val1; 
					var index;
					aka_no = c; 
					index = (aka_set * 16) + aka_no;
					case
						{mode == 0} { this.recallMacro(index) }
						{mode == 1} { this.setMacro(index) }
						{mode == 2} {this.eraseMacro(index) };
					
					}
			);
			
			};	
		
	
	}
	
	noteOn { |src, num, vel|
	
		var index;
	
	//	["noteOn", src, num, vel].postln;
		
		if(num >= 48)
			{
			index = num - 48;
//["Jjj", midiSrcToPopIndexDict[src], currentMidiSourceIndex].postln;	
			if(midiSrcToPopIndexDict[src] == currentMidiSourceIndex)
				{
				case
					{mode == 0} { this.recallMacro(index) }
					{mode == 1} { this.setMacro(index) }
					{mode == 2} {this.eraseMacro(index) };
					
				};
				
			}
			{
			case
				{num == 36} {mode = 0}
				{num == 38} {mode = 1}
				{num == 40} {mode = 2};
			{this.update}.defer;
			};
		
	}
	
	recallMacro { |index|
	
		var blendedPreset, blendedVol, thisBlendAmt;
	
		if(presets[index] != nil) 
			{
			if(lastPreset == nil) {lastPreset = presets[index].deepCopy};

			if(blendAmt > 0.0)
				{
				case
					{blendMode == 0}
					{thisBlendAmt = blendAmt}
					{blendMode == 1}
					{thisBlendAmt = rrand(0, blendAmt)};
					 
				blendedPreset = presets[index].blend(lastPreset, thisBlendAmt);
				blendedVol = vols[index].blend(vols[lastSelectedSlot ? index], thisBlendAmt);
				}
				{
				blendedPreset = presets[index];
				blendedVol = vols[index];
				};
			recallMacroAction.value(blendedPreset, blendedVol);
				
			lastPreset = presets[index].deepCopy;
			{butGrid.highlight(index)}.defer;
			}
			{
			{butGrid.unhighlight}.defer;
			};
		
		if(lastSelectedSlot != index)
			{
			{num_vols.value = vols[index]}.defer;
			};
				
		lastSelectedSlot = index;
		
	}
	
	
	setMacro { |index|
	
		if(presets[index] == nil)
			{
			presets[index] = getMacroAction.value;
			{butGrid.setStatusOfOneStep(index, 1)}.defer;
			};
	
	
	}
	
	eraseMacro { |index|
	
		presets[index] = nil;
		{butGrid.setStatusOfOneStep(index, 0)}.defer;
	
	
	}
	
	
}






