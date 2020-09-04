GSlider : SCViewHolder {
	var <>action;
	var <value;
	var <spec;
	var <name;
	var staticText;
	var slider;
	var numberBox;

	*new { | parent, bounds, initValue = 0, spec, name |
		^super.new.init(parent, bounds, initValue, spec, name);
	}

	init { | parent, bounds, initValue, argSpec, argName |
		spec = argSpec;
		name = argName;
		value = spec.constrain(initValue);
		view = CompositeView(parent, bounds);
		if (name != nil) {
			staticText = StaticText(view).string_(name).maxHeight_(20);
			staticText.setProperty(\wordWrap, false); // for Windows
		};
		numberBox = NumberBox(view).maxWidth_(80).maxHeight_(20).maxDecimals_(3).align_(\center);
		numberBox.clipLo_(spec.clipLo).clipHi_(spec.clipHi);
		slider = Slider(view).maxHeight_(20);
		slider.orientation = \horizontal;
		if (name != nil) {
			view.layout = HLayout(staticText, numberBox, slider).margins_(0).spacing_(2);
		} {
			view.layout = HLayout(numberBox, slider).margins_(0).spacing_(2);
		};
		slider.action = { |slider|
			value = spec.map(slider.value);
			numberBox.value = value;
			this.doAction();
		};
		numberBox.action = { |numberBox|
			value = numberBox.value;
			slider.value = spec.unmap(value);
			this.doAction();
		};
		this.value = value;
	}

	value_ { |v|
		numberBox.value = v;
		slider.value = spec.unmap(v);
		value = v;
	}

	doAction {
		this.action.value(this, value);
	}
}