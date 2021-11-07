C2PL_GUI_Control {

	var <w, cv, but_wins, but_trains, but_synthPlay, but_seqPlay;
	var but_winArrangementSet, but_winArrangementDefault, but_winArrangementReset;
	var currentWinArrangement = -1;
	var <>winArrRecallAction, <>winArrGetBoundsAction;
	var winArrDefaultBounds, winArrBounds;
	var currentTrain = 0;
	var <link;
	var <but_playLink, <but_all, but_mute;
	var data;
	var <>muteAction;
	var num_bpm, num_hz, num_secs, order;
	var but_rebootServer;
	var <playLinkStatus = 0, <allStatus = 0;

	*new { ^super.new.init }
	
	link_ { |l|
	
		link = l;
	
	}
	
	init {
	
		data = C2_DataDevice3_compact.new;
		data.name_("Preset").guiColor_(C2_Color(\grey12)).fileBaseName_("c2pl_sgl");
		data.getDataAction = 
			{
			link.getData;
			};
		data.setDataAction = 
			{
			|args|
			link.setData(args);
			};

		winArrDefaultBounds = 
			[
			Rect(100, 20, 635, 600), Rect(740, 20, 530, 600),
			Rect(500, 100, 640, 480), Rect(200, 20, 645, 630),
			Rect(100, 645, 1170, 110), Rect(100, 60, 650, 620),
			Rect(5, 16, 90, 740) 
			];
			
		winArrBounds = Array.newClear(4);
		order = Array.newClear(4);
		winArrBounds.do { |item, index|
			winArrBounds[index] = winArrDefaultBounds.deepCopy;
			order[index] = [5, 6, 4, 0, 3, 2, 1];
		};
	
	}
	
	reportBounds { ^w.bounds }
	
	setBounds { |bounds| w.bounds_(bounds) }
	
	front { w.front; }
	
	draw { |winX = 5, winY = 700|
	
		var startX, startY, x, y, labels, defaults;
		var stringBackground, msSize = 163, gap = 10;
		
		startX = 15; startY = 30;
		
		w = Window("  Particularity : Controller", Rect(winX, winY, 90, 740), false).front;
		w.background_(C2_Color('tan1'));
		w.userCanClose_(false);
		cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));

		
		but_wins = 
			[
			Button(cv, Rect(5, 10, 80, 20)),
			Button(cv, Rect(5, 35, 80, 20)),
			Button(cv, Rect(5, 60, 80, 20)),
			Button(cv, Rect(5, 85, 80, 20)),
			Button(cv, Rect(5, 110, 80, 20)),
			Button(cv, Rect(5, 135, 80, 20))
			];
			
		but_wins.do { |item, index|
		
			but_wins[index].states = 
				[
				[ ["Synth", "Seq", "Palette", "Mixer", "Picture", "Pic Ctrl"][index], Color.black, C2_Color(\grey72) ]
				];
		
		};
		
		but_trains = Array.newClear(8);
		but_synthPlay = Array.newClear(8);
		but_seqPlay = Array.newClear(8);
		
		but_trains.do { |item, index|
		
			x = 5; y = 170 + (index * 25);
		
			but_trains[index] = Button(cv, Rect(x, y, 20, 20));
			but_trains[index].states = 
				[
				[ (index + 1).asString, Color.black, C2_Color(\grey52) ],
				[ (index + 1).asString, Color.white, C2_Color(\grey12) ]
				]; 
			
			but_synthPlay[index] = Button(cv, Rect(x + 25, y, 25, 20));
			but_synthPlay[index].states = 
				[
				[ "[]", Color.white, C2_Color(\red2) ],
				[ "|>", Color.black, C2_Color(\green1) ]
				]; 
				
			but_seqPlay[index] = Button(cv, Rect(x + 55, y, 25, 20));
			but_seqPlay[index].states = 
				[
				[ "[]", Color.white, C2_Color(\red2) ],
				[ "|>", Color.black, C2_Color(\green1) ]
				]; 
				
		};
		
		but_playLink = Button(cv, Rect(5, 320 + 50, 80, 20));
		but_playLink.states = 
				[
				[ "Play Link", Color.black, C2_Color(\grey52) ],
				[ "Play Link", Color.black, C2_Color(\LightBlue1) ]
				];
		
		
		but_all = Button(cv, Rect(5, 345 + 50, 80, 20));
		but_all.states = 
				[
				[ "All", Color.black, C2_Color(\grey52) ],
				[ "All", Color.black, C2_Color(\LightBlue1) ]
				];
		
		
		but_mute = Button(cv, Rect(5, 375 + 50, 80, 20));
		but_mute.states = 
				[
				[ "----", Color.black, C2_Color(\grey52) ],
				[ "MUTE", Color.black, C2_Color(\yellow2) ]
				];
		
		num_bpm = C2_ScrollNumberBox(cv, Rect(5, 455, 60, 20), 0.1, 10, 500, 0);
		StaticText(cv, Rect(67, 455, 21, 20)).string_("bpm").font_(Font("Helvetica", 10));
		
		num_hz = C2_ScrollNumberBox(cv, Rect(5, 480, 60, 20), 0.001, 0, 999);
		StaticText(cv, Rect(67, 480, 21, 20)).string_("hz").font_(Font("Helvetica", 10));
		
		num_secs = C2_ScrollNumberBox(cv, Rect(5, 505, 60, 20), 0.001, 0, 999);
		StaticText(cv, Rect(67, 505, 21, 20)).string_("secs").font_(Font("Helvetica", 10));
		
		data.guiDraw(cv, 10, 620);
		
		y = 550;

		but_winArrangementDefault = Button(cv, Rect(5, y, 80, 20));
		but_winArrangementDefault.states = 
			[
			["Reset Windows", Color.black, C2_Color(\grey55)],
			];
		but_winArrangementDefault.font_(Font("Helvetica", 10));
				
		but_rebootServer = Button(cv, Rect(5, y + 25, 80, 20));
		but_rebootServer.states = 
			[
			["Restart Audio", Color.black, C2_Color(\grey55)],
			];
			
		but_rebootServer.font_(Font("Helvetica", 10));


		
		this.update;
		this.makeActions;
	}
	
	update {
	
		var allTrainsStatus;
		
		allTrainsStatus = link.allTrainsStatus;
	
		for(0, 7) 
			{ 
			|c| 
			if(c == currentTrain) 
				{ but_trains[c].value = 1 } { but_trains[c].value = 0 };
			
			but_synthPlay[c].value = allTrainsStatus[0][c];
			but_seqPlay[c].value = allTrainsStatus[1][c];
			};
		
		this.update_bpm;
	
	}
	
	update_bpm { |bpm|
	
		bpm = (bpm ? link.bpm).clip(10, 500);
	
		num_bpm.value = bpm.round(0.01);
		num_hz.value = (bpm / 60).round(0.001);
		num_secs.value = (1 / (bpm / 60)).round(0.001);
	
	}
	
	makeActions {
	
	// updateTransportStatus  |idNo, type, status|
	
		but_trains.do { |item, index|

			but_trains[index].action = { |but| currentTrain = index; link.changeTrain(index); this.update };
			but_synthPlay[index].action = { |but| link.updateTransportStatus(index, \train, but.value); this.update };
			but_seqPlay[index].action = { |but| link.updateTransportStatus(index, \seq, but.value); this.update };
		};
		
		but_wins.do { |item, index|
		
			but_wins[index].action = 
				{
				link.winFront([\synth, \seq, \palette, \mixer, \picture, \picCtrl][index])
				};
		
		};
		
		but_mute.action = { |but| muteAction.value(but.value) };
			
		but_winArrangementDefault.action = 
			{
			if(currentWinArrangement >= 0)
				{
				winArrBounds[currentWinArrangement] = link.reportBounds.deepCopy;
				};
			link.setBounds(winArrDefaultBounds, [5, 6, 4, 0, 3, 2, 1]); 
			currentWinArrangement = -1;
			};
			
		num_bpm.action = { |num| link.bpm_(num.value); this.update_bpm };
		num_hz.action = { |num| this.update_bpm(num.value * 60) };
		num_secs.action = { |num| this.update_bpm(60 / num.value) };
		
		but_rebootServer.action = { link.performCmdPeriodFunc; link.serverInit(initSynthsFlag: 1); };
		
		but_playLink.action = { |but| playLinkStatus = but.value };
		but_all.action = { |but| allStatus = but.value };
	
	}
		

}



