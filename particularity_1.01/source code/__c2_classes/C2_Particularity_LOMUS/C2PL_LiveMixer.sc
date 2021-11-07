C2PL_LiveMixer {

	var <w, cv, gui, defaultPatch, autosave;
	var <>link;
	var <outBus, pop_outBus, but_allDefault;

	*new { ^super.new.init }
	
	vals {
	
		^gui.vals
		
	}
	
	getVols {
	
		^[
		gui.vals[2], gui.vals[5], gui.vals[8], gui.vals[11],
		gui.vals[14], gui.vals[17], gui.vals[20], gui.vals[23]
		];
	
	}
	
	getPans {
	
		^[
		gui.vals[1], gui.vals[4], gui.vals[7], gui.vals[10],
		gui.vals[13], gui.vals[16], gui.vals[19], gui.vals[22]
		];
	
	}
	
	getTrsp {
	
		^[
		gui.vals[0], gui.vals[3], gui.vals[6], gui.vals[9],
		gui.vals[12], gui.vals[15], gui.vals[18], gui.vals[21]
		];
	
	}
	
	allTrsp {
	
		^gui.vals[25];
	
	}
	
	allVol {
	
		^gui.vals[26];
	
	}
	
	init {
	
		var baseNames, baseSpecs, controlNames, specs, midiCtrlData;
		
		baseNames = ["Freq", "Pan", "Level"];
		// min, max, warp, stepsize, default, units
		baseSpecs = 
			[
			ControlSpec(-24, 24, \lin, 0.01, 0.0, "Freq"),
			ControlSpec(-1.0, 1.0, \lin, 0.01, 0.0, "Pan"),
			ControlSpec(0, 1, \lin, 0.001, 0.6, "Level")			];
	
		controlNames = Array.newClear(baseNames.size * 8);
		specs = Array.newClear(controlNames.size);
		controlNames.do { |item, index|
		
			controlNames[index] = (index.div(baseNames.size) + 1).asString ++ " - " ++ baseNames[index.wrap(0, baseNames.size - 1)];
			specs[index] = baseSpecs[index.wrap(0, baseNames.size - 1)].deepCopy;
		};
		
		controlNames = controlNames ++ ["All Seq Speed", "All Transpose", "All Vol"];
		specs = specs ++ 
			[
			ControlSpec(0.25, 4, \exp, 0.01, 1.0, "All Seq Speed"),
			ControlSpec(-24, 24, \lin, 0.01, 0.0, "All Transpose"),
			ControlSpec(0, 1, \lin, 0.001, 1.0, "All Vol")			];

		defaultPatch = specs.collect({ |i| i.default });
		
		autosave = C2_AutoSave2("c2pl_pgmix", "C2PL");
		autosave.overwriteFlag_(1);
		
		gui = C2_ControlSpecGUI5_4C2PL("Live Mixer", controlNames, specs, [2, 2, 2, 2, 2, 2, 2, 2, 2]);
		gui.background_(Color.rand).knobColor_(C2_Color(\yellow1));
		
		gui.action = { |vals| link.liveMixerUpdate(vals, outBus) };
		
		gui.midiCtrlChangeAction = { |gui| autosave.save("last", gui.getData_midi) };
		
		midiCtrlData = autosave.open("last");
		if(midiCtrlData != nil)
			{
			gui.setData_midi(autosave.open("last"));
			};
			
		outBus = 0;
	
	
	}
	
	front { w.front }
	
	reportBounds { ^w.bounds }
	
	setBounds { |bounds| w.bounds_(bounds) }
	
	draw { |winX = 85, winY = 20, color|
	
		var x, y;
	
		w = Window("Particularity : Live Mixer", Rect(winX, winY, 650, 620)).front;
		w.userCanClose_(false);
		color = color ? Color.rand;
		
		cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));
		cv.background_(color);
		w.setResizeView(cv);
		w.enableResize(1);
	
		gui.background_(C2_Color('DarkOliveGreen3'));
		gui.guiDraw(cv, 5, 35, height: 16, fontSize: 12);
		
		x = 480;
		
		StaticText(cv, Rect(5, 5, 100, 20)).string_("Master Output: ").font_(Font("Helvetica", 12)).align_(\right);
		
		
		pop_outBus = PopUpMenu(cv, Rect(110, 5, 200, 20));
		pop_outBus.items = ["Stereo 1 & 2", "Stereo 3 & 4", "Stereo 5 & 6", "Stereo 7 & 8", "Stereo 9 & 10", "Stereo 11 & 12", "Stereo 13 & 14", "Stereo 15 & 16"];
		pop_outBus.background_(C2_Color(\cyan2));
		pop_outBus.value = (outBus / 2).round(1).asInt;
		pop_outBus.action = { |pop| outBus = pop.value; link.liveMixerUpdate(gui.vals, outBus * 2) };
		
		but_allDefault = Button(cv, Rect(5, 595, 50, 20));
		but_allDefault.states = [["D_all", Color.white, C2_Color(\brown3)]];
		but_allDefault.action = {
		
			gui.setValsWithArray(
				[
				0.0, 0.0, 0.6, 0.0, 0.0, 0.6, 0.0, 0.0, 0.6, 0.0, 0.0, 0.6, 
				0.0, 0.0, 0.6, 0.0, 0.0, 0.6, 0.0, 0.0, 0.6, 0.0, 0.0, 0.6, 
				1.0, 0.0, 1.0
				]
			);
		
		};

	
	}
	
	getData {
	
		^[outBus]
		
	}
	
	setData { |args|
		
		args = args.deepCopy;
		outBus = args[0];
		

		
		
	}
	
	
	
}