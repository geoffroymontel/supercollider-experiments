//+ Object {
//
//	pl { this.asString.postln; }
//	pcs { this.asCompileString.postln }
//
//}



SynthDefC2 : SynthDef {
	
	var <ugenGraphFuncString;
	
	build { arg ugenGraphFunc, rates, prependArgs;
	
		ugenGraphFuncString = ugenGraphFunc.asCompileString;
		
		protect {
			this.initBuild;
			this.buildUgenGraph(ugenGraphFunc, rates, prependArgs);
			this.finishBuild;
		} {
			UGen.buildSynthDef = nil;
		}
	}


}




RandBy { 

	*new { |val = 1, dev = 0|

		^Rand(val * (1 - dev), val * (1 + dev))
		
	}

}

TRandBy { 

	*ar { |val = 1, dev = 0, trig = 1|

		^TRand.ar(val * (1 - dev), val * (1 + dev), trig)
		
	}
	
	*kr { |val = 1, dev = 0, trig = 1|

		^TRand.kr(val * (1 - dev), val * (1 + dev), trig)
		
	}


}

+ UGen {

	rangeBy { |val = 1.0, dev = 0.0|
	
		^this.range(val * (1 - dev), val * (1 + dev));
	
	
	}

}

+ ControlSpec {

	map { arg value;
	
		// maps a value from [0..1] to spec range
		
		case
			{value.isArray}
			{
			value.do { |item, index|
			
				value[index] = warp.map(item.clip(0.0, 1.0)).round(step);
			};
			
			}
			{
			value = warp.map(value.clip(0.0, 1.0)).round(step);
			};
			
		^value;
	}

	mapWithoutClip { arg value;
	
		// maps a value from [0..1] to spec range
		
		case
			{value.isArray}
			{
			value.do { |item, index|
			
				value[index] = warp.map(item).round(step);
			};
			
			}
			{
			value = warp.map(value).round(step);
			};
			
		^value;
	}
	
	
	unmap { arg value;
		// maps a value from spec range to [0..1]
		
		case
			{value.isArray}
			{
			value.do { |item, index|
			
				value[index] = warp.unmap(item.round(step).clip(clipLo, clipHi));
			};
			
			}
			{
			value = warp.unmap(value.round(step).clip(clipLo, clipHi));
			};
			
		^value;
		
	}
	

}

+ TwoWayIdentityDictionary {

	removeAt { |key|
	
		var obj;
		obj = this.at(key);
	
		idToObj.removeAt(key);
		objToID.removeAt(obj);
	
	}

}

+ Synth {

	*newBundle { arg defName, args, target, addAction=\addToHead, time = 0.0;
		var synth, server, addNum, inTarget;
		
		
		inTarget = target.asTarget;
		server = inTarget.server;
		addNum = addActions[addAction];
		synth = this.basicNew(defName, server);

		if((addNum < 2), { synth.group = inTarget; }, { synth.group = inTarget.group; });
//		server.sendMsg(59, //"s_newargs"
//			defName, synth.nodeID, addNum, inTarget.nodeID,
//			*Node.setnMsgArgs(*args));
		server.sendBundle(
			time,
			["/s_new", defName, synth.nodeID, addNum, inTarget.nodeID] ++ args.asOSCArgArray
		);
		^synth
	}
	
	timed_setn { arg time, startIndex, args;
//		server.sendMsg(*this.setnMsg(*args));
		server.sendBundle(time, ["/n_setn", nodeID, startIndex] ++ args);
	}

}

+ SCView {

	background_ { arg color;
		case
			{color.class == Symbol}
			{color = C2_Color(color)};
		background = color;
		this.setProperty(\background, color)
	}
	
//	font_ { }
	
	font2_ { |name, size|
		
		this.font_(Font(name, size));
	
	
	}

}

+ Array {

	autolace { 
	
		var length;
		length = this[0].size * 2;
		^this.lace(length);

	}
	
}

+ Signal {

	asArray {
	
		^this.collect( {|i| i});
	
	}

}

//+ SCContainerView {
//
//	init { |argParent, argBounds, argScaledBounds|
//		super.init(argParent, argBounds);
//		this.setProperty(\relativeOrigin, relativeOrigin);
//		this.childInit(argBounds, argScaledBounds);
//	}
//	
//	childInit {}
//
//}


