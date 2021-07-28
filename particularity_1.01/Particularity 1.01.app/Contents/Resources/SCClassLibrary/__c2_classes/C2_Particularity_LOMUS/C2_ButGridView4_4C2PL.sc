C2_ButGridView4_4C2PL {


	var cv;
	var <selected = 0, <>action, <currentNote = 0, but, <selectedColor, <unselectedColor, <status, colors;
	var noOfSlots, highlightIndex;
	var <>highlightColor;

	*new { |parent, rect, noOfCols, noOfRows, gap| ^super.new.init(parent, rect, noOfCols, noOfRows, gap) }
	
	init { |parent, rect, noOfCols = 16, noOfRows = 2, gap = 2|
	
		var x, y;
		var width, height, butWidth, butHeight;
	
		cv = SCCompositeView(parent, rect);
		cv.background_(\grey55);
		noOfSlots = (noOfCols * noOfRows).asInt;
		but = Array.newClear(noOfSlots);
		status = Array.newClear(noOfSlots);
		
		width = rect.width; height = rect.height;
		
		butWidth = (width - ((noOfCols + 1) * gap)) / noOfCols;
		butHeight = (height - ((noOfRows + 1) * gap)) / noOfRows;
				
		y = 0;
		
		colors = [C2_Color(\black), C2_Color(\DarkOrange)];
		highlightColor = C2_Color(\LightGoldenrod1);
		
		but.do { |item, index|
		
			var colNo, rowNo;
			
			colNo = index.wrap(0, (noOfCols - 1));
			rowNo = index.div(noOfCols);
		
			x = (gap * (colNo + 1)) + (colNo * butWidth);
			y = (gap * (rowNo + 1)) + (rowNo * butHeight);
		
			but[index] = Button(cv, Rect(x, y, butWidth, butHeight), 10);
			but[index].states = 
				[
				[(index + 1).asString, C2_Color(\grey33), colors[0]],
				[(index + 1).asString, C2_Color(\black), colors[1]],
				[(index + 1).asString, C2_Color(\black), highlightColor]
				];
			but[index].action = { |but| this.action.value(this, index)};
			but[index].font_(Font("Helvetica", 14));
			status[index] = 0;
			
	
		};
		
		this.update;
		
	}
	
	bounds_ { |rect|
	
		cv.resizeAll(rect);
	
	}
	
	update {
	
		but.do { |item, index| if(index == highlightIndex) { item.value = 2 } { item.value = status[index] } };

	}
	
	selectedColor_ { |c|
	
		if(c.isArray)
			{selectedColor = c}
			{selectedColor = [c]};
		this.update;
		
	}
	
	unselectedColor_ { |c|
	
		unselectedColor = c; this.update;
		
	}	
	
	background_ { |b|
	
		cv.background_(b);
	
	
	}
	
	remove {
	
		cv.remove; cv = nil;
	
	}
	
	selected_ { |sel|
	
		selected = sel.clip(0, 1);
		this.update;
	
	}
	
	status_ { |st|
	
		status = st; this.update;
	
	}
	
	setStatusOfOneStep { |index, st|
	
		status[index.clip(0, noOfSlots - 1)] = st;
		this.update;
	
	}
	
	highlight { |index|
	
		highlightIndex = index;
		this.update;
	
	}
	
	unhighlight {
	
		highlightIndex = nil;
		this.update;
	
	}







}

