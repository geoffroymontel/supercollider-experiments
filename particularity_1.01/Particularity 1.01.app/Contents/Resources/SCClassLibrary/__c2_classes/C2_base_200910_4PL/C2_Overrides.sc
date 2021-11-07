// nonprivate@cylob.com


+ Buffer {

	set2D { |channel = 0, index = 0, float = 0.0|
	
		var thisIndex;
	
		if(channel > (numChannels - 1)) {^nil};
		thisIndex = (index * (numChannels - 1)) + channel;
		this.set(thisIndex, float);
	
	}
	
	get2D { |channel = 0, index = 0, action|
	
	}



}

+ ArrayedCollection {

	sizeC {  
		var x;
		x = (this.size - 1); 
		^x 
	}


}


+ SCNumberBox {

	init { arg argParent, argBounds;
		typingColor = Color.red;
		normalColor = Color.black;
		parent = argParent.asView; // actual view
		this.prInit(parent, argBounds.asRect,this.class.viewClass);
		argParent.add(this);//maybe window or viewadapter
		this.align_(\center);
	}


}


+ SCSoundFileView {

	scrollToFrame { | frame |
		this.x_(frame).refresh;
		this.updateScroll;
	}
	
}
	
+ SCListView {

	defaultKeyDownAction { arg char, modifiers, unicode;
			var index;
			unicode.postln;
//			if (char == $ , { this.valueAction = this.value + 1; ^this });
//			if (char == $\r, { this.enterKeyAction.value(this); ^this });
//			if (char == $\n, { this.enterKeyAction.value(this); ^this });
//			if (char == 3.asAscii, { this.enterKeyAction.value(this); ^this });
//			if (unicode == 16rF700, { this.valueAction = this.value - 1; ^this });
//			if (unicode == 16rF703, { this.valueAction = this.value + 1; ^this });
//			if (unicode == 16rF701, { this.valueAction = this.value + 1; ^this });
//			if (unicode == 16rF702, { this.valueAction = this.value - 1; ^this });
//			if (char.isAlpha, {
//				char = char.toUpper;
//				index = items.detectIndex({|item| item.asString.at(0).toUpper >= char });
//				if (index.notNil, {
//					this.valueAction = index
//				});
//				^this
//			});
			^nil		// bubble if it's an invalid key
	}
	
	
}


+ SparseArray {

	compressList {
		var list;
		array.do { |item, i|
			if(item != default) { 
				list = list.add(item); 
			};
		};
		^list
	}
	
	compressInd {
		var ind;
		array.do { |item, i|
			if(item != default) { 
				ind = ind.add(indices.at(i)) 
			};
		};
		^ind
	}
		
	compressCombo {
		var combo;
		array.do { |item, i|
			if(item != default) { 
				combo = combo.add([indices.at(i), item].deepCopy)
			};
		};
		^combo
	}
	
	erase {
	
		var ind;
		array.do { |item, i|
			if(item != default) { 
				array[i] = default.deepCopy
			};
		};

	}
	
}	
	
	
	

