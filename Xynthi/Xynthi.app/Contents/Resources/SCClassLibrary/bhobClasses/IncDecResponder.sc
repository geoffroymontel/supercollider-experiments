IncDecResponder {
	var <>function, <>res, <>src, <>chan, <>num, <>curval, <resp;
	
	*new {|function, res, src, chan, num, initVal|
		^super.new.init(function, res, src, chan, num, initVal);
	}
	
	init {|argfunction, argres, argsrc, argchan, argnum, arginitVal|
		function=argfunction;
		res=argres;
		chan=argchan;
		num=argnum;
		curval=arginitVal;
		resp=CCResponder(
			{|src, chan, num, val|
				(val <= 64).if({
					this.curval=(res * val + this.curval).max(0).min(1);
				}, {
					this.curval=(this.curval - (val - 64 * res)).max(0).min(1);
				});
				this.function.value(src, chan, num, this.curval);
			},
			src,
			chan,
			num
		);
	}
	
	remove {
		resp.remove;
	}
}		
		
IncDecResponderBank {
	classvar resIndex=0, specIndex=1, funcIndex=2, valIndex=3;
	var <states, <resp;
	
	*new {|src, chan ...args|
		^super.new.init(src, chan, args);
	}
	
	init {|src, chan, args|
		var cc, res, spec, func, initVal, nums, length;
		args=args.asArray;
		length=args.size;
		(length % 5 != 0).if({ "Invalid arg list: cc, res, spec, func, initVal, ....".postln; ^false; });
		// cc#, resolution, spec, func, initVal
		states=Dictionary.new;
		nums=List.new;
		forBy(0, length-1, 5, {|i|
			var ip1;
			ip1=i + 1;
			spec=args[ip1 + specIndex].asSpec;
			states.add(args[i] -> [args[ip1 + resIndex], spec, args[ip1 + funcIndex], spec.unmap(args[ip1 + valIndex])]);
			nums.add(args[i]);
		});
		resp=CCResponder(
			{|src, chan, num, val|
				var cc_data, curval, res, spec, func;
				cc_data=this.states.at(num);
				res=cc_data.at(resIndex);
				spec=cc_data.at(specIndex);
				func=cc_data.at(funcIndex);
				curval=cc_data.at(valIndex);
				(val <= 64).if({
					curval=(res * val + curval).max(0).min(1);
				}, {
					curval=(curval - (val - 64 * res)).max(0).min(1);
				});
				func.value(src, chan, num, spec.map(curval));
				cc_data.put(valIndex, curval);
			},
			src,
			chan,
			nums
		);
	}
	
	remove {
		resp.remove;
	}
	
	updateValue {|cc_num, val|
		var spec;
		spec=states.at(cc_num).at(specIndex);
		this.states.at(cc_num).put(valIndex, spec.unmap(val));
	}
	
	updateMultipleValues {|...args|
		var length;
		args=args.asArray;
		length=args.size;
		(length % 2 != 0).if({ "Invalid arg list: cc_num, val, ...".postln; ^false; });
		forBy(0, length-1, 2, {|i|
			this.updateValue(args[i], args[i + 1]);
		});
	}
	
	updateResolution {|cc_num, val|
		this.states.at(cc_num).put(resIndex, val);
	}
	
	updateMultipleResolutions {|...args|
		var length;
		args=args.asArray;
		length=args.size;
		(length % 2 != 0).if({ "Invalid arg list: cc_num, val, ...".postln; ^false; });
		forBy(0, length-1, 2, {|i|
			this.updateResolutions(args[i], args[i + 1]);
		});
	}
	
	updateSpec {|cc_num, val|
		this.states.at(cc_num).put(specIndex, val.asSpec);
	}
	
	updateMultipleSpecs {|...args|
		var length;
		args=args.asArray;
		length=args.size;
		(length % 2 != 0).if({ "Invalid arg list: cc_num, val, ...".postln; ^false; });
		forBy(0, length-1, 2, {|i|
			this.updateSpec(args[i], args[i + 1]);
		});
	}
	
	updateFunc {|cc_num, val|
		this.states.at(cc_num).put(funcIndex, val);
	}
	
	updateMultipleFuncs {|...args|
		var length;
		args=args.asArray;
		length=args.size;
		(length % 2 != 0).if({ "Invalid arg list: cc_num, val, ...".postln; ^false; });
		forBy(0, length-1, 2, {|i|
			this.updateFunc(args[i], args[i + 1]);
		});
	}
}