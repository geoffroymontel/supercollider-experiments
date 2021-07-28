
UGen : AbstractFunction {
	classvar <>buildSynthDef; // the synth currently under construction
	var <>synthDef;
	var <>inputs;
	var <>rate = 'audio';

	var <>synthIndex = -1, <>specialIndex=0;

	var <>antecedents, <>descendants; // topo sorting

	// instance creation
	*new1 { arg rate ... args;
		if (rate.isKindOf(Symbol).not) { Error("rate must be Symbol.").throw };
		^super.new.rate_(rate).addToSynth.init( *args )
	}
	*newFromDesc { arg rate, numOutputs, inputs, specialIndex;
		^super.new.rate_(rate).inputs_(inputs).specialIndex_(specialIndex)
	}
 	*multiNew { arg ... args;
		^this.multiNewList(args);
	}

	*multiNewList { arg args;
		var size = 0, newArgs, results;
		args = args.asUGenInput(this);
		args.do({ arg item;
			(item.class == Array).if({ size = max(size, item.size) });
		});
		if (size == 0) { ^this.new1( *args ) };
		newArgs = Array.newClear(args.size);
		results = Array.newClear(size);
		size.do({ arg i;
			args.do({ arg item, j;
				newArgs.put(j, if (item.class == Array, { item.wrapAt(i) },{ item }));
			});
			results.put(i, this.multiNewList(newArgs));
		});
		^results
	}

 	init { arg ... theInputs;
 		// store the inputs as an array
 		inputs = theInputs;
 	}
 	copy {
 		// you can't really copy a UGen without disturbing the Synth.
 		// Usually you want the same object. This makes .dup work
 		^this
 	}

 	madd { arg mul = 1.0, add = 0.0;
 		^MulAdd(this, mul, add);
 	}
 	range { arg lo = 0.0, hi = 1.0;
 		var mul, add;
		if (this.signalRange == \bipolar, {
			mul = (hi - lo) * 0.5;
			add = mul + lo;
		},{
			mul = (hi - lo) ;
			add = lo;
		});
 		^MulAdd(this, mul, add);
 	}
 	exprange { arg lo = 0.01, hi = 1.0;
 		var rate = if(this.rate == \audio) { \audio } { \control };
		^if (this.signalRange == \bipolar) {
			this.linexp(-1, 1, lo, hi)
		} {
			this.linexp(0, 1, lo, hi)
		};
 	}

 	unipolar { arg mul = 1;
 		^this.range(0, mul)
 	}

 	bipolar { arg mul = 1;
 		^this.range(mul.neg, mul)
  	}

 	clip { arg lo,hi;
 		^if(rate == \audio) {
 			Clip.ar(this, lo, hi)
 		}{
 			if(rate == \demand) {
 				max(lo, min(hi, this))
 			} {
 				Clip.kr(this, lo, hi)
 			}
 		}
 	}

 	fold { arg lo,hi;
 		^if(rate == \audio) {
 			Fold.ar(this, lo, hi)
 		}{
 			if(rate == \demand) {
 				this.notYetImplemented(thisMethod)
 			} {
 				Fold.kr(this, lo, hi)
 			}
 		}
 	}
 	wrap { arg lo,hi;
 		^if(rate == \audio) {
 			Wrap.ar(this, lo, hi)
 		}{
 			if(rate == \demand) {
 				this.notYetImplemented(thisMethod)
 			} {
 				Wrap.kr(this, lo, hi)
 			}
 		}
 	}

 	minNyquist { ^min(this, SampleRate.ir * 0.5) }

	lag { arg t1=0.1, t2;
		^if(t2.isNil) {
			Lag.multiNew(this.rate, this, t1)
		} {
			LagUD.multiNew(this.rate, this, t1, t2)
		}
	}
	lag2 { arg t1=0.1, t2;
		^if(t2.isNil) {
			Lag2.multiNew(this.rate, this, t1)
		} {
			Lag2UD.multiNew(this.rate, this, t1, t2)
		}
	}
	lag3 { arg t1=0.1, t2;
		^if(t2.isNil) {
			Lag3.multiNew(this.rate, this, t1)
		} {
			Lag3UD.multiNew(this.rate, this, t1, t2)
		}
	}

	lagud { arg lagTimeU=0.1, lagTimeD=0.1;
		^LagUD.multiNew(this.rate, this, lagTimeU, lagTimeD)
	}
	lag2ud { arg lagTimeU=0.1, lagTimeD=0.1;
		^Lag2UD.multiNew(this.rate, this, lagTimeU, lagTimeD)
	}
	lag3ud { arg lagTimeU=0.1, lagTimeD=0.1;
		^Lag3UD.multiNew(this.rate, this, lagTimeU, lagTimeD)
	}

	prune { arg min, max, type;
		switch(type,
			\minmax, {
				^this.clip(min, max);
			},
			\min, {
				^this.max(min);
			},
			\max, {
				^this.min(max);
			}
		);
		^this
	}
	linlin { arg inMin, inMax, outMin, outMax, clip;
		^LinLin.multiNew(this.rate, this.prune(inMin, inMax, clip),
						inMin, inMax, outMin, outMax)
	}
	linexp { arg inMin, inMax, outMin, outMax, clip;
		^LinExp.multiNew(this.rate, this.prune(inMin, inMax, clip),
						inMin, inMax, outMin, outMax)
	}
	explin { arg inMin, inMax, outMin, outMax, clip;
		^(log(this.prune(inMin, inMax, clip)/inMin))
			/ (log(inMax/inMin)) * (outMax-outMin) + outMin; // no separate ugen yet
	}
	expexp { arg inMin, inMax, outMin, outMax, clip;
		^pow(outMax/outMin, log(this.prune(inMin, inMax, clip)/inMin)
			/ log(inMax/inMin)) * outMin;
	}

	signalRange { ^\bipolar }
	@ { arg y; ^Point.new(this, y) } // dynamic geometry support

	addToSynth {
		synthDef = buildSynthDef;
		if (synthDef.notNil, { synthDef.addUGen(this) });
	}

	collectConstants {
		inputs.do({ arg input;
			if (input.isNumber, { synthDef.addConstant(input.asFloat)  });
		});
	}

	isValidUGenInput { ^true }
	asUGenInput { ^this }
	asControlInput { Error("can't set a control to a UGen").throw }
	numChannels { ^1 }


	checkInputs { ^this.checkValidInputs }
	checkValidInputs {
		inputs.do({arg in,i;
			var argName;
			if(in.isValidUGenInput.not,{
				argName = this.argNameForInputAt(i) ? i;
				^"arg: '" ++ argName ++ "' has bad input:" + in;
			})
		});
		^nil
	}
	checkSameRateAsFirstInput {
 		if (rate !== inputs.at(0).rate) {
 			^("first input is not" + rate + "rate: " + inputs.at(0) + inputs.at(0).rate);
 		};
 		^this.checkValidInputs
 	}

	argNameForInputAt { arg i;
		var method = this.class.class.findMethod(this.methodSelectorForRate);
		if(method.isNil or: {method.argNames.isNil},{ ^nil });
		^method.argNames.at(i + this.argNamesInputsOffset)
	}
	argNamesInputsOffset { ^1 }
	dumpArgs {
		" ARGS:".postln;
		inputs.do({ arg in,ini;
			("   " ++ (this.argNameForInputAt(ini) ? ini.asString)++":" + in + in.class).postln
		});
	}
	degreeToKey { arg scale, stepsPerOctave=12;
		^DegreeToKey.kr(scale, this, stepsPerOctave)
	}

	outputIndex { ^0 }
	writesToBus { ^false }

	poll { arg trig = 10, label, trigid = -1;
          ^Poll(trig, this, label, trigid)
	}

	dpoll { arg label, run = 1, trigid = -1;
		^Dpoll(this, label, run, trigid)
	}

	checkBadValues { arg id = 0, post = 2;
			// add the UGen to the tree but keep "this" as the output
		CheckBadValues.perform(this.methodSelectorForRate, this, id, post);
	}

	*methodSelectorForRate { arg rate;
		if(rate == \audio,{ ^\ar });
		if(rate == \control, { ^\kr });
		if(rate == \scalar, {
			if(this.class.class.respondsTo(\ir),{
				^\ir
			},{
				^\new
			});
		});
		if(rate == \demand, { ^\new });
		^nil
	}

	*replaceZeroesWithSilence { arg array;
 		// this replaces zeroes with audio rate silence.
 		// sub collections are deep replaced
 		var numZeroes, silentChannels, pos = 0;

 		numZeroes = array.count({ arg item; item == 0.0 });
 		if (numZeroes == 0, { ^array });

 		silentChannels = Silent.ar(numZeroes).asCollection;
 		array.do({ arg item, i;
 			var res;
 			if (item == 0.0, {
 				array.put(i, silentChannels.at(pos));
 				pos = pos + 1;
 			}, {
 				if(item.isSequenceableCollection, {
 					res = this.replaceZeroesWithSilence(item);
 					array.put(i, res);
 				});
 			});
 		});
 		^array;
 	}


	// PRIVATE
	// function composition
	composeUnaryOp { arg aSelector;
		^UnaryOpUGen.new(aSelector, this)
	}
	composeBinaryOp { arg aSelector, anInput;
		if (anInput.isValidUGenInput, {
			^BinaryOpUGen.new(aSelector, this, anInput)
		},{
			anInput.performBinaryOpOnUGen(aSelector, this);
		});
	}
	reverseComposeBinaryOp { arg aSelector, aUGen;
		^BinaryOpUGen.new(aSelector, aUGen, this)
	}
	composeNAryOp { arg aSelector, anArgList;
		^thisMethod.notYetImplemented
	}

	// complex support

	asComplex { ^Complex.new(this, 0.0) }
	performBinaryOpOnComplex { arg aSelector, aComplex; ^aComplex.perform(aSelector, this.asComplex) }

	if { arg trueUGen, falseUGen;
		^(this * (trueUGen - falseUGen)) + falseUGen;
	}

	rateNumber {
		if (rate == \audio, { ^2 });
		if (rate == \control, { ^1 });
		if (rate == \demand, { ^3 });
		^0 // scalar
	}
	methodSelectorForRate {
		if(rate == \audio,{ ^\ar });
		if(rate == \control, { ^\kr });
		if(rate == \scalar, {
			if(this.class.class.respondsTo(\ir),{
				^\ir
			},{
				^\new
			});
		});
		if(rate == \demand, { ^\new });
		^nil
	}
	writeInputSpec { arg file, synthDef;
		file.putInt16(synthIndex);
		file.putInt16(this.outputIndex);
	}
	writeOutputSpec { arg file;
		file.putInt8(this.rateNumber);
	}
	writeOutputSpecs { arg file;
		this.writeOutputSpec(file);
	}
	numInputs { ^inputs.size }
	numOutputs { ^1 }

	name {
		^this.class.name.asString;
	}
	writeDef { arg file;
		//[\WR, this.class.name, rate, this.numInputs, this.numOutputs].postln;
		file.putPascalString(this.name);
		file.putInt8(this.rateNumber);
		file.putInt16(this.numInputs);
		file.putInt16(this.numOutputs);
		file.putInt16(this.specialIndex);
		// write wire spec indices.
		inputs.do({ arg input;
			input.writeInputSpec(file, synthDef);
		});
		this.writeOutputSpecs(file);
		//[this.class.name, file.length].postln;
	}

///////////////////////////////////////////////////////////////

	initTopoSort {
		inputs.do({ arg input;
			if (input.isKindOf(UGen), {
				antecedents.add(input.source);
				input.source.descendants.add(this);
			});
		})
	}

	makeAvailable {
		if (antecedents.size == 0, {
			synthDef.available = synthDef.available.add(this);
		});
	}

	removeAntecedent { arg ugen;
		antecedents.remove(ugen);
		this.makeAvailable;
	}

	schedule { arg outStack;
		descendants.reverseDo({ arg ugen;
			ugen.removeAntecedent(this);
		});
		^outStack.add(this);
	}

	optimizeGraph {}

	dumpName {
		^synthIndex.asString ++ "_" ++ this.class.name.asString
	}
}

MultiOutUGen : UGen {
	// a class for UGens with multiple outputs
	var <channels;

	*newFromDesc { arg rate, numOutputs, inputs;
		^super.new.rate_(rate).inputs_(inputs).initOutputs(numOutputs, rate)
	}

	initOutputs { arg numChannels, rate;
		channels = Array.fill(numChannels, { arg i;
			OutputProxy(rate, this, i);
		});
		if (numChannels == 1, {
			^channels.at(0)
		});
		^channels
	}

	numOutputs { ^channels.size }
	writeOutputSpecs { arg file;
		channels.do({ arg output; output.writeOutputSpec(file); });
	}
	synthIndex_ { arg index;
		synthIndex = index;
		channels.do({ arg output; output.synthIndex_(index); });
	}

}

OutputProxy : UGen {
	var <>source, <>outputIndex, <>name;
	*new { arg rate, itsSourceUGen, index;
		^super.new1(rate, itsSourceUGen, index)
	}
	addToSynth {
		synthDef = buildSynthDef;
	}
	init { arg argSource, argIndex;
		source = argSource;
		outputIndex = argIndex;
		synthIndex = source.synthIndex;
	}

	dumpName {
		^this.source.dumpName ++ "[" ++ outputIndex ++ "]"
	}
}
