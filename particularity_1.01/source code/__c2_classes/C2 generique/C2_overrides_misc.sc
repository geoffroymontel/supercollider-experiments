+ SCNumberBox {

	defaultKeyDownAction { arg char, modifiers, unicode;
		var zoom = this.getScale(modifiers);
		
		
	//	[char, modifiers, unicode].postln;
		
		if(char == $e) {^nil};
		
		// standard chardown
		if (unicode == 16rF700, { this.increment(zoom); ^this });
		if (unicode == 16rF703, { this.increment(zoom); ^this });
		if (unicode == 16rF701, { this.decrement(zoom); ^this });
		if (unicode == 16rF702, { this.decrement(zoom); ^this });
		
		if ((char == 3.asAscii) || (char == $\r) || (char == $\n), { // enter key
			if (keyString.notNil,{ // no error on repeated enter
				this.valueAction_(keyString.asFloat);
			});
			^this
		});
		if (char == 127.asAscii, { // delete key
			keyString = nil;
			this.string = object.asString;
			this.stringColor = normalColor;
			^this
		});
		if (char.isDecDigit || "+-.eE".includes(char), {
			if (keyString.isNil, { 
				keyString = String.new;
				this.stringColor = typingColor;
			});
			keyString = keyString.add(char);
			this.string = keyString;
			^this
		});
		
		

		^nil		// bubble if it's an invalid key
	}
	
}

+ Interpreter {



	interpretPrintCmdLine {
		var res, func;
		"\n".post;
		func = this.compile(cmdLine);
		res = func.value;
		codeDump.value(cmdLine, res, func);
	//	res.postln;
	}
	
	
}
