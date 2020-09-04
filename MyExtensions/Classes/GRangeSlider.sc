GRangeSlider : SCViewHolder {
	var <>action;
	var <minValue;
	var <maxValue;
	var <spec;
	var <name;
	var staticText;
	var rangeSlider;
	var minNumberBox;
	var maxNumberBox;

	*new { | parent, bounds, min = 0, max = 1, spec, name |
		^super.new.init(parent, bounds, min, max, spec, name);
	}

	init { | parent, bounds, argMin, argMax, argSpec, argName |
		spec = argSpec;
		name = argName;
		minValue = spec.constrain(argMin);
		maxValue = spec.constrain(argMax);
		view = CompositeView(parent, bounds);
		if (name != nil) {
			staticText = StaticText(view).string_(name).maxHeight_(20);
			staticText.setProperty(\wordWrap, false); // for Windows
		};
		minNumberBox = NumberBox(view).maxWidth_(80).maxHeight_(20).align_(\center).maxDecimals_(3).value_(minValue);
		minNumberBox.clipLo_(spec.clipLo).clipHi_(spec.clipHi);
		maxNumberBox = NumberBox(view).maxWidth_(80).maxHeight_(20).align_(\center).maxDecimals_(3).value_(maxValue);
		maxNumberBox.clipLo_(spec.clipLo).clipHi_(spec.clipHi);
		rangeSlider = RangeSlider(view).maxHeight_(20).lo_(spec.unmap(minValue)).hi_(spec.unmap(maxValue));
		rangeSlider.orientation = \horizontal;
		if (name != nil) {
			view.layout = HLayout(staticText,minNumberBox,rangeSlider,maxNumberBox).margins_(0).spacing_(2);
		} {
			view.layout = HLayout(minNumberBox,rangeSlider,maxNumberBox).margins_(0).spacing_(2);
		};
		rangeSlider.action = { |slider|
			minValue = spec.map(slider.lo);
			maxValue = spec.map(slider.hi);
			minNumberBox.value = minValue;
			maxNumberBox.value = maxValue;
			this.doAction();
		};
		minNumberBox.action = { |numberBox|
			minValue = numberBox.value;
			rangeSlider.lo = spec.unmap(minValue);
			this.doAction();
		};
		maxNumberBox.action = { |numberBox|
			maxValue = numberBox.value;
			rangeSlider.hi = spec.unmap(maxValue);
			this.doAction();
		};
	}

	doAction {
		this.action.value(this, [minValue, maxValue]);
	}
}