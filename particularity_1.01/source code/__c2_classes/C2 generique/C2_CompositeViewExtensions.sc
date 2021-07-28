// 38nonprivate@durftal.com

// os x only so far

+ SCWindow {

	// WHAT'S DIFFERENT: allows auto resizing of a composite view when the window is resized
	// SCWindow needs to have the vars resizeView, resizeStatus and resizeRoutine declared - 
	// no way to do that here
	
	// var resizeView, resizeStatus = 0, resizeRoutine, cmdPeriodAction, resizeFunction;

	setResizeView { |view|
	
		resizeView = view;
		
		cmdPeriodAction = 
			{
			if(resizeStatus == 1)
				{
				AppClock.play(resizeRoutine);
				};
			
			};
		
	
	}
	
	enableResize { |interval = 0.5|
	
		if(resizeStatus == 1) {^nil};
		
		resizeStatus = 1;
		
		resizeRoutine = Routine({
		
			9999999.do { |i|
			
				if(i > 2)
					{
		
					if([this.bounds.width, this.bounds.height] != [resizeView.bounds.width, resizeView.bounds.height])
						{
						[this.bounds.width, this.bounds.height, resizeView.bounds.width, resizeView.bounds.height].postln;
						"resize".postln;
						resizeView.resizeAll(Rect(0, 0, this.bounds.width, this.bounds.height));
						resizeFunction.value;
						};
						
					};
				interval.wait;
			};
			
		});
		
		AppClock.play(resizeRoutine);
		CmdPeriod.add(cmdPeriodAction);
	
	}
	
	disableResize {
	
		resizeStatus = 0;
		resizeRoutine.stop;
		CmdPeriod.remove(cmdPeriodAction);
	
	}



}

+ SCView {

// WHAT'S DIFFERENT: the use of addFlag
// this allows calling .add directly on an SCCompositeView without adding the gui object twice
// essential for the class C2_4ContainerView

// removed "this view already removed" debug message cos i don't want to read it

	*new { arg parent, bounds, addFlag = 1;
		^super.new.init(parent, bounds, addFlag);
	}
	
	init { arg argParent, argBounds, addFlag = 1;
		parent = argParent.asView; // actual view
		background = Color.clear;
			// call asView again because parent by this point might be a FlowView
		this.prInit(parent.asView, argBounds.asRect,this.class.viewClass);
		if(addFlag == 1) {argParent.add(this)};
		//maybe window or viewadapter
	}
	
	remove {
		if(dataptr.notNil,{
			parent.prRemoveChild(this);
			this.prRemove;
			this.prClose;
		});
	}


}


+ SCCompositeView {

// WHAT'S DIFFERENT: asIfFor bounds allows scaling as the object itself is being drawn
// plus two extensions for scaling composite views and their children
	
	add { arg child, asIfForBounds;
		children = children.add(child);
		if (decorator.notNil, { decorator.place(child); });
		if(asIfForBounds.notNil)
			{
			this.resizeChild(children.size - 1, asIfForBounds);
			};
			
		^child;
		
	}
	
	resizeChild { |index = 0, asIfForBounds, ratio|
	
		var item, left, top, width, height, currentFont, newFont, smallestRatio;
		
		item = children[index];
		
		left = (item.bounds.left / asIfForBounds.width) * this.bounds.width;
		top = (item.bounds.top / asIfForBounds.height) * this.bounds.height;
		width = (item.bounds.width / asIfForBounds.width) * this.bounds.width;
		height = (item.bounds.height / asIfForBounds.height) * this.bounds.height;
		
//		if(ratio == nil)
//			{
//			smallestRatio = [(this.bounds.height / asIfForBounds.height), (this.bounds.width / asIfForBounds.width)].sort[0];
//			ratio = smallestRatio;
//			};
		
		case
			{children[index].class == SCCompositeView}
			{ children[index].resizeAll(Rect(left, top, width, height)) }
			{children[index].respondsTo(\font) == true}
			{
			currentFont = children[index].font;
			if(currentFont != nil)
				{
				newFont = SCFont(
					currentFont.name, 
					currentFont.size 
					// * ratio
					(
						(this.bounds.height)
						/
						(asIfForBounds.height)
					)
				);
				children[index].font_(newFont);
				};
				
			children[index].bounds_(Rect(left, top, width, height));
			}
			{ children[index].bounds_(Rect(left, top, width, height)) };
			
		case
			{children[index].respondsTo(\thumbSize) == true}
			{children[index].thumbSize_(children[index].thumbSize * (this.bounds.width / asIfForBounds.width))};
	
	}
	
	resizeAll { |newBounds|
	
		var oldBounds, smallestRatio;
		
		oldBounds = this.bounds;
		this.bounds_(newBounds);
		
	//	smallestRatio = [(this.bounds.height / oldBounds.height), (this.bounds.width / oldBounds.width)].sort[0];
		
		children.do { |item, index|
			this.resizeChild(index, oldBounds, smallestRatio);
		};	
		
	}
		
}
