GNumberBox : SCViewHolder {
	var <>action;
	var <value;
	var <name;
	var <spec;
	var staticText;
	var numberBox;

	*new { | parent, bounds, initValue = 0, spec, name, numberOfDecimals = 2 |
		^super.new.init(parent, bounds, initValue, spec, name, numberOfDecimals);
	}

	init { | parent, bounds, initValue, argSpec, argName, numberOfDecimals |
		value = initValue;
		name = argName;
		spec = argSpec;
		view = CompositeView(parent, bounds);
		if (name != nil) {
			staticText = StaticText(view).string_(name);
		};
		numberBox = NumberBox(view).clipLo_(spec.clipLo).clipHi_(spec.clipHi).decimals_(numberOfDecimals).value_(value);
		if (name != nil) {
			view.layout = HLayout(staticText, numberBox).margins_(0).spacing_(2);
		} {
			view.layout = HLayout(numberBox).margins_(0).spacing_(2);
		};
		numberBox.action = { |numberBox|
			value = numberBox.value;
			this.doAction();
		};
	}

	value_ { |v|
		numberBox.value = v;
		value = v;
	}

	doAction {
		this.action.value(this, value);
	}
}