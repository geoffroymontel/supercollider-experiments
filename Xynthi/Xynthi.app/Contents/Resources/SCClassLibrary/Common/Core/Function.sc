Function : AbstractFunction {
	var <def, context;
	// a Function is what you get when you write a FunctionDef in your code.
	// it consists of the function's code and the variables in its defining context

	*new { ^this.shouldNotImplement(thisMethod) }
	
	isClosed { ^def.sourceCode.notNil }

	storeOn { arg stream; stream << (def.sourceCode ? "{ \"open Function\" }"); }
	archiveAsCompileString { ^true }
	archiveAsObject { ^true }
	checkCanArchive { if (def.sourceCode.isNil) { "cannot archive open Functions".warn } }
	
	shallowCopy { ^this }
	
	choose { ^this.value }
	
	
	// evaluation
	value { arg ... args; 
		_FunctionValue 
		// evaluate a function with args
		^this.primitiveFailed 
	}
	valueArray { arg ... args;
		_FunctionValueArray 
		// evaluate a function, if the last argument is an array it will be 
		// expanded into separate args.
		^this.primitiveFailed 
	}
	
	valueEnvir { arg ... args; 
		_FunctionValueEnvir
		// evaluate a function with args. 
		// unsupplied argument names are looked up in the currentEnvironment
		^this.primitiveFailed 
	}
	valueArrayEnvir { arg ... args;
		_FunctionValueArrayEnvir 
		// evaluate a function, if the last argument is an array it will be 
		// expanded into separate args.
		// unsupplied argument names are looked up in the currentEnvironment
		^this.primitiveFailed 
	}
	functionPerformList { arg selector, arglist;
		_ObjectPerformList; 
		^this.primitiveFailed 
	}
		
	valueWithEnvir { arg envir;
		var prototypeFrame;
		if(envir.isNil) { ^this.value };
		prototypeFrame = def.prototypeFrame.copy;

		def.argNames.do { |name,i| 
			var val = envir[name];
			val !? { prototypeFrame[i] = val };
		};
		postf("argNames: % prototypeFrame: %\n", def.argNames, prototypeFrame);

		// evaluate a function, using arguments from the supplied environment
		// slightly faster than valueEnvir and does not replace the currentEnvironment
		^this.valueArray(prototypeFrame)
	}	

	numArgs { ^def.numArgs }		// return number of arguments to the function
	numVars { ^def.numVars }		// return number of variables in the function
	varArgs { ^def.varArgs }		// return boolean whether function has ellipsis argument
	
	loop {
		// loop is supported magically by the compiler,
		// thus it can be implemented in terms of itself
		loop { this.value };
	}

	block {
		^this.value {|val| ^val };
	}
//	block {
//		var result;
//		try {
//			result = this.value #{|val| Break(val).throw };
//		}{|error|
//			if (error.class == Break) { 
//				^error.value
//			}{
//				error.throw
//			}
//		}
//		^result
//	}
	
	asRoutine {
		^Routine.new(this)
	}
			
	dup { arg n = 2;
		var array = Array(n);
		n.do {|i| array.add(this.value(i)) };
		^array
	}
	sum { arg n = 2;
		var sum = 0;
		n.do {|i| sum = sum + this.value(i) };
		^sum
	}
	
	defer { arg delta = 0;
		if (delta == 0 and: {this.canCallOS}) {
			this.value
		}{
			AppClock.sched(delta, { this.value; nil })
		}
	}
	
	thunk { ^Thunk(this) }

	// Pattern support
	transformEvent { arg event;
		^this.value(event)
	}

	// ControlView support
	set { arg ... args; ^this.valueArray(args) }
	get { arg prevVal; ^prevVal }
	
	fork { arg clock, quant=0.0, stackSize=64;
		^Routine(this, stackSize).play(clock, quant);
	}
	
	awake { arg beats, seconds, clock;
		var time = seconds; // prevent optimization
		^this.value(beats, seconds, clock)
	}

	cmdPeriod { this.value }	
	

	bench { arg print = true;
		var dt;
		var t0 = Main.elapsedTime;
		this.value;
		dt = Main.elapsedTime - t0;
		if (print) { Post << "time to run: " << dt << " seconds.\n"; }
		^dt
	}
	
	protect { arg handler;
		var result = this.prTry;
		if (result.isException) {
			handler.value(result);
			result.throw;
		}{
			handler.value; // argument should be nil if there was no exception.
			^result
		};
	}
	
	try { arg handler;
		var result = this.prTry;
		if (result.isException) { ^handler.value(result); } { ^result }
	}
	prTry {
		var result;
		var next = thisThread.exceptionHandler;
		thisThread.exceptionHandler = {|error| 
			thisThread.exceptionHandler = next; // pop
			^error 
		};
		result = this.value;
		thisThread.exceptionHandler = next; // pop
		^result
	}
	
	handleError { arg error; ^this.value(error) }

	case { arg ... cases;
		cases = [this] ++ cases;
		cases.pairsDo { | test, trueFunc |
			if (test.value) { ^trueFunc.value };
		};
		if (cases.size.odd) { ^cases.last.value };
		^nil
	}

	r { ^Routine(this) }
	p { ^Prout(this) }
	
	matchItem { arg item;
		^this.value(item)
	}
	
	// multichannel expand function return values
	
	flop {
		if(def.argNames.isNil) { ^this };
		^{ |... args| args.flop.collect(this.valueArray(_)) }
	}

	
	envirFlop {
		var func = this.makeFlopFunc;
		^{ |... args|
			func.valueArrayEnvir(args).collect(this.valueArray(_))
		}
	}
	
	makeFlopFunc {
		if(def.argNames.isNil) { ^this };
		
		^interpret(
				"#{ arg " ++ " " ++ def.argumentString(true) ++ "; " 
				++ "[ " ++ def.argumentString(false) ++ " ].flop };"
				)
	}
	
}

Thunk : AbstractFunction {
	// a thunk is an unevaluated value. 
	// it gets evaluated once and then always returns that value.
	// also known as a "promise" in Scheme.
	// thunks have no arguments.
	var function, value;
	
	*new { arg function;
		^super.newCopyArgs(function)
	}
	value {
		^value ?? { value = function.value; function = nil; value }
	}
	valueArray { ^this.value }
	valueEnvir { ^this.value }
	valueArrayEnvir { ^this.value }
}


