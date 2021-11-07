C2PL_GUI_Synth {

	// the object linked to this gui
	// obviously this gui is very specific so better give it the right object
	var <link;
	
	var <w, cv, ms_harmonics, ms_waveform, ms_envelope, ms_result, ms_freqEnv;
	var gui, but_startStop, but_rndPhaseStatus, num_audioBusOut, num_noOfTrains;
	var but_envOptions, num_envCurve, pop_harmPresets, but_harmPresetsDoIt, gui_spread;
	var harmPresets, <defaultPatch, data, autosave;
	var pop_currentSynthDefIndex;
	var but_bufMode;
	// but_bufMode - buffer filled by (0) harmonics/drawing or (1) external sample?
	var st_soundFileLocation, but_openSoundFile;
	var st_harmonics,	st_waveform, but_allDefault;
	var but_harmonics_rndPhaseFlag, but_harmRnd;
	
	link_ { |argLink, name, color|
	
		link = argLink;
		if(w == nil) {^nil};

		if(name != nil) { {w.name_(name)}.defer };
		if(color != nil) { {cv.background_(color); w.front}.defer };

		
	}

	*new { ^super.new.init }
	
	init {
	
		var controlNames, specs, midiCtrlData;
	
		controlNames = 
			[
			"Start Pos", "Trig Freq hz",
			"Grain Freq Mult", "Env Dur Mult",
			"Modulation Ratio", "Modulation Amt",
			"Flux Amount", 
			"Probability",
			"Pan", "Level"
			];
		
		// min, max, warp, stepsize, default, units
		specs = 
			[
			ControlSpec(0.0, 1.0, \lin, 0.001, 0.0, "Start Pos"),
			
			ControlSpec(2.0, 3000, \exp, 0.001, 120, "Trig Freq hz"),
			ControlSpec(0.05, 16.0, \exp, 0.001, 1.0, "Grain Freq Mult"),
			
			ControlSpec(0.0625, 8.0, \exp, 0.001, 1.0, "Env Dur Mult"),
			
			ControlSpec(0.125, 16, \exp, 0.001, 1.0, "FM Ratio"),
			ControlSpec(0.0, 16.0, \lin, 0.001, 0.0, "FM amt"),
						
			ControlSpec(0.0, 0.99, \lin, 0.001, 0.0, "Flux Amount"),

			ControlSpec(0.0, 1.0, \lin, 0.001, 1.0, "Probability"),

			ControlSpec(-1.0, 1.0, \lin, 0.01, 0, "Pan"),
			ControlSpec(0.1, 1.6, \lin, 0.01, 0.6, "Level")
			];
			
		defaultPatch = specs.collect({ |i| i.default });

		autosave = C2_AutoSave2("c2pl_syngui", "C2PL");
		autosave.overwriteFlag_(1);
		
		gui = C2_ControlSpecGUI5_4C2PL("Synth Params", controlNames, specs, [0, 2, 1, 1, 1]);
		gui.background_(Color.white).knobColor_(C2_Color(\yellow1));
		gui.midiCtrlChangeAction = { |gui| autosave.save("last", gui.getData_midi) };

		midiCtrlData = autosave.open("last");
		if(midiCtrlData != nil)
			{
			gui.setData_midi(autosave.open("last"));
			};
		
		
		// "Saw 1", "Saw 2", "Square 1"
		harmPresets = 
			[
			1 / [1, 2, 3, 4, 5, 6, 7, 8],
			(1 / [1, 2, 3]) ++ [0, 0, 0],
			1 / [1, 2, 3, 4, 5, 6, 7, 8] * [1, 0, 1, 0, 1, 0, 1, 0]
			];
			
		data = C2_DataDevice3.new;
		data.name_("synth").guiColor_(C2_Color('MediumOrchid1')).fileBaseName_("c2pl_syn").guiLength_(155);
		data.getDataAction = 
			{
			link.getData;
			};
		data.setDataAction =
			{
			|args|
			link.setData(args, setSynthDataFlag: 1, setSeqDataFlag: 0);
			};
	}

	front { w.front }
	
	reportBounds { ^w.bounds }
	
	setBounds { |bounds| w.bounds_(bounds) }
	
	draw { |winX = 10, winY = 155, color|
	
		var startX, startY, x, y, labels, defaults;
		var stringBackground, msSize = 158, gap = 10;
		
		startX = 5; startY = 50;
		
		w = Window("Particularity : Synth 1", Rect(winX, winY, 720 - 40 - 45, 600)).front;
		w.userCanClose_(false);
		color = color ? Color.rand;
		
		cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));
		cv.background_(color);
		w.setResizeView(cv);
		w.enableResize(1);
		
		y = 5;
		
		pop_currentSynthDefIndex = PopUpMenu(cv, Rect(420, y, 150, 20));
		pop_currentSynthDefIndex.font_(Font("Helvetica", 10)).background_(\cornsilk2);
		pop_currentSynthDefIndex.items = C2PL_SynthDef.names;
		
		but_startStop = Button(cv, Rect(575, y, 50, 20));
		but_startStop.states = 
			[
			[ "[]", Color.white, C2_Color(\red2) ],
			[ "|>", Color.black, C2_Color(\green1) ]
			];
				
		x = startX; y = startY;
		
		but_bufMode = Button(cv, Rect(5, 5, 120, 20));
		but_bufMode.font_(Font("Helvetica", 10));
		but_bufMode.states =
			[
			["Harmonics / Draw Wave", Color.black, C2_Color(\grey)],
			["Use Sound File", Color.black, C2_Color(\yellow2)]
			];
			
		st_soundFileLocation = StaticText(cv, Rect(130, 5, 260, 20));
		st_soundFileLocation.background_(\grey);
		st_soundFileLocation.font_(Font("Helvetica", 10)).align_(\center);
		
		but_openSoundFile = Button(cv, Rect(395, 5, 20, 20));
		but_openSoundFile.states = [ ["O", Color.white, Color.red] ];
		
		stringBackground = \yellow2;

		st_harmonics = 
			StaticText(cv, Rect(x, y - 20, msSize - 40 + 25, 20)).string_("Harmonics")
				.font_(Font("Helvetica", 12)).background_(stringBackground).align_(\center);
				
		ms_harmonics = MultiSliderView(cv, Rect(x, y, msSize - 40 + 25, msSize - 25));
		ms_waveform = C2L_GUI_WaveEditor(cv, Rect(x + msSize + gap - 20, y - 20, msSize - 25, msSize - 25), 2048); 

		ms_envelope = C2L_GUI_AmpEnvEditor(cv, Rect(x + (msSize * 2) + (gap * 2) - 50, y - 20, msSize, msSize - 25), 64);
		ms_freqEnv = C2L_GUI_AmpEnvEditor(cv, Rect(x + (msSize * 3) + (gap * 3) - 50, y - 20, msSize, msSize), 64, "Freq Envelope");

		msSize = 150;	
		
		ms_harmonics.value = Array.fill(16, {0.0});
		ms_harmonics.elasticMode_(1);
		ms_harmonics.background_(\MediumPurple1)
			.strokeColor_(C2_Color(\yellow1))
			.fillColor_(C2_Color(\DeepPink2))
			.drawLines_(false).drawRects_(true)
			.isFilled_(true).valueThumbSize_(1);
		ms_harmonics.reference = Array.fill(16, {0.0});

		
		but_harmonics_rndPhaseFlag = Button(cv, Rect(x, (y + msSize + 15) - 25, msSize - 25 - 40 - 10, 20));
		but_harmonics_rndPhaseFlag.states = 
			[
			["all phases 0.0", Color.black, C2_Color('sky blue')],
			["rnd phases", Color.black, C2_Color('orchid1')]
			];
		but_harmonics_rndPhaseFlag.font_(Font("Helvetica", 10));
		
		but_harmRnd = Button(cv, Rect(x + (msSize - 25 - 40) - 5, (y + msSize + 15) - 25, 60, 20));
		but_harmRnd.states = 
			[
			["rand amp", Color.black, C2_Color(\GreenYellow)]
			];
		but_harmRnd.font_(Font("Helvetica", 10));
		
		pop_harmPresets = PopUpMenu(cv, Rect(x, (y + msSize + 15), msSize - 25 - 40, 20));
		pop_harmPresets.font_(Font("Helvetica", 10)).background_(\cornsilk2);
		pop_harmPresets.items = ["Saw 1", "Saw 2", "Square 1"];
		but_harmPresetsDoIt = Button(cv, Rect(x + msSize - 20 - 40, (y + msSize + 15), 20, 20));
		but_harmPresetsDoIt.states = [["do", Color.black, C2_Color(\cornsilk2)]];
		but_harmPresetsDoIt.font_(Font("Helvetica", 10));
		
		gui.background_(C2_Color('grey77'));
		gui.guiDraw(cv, 5, 280, height: 22, fontSize: 11);
		
		x = 534 - 40 - 20; y = 220;
		
		but_rndPhaseStatus = Button(cv, Rect(5, 255, 200, 20));
		but_rndPhaseStatus.states = 
			[
			["Start Trigger Phase 0.0", Color.white, C2_Color(\purple3)],
			["Start Trigger Random Phase", Color.black, C2_Color('chartreuse')]
			];
			
		StaticText(cv, Rect(x, y + 30, 115, 20)).string_("No. Of Spreads")
			.font_(Font("Helvetica", 12)).background_(stringBackground).align_(\center);
			
		
		data.guiDraw(cv, x, 245);
		
		but_allDefault = Button(cv, Rect(x - 60, 255, 50, 20));
		but_allDefault.states = [["D_all", Color.white, C2_Color(\brown3)]];
		
		this.makeActions;
		
	}
	
	makeActions {
	
		but_harmonics_rndPhaseFlag.action = { |but| link.harmonics_rndPhaseFlag = but.value; link.setHarmonics(ms_harmonics.value) };
		but_harmRnd.action = { data.copy; ms_harmonics.value = Array.rand(ms_harmonics.value.size, 0.0, 1.0); link.setHarmonics(ms_harmonics.value) };
		pop_currentSynthDefIndex.action = { |pop| link.changeSynthDef(pop.value) };
	
		but_startStop.action = { |but| link.startStop(but.value) };
		but_rndPhaseStatus.action = { |but| link.rndPhaseStatus_(but.value) };
		
		ms_harmonics.action = { |ms| link.setHarmonics(ms.value) };
		ms_harmonics.mouseDownAction = { |ms| data.copy };
		ms_waveform.mouseUpAction = { |ms| data.copy; link.setSignal(ms.value.collect({|i| [-1.0, 1.0].asSpec.map(i)})) };
		ms_envelope.mouseUpAction = { |ms| link.envArray_(ms.value) };
		ms_envelope.getWaveToCopyAction = { link.signal_wave };
		ms_freqEnv.mouseUpAction = { |ms| link.freqEnvArray_(ms.value) };
		ms_freqEnv.getWaveToCopyAction = { link.signal_wave };		
		but_harmPresetsDoIt.action = 
			{
			link.setHarmonics(harmPresets[pop_harmPresets.value]);
			};

		gui.action = { |vals, valIndex| this.respondToAction(vals, valIndex) };
		
		but_bufMode.action = { |but| link.setBufMode(but.value.asInt); this.update; };
		
		but_openSoundFile.action = 
			{
			
			CocoaDialog.getPaths(
				{
				arg paths;
				var temp;
				link.setFilePath(paths[0]);
				{this.update}.defer;
				},
				{
				(" Particularity Synth - open soundfile cancelled").postln;
				},
				1
			)		
			
			};
			
		but_allDefault.action = 
			{
			data.copy;
			gui.setValsWithArray(defaultPatch);
			this.respondToAction(defaultPatch);
			ms_envelope.createEnv(\rec);
			link.setHarmonics([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
			link.freqEnvArray_(ms_freqEnv.value.collect({|i| 0.0}) );
			this.update;
			};
	
	}
	
	update {
	
		var noOfSpreads, spreadWidth, spreadAmpReduce, splay;
	
		if(link == nil) {^nil};
		
		but_harmonics_rndPhaseFlag.value = link.harmonics_rndPhaseFlag;
		
		#noOfSpreads, spreadWidth, spreadAmpReduce, splay = link.getSpreadParams.deepCopy;
		
		pop_currentSynthDefIndex.value = link.currentSynthDefIndex;
		but_startStop.value = link.synthRunningStatus;
		but_rndPhaseStatus.value = link.rndPhaseStatus;
		ms_harmonics.value = link.harmonicsArray;
		if((link.signalMode == 1) or: (link.bufMode == 1))
			{
			ms_harmonics.background_(\grey44).fillColor_(C2_Color(\grey40));
			st_harmonics.background_(\grey44);
			}
			{
			ms_harmonics.background_(\MediumPurple1).fillColor_(C2_Color(\DeepPink2));
			st_harmonics.background_(\yellow2);
			};
		ms_waveform.value = link.signal_wave.collect( {|i| [-1.0, 1.0].asSpec.unmap(i) } );
		if(link.bufMode == 1)
			{
			ms_waveform.used_(0);
			st_soundFileLocation.background_(\yellow2);
			}
			{
			ms_waveform.used_(1);
			st_soundFileLocation.background_(\grey);
			};
		ms_envelope.value = link.envArray.collect( {|i| i } );
		ms_freqEnv.value = link.freqEnvArray.collect( {|i| i } );
			
		gui.setValsWithArray(link.synthVals);
		
		but_bufMode.value = link.bufMode;
		
		if(link.soundfilePath != nil)
			{st_soundFileLocation.string = PathName(link.soundfilePath).fileName}
			{st_soundFileLocation.string = "-"};
	
	}
	
	// vals from the C2_ControlSpecGUI4 gui
	respondToAction { |vals, valIndex|
	
		link.setSynthVals(vals);
	
	}
	
	




}
