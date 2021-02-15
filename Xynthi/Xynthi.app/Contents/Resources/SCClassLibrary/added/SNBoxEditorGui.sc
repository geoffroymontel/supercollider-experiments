// blackrain - 0206

SNBoxEditorGui : EditorGui {

	var numv;
	
	guiBody { arg layout, step=0.01;
		var r;
		numv = SNBox(layout,Rect(0,0,40,17))
			.clipLo_(model.spec.clipLo).clipHi_(model.spec.clipHi).step_(step)
			.object_(model.poll)
		//	.boxColor_(this.background)
			.action_({ arg nb;
				model.activeValue_(nb.value).changed(numv);
			});
		if(consumeKeyDowns,{ numv.keyDownAction = {nil}; });
	}
	scroll_{ arg state;
		numv.scroll_(state);
	}
	step_{ arg val;
		numv.step_(val);
	}
	step { 
		^numv.step;
	}
	shift_step_ { arg val=0.1;
		numv.shift_step_(val);
	}
	shift_step {
		^numv.shift_step;
	}
	ctrl_step_ { arg val=10.0;
		numv.ctrl_step_(val);
	}
	ctrl_step {
		^numv.ctrl_step;
	}
	update {arg changed,changer;
		{
			if(changer !== numv,{
				numv.value_(model.poll);
			});
			nil
		}.defer;
	}
	background { ^Color.blue(0.5,0.3); }
}

KrSNBoxEditorGui : SNBoxEditorGui {
	knobColor { ^Color.blue(0.5,0.5); }
}

IrSNBoxEditorGui : SNBoxEditorGui {
	knobColor { ^Color.blue(0.0,0.1); }
}
