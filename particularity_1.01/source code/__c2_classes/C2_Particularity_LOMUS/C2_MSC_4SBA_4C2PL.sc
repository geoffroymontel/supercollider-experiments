C2_MSC_4SBA_4C2PL {

	var <>updateAction;
	
	// use this:
	var <>action;
	
	var <limit = 512, num_limit, repeatMode;
	var array, cArray;
	var w, w2, ms, slider_all, rs_modify;		// rangeslider for modifying array
	var modify;		// remember what's been selected for when the gui gets redrawn
	var dur_secs, dur_beats, bpm = 120;
	var zoom = 64, num_zoom;		// display 16, 32, 64, 128 or 256
	
	var <>msLength = 800, <>msHeight = 110;
	
	var start = 0, num_start;
	var <>lo = 0, <>hi = 1, num_lo, num_hi;
	// but_warp, <>warp = 0
	var <>name = "", st_name;
	var slider_all, but_safety, safety;
	var div, num_div;
	var group, num_group;
	var stepsPerQuarterNote, stepsPerSecond;
	var num_stepsPerQuarterNote, num_stepsPerSecond;
	
	var <>rangeChangable = true, <>warpChangable = true;
	// rangeChangable refers to lo and hi being changable
	
	var <>outRangeBoundryLo = 0, <>outRangeBoundryHi = 1, <>outRangeStep = 0.01;
	// what's the lowest and the highest that i will be allowed to change the lo and hi to?
	
	var <>backgroundColor;
	
	var comb, num_comb, combOffset, num_combOffset, combWidth, num_combWidth;
	var but_shiftLeft, but_shiftRight;
	var <>idNo;
	var loopMode, but_loopMode;
	var but_rsFull;
	// , interpolation, but_interpolation
	var but_copy, but_paste, <>copyBuffer;
//	var rateScale, num_rateScale;
	
//	limit_ { |l|
//	
//		limit = l;
//		if(limit > (array.size - 1))
//			{
//			array = array ++ Array.series(limit - (array.size - 1), 0, 0);
//			};
//			
//		if(limit < (array.size - 1))
//			{
//			array = array.copyRange(0, limit);
//			};
//	
//	}
	
	*new { |limit = 512| ^super.new.init(limit) }


	init { |argLimit|
	
		var fillValue = 0;
		
		limit = argLimit;
	
		array = Array.series(limit, fillValue, 0);
		// this is the holder of all the data
		cArray = array.copyRange(0, limit - 1);
		// current array, copying range of array between 0 and limit
//		repeatMode = 0;		// 0 = play til end, 1 = loop, 2 = bounce loop
		div = 128; group = 1;
				
//		stepsPerQuarterNote = 8; 
//		stepsPerSecond = this.stepsPerQuarterNote_to_stepsPerSecond(stepsPerQuarterNote);
		
		comb = 1; combOffset = 0; combWidth = 1;
		
		modify = [0, 0];		
		safety = 0;		// 0 = can't modify, 1 = can
		
		loopMode = 1;		// 1 = looping on
				
		copyBuffer = [0];
		
	//	rateScale = 1;
	
	}
	
	copy {
	
		var lo, hi;

		if( (rs_modify.range > 0) and: (but_safety.value == 1),
			{
			lo = [start, start + zoom - 1].asSpec.map(rs_modify.lo).ceil(1).asInt;
			hi = [start, start + zoom - 1].asSpec.map(rs_modify.hi).floor(1).asInt;
			
			copyBuffer = array.copyRange(lo, hi);
			}
		);
		
	//	updateObject.setCopyBuffer(copyBuffer);
			
	}
	
	paste {
	
//		arg pasteArg;
		var lo, hi;
		
	//	updateObject.getCopyBuffer;
		
//		if(pasteArg.class != Array,
//			{
//		//	pasteArg = updateObject.getCopyBuffer ? copyBuffer.deepCopy;
//			}
//		);
	
		if( (rs_modify.range > 0) and: (but_safety.value == 1),
			{
			lo = [start, start + zoom - 1].asSpec.map(rs_modify.lo).ceil(1).asInt;
			hi = [start, start + zoom - 1].asSpec.map(rs_modify.hi).floor(1).asInt;
			
			for(lo, hi,
				{
				arg c;
				array.put(c, copyBuffer.wrapAt(c - lo));
				}
			);
			
			}
		);
		
		cArray = array.copyRange(0, limit - 1);	
		this.guiUpdate;
		
		action.value(array);
	//	updateAction.value(idNo);
	
	}
	
	setDiv {
	
		arg d;
		div = d;
		
	}

	
	getEnv {
	
		var env;
	
	}
	
	getData {
	
		^[
		name, lo, hi, nil, 
		limit, array, repeatMode, div,
		backgroundColor,
		outRangeBoundryLo, outRangeBoundryHi, outRangeStep,
		loopMode,
		nil,
		nil
		];
		
	
	}
	
	setData {
	
		arg args; args = args.deepCopy;

		name = args.at(0); lo = args.at(1); hi = args.at(2);
		// warp = args.at(3); 
		limit = args.at(4); array = args.at(5); repeatMode = args.at(6); div = args.at(7);
		backgroundColor = args.at(8);
		outRangeBoundryLo = args.at(9); 
		outRangeBoundryHi = args.at(10); 
		outRangeStep = args.at(11);
		loopMode = args.at(12);
//		interpolation = args.at(13);
//		rateScale = args.at(14) ? 1;
				
		cArray = array.copyRange(0, limit - 1);
	
	}
	
	getArray {
	
		^array;
	
	}
	
	setArray {
	
		arg arrayArg;
		
		if(arrayArg.class != Array) {^nil};
		
		limit = arrayArg.size - 1;
		start = start.clip(0, arrayArg.size - 1);
		array = arrayArg.deepCopy;
		cArray = array.copyRange(0, limit - 1);
		{this.guiUpdate}.defer;
		
		
		
//		if( (arrayArg.class == Array) and: (arrayArg.size == array.size),
//			{
//			array = arrayArg.deepCopy;
//			cArray = array.copyRange(0, limit - 1);
//			}
//		);
	
	}
	
	setBpm {
	
		arg bpmArg;
		bpm = bpmArg;
	
	}
	
	guiDraw {
	
		arg window, startX, startY;
		var xTemp, yTemp;
		
		yTemp = 5;
		
		w2 = C2_CompositeView(window, Rect(startX, startY, 15, msHeight + 40));
		w2.background_(C2_Color(\yellow2));
		
		C2_VerticalStaticText(w2, Rect(0, 0, 15, msHeight + 40), font: Font("Helvetica Bold", 10), string: "edit");
	
	//	C2_StaticText(w2, Rect(0, 0, 15, 140)).string_("cock");
				
		w = C2_CompositeView(window, Rect(startX + 15, startY, msLength + 250, msHeight + 40));
		w.background_(backgroundColor);
		
//		but_loopMode = C2_Button(w, Rect(5, yTemp - 5, 45, 21));
//		but_loopMode.states =
//			[
//			["1nce", Color.white, C2_Color(\grey27)],
//			["Loop", Color.white, C2_Color(\blue4)]
//			];
		
		ms = C2_MultiSliderView(w, Rect(60, yTemp + 22, msLength, msHeight));
		ms.background_(C2_Color(\grey65));
			ms.gap_(0);
			ms.valueThumbSize_(5);
			ms.thumbSize_(5);
		//	ms.isFilled_(true);
			ms.fillColor_(C2_Color(\grey22));			
		rs_modify = C2_RangeSlider(w, Rect(57, yTemp, msLength + 6, 16));
		
		
		but_safety = C2_Button(w, Rect(msLength + 70, yTemp, 20, 15));
		but_safety.states =
			[
			[" ", Color.white, C2_Color(\red1)],
			[" ", Color.black, C2_Color(\green1)]
			];
			
		slider_all = C2_Slider(w, Rect(msLength + 70, yTemp + 22, 20, msHeight));
		
		but_copy = C2_Button(w, Rect(msLength + 100, yTemp + 22, 30, 20));
		but_copy.states = [["C", Color.white, C2_Color(\purple3)]];
		
		but_paste = C2_Button(w, Rect(msLength + 135, yTemp + 22, 30, 20));
		but_paste.states = [["P", Color.white, C2_Color(\purple4)]];				
		num_lo = C2_ScrollNumberBox(w, Rect(5, yTemp + 23 + msHeight - 1 - 18, 50, 18), outRangeStep, outRangeBoundryLo, outRangeBoundryHi);
		num_hi = C2_ScrollNumberBox(w, Rect(5, yTemp + 23, 50, 18), outRangeStep, outRangeBoundryLo, outRangeBoundryHi);
		
//		but_warp = C2_Button(w, Rect(5, yTemp + 50, 50, 18));
//		but_warp.states =
//			[
//			["lin", Color.black, C2_Color(\grey77)],
//			["exp", Color.white, C2_Color(\grey22)]
//			];
				
//		but_interpolation = C2_Button(w, Rect(5, yTemp + 75, 50, 18));
//		but_interpolation.font_(Font("Helvetica", 10));
//		but_interpolation.states =
//			[
//			["none", Color.black, C2_Color(\orange1)],
//			["linear", Color.white, C2_Color(\orange3)],
//			["cubic", Color.white, C2_Color(\OrangeRed3)],
//			];
		
		
		
		
		
	//	C2_StaticText(w, Rect(595, yTemp - 5, 40, 18)).string_("group").align_(\center);
	
	
		num_group = C2_ScrollNumberBox(w, Rect(msLength + 125, yTemp, 40, 16), 1, 1, 32);

		but_rsFull = C2_Button(w, Rect(msLength + 95, yTemp, 25, 15));
		but_rsFull.states =
			[
			["f", Color.white, C2_Color(\brown4)]
			];
					
		but_shiftLeft = C2_Button(w, Rect(msLength + 170, yTemp, 15, 18));
		but_shiftLeft.states = [["<", Color.white, Color.black]];
		
		but_shiftRight = C2_Button(w, Rect(msLength + 190, yTemp, 15, 18));
		but_shiftRight.states = [[">", Color.white, Color.black]];

		C2_StaticText(w, Rect(msLength + 95, yTemp + 40, 40, 18)).string_("div").align_(\center);		num_div = C2_ScrollNumberBox(w, Rect(msLength + 95, yTemp + 60, 40, 18), 1, 2, 256);
		
//		C2_StaticText(w, Rect(msLength + 140, yTemp + 40, 60, 18)).string_("rateScale").align_(\center);		num_rateScale = C2_ScrollNumberBox(w, Rect(msLength + 150, yTemp + 60, 40, 18), 0.01, 0.01, 256);		
		
		
				
		C2_StaticText(w, Rect(msLength + 95, yTemp + 85, 40, 18)).string_("comb").align_(\center);		num_comb = C2_ScrollNumberBox(w, Rect(msLength + 95, yTemp + 105, 40, 18), 1, 1, 128);
		
		C2_StaticText(w, Rect(msLength + 140, yTemp + 85, 40, 18)).string_("+offset").align_(\center);		num_combOffset = C2_ScrollNumberBox(w, Rect(msLength + 140, yTemp + 105, 40, 18), 1, 0, 128);

		C2_StaticText(w, Rect(msLength + 185, yTemp + 85, 40, 18)).string_("width").align_(\center);		num_combWidth = C2_ScrollNumberBox(w, Rect(msLength + 185, yTemp + 105, 40, 18), 1, 1, 256);
				
		
		
								
		this.guiUpdate;
		this.guiMakeActions;

	}
	
	setReference { |r = 0.5|
	
		ms.reference_(Array.fill(ms.size, {r}));
		ms.drawLines_(true).drawRects_(false).valueThumbSize_(1);
	}
	
	guiReconfigureMS {


		if(w != nil, 
			{
		//	"ms value".postln;
		
	//	["guiReconfigureMS", lo, hi].postln;
			ms.value_(
				[lo, hi].asSpec.unmap(
					cArray.copyRange(start, (start + zoom).clip(0, cArray.sizeC))
				)
			);
			ms.thumbSize_( (msLength / zoom) - 0);
			
			if(zoom > 127, 
				{
				ms.fillColor_(C2_Color(\black));
				},
				{
				ms.fillColor_(C2_Color(\grey22));
				}
			);
//			ms.gap_(0);
//			ms.valueThumbSize_(0);
//			ms.isFilled_(true);
//			ms.fillColor_(C2_Color(\grey22));	
			
			rs_modify.step_((1 / zoom) * group);
			}
		);	
	
	
	}
	
	guiUpdate {
	
		slider_all.knobColor_( [C2_Color(\red1), C2_Color(\green1)].at(safety) ).background_(C2_Color(\grey42));
		rs_modify.knobColor_( [C2_Color(\red1), C2_Color(\green1)].at(safety) ).background_(C2_Color(\grey42));
		
//		but_interpolation.value = [nil, 0, 1, nil, 2].at(interpolation);
				
//		but_loopMode.value = loopMode;
//		but_warp.value = warp;
		num_lo.value = lo; num_hi.value = hi;
		num_div.value = div; num_group.value = group;
		num_comb.value = comb; num_combOffset.value = combOffset; num_combWidth.value = combWidth;
		but_safety.value = safety;
		
		rs_modify.lo = modify.at(0); rs_modify.hi = modify.at(1);
		
	//	num_rateScale.value = rateScale;
	
		this.guiReconfigureMS;
	
	}
	
//	setStepsPerSecond {
//	
//		arg num; 
//		stepsPerSecond = num.value;
//		stepsPerQuarterNote = this.stepsPerSecond_to_stepsPerQuarterNote(stepsPerSecond);
//	//	num_stepsPerQuarterNote.value = stepsPerQuarterNote;	
//	}
//
//	setStepsPerQuarterNote {
//	
//		arg num; 
//		stepsPerQuarterNote = num.value;
//		stepsPerSecond = this.stepsPerQuarterNote_to_stepsPerSecond(stepsPerQuarterNote);
//	//	num_stepsPerSecond.value = stepsPerSecond;	
//	
//	}
	
	setStart {
	
		arg num;
		start = num.value.asInt.clip(0, limit - 1);
		{this.guiReconfigureMS}.defer;
	
	}
	
	setLimit {
	
		// horizontal limit
	
		arg num;
		limit = num.value.asInt;
		cArray = array.copyRange(0, limit - 1);
		this.guiReconfigureMS;	
		
	}
	
	setZoom {
	
		arg num;
		zoom = num.value.asInt;
		this.guiReconfigureMS;

	}
	
	setZoomByFraction { |z|
	
		z = z.clip(0, 1);
		zoom = [8, limit - 1, \exponential].asSpec.map(z).asInt;
		{this.guiReconfigureMS}.defer;
	
	}
	
	setLoHi { |lo, hi|
	
	
	
	
	}
		
	guiMakeActions {
	
	//	num_rateScale.action = { arg num; rateScale = num.value };
	
		but_copy.action = { arg but; this.copy };
		but_paste.action = {arg but; this.paste };

//		but_interpolation.action = 
//			{
//			arg but;
//			interpolation = [1, 2, 4].at(but.value);
//			};
			
		but_rsFull.action = 
			{
			arg but;
			rs_modify.lo_(0); rs_modify.hi_(1);
			};
				
//		but_loopMode.action = { arg but; loopMode = but.value; this.updateAction };
	
		num_comb.action = { arg num; comb = num.value };
		num_combOffset.action = { arg num; combOffset = num.value };
		num_combWidth.action = { arg num; combWidth = num.value };
	
		but_safety.action = 
			{
			arg but;
			safety = but.value;
			slider_all.knobColor_( [C2_Color(\red1), C2_Color(\green1)].at(but_safety.value) ).background_(C2_Color(\grey42));
			rs_modify.knobColor_( [C2_Color(\red1), C2_Color(\green1)].at(but_safety.value) ).background_(C2_Color(\grey42));
			};

//		but_warp.action = 
//			{
//			arg but;
//			if(warpChangable == true,
//				{
//				warp = but.value;
//				},
//				{
//				but.value = warp;
//				}
//			);
//		//	this.updateAction;
//			};	
							
		num_lo.action = 	
			{
			arg num;
			if(rangeChangable == true, {lo = num.value}, {num.value = lo});
			updateAction.value(idNo);
			this.guiReconfigureMS;
			};

		num_hi.action = 	
			{
			arg num;
			if(rangeChangable == true, {hi = num.value}, {num.value = hi});
			updateAction.value(idNo);
			this.guiReconfigureMS;
			};
				
		ms.action = 
			{
			arg mslider;
			array.put(
				start + mslider.index,
				[lo, hi].asSpec.map(mslider.currentvalue.round(1 / div))
			);
			cArray = array.copyRange(0, limit - 1);
			};
			
		ms.mouseUpAction =
			{
			this.guiReconfigureMS;
			updateAction.value(idNo);
			action.value(array);
			};
			
		num_div.action = 
			{
			arg num;
			num.value = num.value.asInt;
			if(1 == 1,
				{
				div = num.value;
				slider_all.value = slider_all.value.round(1 / div);
				this.guiReconfigureMS;
				},
				{
				num.value = div;
				}
			);
			
			};
			
		num_group.action = 
			{
			arg num;
			group = num.value.asInt;
			};
			
		rs_modify.action  =
			{
			arg rslider;
			rslider.step_((1 / zoom) * group);
			modify = [rslider.lo, rslider.hi];
			};
			
		slider_all.action = 
			{
			arg slider;
			var posLo, posHi;
			slider.value = slider.value.round(1 / div);
			if( (rs_modify.range > 0) and: (but_safety.value == 1),
				{
				posLo = [start, start + zoom - 1].asSpec.map(rs_modify.lo).ceil(1);
				posHi = [start, start + zoom - 1].asSpec.map(rs_modify.hi).floor(1);
			//	[lo, hi].postln;
				forBy(posLo + combOffset, posHi, comb,
					{
					arg c;
					
					combWidth.do({
						arg item, index;
						if( (c + index) < array.sizeC,
							{
							array.put(
								(c + index), 
								[lo, hi].asSpec.map(slider.value)
							);
							}
						);
						
					});
					
					}
				);
				cArray = array.copyRange(0, limit - 1);
				this.guiReconfigureMS;
				}
			);
		//	updateAction.value(idNo);
			
			};
			
		slider_all.mouseUpAction =
			{
			updateAction.value(idNo);
			action.value(array);
			};
			
		but_shiftLeft.action = 
			{
			arg but;
		//	array = array.rotate(group.neg);
			cArray = array.copyRange(0, limit - 1);
			cArray = cArray.rotate(group.neg);
			array = cArray ++ array.copyRange(limit, array.size - 1);
			
			this.guiReconfigureMS;
			updateAction.value(idNo);
			action.value(array);
			};
			
		but_shiftRight.action = 
			{
			arg but;
		//	array = array.rotate(group);
			cArray = array.copyRange(0, limit - 1);
			cArray = cArray.rotate(group);
			array = cArray ++ array.copyRange(limit, array.size - 1);
			
			this.guiReconfigureMS;
			updateAction.value(idNo);
			action.value(array);
			};	
		
	}
	
	guiRemove {
	
		if(w != nil, { w.remove; w = nil; w2.remove; w2 = nil });
	
	}





}




