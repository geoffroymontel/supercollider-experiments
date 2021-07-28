SCNumberBox : SCStaticTextBase {
	var <> keyString, <>step=1, <>scroll_step=1;
	var <>typingColor, <>normalColor;
	var <>clipLo = -inf, <>clipHi = inf, hit, inc=1.0, <>scroll=true;
	var <>shift_scale = 100.0, <>ctrl_scale = 10.0, <>alt_scale = 0.1;
	var <>scrollDirection = \v;

	getScale { |modifiers|
		^case
			{ modifiers & 131072 == 131072 } { shift_scale }
			{ modifiers & 262144 == 262144 } { ctrl_scale }
			{ modifiers & 524288 == 524288 } { alt_scale }
			{ 1 };
	}

	*paletteExample { arg parent, bounds;
		var v;
		v = this.new(parent, bounds);
		v.value = 123.456;
		^v
	}

	init { arg argParent, argBounds;
		typingColor = Color.red;
		normalColor = Color.black;
		background = Color.white;
		parent = argParent.asView; // actual view
		this.prInit(parent.asView, argBounds.asRect,this.class.viewClass);
		argParent.add(this);//maybe window or viewadapter
	}

	increment {arg mul=1; this.valueAction = this.value + (step*mul); }
	decrement {arg mul=1; this.valueAction = this.value - (step*mul); }

	defaultKeyDownAction { arg char, modifiers, unicode;
		var zoom = this.getScale(modifiers);

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

	value { ^object }
	value_ { arg val;
		keyString = nil;
		this.stringColor = normalColor;
		object = val !? { val.clip(clipLo, clipHi) };
		this.string = object.asString;
	}
	valueAction_ { arg val;
		var prev;
		prev = object;
		this.value = val !? { val.clip(clipLo, clipHi) };
		if (object != prev, { this.doAction });
	}

	boxColor {
		this.deprecated(thisMethod, SCView.findMethod(\background));
		^this.background;
	}
	boxColor_ { arg color;
		this.deprecated(thisMethod, SCView.findMethod(\background_));
		this.background_(color)
	}

	properties {
		^super.properties ++ #[\boxColor]
	}
	defaultGetDrag {
		^object.asFloat
	}
	defaultCanReceiveDrag {
		^currentDrag.isNumber;
	}
	defaultReceiveDrag {
		this.valueAction = currentDrag;
	}

	mouseDown { arg x, y, modifiers, buttonNumber, clickCount;
		hit = Point(x,y);
		if (scroll == true, { inc = this.getScale(modifiers) });
		mouseDownAction.value(this, x, y, modifiers, buttonNumber, clickCount)
	}

	mouseMove { arg x, y, modifiers;
		var direction;
		if (scroll == true, {
		
			case
				{scrollDirection == \h}
				{
				// horizontal scrolling:
				if ((x - hit.x) < 0) {direction = -1.0} {direction = 1.0};
				}
				{scrollDirection == \v}
				{
				// vertical scrolling:
				if ((y - hit.y) > 0) {direction = -1.0} {direction = 1.0};
				}
				{
				// horizontal or vertical scrolling:
				direction = 1.0;
				if ( (x - hit.x) < 0 or: { (y - hit.y) > 0 }) { direction = -1.0; };
				};
				

			this.valueAction = (this.value + (inc * this.scroll_step * direction));
			hit = Point(x, y);
		});
		mouseMoveAction.value(this, x, y, modifiers);
	}
	mouseUp{
		inc=1
	}
}
