StepSeq {
	var <view, <steps, <valarr, <knobs, <lights, <lastIndex, <clock, <>action, <wait;
	var hasGui=false;
	
	*new {|steps=16, action, clock, spec|
		^super.new.init(steps, action, clock, spec);
	}
	
	init {|argsteps=16, argaction, argclock|
		steps=argsteps;
		action=argaction;
		clock=argclock ? TempoClock.default;
		valarr=Array.fill(steps, 1);
	}
	
	play {|perbeat=4|
		var ticker, index;
		wait=perbeat.reciprocal;
		ticker=clock.schedAbs(clock.beats.ceil, {|beat|
			index=beat * perbeat;
			action.value(valarr.wrapAt(index), beat);
			(hasGui).if({ 
				{
					lights.wrapAt(index - 1).value_(0);
					(wait.notNil).if({ lights.wrapAt(index).value_(1); });
				}.defer
			});
			wait;
		});
	}
	
	randomPlay {|perbeat=4|
		var ticker, index, lastindex=0;
		wait=perbeat.reciprocal;
		ticker=clock.schedAbs(clock.beats.ceil, {|beat|
			index=rrand(0, steps - 1);
			(index==lastindex).if({ index=index + [-1, 1].choose });
			action.value(valarr.wrapAt(index), beat);
			(hasGui).if({ 
				{
					lights.wrapAt(lastindex).value_(0);
					(wait.notNil).if({ lights.wrapAt(index).value_(1); });
					lastindex=index;
				}.defer
			}, { lastindex=index });
			wait;
		});
	}
	
	stop {
		wait=nil;
	}
	
	getIndex {|index|
		^valarr[index];
	}
	
	setIndex {|index, val|
		valarr[index]=val;
		(hasGui).if({ knobs[index].value_(val) });
	}
	
	value {
		^valarr.asArray;
	}
	
	value_ {|arr|
		valarr=arr.asArray;
	}
	
	gui {|parent, bounds|
		var xincr, yincr, xwidth, ywidth, butx, buty, butxbord, butybord, kx, kxbord, kybord;
		(parent.notNil).if({
			view=parent;
		}, {
			view=SCWindow("Stepper", bounds);
			view.front;
		});
		xincr=bounds.width / steps;
		yincr=bounds.height * 0.125;
		butx=xincr * 0.25;
		buty=yincr * 0.5;
		butxbord=xincr - butx * 0.5;
		butybord=yincr - buty * 0.5;
		lights=Array.fill(steps, {|i|
			SCButton(view, Rect(i * xincr + butxbord, butybord, butx, buty))
				.states_([["", "", Color.red], ["", "", Color.white]]);
		});
		kx=xincr * 0.9;
		kxbord=xincr - kx * 0.5;
		kybord=4; 
		knobs=Array.fill(steps, {|i|
			var knob;
			knob=Knob.new(view, Rect(i * xincr + kxbord, yincr + kybord, kx, kx));
			knob.action_({|v|
					valarr[i]=v.value;
				});
			knob.value_(valarr[i]);
			knob
		});
		hasGui=true;
		view.onClose_({ hasGui=false });
	}
}