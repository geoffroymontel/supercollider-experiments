C2_DataDevice3 {

	var w, <>pushObject;
	var <>name, <>guiColor, <>guiLength;
	var but_open, but_save, but_copy, but_paste;
	var copyBuffer, undoBuffer, pasteCount = 0;
	var <>fileBaseName;
	var <>getDataAction, <>setDataAction;
	
	*new { ^super.new.init }	
	
	init {
	
		fileBaseName = "c2_dd";
		name = "";
		guiColor = C2_Color('grey66');
		guiLength = 300;
	
	}

	open {
			
		CocoaDialog.getPaths(
				{
				arg paths;
				var temp;
					paths.do({ arg p;
						if(p.basename.splitext[1] == fileBaseName,
							{
							temp = Object.readBinaryArchive(p);
							setDataAction.value(temp);
							}
						);
					
					})
				},
				{
				(name ++ " - open cancelled").postln;
				},
				1
			)
	
	}
	
	save {
			
		CocoaDialog.savePanel(
			{
			arg path;
			var temp;

			temp = getDataAction.value;
			temp.writeBinaryArchive(path ++ "." ++ fileBaseName);
			},
			{
			(name ++ " - save cancelled").postln;
			}
		);

	
	}
	
	copy {
	
		copyBuffer = getDataAction.value;
		pasteCount = 0;
	
	}
	
	paste {
	
		if(copyBuffer == nil) {^nil};
		
//		if(pasteCount.even)
//			{
//			undoBuffer = getDataAction.value;
			setDataAction.value(copyBuffer.deepCopy);
//			}
//			{
//			if(undoBuffer != nil) { setDataAction.value(undoBuffer.deepCopy); };
//			};
		
		pasteCount = pasteCount + 1;
	
	}
	
	
	
	guiDraw { arg window, startX, startY;
	
		var x, y;
		
		w = SCCompositeView(window, Rect(startX, startY, guiLength, 30));
		w.background_(guiColor);
		
		C2_StaticText(w, Rect(5, 5, guiLength - 110, 20)).string_(name).font_(Font("Helvetica", 12));
		
		but_open = C2_Button(w, Rect(guiLength - 100, 5, 20, 20));
		but_open.states = [["O", C2_Color('white'), C2_Color('red1')]];
		but_open.font_(Font("Helvetica", 12));
		
		but_save = C2_Button(w, Rect(guiLength - 75, 5, 20, 20));
		but_save.states = [["S", C2_Color('white'), C2_Color('green3')]];
		but_save.font_(Font("Helvetica", 12));
		
		but_copy = C2_Button(w, Rect(guiLength - 50, 5, 20, 20));
		but_copy.states = [["c", Color.black, C2_Color('yellow1')]];
		but_copy.font_(Font("Helvetica", 12));
		
		but_paste = C2_Button(w, Rect(guiLength - 25, 5, 20, 20));
		but_paste.states = [["p", Color.black, C2_Color('LightBlue1')]];
		but_paste.font_(Font("Helvetica", 12));

		this.guiMakeActions;
	
	}
	
	guiUpdate {
	
		w.background_(guiColor);
	
	}
	
	guiMakeActions {
	
		but_open.action = { arg but; this.open };
		but_save.action = { arg but; this.save };
		but_copy.action = { arg but; this.copy }; 
		but_paste.action = { arg but; this.paste }; 
	
	}
	
	guiRemove {
	
		if(w != nil) {w.remove; w = nil};
	
	}

}


C2_DataDevice3_compact : C2_DataDevice3 {

	// guiLength set at 70 - for pulsar generator 2010
	guiDraw { arg window, startX, startY;
	
		var x, y;
		
		guiLength = 70;
		
		w = SCCompositeView(window, Rect(startX, startY, guiLength, 100));
		w.background_(guiColor);
		
		C2_StaticText(w, Rect(5, 5, guiLength - 10, 20)).string_(name).stringColor_(Color.white).align_(\center);
		
		but_open = C2_Button(w, Rect(10, 35, 20, 20));
		but_open.states = [["O", C2_Color('white'), C2_Color('red1')]];
		
		but_save = C2_Button(w, Rect(40, 35, 20, 20));
		but_save.states = [["S", C2_Color('white'), C2_Color('green3')]];
		
		but_copy = C2_Button(w, Rect(10, 70, 20, 20));
		but_copy.states = [["c", Color.black, C2_Color('yellow1')]];
		
		but_paste = C2_Button(w, Rect(40, 70, 20, 20));
		but_paste.states = [["p", Color.black, C2_Color('LightBlue1')]];

		this.guiMakeActions;
	
	}



}

