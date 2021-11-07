C2PL_Synth {

	// things here are gettable and settable but only for the benefit of the gui
	// if you mess with them from outside you might be in trouble
	var <>noOfSteps = 64, <>freqRange, <harmonicsArray;
	
	var <synthRunningStatus = 0, <seqRunningStatus = 0;
	
	// link to the gui
	var <>link;
		
	var spec_envMult, routines;
	var server, buf_wave, pulsarFunc, <signal_wave, <envArray, <>buf_env, waveBufDur, envBufDur, synth_pulsar, synth_seq;
	var <signalMode = 0;
	// signalMode: 0 - use harmonics to "build" wave, 1 - use "drawn" or imported buffer values directly
	var noOfFrames = 2048, envNoOfFrames = 64;
	var <noOfSpreads = 1, <spreadWidth = 0.0, <spreadAmpReduce = 0.5, <splay = 0.0;
	
	var <>idNo, <synthVals, xloc, spreadVols, synthParamSymbols, dontChangeIndexArray;
	var seq;
	var <freqEnvArray, buf_freqEnv;
	var fundFreqMult = 1.0, formFreqMult = 1.0, panOffset = 0.0, ampMult = 1.0, <probMult = 1.0;
	var seqParamSymbols, liveMixerParamSymbols;
	var totalNoOfSynths;
	var <>rndPhaseStatus = 0;
	var <>picAction;
	var muteStatus = 0;
	var synthDefNames, <currentSynthDefIndex = 0;
	
	var volDistribution;
	
	var <bufMode = 0;
	// 0 - use harmonics/draw wave, 1 - use soundfile
	
	var <soundfileBufnum, <soundfilePath;
	
	// which parameters are being sequenced?
	var <>seqParamNos;
	
	// what are the specs of the sequence altering the params?
	var seqParamSpecRanges;
	var seqParamUseMidiratioFlag, seqParamUseFreqRangeFlag, seqParamMathInstruction;
	
	// stuff to do with the sequencer
	var <>defaultOnStop = 1, <>resetOnSetPatch = 1, <loopStatus = 1;
	
	var <>harmonics_rndPhaseFlag = 0;
	
	var <group;
	
	var defaultPatch;
	
	group_ { |g|
	
		group = g;
		
	}
	
	loopStatus_ { |status|
	
		loopStatus = status;
		seq.setLoopStatus(status);
		
	}
	
	setFilePath { |fp|
	
	// fp should be a string with the path to the soundfile
	
		soundfilePath = fp;
		// addSoundFile returns a buffer number
		soundfileBufnum = link.addSoundFile(fp);
		this.setSynthVals;
		{this.guiUpdate}.defer;
	
	}
	
	setBufMode { |m|
	
		if(soundfilePath != nil)
			{bufMode = m}
			{bufMode = 0};
		this.setSynthVals;
		// then if synth is playing, update all synths bufnums
		
	}
	
	bpm { ^link.bpm }

	*new { |server, defaultPatch| ^super.new.init(server, defaultPatch) }
	
	init { |argServer, argDefaultPatch|
	
		server = argServer ? Server.internal;
		
		synthDefNames = C2PL_SynthDef.names;
		synthDefNames.do { |item, index| synthDefNames[index] = "C2PL_" ++ synthDefNames[index]; };
		
		synth_pulsar = Array.newClear(65);
	
		freqRange = 24; 
		spec_envMult = [1, 8, \exponential].asSpec;
	
			
		harmonicsArray = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		envArray = Array.series(64, 1.0, 0);
		envArray[envArray.lastIndex] = 0;
		
		freqEnvArray = Array.series(64, 0.0, 0);
		
		defaultPatch = argDefaultPatch.deepCopy;
		synthVals = argDefaultPatch;
		
		synthParamSymbols = 
			[
			\startPos, \trigFreq, \grainFreqMult,
			\envRateMult,
			\fmRatio, \fmAmt,
			\allFluxAmt,
			\probability,
			\pan, \amp
			];

		seqParamNos = [1, 5, 6, 1, 5, 6];
					
		seqParamSymbols = 
			[
			\seq_startPosOffset, \seq_trigFreqMult, \seq_grainMult, 
			\seq_fmRatioMult, \seq_fmAmtMult, \seq_ampMult, \seq_probMult, \seq_panOffset
			];
		seqParamSpecRanges = 
			[
			[-1.0, 1.0], [0, 0], [-12, 12],
			[-36, 36], [0.0, 2.0], [0.0, 2.0], [0.0, 2.0],
			[-1.0, 1.0]
			];
		
		seqParamUseMidiratioFlag = [0, 1, 1, 1, 0, 0, 0, 0];
		seqParamUseFreqRangeFlag = [0, 1, 1, 0, 0, 0, 0, 0];
		seqParamMathInstruction = [\add, \add, \add, \add, \mul, \mul, \mul, \add];
		
		liveMixerParamSymbols = [\live_allFreqMult, \live_panOffset, \live_ampMult ];
		
		seq = C2PL_Seq.new;
		seq.link_(this);
		for(0, 1)
			{
			|c|
			this.setSeqData(c, 0, Array.fill(64, {0.5}));
			this.setSeqData(c, 1, Array.fill(64, {0.5}));
			this.setSeqData(c, 2, Array.fill(64, {0.5}));
			};
			
		this.initBuf;
		this.calcSpread;
	
	}
	
	initBuf {
	
	// C2P_Pulsar
	
		server.waitForBoot({
			
			buf_wave = Buffer.alloc(server, noOfFrames, 1);
			waveBufDur = noOfFrames / server.sampleRate;
			signal_wave = Signal.sineFill(buf_wave.numFrames, harmonicsArray);
			buf_wave.loadCollection(signal_wave);
			
			buf_env = Buffer.alloc(server, envNoOfFrames, 1);
			envBufDur = envNoOfFrames / server.sampleRate;
			
			buf_freqEnv = Buffer.alloc(server, envNoOfFrames, 1);			this.guiUpdate;	
		});
	
	
	}

	updateFromSeq { |args, microPos, macroPos|
	
	// all of those values will be arrays with pairs of values
		var trigFreqMult, envRateMult, grainFreqMult, freqSpec;
		var results;
		
		link.updateSeqProgress(idNo, [microPos, macroPos]);
			
		// start off with values that will result in no change at all
		// these values already conform to the specs (and before midiratio)
		results = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0];
		
		picAction.value(args);
		if(synthRunningStatus == 0) {^nil};
		
		args.do { |item, index|
		
			var thisParamIndex, thisValue;
			
			thisParamIndex = seqParamNos[index];
		
			case
				{seqParamUseFreqRangeFlag[thisParamIndex] == 1}
				{thisValue = [freqRange.neg, freqRange].asSpec.map(args[index])}
				{thisValue = seqParamSpecRanges[thisParamIndex].asSpec.map(args[index])};

			case
				{seqParamMathInstruction[seqParamNos[index]] == \mul}
				{results[thisParamIndex] = results[thisParamIndex] * thisValue}
				{seqParamMathInstruction[seqParamNos[index]] == \add}
				{results[thisParamIndex] = results[thisParamIndex] + thisValue};
		
		};
		results.do { |item, index|
		
			if(seqParamUseMidiratioFlag[index] == 1)
				{results[index] = results[index].midiratio};
				
		};
		
		results = [seqParamSymbols, results].autolace;
		
		65.do { |index|
		
			if(index < totalNoOfSynths)
				{synth_pulsar[index].set(*results)}
				{synth_pulsar[index].free};
		};

	
	}	
	
	setSeqDefault {
	
	//	var results;
		
		this.updateFromSeq([0.5, 0.5, 0.5, 0.5, 0.5, 0.5], 0.0, 0.0);
	
//		results = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
//		results.do { |item, index|
//		
//			if(seqParamUseMidiratioFlag[index] == 1)
//				{results[index] = results[index].midiratio};
//				
//		};	
//		results = [seqParamSymbols, results].autolace;
//		65.do { |index|
//		
//			if(index < totalNoOfSynths)
//				{synth_pulsar[index].set(*results)}
//				{synth_pulsar[index].free};
//		};
	
	}
	
	updateFromLiveMixer { |live_allFreqMult, live_panOffset, live_ampMult, live_speedMult|
	
		var lacedParams; 
	
		if(synthRunningStatus == 0) {^nil};
		
		lacedParams = [liveMixerParamSymbols, [live_allFreqMult, live_panOffset, live_ampMult]].autolace;
			
		65.do { |index|
		
			if(index < totalNoOfSynths)
				{
				synth_pulsar[index].set(*lacedParams);
				}
				{
				synth_pulsar[index].free;
				synth_pulsar[index] = nil;
				};
		};
		
		seq.liveSpeedMult(live_speedMult);

	
	}
	
	setSynthVals { |argVals|
	
		var thisSynthVals, thisSynthValsBasis, ampScaling;
		thisSynthVals = this.calcSynthParams(argVals);
		
		if(synthRunningStatus == 0) {^nil};
	
		65.do { |index|
		
			if(index < totalNoOfSynths)
				{
				synth_pulsar[index].set(
					*(
					thisSynthVals[index] ++ 
					[
					\mute, muteStatus, 
					\bufnum, [buf_wave.bufnum, soundfileBufnum][bufMode]
					]
					)
				);
				
				}
				{
				synth_pulsar[index].free;
				synth_pulsar[index] = nil;
				};
		};

	}
	
	calcSpread {
	
		var pairCount, increment, lo, hi;
		
		totalNoOfSynths = (1 + ((noOfSpreads - 1) * 2)).asInt;
		volDistribution = [1];
	}
	
	calcSynthParams { |basis|
		
		var thisSynthVals, ampScaling;
		var panStart, panEnd, panIncrement;

		if(basis == nil) {basis = synthVals} {synthVals = basis.deepCopy};

		ampScaling = (1 / (noOfSpreads * 0.35));

		totalNoOfSynths = (1 + ((noOfSpreads - 1) * 2)).asInt;
		thisSynthVals = Array.newClear(totalNoOfSynths);
		// amp 

		thisSynthVals[0] = [synthParamSymbols, basis.deepCopy.put(9, basis[9] * volDistribution[0] * ampScaling) ].autolace;

		panStart = basis[8] - (splay * 0.5);
		panEnd = basis[8] + (splay * 0.5);
		panIncrement = (panEnd - panStart) / totalNoOfSynths;
		

//		if(noOfSpreads > 1)
//			{
//			for(1, totalNoOfSynths - 1)
//				{
//				|c|
//				var ampIndex;
//				ampIndex = (((c + 1) / 2)).floor;
//				thisSynthVals[c] = (basis * (1 - spreadWidth)).blend( (basis * (1 + spreadWidth)), xloc[c - 1]);
////				dontChangeIndexArray.do { |item|
////					thisSynthVals[c][item] = basis[item]
////				};
//				// pan
//				thisSynthVals[c][15] = panStart + panIncrement;
//				// amp
//				thisSynthVals[c][16] = basis[16] * volDistribution[ampIndex] * ampScaling;
//				thisSynthVals[c] = [synthParamSymbols, thisSynthVals[c]].autolace;
//						
//				};
//				
//			};
			
		^thisSynthVals;

	}
	
	mute { |status = 0|
	
		muteStatus = status;
		if(synthRunningStatus == 1) {this.setSynthVals};
		
	}
	
	startStop { |status, relayFlag = 1, from|
	
	
	// why? because setData might be coming from the use of the palette
	// these need to update regardless of playing status
		buf_env.setn(0, envArray);
		buf_freqEnv.setn(0, freqEnvArray);
		
		buf_wave.loadCollection(signal_wave);
		
		this.calcSpread;
		this.setSynthVals;
	
		if(status == synthRunningStatus) {^nil};
	
		case
			{status == 1}
			{this.start(1)}
			{status == 0}
			{this.stop};
			
		if(relayFlag == 1) {link.updateTransportStatus(idNo, \train, synthRunningStatus)};
	
	}	
	

// !!! start and stop are intended only to be called by startStop	
	start { |fromStartStopFlag = 0|
	
		var vals;
		synthRunningStatus = 1;
		totalNoOfSynths = (1 + ((noOfSpreads - 1) * 2)).asInt;
		
// spreadFactor

// here the synth just gets started
// then setSynthVals can do all the spread calcs
// there might be loads of spreaded synths and they are all getting the same params to begin with
// so make things quiet until stuff actually spreads...

// err this doesn't make any sense, what was i meaning??

//		// if the instruction is coming from startStop, this has already been done, if not, it hasn't..
//		// is there a more elegant way, i don't know.

			this.calcSpread;
			vals = this.calcSynthParams(synthVals);

			
			65.do { |index|
			
				if(index < totalNoOfSynths)
					{
					synth_pulsar[index] = 
						Synth(synthDefNames[currentSynthDefIndex],
							[
							\outBus, 0, \bufnum, [buf_wave.bufnum, soundfileBufnum][bufMode], \envbufnum, buf_env.bufnum,
							\freqEnvBufNum, buf_freqEnv.bufnum,
							\bufdur, waveBufDur, \envBufDur, envBufDur,
							\phase, [0, rrand(0, 1)][rndPhaseStatus], \mute, muteStatus
							]
							++
							vals[index],
							group,
							\addToTail
						);
					}
					{
					synth_pulsar[index].free;
					synth_pulsar[index] = nil;
					};
			};
			
			link.liveMixerUpdate;
	
				
	}
	
	stop {
	
		synthRunningStatus = 0;
		
		synth_pulsar.do { |item| item.free };
		
	
	}
	

	
	seqStartStop { |status, relayFlag = 1|
		
		seq.startStop(status);
		seqRunningStatus = status;
		if(relayFlag == 1) {link.updateTransportStatus(idNo, \seq, status)};
		if(status == 0)
			{
			if(defaultOnStop == 1)
				{
				this.setSeqDefault
				};
				
			};
	
	}
	
	getSeqStatus {
		
		^seq.playStatus;
	
	}
	
	harmonicsArray_ { |h|
		
		harmonicsArray = h.deepCopy;
		signal_wave = Signal.sineFill(buf_wave.numFrames, harmonicsArray);
		buf_wave.loadCollection(signal_wave);
		this.guiUpdate;
	
	}
	
	envArray_ { |a|
	
		envArray = a.deepCopy;
		envArray[envArray.lastIndex] = 0;
		buf_env.setn(0, envArray);
		this.guiUpdate;
			
	}
	
	freqEnvArray_ { |a|

		freqEnvArray = a.deepCopy;
		buf_freqEnv.setn(0, freqEnvArray);

	}
	
	setSpreadParams { |args|
	
		var oldNoOfSpreads;
		oldNoOfSpreads = noOfSpreads;
		
		#noOfSpreads, spreadWidth, spreadAmpReduce, splay = args;
		
		if(oldNoOfSpreads != noOfSpreads)
			{
			totalNoOfSynths = (1 + ((noOfSpreads - 1) * 2)).asInt;
			
			this.calcSpread;
			if(synthRunningStatus == 1)
				{
				65.do { |index|
				
					if(index < totalNoOfSynths)
						{
						if(synth_pulsar[index].isKindOf(Synth) == false)
							{
							synth_pulsar[index] = 
								Synth(synthDefNames[currentSynthDefIndex],
									[
									\outBus, 0, \bufnum, [buf_wave.bufnum, soundfileBufnum][bufMode], \envbufnum, buf_env.bufnum,
									\freqEnvBufNum, buf_freqEnv,
									\bufdur, waveBufDur, \envBufDur, envBufDur, \bufStartFrame, 0,
									\phase, [0, rrand(0, 1)][rndPhaseStatus], \mute, muteStatus,
									\amp, 0
									],
									group,
									\addToTail
								);
								
							}
							{
							
							};
						}
						{
						synth_pulsar[index].free;
						synth_pulsar[index] = nil;
						};
						
						
				};
					
				};
				
			}
			{
			this.calcSpread;
			};
			this.setSynthVals;

	
	}
	
	guiUpdate {
	
		link.guiUpdate(idNo);
	
	}
	
	setOutBus { |bus = 0|
	
		if(synthRunningStatus == 0) {^nil};
	
		65.do { |index|
		
			if(index < totalNoOfSynths)
				{
				synth_pulsar[index].set(\outBus, bus);
				};
		};
	
	
	}
	
	setSeqData { |routineType, dataType, vals|
	
		seq.setSingleData(routineType, dataType, vals);
	
	}
	
	getSeqData { |routineType, dataType|
	
		^seq.getSingleData(routineType, dataType);
	
	}
	
	setSeqParamNos { |routineType, dataType, val|
	
		seqParamNos[(routineType * 3) + dataType] = val;
		
	}
	
	getSeqParamNos { |routineType, dataType|
	
		^seqParamNos[(routineType * 3) + dataType];
	
	}
	
	setSeqDur { |routineType, secs|
	
		seq.setDur(routineType, secs);
		
	}
	
	getSeqDur { |routineType|
	
		^seq.getDur(routineType);
		
	}
	
	setSeqDurBeats { |routineType, beats|
	
		seq.setDurBeats(routineType, beats);
		
	}
	
	getSeqDurBeats { |routineType|
	
		^seq.getDurBeats(routineType);
		
	}
	
	
	// getData and setData - everything for opening and saving files...
	// getPatch and setPatch - ONLY numerical type data - blendable stuff! no strings etc.
	
	getData {
	
		^[
		this.getPatch,
		soundfilePath,
		seqParamNos
		]
		
	}
	
	setData { |args, setSynthDataFlag = 1, setSeqDataFlag = 1, liveRecallFlag = 0, volAdjust = 1.0|

	//	var argLoopStatus;
		
		soundfilePath = args[1].deepCopy;
		seqParamNos = args[2].deepCopy;	
		
		// the gui updates should happen in setPatch
		this.setPatch(args[0], setSynthDataFlag, setSeqDataFlag, liveRecallFlag, volAdjust);
	}
		
	
	getPatch {
	
		^[
		synthVals, harmonicsArray, envArray, freqEnvArray,
		[noOfSpreads, spreadWidth, spreadAmpReduce, splay],
		harmonics_rndPhaseFlag, bufMode,
		freqRange,
		seq.getData,
		0,
		rndPhaseStatus,
		synthRunningStatus, seqRunningStatus,
		currentSynthDefIndex,
		signalMode, signal_wave,
		defaultOnStop, resetOnSetPatch, loopStatus
		];
		
	}
	
	setPatch { |args, setSynthDataFlag = 1, setSeqDataFlag = 1, liveRecallFlag = 0, volAdjust = 1.0|
	
		var class, name, number, seqData, local_spreadParams;
		var oldSynthDefIndex, argHarmonicsArray, dummy, argBufMode;
		var argLoopStatus;
		
		args = args.deepCopy;
				
		if(setSynthDataFlag == 1)
			{
			// volAdjust - this is ugly
			args[0][args[0].lastIndex] = (args[0][args[0].lastIndex] * volAdjust).deepCopy;
			
			#synthVals, argHarmonicsArray, envArray, freqEnvArray,
				local_spreadParams, harmonics_rndPhaseFlag, argBufMode,
				freqRange = args;
				
			this.setSpreadParams(local_spreadParams);
			
			harmonics_rndPhaseFlag = harmonics_rndPhaseFlag.round(1).asInt;
			defaultOnStop = args[16].round(1).asInt; resetOnSetPatch = args[17].round(1).asInt; argLoopStatus = args[18].round(1).asInt;
			this.loopStatus_(argLoopStatus);
			
			rndPhaseStatus = args[10] ? 0;
			
			oldSynthDefIndex = currentSynthDefIndex;
			currentSynthDefIndex = (args[13] ? 0).round(1).asInt;
			signalMode = args[14];
			if(signalMode == 0)
				{
				this.setHarmonics(argHarmonicsArray, 0);
				}
				{
				this.setSignal(args[15], 0);
				};
			
			
			if(synthRunningStatus == 1)
				{
				if(currentSynthDefIndex != oldSynthDefIndex)
					{
					this.stop;
					};
					
				};
			this.startStop(args[11].round(1).asInt, 1, \setData);
			this.seqStartStop(args[12].round(1).asInt, 0);
			
			argBufMode = argBufMode.round(1).asInt.clip(0, 1);
			this.setBufMode(argBufMode);
			};
		
		if(setSeqDataFlag == 1)
			{	
			seqData = args[8]; seq.setData(seqData, liveRecallFlag);
			};
			
		if((resetOnSetPatch == 1) and: (seq.playStatus == 1))
			{
			seq.startStop(0);
			seq.startStop(1);
			};
		

		
		{this.guiUpdate}.defer;
	
	}
	
	changeSynthDef { |sdNo = 0|
	
		var oldSynthDefIndex;
				
		oldSynthDefIndex = currentSynthDefIndex;
		currentSynthDefIndex = sdNo;
		if(synthRunningStatus == 1)
			{
			if(currentSynthDefIndex != oldSynthDefIndex)
				{
				// this.startStop(0, 0, \setData);
				// i don't want to send all the buf data twice in a row so do this directly
				this.stop;
				};
			this.startStop(1, 0, \changeSynthDef);
			};
			
	
	}
	
	setHarmonics { |harmonics, guiUpdateFlag = 1|
	
		var phases;
	
		if(harmonics == nil) {^nil};
		
		case
			{harmonics_rndPhaseFlag == 1}
			{phases = Array.rand(16, 0.0, 1.0)}
			{phases = Array.series(16, 0.0, 0.0)};
			
		signalMode = 0;
		harmonicsArray = harmonics.deepCopy ++ Array.series(16 - harmonics.size, 0.0, 0.0);
		signal_wave = Signal.sineFill(buf_wave.numFrames, harmonics, phases);
		buf_wave.loadCollection(signal_wave);
				
		if(guiUpdateFlag == 1) { {this.guiUpdate}.defer; };
	
	}
	
	setSignal { |array, guiUpdateFlag = 1|
	
		signalMode = 1;
		array.do { |item, index|
			signal_wave[index] = array[index];
		};
		buf_wave.loadCollection(signal_wave);
		
		if(guiUpdateFlag == 1) { {this.guiUpdate}.defer; };
	
		
	
	}
	
	getProbability {
	
		^synthVals[7];
	
	}
	
	getFlux {
	
		^synthVals[6];
	
	
	}
	
	getSpreadParams {
	
		^[noOfSpreads, spreadWidth, spreadAmpReduce, splay];
	
	
	}
	
	
}

