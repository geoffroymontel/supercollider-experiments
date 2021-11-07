C2PL_Seq {

	var <>link, data, routine, whichRoutine = 0, <playStatus = 0;
	var beats;
	var currentValues;
	var noOfSteps = 64;
	var speedMult = 1.0;
	
	liveSpeedMult { |argSpeedMult = 1.0|
	
		speedMult = argSpeedMult;
	
	}

	*new { ^super.new.init }
	
	setLoopStatus { |status = 1|
	
		data.do { |item, index|
		
			data[index].do { |item2|
			
				item2.loopStatus_(status);
				
			}
			
		};
	
	}
	
	reset {
	
		data.do { |item, index|
		
			data[index].do { |item2|
			
				item2.reset;
				
			}
			
		};
	
	
	}

	init {
	
	// micro, meta
		data = 
			[
			[
			C2_StepSeqData1(noOfSteps), C2_StepSeqData1(noOfSteps),
			C2_StepSeqData1(noOfSteps)
			],
			[
			C2_StepSeqData1(noOfSteps), C2_StepSeqData1(noOfSteps),
			C2_StepSeqData1(noOfSteps)
			]
			];
			
		beats = [2, 8];
		currentValues = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
		this.initRoutine;
	
	
	}
	
	getData {
		
		^[data.flatten.collect( { |i| i.getData } ), beats.deepCopy, playStatus];
	
	}
	
	setData { |args, liveRecallFlag = 0|
	
		var seqData;
		args = args.deepCopy;
		#seqData, beats = args;
		
		seqData = seqData.clump(3);
		data.do { |item, index|
			data[index].do { |item2, index2|
				data[index][index2].setData(seqData[index][index2]);
			}
		};
		if(liveRecallFlag == 1) {this.startStop(args[2] ? 0, 0)};
	
	}
	
	sendCurrentValues {

		link.updateFromSeq(currentValues, data[0][0].currentStep / noOfSteps, data[1][0].currentStep / noOfSteps);
		
	}
	
	initRoutine {
	
		routine = Array.newClear(2);
		
		for(0, 1)
			{
			|c|
			routine[c] = Array.newClear(4);
			for(0, 3)
				{
				|c2|
				routine[c][c2] = 
					Routine({
						
						var theseValues, nextTime;
						for(0, 2) { |dc| data[c][dc].reset };
					
						9999999.do { |sc|
						
							for(0, 2) { |i| currentValues[i + (c * 3)] = data[c][i].getNext };
							this.sendCurrentValues;
							nextTime = ((60 / link.bpm) * beats[c]) / noOfSteps;
							(nextTime * speedMult).wait;
						
						};
						
					});
					
				};
				
			};
	
	}
	
	startStop { |instruction|
		
		if(instruction == playStatus) {^nil};
	
		if(instruction == nil, {instruction = 1 - playStatus});

		case
			{instruction == 1}
			{
			for(0, 1)
				{
				|c|
				routine[c][whichRoutine].reset; 
				SystemClock.play(routine[c][whichRoutine]);
				};
			playStatus = 1;
			}
			{instruction == 0}
			{
			for(0, 1)
				{
				|c|
				routine[c][whichRoutine].stop;
				};
			whichRoutine = (whichRoutine + 1).wrap(0, 3);
			playStatus = 0;
			};

	
	}
 
	
	setSingleData { |routineType, dataType, vals|
	
		// routineType: 0 (micro) or 1 (meta)
		// dataType: 0 - 2
		
		data[routineType][dataType].vals = vals.deepCopy;
		
	}
	
	getSingleData { |routineType, dataType|
	
		// routineType: 0 (micro) or 1 (meta)
		// dataType: 0 - 2
		
		^data[routineType][dataType].vals;
		
	}

	
	setDurBeats { |routineType, argBeats|
	
		beats[routineType] = argBeats;
		
	}
	
	getDurBeats { |routineType|
	
		^beats[routineType];
			
	
	}


}





