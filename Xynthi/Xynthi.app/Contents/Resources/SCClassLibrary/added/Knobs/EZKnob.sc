// blackrain - 0106
EZKnob	{
	var <>labelView, <>knobView, <>numberView, <value, <>round = 0.0001, <>action, <>controlSpec;
	var layout;

	*new { arg window, dimensions, label, controlSpec, action, initVal, 
			initAction=false, labelWidth=50, numberWidth = 50, centered=false;
			
		^super.new.init(window, dimensions, label, controlSpec, action, initVal, 
			initAction, labelWidth, numberWidth, centered);
	}

	init { arg window, dimensions, label, argControlSpec, argAction, initVal, 
			initAction, labelWidth, numberWidth, centered;
		var width;
		var decorator = window.tryPerform(\decorator), gap = decorator.tryPerform(\gap);

		gap.notNil.if({
			labelWidth = labelWidth - gap.x;
			numberWidth = numberWidth - gap.x;
			(dimensions = dimensions.copy).x_(dimensions.x - (2*gap.x));
		});
		
		controlSpec = argControlSpec.asSpec;
		initVal = initVal ? controlSpec.default;
		action = argAction;

		width = labelWidth.max(dimensions.x).max(numberWidth);
		layout = FlowView.new(window, (width + 4) @
			(dimensions.y + dimensions.x + dimensions.y + 14));
		layout.do({ arg lay;
			labelView = SCStaticText(lay, width @ dimensions.y);
			labelView.string = label;
			labelView.align = \center;
	
			knobView = Knob(lay, dimensions.x @ dimensions.x);
			knobView.action = {
				value = controlSpec.map(knobView.value);
				numberView.value = value.round(round);
				action.value(this);
			};
			if (controlSpec.step != 0) {
				knobView.step = (controlSpec.step / (controlSpec.maxval - controlSpec.minval));
			};
			
			knobView.centered = centered;

			numberView = SCNumberBox(lay, numberWidth @ dimensions.y);
			numberView.action = {
				numberView.value = value = controlSpec.constrain(numberView.value);
				knobView.value = controlSpec.unmap(value);
				action.value(this);
			};
			
			if (initAction, {
				this.value = initVal;
			}, {
				value = initVal;
				knobView.value = controlSpec.unmap(value);
				numberView.value = value.round(round);
			});
		}).background_(Color.blue(0.2, alpha:0.1)).resizeToFit;

	}
	value_ { arg value; numberView.valueAction = value }
	valueNoAction_ { arg val;
		value=val; 
		numberView.value=value.round(round);
		knobView.value_(controlSpec.unmap(value));
	}
	set { arg label, spec, argAction, initVal, initAction=false;
		labelView.string = label;
		controlSpec = spec.asSpec;
		action = argAction;
		initVal = initVal ? controlSpec.default;
		if (initAction) {
			this.value = initVal;
		}{
			value = initVal;
			knobView.value = controlSpec.unmap(value);
			numberView.value = value.round(round);
		};
	}
	
	centered_ { arg bool;
		knobView.centered_(bool)
	}
	
	visible_ { arg bool;
		layout.visible_(bool)
	}
}
