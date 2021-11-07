C2L_GUI_AmpEnvEditor {

	var <>parent, <>bounds, cv, ms, but_options, num_curve;
	var <>action, <>mouseUpAction, <>getWaveToCopyAction;

	*new { |parent, bounds, msSize, name| ^super.new.init(parent, bounds, msSize, name) }
	
	init { |argParent, argBounds, msSize = 64, name|
	
		//var msSize = 158;
	
		// ignore bounds for now, the size is preset
		
		var stringBackground;
		
		// default for now so error isn't created when "copying wave"
		// it will just flatten everything
		getWaveToCopyAction = { Array.series(16, 1.0, 0.0) };
		
		stringBackground = C2_Color(\yellow2);
		parent = argParent; bounds = argBounds;
		name = name ? "Amp Envelope";
		cv = CompositeView(parent, Rect(bounds.left, bounds.top, 158, 158 - 25 + 55));
		
		StaticText(cv, Rect(0, 0, cv.bounds.width, 20)).string_(name)
			.font_(Font("Helvetica", 12)).background_(stringBackground).align_(\center);
			
		ms = MultiSliderView(cv, Rect(0, 20, cv.bounds.width, cv.bounds.height - 55));
	
		ms.value = Array.fill(64, {0.0});
		ms.elasticMode_(1).background_(\grey94).strokeColor_(Color.black)
			.fillColor_(Color.black).drawLines_(true)
			.drawRects_(false).isFilled_(false)
			.valueThumbSize_(1);
		ms.reference = Array.fill(64, {0.0});	
		
		ms.action = { |ms| action.value(ms) };
		ms.mouseUpAction = { |ms| mouseUpAction.value(ms) };
		
		but_options = 
			[
			Button(cv, Rect(0, (158 + 15) - 15, 20, 20)),
			Button(cv, Rect(25, (158 + 15) - 15, 20, 20)),
			Button(cv, Rect(50, (158 + 15) - 15, 20, 20)),
			
			Button(cv, Rect(75, (158 + 15) - 15, 25, 20)),
			Button(cv, Rect(105, (158 + 15) - 15, 25, 20)),
			Button(cv, Rect(135, (158 + 15) - 15, 25, 20)),
			
			Button(cv, Rect(0, (158 + 25), 40, 20)),
			Button(cv, Rect(45, (158 + 25), 40, 20))
			];
		but_options.do { |item, index|
			but_options[index].states = 
				[
					[
					["H", Color.black, C2_Color(\cornsilk2)],
					["W", Color.black, C2_Color(\cornsilk2)],
					["R", Color.black, C2_Color(\cornsilk2)],
					
					["Rev", Color.black, C2_Color('green yellow')],
					["Inv", Color.black, C2_Color('green yellow')],
					
					["Wav", Color.black, C2_Color('MediumPurple1')],
					["Cur D", Color.black, C2_Color(\PowderBlue)],
					["Cur UD", Color.black, C2_Color(\PowderBlue)]
					][index]
				];
			but_options[index].font_(Font("Helvetica", 10));
			
			but_options[index].action = { this.createEnv([\ham, \wel, \rec, \rev, \inv, \wave, \curD, \curUD][index], num_curve.value) };
			
		};
	
		num_curve = C2_ScrollNumberBox(cv, Rect(90, (158 + 25), 40, 20), 0.1, -20.0, 20.0, 1);
		num_curve.font_(Font("Helvetica", 12));
		num_curve.value_(0.0);
	}
	
	value {
	
		^ms.value
	
	}
	
	value_ { |v|
	
		ms.value = v;
	
	}
	
	createEnv { |type, curve|
	
	// \ham, \wel, \rec, \rev, \inv, \curD, \curUD
	
		var sig, array, warp, envNoOfFrames, envArray;
		envNoOfFrames = ms.value.size;
		case
			{type == \ham}
			{sig = Signal.hammingWindow(envNoOfFrames)}
			{type == \wel}
			{sig = Signal.welchWindow(envNoOfFrames)}
			{type == \rec}
			{sig = Signal.rectWindow(envNoOfFrames)}
			{type == \rev}
			{array = ms.value.reverse}
			{type == \inv}
			{array = 1 - ms.value}
			{type == \wave}
			{
			array = this.getWaveToCopyAction.value.asArray.resamp1(envNoOfFrames);
			array = [-1.0, 1.0].asSpec.unmap(array);
			}
			{type == \curD}
			{
			array = Array.newClear(envNoOfFrames);
			warp = CurveWarp.new([1.0, 0.0], curve);
			envNoOfFrames.do { |i|
				var x, v;
				x = i.fold(0, envNoOfFrames.asInt);
				v = [0, envNoOfFrames].asSpec.unmap(x);
				v = warp.map(v);
				array[i] = v;
			}
			}
			{type == \curUD}
			{
			array = Array.newClear(envNoOfFrames);
			warp = CurveWarp.new([0.0, 1.0], curve.neg);
			envNoOfFrames.do { |i|
				var x, v;
				x = i.fold(0, (envNoOfFrames / 2).asInt);
				v = [0, envNoOfFrames / 2].asSpec.unmap(x);
				v = warp.map(v);
				array[i] = v;
			};
			
			};
		case
			{sig != nil}
			{
			envArray = sig.asArray;
			}
			{
			envArray = array.deepCopy;
			};
		envArray[envArray.lastIndex] = 0;
		ms.value = envArray;
		mouseUpAction.value(ms);
		
	}



}