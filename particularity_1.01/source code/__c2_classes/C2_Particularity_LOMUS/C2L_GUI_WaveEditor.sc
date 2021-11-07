C2L_GUI_WaveEditor {

	var <>parent, <>bounds, cv, ms, but_options, num_curve;
	var <>action, <>mouseUpAction, <>getWaveToCopyAction, st;
	var <used = 1, pop_presets, but_presetsDoIt;

	*new { |parent, bounds, msSize| ^super.new.init(parent, bounds, msSize) }
	
	init { |argParent, argBounds, msSize = 2048, name|
	
		var stringBackground;
		
		stringBackground = C2_Color(\yellow2);
		parent = argParent; bounds = argBounds;
		name = name ? "Waveform";
		cv = CompositeView(parent, Rect(bounds.left, bounds.top, 158 - 20, 158 + 50));
		
		st = StaticText(cv, Rect(0, 0, cv.bounds.width - 3, 20)).string_("Waveform")
			.font_(Font("Helvetica", 12)).background_(stringBackground).align_(\center);
			
		ms = MultiSliderView(cv, Rect(0, 20, 158 - 25, 158 - 25));
	
		ms.value = Array.fill(2048, {0.0});
		ms.elasticMode_(1).background_(\grey85).strokeColor_(Color.black)
			.fillColor_(Color.black).drawLines_(true)
			.drawRects_(false).isFilled_(false)
			.valueThumbSize_(1);
		ms.reference = Array.fill(2048, {0.5});	
		
		ms.action = { |ms| action.value(ms) };
		ms.mouseUpAction = { |ms| mouseUpAction.value(ms) };
		
		but_options = 
			[
			Button(cv, Rect(0, 158, 40, 20)),
			Button(cv, Rect(45, 158, 40, 20)),
			Button(cv, Rect(90, 158, 40, 20))
			];
		but_options.do { |item, index|
		
			but_options[index].font_(Font("Helvetica", 12));
			but_options[index].states = 
				[
					[
					["norm", Color.black, C2_Color('sky blue')],
					["smooth", Color.black, C2_Color('sky blue')],
					["open", Color.white, C2_Color(\red1)]
					][index]
				];
			but_options[index].font_(Font("Helvetica", 10));
			but_options[index].action = { this.change([\norm, \smooth, \open][index]) };
				
		};
		
		pop_presets = PopUpMenu(cv, Rect(0, (158 + 25), 158 - 25 - 40, 20));
		pop_presets.font_(Font("Helvetica", 10)).background_(\cornsilk2);
		pop_presets.items = ["Saw", "Tri", "Square", "Noise"];
		
		but_presetsDoIt = Button(cv, Rect(158 - 25 - 40 + 5, (158 + 25), 20, 20));
		but_presetsDoIt.states = [["do", Color.black, C2_Color(\cornsilk2)]];
		but_presetsDoIt.font_(Font("Helvetica", 10));
		but_presetsDoIt.action = { this.create(pop_presets.items[pop_presets.value].asSymbol) };
		
	}
	
	used_ { |u|
	
		used = u;
	
		ms.background_( [C2_Color(\grey44), C2_Color(\grey88)][used] );
		st.background_( [C2_Color(\grey44), C2_Color(\yellow2)][used] );
	
	
	}
	
	value {
	
		^ms.value
	
	}
	
	value_ { |v|
	
		ms.value = v;
	
	}
	
	create { |type|
	
		// \Saw, \Tri, \Square, \Noise
		
		var array;
		
		array = C2L_GUI_WaveEditor.create(type, ms.size);
			
		if(array != nil) {ms.value_(array); mouseUpAction.value(ms); };
	
	}
	
	change { |type|
	
		var array, sf, smoothBy = 32, smoothScope = 256;
		var average, smoothingBlend = 0.01;
	
		case
			{type == \norm}
			{
			array = ms.value.deepCopy;
			array = array.normalize;
			if(array != nil) {ms.value_(array); mouseUpAction.value(ms); };
			}
			{type == \smooth}
			{
			array = ms.value.deepCopy;
			
			forBy(0, array.size - 1, smoothBy)
				{
				|c|
				var start, end;
				start = c; end = (c + smoothScope).clip(0, array.size - 1);
				average = array.copyRange(start, end).sum / (end - start);
				
				for(start, end)
					{
					|c2|
					array[c2] = array[c2].blend(average, smoothingBlend);
					};
				
//				array.overWrite(Array.interpolation(smoothBy, start, end), c);
				};

//			average = array.sum / array.size;
//			for(0, array.size - 1)
//				{
//				|c|
//				array[c] = array[c].blend(average, smoothingBlend);
//				};
			
			if(array != nil) {ms.value_(array); mouseUpAction.value(ms); };
			}
			{type == \open}
			{
			
			CocoaDialog.getPaths(
				{
				arg paths;
				var temp;
				sf = SoundFile.new;
				if(sf.openRead(paths[0]) == true)
					{
					// can read mono files only
					if(sf.numChannels == 1)
						{
						temp = FloatArray.newClear(sf.numFrames);
						sf.readData(temp);
						array = temp.asArray.resamp1(ms.size).deepCopy;
						array = [-1.0, 1.0].asSpec.unmap(array);
						if(array != nil) {ms.value_(array); mouseUpAction.value(ms); };
						}
						{
						(" C2 Wave Editor - open soundfile aborted because sound must be mono.").postln;
						}
					};
				},
				{
				(" C2 Wave Editor - open soundfile cancelled.").postln;
				},
				1
			)			
			
			};

		

		
	}
	
	*create { |type, size = 2048|
	
		// \Saw, \Tri, \Square, \Noise
		
		var array;
		
		case
			{type == \Saw}
			{
			array = Array.interpolation(size, 1.0, 0.0);
			}
			{type == \Tri}
			{
			array = Array.interpolation(size / 4, 0.5, 1.0) 
				++ Array.interpolation(size / 4, 1.0, 0.5) 
				++ Array.interpolation(size / 4, 0.5, 0.0) 
				++ Array.interpolation(size / 4, 0.0, 0.5);
			
			}
			{type == \Square}
			{
			array = [1.0, 0.0].resamp0(size);
			}
			{type == \Noise}
			{
			array = Array.rand(size, 0.0, 1.0);
			};
			
		^array
	
	}
	
	
	
}







