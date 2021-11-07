C2PL_GUI_PicCtrl {

	var <w, cv, gui, defaultPatch, autosave;
	var <>link;
	var <>action, <>picEnableAction, <>resizeAction;
	var <updateFromSetDataFlag = 1, but_updateFromSetDataFlag;
	var enabled = 0, but_enabled;
	var fps = 24, num_fps;
	var but_resize, but_allDefault;
	var data;

	*new { ^super.new.init }
	
	init {
	
		var controlNames, specs, midiCtrlData;
		
		controlNames = [
			"bounds arr", "line width", "width mult", "non wid mult",
			"vol max", "movement amt", "flux sens",
			"blendMode", "maskAlpha",
			"blob width mult", "dashMult", "minimum dash",
			"style",
			"background",
			"color 1", "color 2", "color 3", "color 4",
			"color 5", "color 6", "color 7", "color 8",
			];
		// min, max, warp, stepsize, default, units
		specs = 
			[
			ControlSpec(0.0, 1.0, \lin, 0.01, 0.0, "arr"),
			
			ControlSpec(0.5, 20.0, \lin, 0.01, 10.0, "width"),
			ControlSpec(1.0, 20.0, \lin, 0.01, 1.0, "width mult"),
			ControlSpec(0.0, 1.0, \lin, 0.001, 0.0, "nonactive w mult"),
			
			ControlSpec(0.2, 2.0, \lin, 0.01, 1.0, "vol max"),
			ControlSpec(0.2, 1.5, \lin, 0.001, 1.0, "movement amt"),
			ControlSpec(0, 0.8, \lin, 0.001, 0.1, "flux sens"),
			
			ControlSpec(0, 15, \lin, 1, 0, "blendMode"),
			ControlSpec(0.006, 1.0, \exp, 0.0001, 1.0, "maskAlpha"),
			
			ControlSpec(0.1, 20.0, \exp, 0.001, 1.0, "blobWidthMult"),
			ControlSpec(0.005, 2.0, \exp, 0.001, 0.01, "dashMult"),
			ControlSpec(0.001, 1.0, \lin, 0.001, 0.001, "minimum dash"),
			
			ControlSpec(0, 10, \lin, 1, 0, "style"),
			
			ControlSpec(0.0, 1.0, \lin, 0.0001, 1.0, "background"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 1"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 2"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 3"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 4"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 5"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 6"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 7"),
			ControlSpec(0.0, 1.0, \lin, 0.0001, 0.0, "color 8"),
			];

		defaultPatch = specs.collect({ |i| i.default });
		
		autosave = C2_AutoSave2("c2pl_pic", "C2PL");
		autosave.overwriteFlag_(1);
		
		gui = C2_ControlSpecGUI5_4C2PL("Pic Control", controlNames, specs, [0, 2, 2, 1, 2, 0, 8]);
		gui.background_(Color.rand).knobColor_(C2_Color(\yellow1));
		
		gui.action = { |vals| action.value([fps] ++ vals) };
		
		gui.midiCtrlChangeAction = { |gui| autosave.save("last", gui.getData_midi) };
		
		midiCtrlData = autosave.open("last");
		if(midiCtrlData != nil)
			{
			gui.setData_midi(autosave.open("last"));
			};
			
		data = C2_DataDevice3.new;
		data.name_("picCtrl").guiColor_(C2_Color('MediumOrchid2')).fileBaseName_("c2pl_pic").guiLength_(155);
		data.getDataAction =
			{
			this.getData;
			};
		data.setDataAction = 
			{
			|args|
			this.setData(args);
			};

	
	
	}
	
	front { w.front }
	
	reportBounds { ^w.bounds }
	
	setBounds { |bounds| w.bounds_(bounds) }
	
	draw { |winX = 85, winY = 20, color|
	
		w = Window("Particularity : Picture Controller", Rect(winX, winY, 645, 630)).front;
		w.userCanClose_(false);
		color = color ? C2_Color('SteelBlue');
		
		cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));
		cv.background_(color);
		w.setResizeView(cv);
		w.enableResize(1);
		
		but_enabled = Button(cv, Rect(10, 10, 100, 20));
		but_enabled.font_(Font("Helvetica", 12));
		but_enabled.states = 
			[
			["disabled", Color.white, Color.red],
			["enabled", Color.black, Color.green]
			];
		but_enabled.value = enabled;
		but_enabled.action = { |but| enabled = but.value; picEnableAction.value(enabled) };
		
		but_updateFromSetDataFlag = Button(cv, Rect(120, 10, 180, 20));
		but_updateFromSetDataFlag.font_(Font("Helvetica", 12));
		but_updateFromSetDataFlag.states = 
			[
			["Don't update from Palette", Color.black, Color.grey],
			["Accept update from Palette", Color.black, Color.yellow]
			];
		but_updateFromSetDataFlag.value = updateFromSetDataFlag;
		but_updateFromSetDataFlag.action = { |but| updateFromSetDataFlag = but.value };
		
		StaticText(cv, Rect(310, 10, 30, 20)).font_(Font("Helvetica", 12)).string_("FPS ").align_(\right);
		
		num_fps = C2_ScrollNumberBox(cv, Rect(345, 10, 35, 20), 1, 1, 120);
		num_fps.action =  { |num| fps = num.value; action.value([fps] ++ gui.vals) };
		num_fps.value = fps;
		
		but_resize = Button(cv, Rect(390, 10, 100, 20));
		but_resize.font_(Font("Helvetica", 12));
		but_resize.states = 
			[
			["resize", Color.white, Color.black]
			];
		but_resize.action = { |but| resizeAction.value };
		
		but_allDefault = Button(cv, Rect(10, 590, 50, 20));
		but_allDefault.states = [["D_all", Color.white, C2_Color(\brown3)]];
		but_allDefault.action = {
		
			gui.setValsWithArray(defaultPatch.deepCopy);
		
		};

		gui.background_(C2_Color('DarkOliveGreen3'));			gui.guiDraw(cv, 10, 35, height: 20, fontSize: 11);
		
		data.guiDraw(cv, 450, 590);
		
		
			
	
	}
	
	vals {
	
		^gui.vals;
	
	}
	
	setData { |args|
	
		args = args.deepCopy;
				
		if(updateFromSetDataFlag == 1)
			{
			gui.setValsWithArray(args.deepCopy);
			action.value([fps] ++ args);
			};
		
	}
	
	getData {
	
		^gui.vals.deepCopy;
	
	}
	
	
	
}





