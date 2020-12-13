// blackrain - 1105
Knob {
	var <knob, <>action, <>color, <>mouseOverAction, <>keyDownFunc, value, <>step, 
		hit, <>keystep, isCentered = false, <>mode;
	
	*new { arg parent, bounds;
		^super.new.initKnob(parent, bounds)
	}

	initKnob { arg parent, bounds;
		var knobFunc;

		mode = \round;
		keystep = 0.01;
		step = 0.01;
		value = 0.0;
		
		color = [Color.blue(0.7, 0.5), Color.green(0.8, 0.8), Color.black.alpha_(0.3),
			Color.black.alpha_(0.7)];

		knob = SCUserView.new(parent, bounds)
			.keyDownFunc_({arg me, key, modifiers, unicode;
				keyDownFunc.value(key, modifiers, unicode);
			})
			.mouseOverAction_({arg v, x, y; this.mouseOverAction.value(this, x, y); })
			.mouseDownAction_({arg v, x, y, modifiers;
				hit = Point(x,y);
				knobFunc.value(v, x, y, modifiers);
			})
			.mouseTrackFunc_({arg v, x, y, modifiers;
				knobFunc.value(v, x, y, modifiers);
			})
			.drawFunc_({
				var startAngle, arcAngle, size;
				size = knob.bounds.width;
				
				color[2].set;
				Pen.addAnnularWedge(
					knob.bounds.center, 
					(knob.bounds.width * 0.5) - (0.08 * size), 
					knob.bounds.width * 0.5, 	
					0.25pi, 
					-1.5pi
				);
				Pen.perform(\fill);
		
				if (isCentered == false, {
					startAngle = 0.75pi; 
					arcAngle = 1.5pi * value;
				}, {
					startAngle = -0.5pi; 
					arcAngle = 1.5pi * (value - 0.5);
				});

				color[1].set;
				Pen.addAnnularWedge(
					knob.bounds.center, 
					(knob.bounds.width * 0.5) - (0.12 * size), 
					knob.bounds.width * 0.5, 	
					startAngle, 
					arcAngle
				);
				Pen.perform(\fill);
		
				color[0].set;
				Pen.addWedge(knob.bounds.center, (knob.bounds.width * 0.5) - (0.14 * size),
					0, 2pi);
				Pen.perform(\fill);

				color[3].set;
				Pen.width = (0.08 * size);
				Pen.moveTo(knob.bounds.center);
				Pen.lineTo(Polar.new((knob.bounds.width * 0.5) - (0.14 * size),
					0.75pi + (1.5pi * value)).asPoint + knob.bounds.center);
				Pen.stroke;
			})
			.canReceiveDragHandler_({
				SCView.currentDrag.isFloat
			})
			.receiveDragHandler_({
				this.valueAction = SCView.currentDrag.clip(0.0, 1.0);
			})
			.beginDragAction_({ arg v;  this.value.asFloat;  });
		//	.onClose_({ knob = nil; });

		knobFunc = {arg v, x, y, modifiers;
			var pt, angle, inc = 0;

			if (modifiers != 1048576, { // this is not a drag - apple key (is this portable?)
				case
					{ (mode == \vert) || (modifiers == 262144) } { // or Control
						if ( hit.y > y, {
							inc = step;
						}, {
							if ( hit.y < y, {
								inc = step.neg;
							});
						});
						value = (value + inc).clip(0.0, 1.0);
						hit = Point(x,y);
						action.value(this, x, y, modifiers);
						v.refresh;
					}
					{ (mode == \horiz) || (modifiers == 524288) } { // or Option
						if ( hit.x > x, {
							inc = step.neg;
						}, {
							if ( hit.x < x, {
								inc = step;
							});
						});
						value = (value + inc).clip(0.0, 1.0);
						hit = Point(x,y);
						action.value(this, x, y, modifiers);
						v.refresh;
					}
					{ mode == \round } {
						pt = v.bounds.center - Point(x,y);
						angle = Point(pt.y, pt.x.neg).theta;
						if ((angle >= -0.80pi) && (angle <= 0.80pi), {
							value = [-0.75pi, 0.75pi].asSpec.unmap(angle);
							action.value(this, x, y, modifiers);
							v.refresh;
						});

					}
			});
		};

		keyDownFunc = {arg key, modifiers, unicode;
			this.defaultKeyDownAction(key, modifiers, unicode);
		}
	}

	value_ {arg val;
		value = val.clip(0.0, 1.0);
		knob.refresh;
		^value;
	}

	value {
		^value;
	}
	
	valueAction_ {arg val;
		value = val.clip(0.0, 1.0);
		action.value(this);
		knob.refresh;
		^value
	}
	
	canFocus_ { arg state = false;
		knob.canFocus_(state);
		^this
	}

	canFocus {
		^knob.canFocus;
	}

	visible_ { arg bool;
		knob.visible_(bool)
	}

	visible {
		^knob.visible
	}
	
	enabled_{ arg bool;
		knob.enabled_(bool)
	}
	
	enabled {
		^knob.enabled
	}
	
	refresh {
		knob.refresh;
		^this
	}
	
	centered_ { arg bool;
		isCentered = bool;
		knob.refresh;
		^this
	}
	
	centered {
		^isCentered
	}

	properties {
		^knob.properties;
	}

	canReceiveDragHandler_ { arg f;
		knob.canReceiveDragHandler_(f);
	}
	
	canReceiveDragHandler {
		^knob.canReceiveDragHandler;
	}
	
	receiveDragHandler_ { arg f;
		knob.receiveDragHandler_(f);
	}
	
	receiveDragHandler {
		^knob.receiveDragHandler;
	}
	
	beginDragAction_ { arg f;  knob.beginDragAction_(f);  }

	beginDragAction {  ^knob.beginDragAction;  }

	// rip from slider
	increment { ^this.valueAction = (this.value + keystep).min(1) }
	decrement { ^this.valueAction = (this.value - keystep).max(0) }

	defaultKeyDownAction { arg char, modifiers, unicode,keycode;
		// standard keydown
		if (char == $r, { this.valueAction = 1.0.rand; });
		if (char == $n, { this.valueAction = 0.0; });
		if (char == $x, { this.valueAction = 1.0; });
		if (char == $c, { this.valueAction = 0.5; });
		if (char == $], { this.increment; ^this });
		if (char == $[, { this.decrement; ^this });
		if (unicode == 16rF700, { this.increment; ^this });
		if (unicode == 16rF703, { this.increment; ^this });
		if (unicode == 16rF701, { this.decrement; ^this });
		if (unicode == 16rF702, { this.decrement; ^this });
	}

}

