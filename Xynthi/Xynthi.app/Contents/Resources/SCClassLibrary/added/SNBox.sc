// blackrain
SNBox : SCNumberBox {
	var <>clipLo = -inf, <>clipHi = inf, hit, inc=1.0, <>scroll=true, <>shift_step=0.1, <>ctrl_step=10;

	*viewClass { ^SCNumberBox }
/*
	init { arg argParent, argBounds;
		super.init(argParent, argBounds).boxColor_(Color.blue(0.0,0.1));
	}
*/
	value_ { arg val;
		keyString = nil;
		this.stringColor = normalColor;
		object = val.clip(clipLo, clipHi);
		this.string = object.asString;
	}	
	valueAction_ { arg val;
		var prev;
		prev = object;
		this.value = val.clip(clipLo, clipHi);
		if (object != prev, { this.doAction });
	}
	mouseDown{ arg x, y, modifiers, buttonNumber, clickCount;
		hit = Point(x,y);
		if (scroll == true, {
			inc = 1.0;
			case
				{ modifiers == 131072 } // shift defaults to step x 0.1
					{ inc = shift_step }
				{ modifiers == 262144 } // control defaults to step x 10
					{ inc = ctrl_step };
		});			
		mouseDownAction.value(this, x, y, modifiers, buttonNumber, clickCount)
	}
	mouseMove{ arg x, y, modifiers;
		var direction;
		if (scroll == true, {
			direction = 1.0;
			if (y > hit.y, { direction = -1.0 });
			this.valueAction = (this.value + (inc * this.step * direction));
			hit = Point(x,y);
		});
		mouseMoveAction.value(this, x, y, modifiers);	
	}
}
