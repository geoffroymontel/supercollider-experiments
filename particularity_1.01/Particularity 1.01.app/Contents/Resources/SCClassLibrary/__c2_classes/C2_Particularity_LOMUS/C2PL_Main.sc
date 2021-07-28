/*
(
x = C2P_Main.new;
)
*/

C2PL_Main {

	var gui_control, gui_synth, gui_seq, gui_palette, gui_liveMixer;
	var trains, currentTrainBeingEdited = 0;
	var colors, lastMixerVals;
	var picCoords, gui_pic, gui_picCtrl;
	var server, <bpm = 120;
	
	// support for soundfiles: a disk path to 
	var sfPaths, sfPathToBufNumDict, sfBuffers;
	
	var <groups, cmdPeriodFunc;
	
	*new { |server| ^super.new.init(server) }
	
	serverInit { |argServer, initSynthsFlag = 0|
	
		var noOfFrames = 2048;
	
		server = argServer ? Server.internal;
		server.waitForBoot({
			server.volume_(-8);
			this.reloadSfBuffers;
			C2PL_SynthDef.send(server);
			
			groups = Array.newClear(8);
			this.resetGroups;
			
			if(initSynthsFlag == 1) { this.synthsReInit };
			
		});
	
	}
	
	synthsReInit {
	
		trains.do { |item, index|
			item.initBuf;
		};
	
	
	}
	
	performCmdPeriodFunc {
		
		trains.do { |item, index|
//			trains[index].startStop(0, 0);
//			trains[index].seqStartStop(0, 0);
			
			this.updateTransportStatus(index, \train, 0);
			this.updateTransportStatus(index, \seq, 0);
			
		};
//		{this.guiUpdate}.defer;
		
		this.resetGroups;
	
	}
	
	resetGroups {
	
		groups.do { |item, index|
			groups[index] = Group(server, \addToTail);
			trains[index].group_(groups[index]);
		};	
	
	}
	
	init { |argServer|
	
		argServer = argServer ? Server.internal;
		server = argServer;	
		cmdPeriodFunc = { {this.performCmdPeriodFunc}.defer(0.1);  };
		CmdPeriod.add(cmdPeriodFunc);
		sfPaths = [];
	
		colors = 
			[
			Color(0.44964079856873, 0.51216723918915, 0.69256610870361, 1.0),
			Color(0.39222900867462, 0.82839775085449, 0.5793653011322, 1.0),
			Color(0.76902780532837, 0.37183413505554, 0.82872104644775, 1.0),
			Color(0.78125023841858, 0.62082488536835, 0.48748097419739, 1.0),
			Color(0.35635063648224, 0.77297630310059, 0.81480774879456, 1.0),
			Color(0.34546709060669, 0.54165852069855, 0.48702321052551, 1.0),
			Color(0.62568583488464, 0.82837450504303, 0.30923731327057, 1.0),
			Color(0.4276439666748, 0.37010107040405, 0.76727313995361, 1.0)
			];
	
		gui_synth = C2PL_GUI_Synth.new;
		gui_seq = C2PL_GUI_Seq.new;
		
		gui_pic = C2PL_GUI_Pic.new;
		gui_picCtrl = C2PL_GUI_PicCtrl.new;
		gui_picCtrl.action = 
			{
			|vals|
			gui_pic.updateFromCtrl(vals);
			};
			
		gui_picCtrl.picEnableAction = 
			{
			|enabled|
			gui_pic.enableByVal(enabled);
			};
			
		gui_picCtrl.resizeAction = { gui_pic.resize };
		
		gui_palette = C2_PresetPalette3_4C2PL.new("c2pl_pal");
		gui_palette.windowName_("Particularity : Preset Palette");
		
		gui_palette.getMacroAction = 
			{
			[
			\bl_unb, this.getPatch, 
			trains.collect({|i| [i.soundfilePath, i.seqParamNos]})
			] 
			};
		gui_palette.recallMacroAction = 
			{
			|args, volAdjust| 
			args = args.deepCopy;
			this.setPatch(args[0], 1, volAdjust);
			trains.do { |item, index| 
				trains[index].setFilePath(args[1][index][0]);
				trains[index].seqParamNos_(args[1][index][1]);
			};
			};

			
		gui_palette.openAction = 
			{
			|args|
			// get these additional args - ie the soundfile dict
			if(args != nil) { args = args.deepCopy; sfPaths = args[0]; gui_liveMixer.setData(args[1]); this.reloadSfBuffers; };
			};
		gui_palette.saveAction = 
			{
			// save additional stuff - provide more stuff to save
			// return the soundfile dict
			[sfPaths, gui_liveMixer.getData]
			};
		
		gui_liveMixer = C2PL_LiveMixer.new;
		gui_liveMixer.link_(this);
		
		trains = Array.newClear(8);
		picCoords = Array.newClear(8);
		trains.do { |item, index| 
			trains[index] = C2PL_Synth.new(server, defaultPatch: gui_synth.defaultPatch);
			trains[index].link_(this); trains[index].idNo_(index);
			trains[index].picAction_(
				{
				|pairs|
				picCoords[index] = pairs.deepCopy;
				gui_pic.setCoords(
					index,
					picCoords[index],
					trains.collect({|i| i.synthRunningStatus}),
					trains.collect({|i| i.seqRunningStatus}),
					trains.collect({|i| i.getProbability}),
					trains.collect({|i| i.getFlux}),
					gui_liveMixer.getVols,
					gui_liveMixer.getPans,
					gui_liveMixer.getTrsp,
					gui_liveMixer.allTrsp, gui_liveMixer.allVol
				);
				}
			);
			picCoords[index] = [ [0, 0], [0, 0], [0, 0], [0, 0], [0, 0] ];
		};
		
		gui_control = C2PL_GUI_Control.new;
		gui_control.link_(this);
		gui_control.muteAction = { |val| 8.do { |i| trains[i].mute(val) } };
		
		gui_synth.link_(
			trains[currentTrainBeingEdited],
			"Particularity : Synth " ++ (currentTrainBeingEdited + 1).asString,
			colors[currentTrainBeingEdited]
		);
		gui_seq.link_(
			trains[currentTrainBeingEdited],
			"Particularity : Sequences " ++ (currentTrainBeingEdited + 1).asString,
			colors[currentTrainBeingEdited]
		);
		
		this.serverInit(argServer);
		this.guiDraw;
	
	}
	
	allTrainsStatus {
	
		^[
		trains.collect({|i| i.synthRunningStatus}),
		trains.collect({|i| i.seqRunningStatus})
		];
	
	}
	
	pallette_scaleAllVols { |mul|
	
		gui_palette.scaleAllVols(mul);
		
	}
	
	liveMixerUpdate { |vals, outBus|

		var speed, trspMult, vol;
				
		if(vals == nil) {vals = gui_liveMixer.vals};
		if(outBus == nil) {outBus = gui_liveMixer.outBus};
		lastMixerVals = vals.deepCopy;
		vals = vals.clump(3);
		
		#speed, trspMult, vol = vals[vals.lastIndex].deepCopy;
		
		trains.do { |item, index|
		
			vals[index][0] = vals[index][0].midiratio * trspMult.midiratio;
			vals[index][2] = vals[index][2] * vol;
			item.updateFromLiveMixer(*(vals[index] ++ [speed]));
			item.setOutBus(outBus);
		};
		
	
	}
	
	winFront { |type|
	
		case
			{type == \synth}
			{gui_synth.front}
			{type == \seq}
			{gui_seq.front}
			{type == \palette}
			{gui_palette.front}
			{type == \mixer}
			{gui_liveMixer.front}
			{type == \picture}
			{gui_pic.front}
			{type == \picCtrl}
			{gui_picCtrl.front};
	
	
	}
	
	guiDraw {
	
		var color;
	
		color = Color(0.44964079856873, 0.51216723918915, 0.69256610870361, 1.0);
		gui_control.draw(5, 16);
		gui_synth.draw(100, 20, color); gui_seq.draw(740, 20, color);
		gui_palette.draw(100, 645, C2_Color('wheat3'));
		
		gui_liveMixer.draw(100, 60, C2_Color('DarkOliveGreen4'));
		gui_pic.draw(500, 100);
		gui_picCtrl.draw(200, 20);
		
		gui_synth.front; gui_seq.front; gui_palette.front;
		
	}
	
	guiUpdate { |idNo|
	
		if(idNo != currentTrainBeingEdited) {^nil};
		
		gui_synth.update;
		gui_seq.update;
	
	}
	
	changeTrain { |t|
	
		currentTrainBeingEdited = t;
		
		gui_synth.link_(
			trains[currentTrainBeingEdited],
			"Particularity : Synth " ++ (currentTrainBeingEdited + 1).asString,
			colors[currentTrainBeingEdited]
		);
		gui_seq.link_(
			trains[currentTrainBeingEdited],
			"Particularity : Sequences " ++ (currentTrainBeingEdited + 1).asString,
			colors[currentTrainBeingEdited]
		);
		
		this.guiUpdate(t);
		
	
	}
	
	updateTransportStatus { |idNo, type, status|
	
		var playLinkStatus = 0, allStatus = 0, from, to;
		
		
		playLinkStatus = gui_control.playLinkStatus;
		allStatus = gui_control.allStatus;
		
		
		if(allStatus == 1) {from = 0; to = 7} {from = idNo; to = idNo};
		case
			{type == \train}
			{
			for(from, to)
				{
				|c|
				if(playLinkStatus == 1)
					{
					trains[c].seqStartStop(status, 0, \updateTransportStatus);
					};

				trains[c].startStop(status, 0, \updateTransportStatus);

				};
				
			}
			{type == \seq}
			{
			for(from, to)
				{
				|c|
				if(playLinkStatus == 1)
					{
					trains[c].startStop(status, 0, \updateTransportStatus);
					};
					
				trains[c].seqStartStop(status, 0, \updateTransportStatus);
				};
				
			};
	
		{
		this.guiUpdate(currentTrainBeingEdited);
		gui_control.update
		}.defer;
	
	}
	
	// getData and setData - everything for opening and saving files...
	// getPatch and setPatch - ONLY numerical type data - blendable stuff! no strings etc.
	
	// !! here in particular there may appear to be no difference but look closer
	
	getData {
	
		^[
		0, 0, 0,
		trains.collect( { |i| i.getData } ),
		0,
		gui_picCtrl.getData,
		bpm,
		sfPaths
		];
	
	}
	
	setData { |args|
	
		args = args.deepCopy;
		
		args[3].do { |item, index| 
			trains[index].setData(item) 
		};
		if(lastMixerVals != nil) { this.liveMixerUpdate(lastMixerVals, gui_liveMixer.outBus) };
		
		gui_picCtrl.setData(args[5]);
		bpm = args[6];
		
		sfPaths = args[7];
		// then fill buffers and dictionary based on sfPaths
		this.reloadSfBuffers;
		
//		gui_liveMixer.setData(args[8]);
		
		{gui_control.update}.defer;
		{this.guiUpdate}.defer;
	
	}
	
	
	getPatch {
		
		^[
		0, 0, 0,
		trains.collect( { |i| i.getPatch } ),
		0,
		gui_picCtrl.getData,
		bpm
		];
	
	}
	
	setPatch { |args, liveRecallFlag = 0, volAdjust = 1|
		
		args = args.deepCopy;
		
		args[3].do { |item, index| 
			trains[index].setPatch(item, liveRecallFlag: liveRecallFlag, volAdjust: volAdjust) 
		};
		if(lastMixerVals != nil) { this.liveMixerUpdate(lastMixerVals, gui_liveMixer.outBus) };
		
		
		gui_picCtrl.setData(args[5]);
		bpm = args[6];
		
		{gui_control.update}.defer;
		{this.guiUpdate}.defer;

	
	}
	
	reportBounds {
	
		var b = [], t = [], order;
		
		[gui_synth, gui_seq, gui_pic, gui_picCtrl, gui_palette, gui_liveMixer, gui_control].do { |item|
			b = b ++ [item.reportBounds];
			t = t ++ [item.w.processTimeOfLastFront];
		};
		order = t.order;
		^[b, order]
	
	}
	
	setBounds { |boundsArray, order|
	
		order = [3, 2, 5, 6, 0, 1, 4];
	
		Task {
		
			order.do { |item, index|
			
				[gui_synth, gui_seq, gui_pic, gui_picCtrl, gui_palette, gui_liveMixer, gui_control][item].setBounds(boundsArray[item]).front;
				
			};
			
			0.05.wait;
			
		}.play(AppClock);
	
	
	}
	
	bpm_ { |b|
	
		bpm = b;
	
	}
	
	reloadSfBuffers {
	
		sfPathToBufNumDict = Dictionary.new;
		sfBuffers.do { |item| item.free };
		sfBuffers = [];
		sfPaths.do { |item, index|
		
			sfBuffers = sfBuffers.add(Buffer.read(server, item));
			sfPathToBufNumDict.put(item, sfBuffers[sfBuffers.lastIndex].bufnum);
		
		};
	
	}
	
	getBufnumFromFilepath { |filepath|
		
		^sfPathToBufNumDict[filepath.asSymbol]
	
	}
	
	addSoundFile { |filepath|
	
		var bufnum;
		
		if(sfPathToBufNumDict[filepath.asSymbol] == nil)
			{
			sfPaths = sfPaths.add(filepath);
			sfBuffers = sfBuffers.add(Buffer.read(server, sfPaths[sfPaths.lastIndex]));
			bufnum = sfBuffers[sfBuffers.lastIndex].bufnum;
			sfPathToBufNumDict.put(filepath.asSymbol, bufnum);
			}
			{
			bufnum = sfPathToBufNumDict[filepath.asSymbol];
			}
		^bufnum;
	
	}
	
	updateSeqProgress { |index, vals|
	
		if(index == currentTrainBeingEdited)
			{
		
			{gui_seq.updateProgress(vals)}.defer;
			
			};
	
	}
	

}







