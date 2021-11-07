// nonprivate@cylob.com



C2_StaticText {


	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.staticText.new(parent, Rect(left, top, bounds.width, bounds.height));
		^GUI.staticText.new(parent, bounds);	
	}
	
	
}

C2_VerticalStaticText {

	*new {
	
		arg parent, bounds, font, fontHeight = 12, string = "";
		
		var left, top, st, yTemp;
		
		if(font == nil, {font = Font("Helvetica", 12)});
		
//		left = parent.bounds.left + bounds.left;
//		top = parent.bounds.top + bounds.top;

		left = bounds.left;
		top = bounds.top;
		
//		st = C2_CompositeView(parent, Rect(left, top, bounds.width, bounds.height));
		
		string.size.do(
			{
			arg item, index;
			yTemp = (fontHeight + (fontHeight / 3) - 1) * index;
			C2_StaticText(parent, Rect(0, yTemp, fontHeight, bounds.width)).font_(font).string_(string.at(index)).align_(\center);
			}
		);
		
	
	}
	

}

C2_MultiSliderView {


	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.multiSliderView.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.multiSliderView.new(parent, bounds);	
	}
	
	
}



C2_NumberBox {


	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^SCNumberBox(parent, Rect(left, top, bounds.width, bounds.height));
	
	//	^GUI.numberBox.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.numberBox.new(parent, bounds);
	
	}
	
	
}

C2_TabletView {

	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
			
	//	^SCTabletView.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^SCTabletView.new(parent, bounds);
	
	}

}

C2_ScrollNumberBox {

	var snbox;

	*new {
	
		arg parent, bounds, step, argClipLo, argClipHi, argRoundStepFlag, argSpeed, addFlag = 1;
		
		
		^super.new.init(parent, bounds, step, argClipLo, argClipHi, argRoundStepFlag, argSpeed, addFlag)
		
	}
	
	init { arg parent, bounds, step, argClipLo, argClipHi, argRoundStepFlag, argSpeed, addFlag = 1;
			
//		var left, top;
//		
////		left = parent.bounds.left + bounds.left;
////		top = parent.bounds.top + bounds.top;
//
//		left = bounds.left;
//		top = bounds.top;
		
	//	^GUI.scrollNumbeBox.new(parent, Rect(left, top, bounds.width, bounds.height), step, argClipLo, argClipHi, argRoundStepFlag, argSpeed);
		snbox = ScrollNumberBox9(parent, bounds, step, argClipLo, argClipHi, argRoundStepFlag, argSpeed, addFlag);
		^snbox;
	}
	
	
	

}

ScrollNumberBox9 {

	var nrbox, scroller, <>action, <>mouseUpAction, <>keyUpAction, <>step, <>clipLo, <>clipHi, <>speed, <>roundStepFlag;

	*new { arg parent, bounds, argStep, argClipLo, argClipHi, argRoundStepFlag, argSpeed, addFlag; 
		^super.new.initScrollNumberBox(parent, bounds, argStep, argClipLo, argClipHi, argRoundStepFlag, argSpeed, addFlag);
	}
	
	prClose {
		
		nrbox.remove;
		scroller.remove;
	
	}
	
	bounds {
	
		^nrbox.bounds;
	
	
	}
	
	bounds_ { |rect|
	
		nrbox.bounds_(rect);
		scroller.bounds_(rect);
	
	}

	initScrollNumberBox { arg parent, bounds, argStep, argClipLo, argClipHi, argRoundStepFlag, argSpeed, addFlag;
		var value, offset, startFlag;
		startFlag = true;
		step = argStep ? 1; 
		clipLo = argClipLo ? -inf; 
		clipHi = argClipHi ? inf;
		roundStepFlag = argRoundStepFlag ? 0;
		speed = argSpeed ? 1;
		        
		nrbox = SCNumberBox(parent, bounds);
		//nrbox = parent.add(NumberBox(parent, bounds, addFlag));
		nrbox.step = step;
		nrbox.scroll_(false);
        
		scroller = SCTabletView(parent, bounds);
		//scroller = parent.add(TabletView(parent, bounds, addFlag));
		scroller.background = Color.new(11,11,11,0);
		scroller.canFocus_(false);
		scroller.setProperty(\clipToBounds, 0);
		scroller.mouseDownAction = { arg view, x, y;
			// resize the scroller so other boxes in a row of nrboxes can also detect mousedown
			scroller.bounds_(
				Rect(nrbox.bounds.left, 
					nrbox.bounds.top - 400, 
					nrbox.bounds.width, 
					800)
			);
			
			value = nrbox.value;
			nrbox.focus(true);
		};
		
		nrbox.action = { arg num;
			num.value = num.value.clip(clipLo, clipHi);
			if(roundStepFlag == 1, { num.value = num.value.round(step); });
			action.value(num);
		};
		
		nrbox.mouseUpAction = {
			arg num;
			mouseUpAction.value(num)
		};
		
		nrbox.keyUpAction = {
			arg num;
			keyUpAction.value(num)
		
		};
        
		scroller.action = { arg view, x, y;
			// the mousedown would not take offset from the new (resized) rect so... here
			if(startFlag == true, {offset = y; startFlag = false});
			nrbox.value_(
				(
					((offset - y) * step) + value
				).clip(clipLo, clipHi) 
			);       
			action.value(nrbox);
		};
         
		scroller.mouseUpAction = { arg view, x, y;
		scroller.bounds_(bounds);
		startFlag = true;
		mouseUpAction.value(nrbox)
		};
    }

	increment { nrbox.increment; }
	decrement { nrbox.decrement; }
	
	remove {
	
		nrbox.remove;
	
	}
	
	typingColor_ { arg color;
		nrbox.typingColor_(color);
	}	
	
	normalColor_ { arg color;
		nrbox.normalColor_(color);
	}
			    
	value_ { arg val;
		nrbox.value_(val)
	}

	value {
		^nrbox.value;
	}

	valueAction_ { arg val;
		nrbox.valueAction_(val);
	}	
	
	boxColor {
		^nrbox.background;
	}
    
	boxColor_{ arg color;
		nrbox.background_(color);
	}
	
	background_{ arg color;
		nrbox.background_(color);
	}
	
	defaultGetDrag { 
		^nrbox.defaultGetDrag;
	}
	
	defaultCanReceiveDrag {
		^nrbox.defaultCanReceiveDrag;
	}
	
	defaultReceiveDrag {
		nrbox.defaultReceiveDrag
	}

	canFocus_ { arg bool;
		nrbox.canFocus_(bool)
	}

	font_ { arg argFont;
		nrbox.font_(argFont);
	}
	
	string_ { arg argString;
		nrbox.string_(argString);
	}
	align_ { arg align;
		nrbox.align_(align);
	}
	
	stringColor {
		^nrbox.stringColor;
	}
	
	stringColor_ { arg color;
		nrbox.stringColor_(color);
	}


	object_ { arg obj;
		nrbox.object_(obj);
	}
	
	properties {
		^nrbox.properties;
	}
	
	setProperty { arg key, value;
		nrbox.setProperty(key, value);
	}

}



C2_PopUpMenu {


	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.popUpMenu.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.popUpMenu.new(parent, bounds);
	
	}
	
	
}


C2_Slider {

	
	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.slider.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.slider.new(parent, bounds);
	
	}
	
}



C2_Button {

	
	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.button.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.button.new(parent, bounds);
	
	}
	
}

C2_RoundButton {

// you need wslib for this...

	
	*new {
	
		arg parent, bounds;
		
		var left, top, but;
		
//		left = parent.bounds.left + bounds.left;
//		top = parent.bounds.top + bounds.top;

		left = bounds.left;
		top = bounds.top;
		
		but = RoundButton(parent, Rect(left, top, bounds.width, bounds.height));
		but.canFocus_(false).extrude_(false).border_(2).radius_(2);
		^but
	
	}
	
}


C2_TextField {

	
	*new {
	
		arg parent, bounds;
		
		var left, top, tf;
		
//		left = parent.bounds.left + bounds.left;
//		top = parent.bounds.top + bounds.top;

		left = bounds.left;
		top = bounds.top;
		
		tf = GUI.textField.new(parent, Rect(left, top, bounds.width, bounds.height));
	//	tf.keyDownAction_({nil});
		^tf
	}
	
}

C2_CompositeView {

	
	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.compositeView.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.compositeView.new(parent, bounds);
	
	}
	
}

C2_UserView {

	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^SCUserView.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^SCUserView.new(parent, bounds);
	
	}
	
}

C2_EnvelopeView {

	
	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.envelopeView.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.envelopeView.new(parent, bounds);
	
	}
	
}

C2_2DSlider {

	
	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.slider2D.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.slider2D.new(parent, bounds);
	
	}
	
}
	
	
C2_ListView {

	
	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.listView.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.listView.new(parent, bounds);
	
	}

	
}


//C2_Knob {
//
//	
//	*new {
//	
//		arg parent, bounds;
//		
//		var left, top;
//		
//		left = parent.bounds.left + bounds.left;
//		top = parent.bounds.top + bounds.top;
//		
//		^Knob(parent, Rect(left, top, bounds.width, bounds.height));
//	
//	}
//
//	
//}

C2_RangeSlider {

	
	*new {
	
		arg parent, bounds;
		
		var left, top;
		
		left = parent.bounds.left + bounds.left;
		top = parent.bounds.top + bounds.top;
		
	//	^GUI.rangeSlider.new(parent, Rect(left, top, bounds.width, bounds.height));
	
		^GUI.rangeSlider.new(parent, bounds);
	
	}

	
}

//C2_MultiSliderView {
//
//
//	*new {
//	
//		arg parent, bounds;
//		
//		var left, top;
//		
//		left = parent.bounds.left + bounds.left;
//		top = parent.bounds.top + bounds.top;
//		
//		^SCMultiSliderView.new(parent, Rect(left, top, bounds.width, bounds.height));
//	
//	}
//
//
//
//
//
//
//
//}




