C2_PresetPalette3_4C2PL {

	var <w, cv, butGrid, but_mode;
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
	var <windowName, fileBaseName;
	var includeEnv = 1, but_includeEnv;
	var lastPresetWasRecalledDuringTweakModeFlag = 0;
	var <>openAction, <>saveAction;
	
	*new { |fileBaseName| ^super.new.init(fileBaseName) }
	
	init { |argFileBaseName|
	
		fileBaseName = argFileBaseName ? "c2pp";
	
		windowName = "Preset Palette";
	
		presets = Array.newClear(32);
		vols = Array.fill(32, {|i| 1.0});
		
		data = C2_DataDevice3.new;
		data.name_("Palette").guiColor_(C2_Color('DarkOliveGreen1')).fileBaseName_(argFileBaseName).guiLength_(200);
		data.getDataAction = {[presets, vols]};
		data.setDataAction = 
			{ |args| 
			args = args.deepCopy;
			if(args.size == 32) 
				{
				args = [args] ++ [Array.fill(32, {|i| 1.0})];
				};
				presets = args[0]; vols = args[1]; this.update;
				
			};
		
		midiSources = C2_MidiDeviceName.popSources.deepCopy ++ ["none"];
		
		midiSrcToPopIndexDict = Dictionary.new;
		midiSources.do { |item, index|
		
			midiSrcToPopIndexDict.put(C2_MidiDeviceName.getUid(\source, item), index);
		
		};
		
		this.setupMidiResponder;
		
	}
	
	getData {
	
		^[presets, vols, blendMode, blendAmt, midiSourceNo, midiChan, includeEnv, saveAction.value];
	
	}
	
	setData { |args|
	
		var xtra;
	
		args = args.deepCopy;
		
		#presets, vols, blendMode, blendAmt, midiSourceNo, midiChan, includeEnv, xtra = args;
		openAction.value(xtra);
		{this.update}.defer;	
	}
	
	
	
	scaleAllVols { |mul = 1.0|
	
		vols.do { |item, index| vols[index] = vols[index] * mul };
	}
	
	front { w.front }
	
	windowName_ { |wn|
	
		windowName = wn;
		if(w != nil) {w.name_(windowName) };
		
	}
	
	reportBounds { ^w.bounds }
	
	setBounds { |bounds| w.bounds_(bounds) }
	
	draw { |winX = 20, winY = 80, color, style = 0, parent|
	
		this.draw0(winX, winY, color, parent);
			
	}
	
	draw0 { |winX, winY, color, parent|
	
		if(parent == nil)
			{
			w = Window(windowName, Rect(winX, winY, 1170, 110)).front;
			w.userCanClose_(false);
			color = color ? Color.rand;
			w.background_(color);
			cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));
			w.setResizeView(cv);
			w.enableResize(1);
			}
			{
			cv = parent;
			};
		
		butGrid = C2_ButGridView4_4C2PL(cv, Rect(5, 5, 800, 60), 16, 2, 5);
		
		but_mode = 
			[
			Button(cv, Rect(5, 70, 30, 30)), Button(cv, Rect(40, 70, 30, 30)),
			Button(cv, Rect(75, 70, 30, 30)), Button(cv, Rect(145, 70, 30, 30))
			];
			
		but_mode.do { |item, index|
		
			but_mode[index].states = 
				[
				[ ["<", "+", "X", "T"][index], Color.black, Color.grey ],
				[ 
					["<", "+", "X", "T"][index], 
					[Color.black, Color.black, Color.white, Color.white][index], 
					[Color.green, Color.yellow, Color.red, C2_Color(\purple3)][index] 
				]
				];
				
			but_mode[index].font_(Font("Helvetica", 12));
		
		};
		data.guiDraw(cv, 820, 70);
		
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

		but_midiCtrl = Button(cv, Rect(820, 5, 80, 20));
		but_midiCtrl.states = [ ["MIDI Ctrl off", Color.black, Color.grey], ["MIDI Ctrl on", Color.black, Color.yellow] ];
		but_midiCtrl.font_(Font("Helvetica", 12));
		pop_midiSource = PopUpMenu(cv, Rect(820, 35, 280, 20));
		pop_midiSource.items = midiSources;
		pop_midiSource.background_(C2_Color('DarkSlateGray2'));
		pop_midiSource.font_(Font("Helvetica", 12));
		StaticText(cv, Rect(910, 5, 145, 20)).align_(\right).font_(Font("Helvetica", 12)).string_("Listen to MIDI Channel: ");
		num_midiChan = C2_ScrollNumberBox(cv, Rect(1060, 5, 40, 20), 1, 1, 16, 1);
		
		this.makeActions; this.update;

	}
	
	makeActions {
		
		pop_midiSource.action = { |pop| midiSourceNo = pop.value };
		num_midiChan.action = { |num| midiChan = num.value };

		if(but_includeEnv != nil)
			{but_includeEnv.action = { |but| includeEnv = but.value }};
		butGrid.action = 
			{
			|view, index|
			
			case
				{mode == 0} { this.recallMacro(index) }
				{mode == 1} { this.setMacro(index) }
				{mode == 2} {this.eraseMacro(index) }
				{mode == 3} {this.tweak(index) };
				
			};
		but_mode.do { |item, index|
		
			but_mode[index].action = { mode = index; if(index == 3) {lastSelectedSlot = nil}; this.update };
		
		};
		but_blendMode.action = { |but| blendMode = but.value };
		num_blendAmt.action = { |num| blendAmt = num.value };
		num_vols.action = { |num| if(lastSelectedSlot != nil) {vols[lastSelectedSlot] = num.value; this.recallMacro(lastSelectedSlot)}; };
		but_midiCtrl.action = { |but| if(but.value == 1) {this.startMidiResponder} {this.stopMidiResponder}; };
		pop_midiSource.action = { |pop| currentMidiSourceIndex = pop.value };
		
	}
	
	update {
	
		if(cv == nil) {^nil};
		pop_midiSource.value = midiSourceNo;
		num_midiChan.value = midiChan;
		if(but_includeEnv != nil)
			{but_includeEnv.value = includeEnv};

		butGrid.status_(presets.collect({|i| if(i != nil) {1} {0} }));
		
		but_mode.do { |item, index|
			if(index == mode) {but_mode[index].value = 1} {but_mode[index].value = 0};		};
		but_blendMode.value = blendMode;
		num_blendAmt.value = blendAmt;
		if(lastSelectedSlot != nil) { num_vols.value = vols[lastSelectedSlot] } {num_vols.value = nil; butGrid.unhighlight};
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
	
	}
	
	startMidiResponder { |index|
	
		if(midiResponderStatus == 1)
			{
			"C2_Particularity_Palette startResponder: responderStatus is already 1".postln;
			^nil;
			};
			
		midiResponderStatus = 1;
		NoteOnResponder.add(noteOnResponder);
			
	}

	stopMidiResponder {
	
		midiResponderStatus = 0;
		NoteOnResponder.remove(noteOnResponder);
	}
	
	noteOn { |src, num, vel|
	
		var index;

		if(midiSrcToPopIndexDict[src] == currentMidiSourceIndex)
			{
			
			if(num.inclusivelyBetween(48, 70))
				{
				index = num - 48;
				
				case
					{mode == 0} { this.recallMacro(index) }
					{mode == 1} { this.setMacro(index) }
					{mode == 2} {this.eraseMacro(index) }
					{mode == 3} {this.tweak(index) };
	
				}
				{
				case
					{num == 36} {mode = 0}
					{num == 38} {mode = 1}
					{num == 40} {mode = 2}
					{num == 41} {mode = 3};
				{this.update}.defer;
				};
				
			};
		
	}
	
	recallMacro { |index|
	
		var blendedPreset, blendedVol, thisBlendAmt;
		
		if(presets[index] != nil) 
			{
			if(lastPresetWasRecalledDuringTweakModeFlag == 1)
				{
				if(lastSelectedSlot != nil)
					{presets[lastSelectedSlot] = getMacroAction.value};
			
				};
			lastPresetWasRecalledDuringTweakModeFlag = 0;
			if(lastPreset == nil) {lastPreset = presets[index].deepCopy};
			if(blendAmt > 0.0)
				{
				case
					{blendMode == 0}
					{thisBlendAmt = blendAmt}
					{blendMode == 1}
					{thisBlendAmt = rrand(0, blendAmt)};
				if(presets[index].asArray[0] == \bl_unb)
					{
					// the preset contains BLENDABLE and then UNBLENDABLE information
					// blend the blendable and choose the unblendable
					blendedPreset = 
						[
						presets[index][1].blend(lastPreset[1], thisBlendAmt),
						[presets[index][2], lastPreset[2]][thisBlendAmt.round(1).asInt.clip(0, 1)]
						];
				//	blendedPreset.postcs;
					}
					{
					blendedPreset = presets[index].blend(lastPreset, thisBlendAmt);
					};
				blendedVol = vols[index].blend(vols[lastSelectedSlot ? index], thisBlendAmt);	
				}
				{
				if(presets[index].asArray[0] == \bl_unb)
					{blendedPreset = presets[index].copyRange(1, 2)}
					{blendedPreset = presets[index]};
				blendedVol = vols[index];
				};
			recallMacroAction.value(blendedPreset, blendedVol, includeEnv);
				
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
		 lastPresetWasRecalledDuringTweakModeFlag = 0;
	
	
	}
	
	eraseMacro { |index|
	
		presets[index] = nil;
		{butGrid.setStatusOfOneStep(index, 0)}.defer;
		lastPresetWasRecalledDuringTweakModeFlag = 0;
	
	
	}
	
	tweak { |index|
		
		if(lastSelectedSlot != nil)
			{presets[lastSelectedSlot] = getMacroAction.value};
		this.recallMacro(index);
		lastPresetWasRecalledDuringTweakModeFlag = 1;
	
	
	}
	
		
}






