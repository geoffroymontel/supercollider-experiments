C2P_GUI_MSC_4C2PL {

	var w, cv, msc, num_startFrame, sl_zoom, startFrame = 0, zoom, limit;
	var <action, <openStatus = 1;
	var <>closeAction;

	*new { |startX = 300, startY = 200, limit = 64, title| ^super.new.init(startX, startY, limit, title) }
	
	init { |startX = 300, startY = 200, argLimit = 64, argName|

		limit = argLimit;
		zoom = limit;
		
		w =  Window.new(argName ? "", Rect(startX, startY, 870, 290), false);
		w.front;
		w.onClose_({openStatus = 0; closeAction.value});
		cv = CompositeView(w, Rect(0, 0, 870, 260));
		msc = C2_MSC_4SBA_4C2PL(limit);
		
		msc.name_("freq").msLength_(580).msHeight_(180);
		msc.backgroundColor_(C2_Color('SlateBlue1'));
		msc.guiDraw(cv, 10, 30);
		msc.setZoom(zoom);
		StaticText(cv, Rect(5, 5, 70, 20)).string_("Start Frame:");
		num_startFrame = C2_ScrollNumberBox(cv, Rect(80, 5, 70, 20), 1, 0, 99999);
		num_startFrame.value_(0);
		StaticText(cv, Rect(160, 5, 40, 20)).string_("Zoom:");
		sl_zoom = C2_Slider(cv, Rect(205, 5, 150, 20));
		sl_zoom.value_(1.0);
		num_startFrame.action = 
			{ 
			|num| 
			startFrame = num.value; 
			msc.setStart(startFrame); this.guiUpdate;
			};
		sl_zoom.action = 
			{ 
			|sl|
			zoom = sl.value;
			msc.setZoomByFraction(zoom);
			this.guiUpdate;
			};

	}
	
	action_ { |func|
	
		msc.action = func;
	
	}
	
	value { ^msc.getArray }
	
	value_ { |array| msc.setArray(array) }
	
	name_ { |n| if(openStatus == 0) {^nil}; {w.name_(n)}.defer }
	
	close { {w.close}.defer; }
	
	front { w.front }
	
}





