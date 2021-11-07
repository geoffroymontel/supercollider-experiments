C2PL_SynthDef {

	*names {
	
		^[
		"pulsar", "fmGrain1", "fmGrain2"
		]
		
	}


	*send { |server|
	
		server = server ? Server.internal;
	
		server.waitForBoot({
			
			this.names.do { |item|
				
				SynthDef("C2PL_" ++ item,
					{
					|
					inBus = 999,
					outBus = 0, bufnum = 0, envbufnum = 1, freqEnvBufNum = 2, 
					bufdur = 0.1, envBufDur = 0.1,
					phase = 0.0,
					startPos = 0.0,
					trigFreq = 50,
					grainFreqMult = 1.0,
					envRateFrom = 0, envRateMult = 1.0,
					fmRatio = 1.0, fmAmt = 0.0,
					
					allFluxAmt = 0.0,
					
					probability = 1.0,
					pan = 0.0, amp = 0.5, mute = 0,
					
					seq_startPosOffset = 0.0, seq_trigFreqMult = 1.0, seq_grainMult = 1.0, seq_envRateMult = 1.0,
					seq_fmRatioMult = 1.0, seq_fmAmtMult = 1.0,
					seq_ampMult = 1.0, seq_probMult = 1.0, seq_panOffset = 0.0,
					
					live_allFreqMult = 1.0, live_panOffset = 0.0, live_ampMult = 1.0
					|
					var envFreq, envRate, output, trig, playBuf, envPlayBuf, freqEnvPlayBuf, rate, grainFreq, grainDur;
					var fluxRate = 20.0, trigFreqFlux, envRateFlux = 0.0, grainFreqFlux, ampFlux, ampRand = 0.0;
					var lag = 0.02;
					
					trigFreqFlux = allFluxAmt; grainFreqFlux = allFluxAmt; ampFlux = allFluxAmt;
					
					startPos = startPos + seq_startPosOffset;
					fmRatio = fmRatio * seq_fmRatioMult;
					fmAmt = fmAmt * seq_fmAmtMult;
									
				// the live inputs coming from seqs and live mixer
					trigFreq = trigFreq * seq_trigFreqMult * live_allFreqMult;
					
					grainFreq = trigFreq * grainFreqMult * seq_grainMult * live_allFreqMult;
					
					envRate = grainFreq * envBufDur * (1 / envRateMult) * seq_envRateMult;

					grainDur = envBufDur / envRate;
					grainFreq = grainFreq * LFNoise0.kr(fluxRate * ExpRand(0.8, 1.2), grainFreqFlux, 1).lag(1.2);
					
					pan = pan + live_panOffset + seq_panOffset;
					amp = amp * seq_ampMult * live_ampMult * (1 - mute);
					probability = probability * seq_probMult;
					
					trig = Impulse.ar(trigFreq.lag(lag) * LFNoise0.kr(fluxRate * ExpRand(0.8, 1.2), trigFreqFlux, 1).lag(1.2), phase);
					trig = trig * CoinGate.ar(probability, trig);
					
					freqEnvPlayBuf = PlayBuf.ar(1, freqEnvBufNum, (grainFreq * envBufDur), trig, 0, loop: 0);
					
					rate = 
						(grainFreq * bufdur)
						*
						(1 + (freqEnvPlayBuf * fmAmt));
					
					output = this.perform(
						item.asSymbol, 
						trig, bufnum, envbufnum, rate, envRate,
						fmRatio, fmAmt, grainDur, ampRand, grainFreq,
						startPos
					);
					
					output = output * amp;
					Out.ar(outBus, Pan2.ar(output, pan));
					}
				).load(server);	
				
			};
			
			
				
		});
		
	}
	
	*pulsar { |trig, bufnum, envbufnum, rate, envRate, fmRatio, fmAmt, grainDur, ampRand, grainFreq, startPos|
	
		var playBuf, envPlayBuf, bufStartFrame, output;
		
		bufStartFrame = startPos * BufFrames.kr(bufnum);
		
		playBuf = PlayBuf.ar(1, bufnum, rate, trig, bufStartFrame, loop: -1);
		envPlayBuf = PlayBuf.ar(1, envbufnum, envRate, trig, 0, loop: 0);
		output = playBuf * envPlayBuf * TRand.ar(1 - ampRand, 1, trig);
		^output;
	
	}
	
	*fmGrain1 { |trig, bufnum, envbufnum, rate, envRate, fmRatio, fmAmt, grainDur, ampRand, grainFreq, startPos|
	
		var output;
		output = BufGrainB.ar(trig, grainDur, bufnum, rate * (1 + SinOsc.ar(grainFreq * fmRatio, 0, fmAmt / 16)), startPos, envbufnum, 2, TRand.ar(1 - ampRand, 1, trig).lag(0.01));
		^output;
	}
	
	*fmGrain2 { |trig, bufnum, envbufnum, rate, envRate, fmRatio, fmAmt, grainDur, ampRand, grainFreq, startPos|
	
		var output;
		output = FMGrainB.ar(trig, grainDur, grainFreq, grainFreq * fmRatio, fmAmt, envbufnum, TRand.ar(1 - ampRand, 1, trig).lag(0.01));
		^output;
	
	}
	

}



