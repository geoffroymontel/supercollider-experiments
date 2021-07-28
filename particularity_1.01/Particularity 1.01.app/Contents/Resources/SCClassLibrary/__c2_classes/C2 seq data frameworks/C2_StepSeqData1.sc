C2_StepSeqData1 {

	// very simple, a value (0 - 1) a duration and a curve
	// vals get interpreted through spec

	var noOfSteps, <>vals, <>durs, <>spec;
	var <currentStep = 0;
	var <>loopStatus = 1;

	*new { |noOfSteps, spec| ^super.new.init(noOfSteps, spec) }
	
	init { |argNoOfSteps = 32, argSpec|
	
		noOfSteps = argNoOfSteps;
		vals = Array.series(noOfSteps, 0, 0);
		durs = Array.series(noOfSteps, 1, 0);
		
		spec = argSpec ? [0, 1, \linear].asSpec;
		
	}
	
	getNext {
	
		var output;
	//	output = [spec.map(vals[currentStep]), durs[currentStep]];
		output = vals[currentStep];
		case
			{loopStatus == 1}
			{currentStep = (currentStep + 1).wrap(0, noOfSteps - 1)}
			{currentStep = (currentStep + 1).clip(0, noOfSteps - 1)};
		^output;
	
	}
	
	reset {
	
		currentStep = 0;
	
	}
	
	setData { |args|
	
		#noOfSteps, vals = args;
		
		// , durs, spec = args
	
	}
	
	getData {
	
		^[noOfSteps, vals];
		
		// , durs, spec
	
	}



}


//	setVal { |index = 0, val = 0|
//	
//		index = index.clip(0, noOfSteps - 1);
//		vals[index] = val.clip(0, 1);
//	
//	}
//	
//	getVal { |index = 0|
//		
//		index = index.clip(0, noOfSteps - 1);
//		^vals[index];
//	}
//	
//	setDur { |index = 0, dur = 1|
//	
//		index = index.clip(0, noOfSteps - 1);
//		durs[index] = dur.clip(0, inf);
//	
//	}
//	
//	getDur { |index = 0|
//		
//		index = index.clip(0, noOfSteps - 1);
//		^durs[index];
//	}
