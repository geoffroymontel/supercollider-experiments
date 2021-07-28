C2PL_GUI_Seq {

	var <link;
	var <w, cv, ms_seq, num_freqRange, but_seqStartStop;
	var num_beats;
	var data;
	var but_msExternEdit, msExternEditIndex = nil, msExternEdit;
	var labels;
	var pop_params;
	var but_msDefault, but_allDefault;
	var noOfSteps = 64;
	var but_defaultOnStop, but_resetOnSetPatch, but_loopStatus;
	var sl_progress;
	
	link_ { |argLink, name, color|
	
		link = argLink;
		if(w == nil) {^nil};
		
		if(name != nil) { {w.name_(name)}.defer };
		if(color != nil) { {cv.background_(color); w.front}.defer };
		
	}

	*new { ^super.new.init }
	
	init {
	
		data = C2_DataDevice3.new;
		data.name_("seq").guiColor_(C2_Color('MediumOrchid2')).fileBaseName_("c2pl_seq").guiLength_(155);
		data.getDataAction =
			{
			link.getData;
			};
		data.setDataAction = 
			{
			|args|
			link.setData(args, setSynthDataFlag: 0, setSeqDataFlag: 1);
			};
	
	}
	
	front { w.front }
	
	reportBounds { ^w.bounds }
	
	setBounds { |bounds| w.bounds_(bounds) }
	
	draw { |winX = 560, winY = 720, color|
	
		var startX, startY, x, y, defaults;
	
		w = Window("Particularity : Sequences 1", Rect(winX, winY, 530, 600)).front;
		w.userCanClose_(false);
		color = color ? Color.rand;
		
		cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));
		cv.background_(color);
		w.setResizeView(cv);
		w.enableResize(1);

		labels = 
			[
			["Start Pos", "Trig Freq", "Grain Freq",
			"Modulation Ratio", "Modulation Amt", "Amp", "Probability", "Pan"],
			["Start Pos", "Trig Freq", "Grain Freq",
			"Modulation Ratio", "Modulation Amt", "Amp", "Probability", "Pan"]
			];
		
		x = 15; y = 5;
		but_seqStartStop = Button(cv, Rect(x, y, 50, 20));
		but_seqStartStop.states = 
			[
			[ "[]", Color.white, C2_Color(\red2) ],
			[ "|>", Color.black, C2_Color(\green1) ]
			];

		StaticText(cv, Rect(x + 130, y, 40, 20)).string_("micro")
				.font_(Font("Helvetica Bold", 12)).align_(\left).stringColor_(Color.white);
				
		StaticText(cv, Rect(x + 335 + 50, y, 40, 20)).string_("macro")
				.font_(Font("Helvetica Bold", 12)).align_(\left).stringColor_(Color.white);
		
		y = 5;
		num_beats = 
			[
			C2_ScrollNumberBox(cv, Rect(x + 150 + 20, y, 70, 17), 0.01, 1, 999, 1),
			C2_ScrollNumberBox(cv, Rect(x + 260 + 150 + 20, y, 70, 17), 0.01, 4, 999, 1)
			];
		startX = 10; startY = 75;
		
		sl_progress = 
			[
			Slider(cv, Rect(10, 35, 250, 15)),
			Slider(cv, Rect(270, 35, 250, 15))
			];
		sl_progress.do { |item|
			item.background_(C2_Color(\black)).knobColor_(C2_Color(\white)).thumbSize_(10);
		};
		
		ms_seq = Array.newClear(6);
		but_msExternEdit = Array.newClear(6);
		pop_params = Array.newClear(6);
		but_msDefault = Array.newClear(6);
		ms_seq.do { |item, index|
			
//			x = startX + (index.wrap(0, 1) * 260);
//			y = startY + (index.div(2) * 175);
			
			x = startX + (index.div(3) * 260);
			y = startY + (index.wrap(0, 2) * 170);
			
			ms_seq[index] = MultiSliderView(cv, Rect(x, y, 250, 135));
			ms_seq[index].value = Array.fill(noOfSteps, {0.0});
			ms_seq[index].elasticMode_(1);
			ms_seq[index].valueThumbSize_(1);
			
			ms_seq[index].background_(\grey8).strokeColor_(C2_Color(\white)).drawLines_(true).drawRects_(false);
			ms_seq[index].reference = Array.fill(ms_seq[index].size, {0.5});
			but_msExternEdit[index] = Button(cv, Rect(x, y - 20, 20, 20));
			but_msExternEdit[index].states = 
				[
				["", Color.black, C2_Color(\yellow2)],
				["E", Color.white, Color.blue(0.5)]
				];
			
			but_msDefault[index] = Button(cv, Rect(x + 230, y - 20, 20, 20));
			but_msDefault[index].states = 
				[
				["D", Color.white, C2_Color(\brown3)]
				];

				
			pop_params[index] = PopUpMenu(cv, Rect(x + 25, y - 20, 190, 20));
			pop_params[index].font_(Font("Helvetica", 12)).background_(\yellow2);
			pop_params[index].items = labels[index.div(3)].deepCopy;		
			
		};

			StaticText(cv, Rect(startX + 200, 560, 180, 20)).string_("Freq Range - / + semitones: ")
				.font_(Font("Helvetica Bold", 12)).align_(\right);		
		num_freqRange = C2_ScrollNumberBox(cv, Rect(startX + 385, 560, 50, 20), 1, 1, 96, 1);
		num_freqRange.font_(Font("Helvetica Bold", 12)).background_(Color.black).normalColor_(Color.white);
		
		but_allDefault = Button(cv, Rect(startX + 460, 560, 50, 20));
		but_allDefault.states = [["D_all", Color.white, C2_Color(\brown3)]];

		
		data.guiDraw(cv, startX, 560);
		
		this.makeActions;
		this.update;
		
	}
	
	makeActions {
	
		but_seqStartStop.action = { |but| link.seqStartStop(but.value) };
	
		ms_seq.do { |item, index|
			ms_seq[index].action =
				{
				|ms|
				link.setSeqData(index.div(3), index.wrap(0, 2), ms.value);
				if(msExternEditIndex != nil) {msExternEdit.value = ms.value};
				};
			but_msExternEdit[index].action = { this.refreshExternEdit(index) };
			
			but_msDefault[index].action = 
				{
				data.copy;
				ms_seq[index].value = Array.fill(noOfSteps, {0.5});
				link.setSeqData(index.div(3), index.wrap(0, 2), ms_seq[index].value);
				if(msExternEditIndex != nil) {msExternEdit.value = ms_seq[msExternEditIndex].value};
				};
			
		};
		
		but_allDefault.action = 
			{
			data.copy;
			link.seqParamNos = [1, 5, 6, 1, 5, 6];
			ms_seq.do { |item, index|
				ms_seq[index].value = Array.fill(noOfSteps, {0.5});
				link.setSeqData(index.div(3), index.wrap(0, 2), ms_seq[index].value);
			};
			if(msExternEditIndex != nil) {msExternEdit.value = ms_seq[msExternEditIndex].value};
			this.update;
			};

		num_freqRange.action = { |num| link.freqRange = num.value };

		num_beats.do { |item, index|
		
			num_beats[index].action = { |num| link.setSeqDurBeats(index, num.value) };
		
		};
		
		pop_params.do { |item, index|
		
			pop_params[index].action = 
				{
				|pop|
				link.seqParamNos[index] = pop.value;
				};
		
		};
		
	
	}
	
	update {
	
		if(link == nil) {^nil};
		
		but_seqStartStop.value = link.seqRunningStatus;
	
		ms_seq.do { |item, index|
			item.value = link.getSeqData(index.div(3), index.wrap(0, 2));
		};
		num_freqRange.value = link.freqRange;
		
		num_beats.do { |item, index|
			item.value = link.getSeqDurBeats(index);
		};
		
		pop_params.do { |item, index|
		
			item.value = link.seqParamNos[index];
		};
		
		this.refreshExternEdit;
		
	}
	
	refreshExternEdit { |index|
	
		var createFlag = 0;
	
		if(index == msExternEditIndex) {msExternEditIndex = nil} {msExternEditIndex = index};
		if(msExternEditIndex == nil)
			{
			// close if it's already there
			if(msExternEdit != nil) {msExternEdit.close; msExternEdit = nil};
			this.refreshExternEditButtons;
			};
		// escape now if there's nothing else to do
		if(msExternEditIndex == nil) { ^nil};
			
		// create it if needed
		if(msExternEdit == nil)
			{createFlag = 1}
			{
			if(msExternEdit.openStatus == 0) {createFlag = 1};
			};
		if(createFlag == 1)
			{
			msExternEditIndex = index;
			msExternEdit = C2P_GUI_MSC_4C2PL(300, 200, 64, "");
			msExternEdit.action =
				{
				|array|
				ms_seq[msExternEditIndex].value = array.deepCopy;
				link.setSeqData(msExternEditIndex.div(3), msExternEditIndex.wrap(0, 2), array.deepCopy);
				};
			msExternEdit.closeAction = {msExternEditIndex = nil; this.refreshExternEditButtons};
			};
			
		msExternEdit.value = ms_seq[msExternEditIndex].value.deepCopy;
		msExternEdit.name_(
			"Pulsar Seq Edit : " ++
			labels[0][link.getSeqParamNos(index.div(3), index.wrap(0, 2)).asInt] ++
			[" micro", " macro"][index.div(3)]
			);
		msExternEdit.front;
		this.refreshExternEditButtons;
	
	}
	
	refreshExternEditButtons {
	
		but_msExternEdit.do { |item, index|
		
			if(index == msExternEditIndex) {item.value = 1} {item.value = 0};
		
		}
	
	}
	
	updateProgress { |vals|
	
		sl_progress.do { |item, index| item.value = vals[index] };
		
	}





}


