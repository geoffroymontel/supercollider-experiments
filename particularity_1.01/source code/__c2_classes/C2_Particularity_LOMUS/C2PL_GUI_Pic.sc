C2PL_GUI_Pic {

	var <w, cv, uv;
	var coords, synthStatus, seqStatus, updatePeriod = 0.02;
	var colors, trainBounds, offCoords, historyCoords;
	var lineThickness = 2.0, thicknessMult = 1.0, fps = 24, amp2alpha = 0.0, maskAlpha = 1.0, blendMode = 0, naNos = 0, fluxSens = 0.1;
	var probability, probMult, flux, vol, pan, volMin = 0.01, volMax = 1.2, panAmt = 0.4, style, blobWidthMult = 1.0, dashMult = 0.01;
	var minimumDash = 0.001;
	var background, boundsA, boundsB, trsp, drawFunc;
	var allVol = 1, allTrsp = 0.0;

	var clumpMode = 0;
	
	// how????
	var movementAmt = 1.0;
	
	*new { ^super.new.init }
	
	init {
	
		this.defineDrawFunc;
	
		// lightens or darkens colors - 0.0 does neither
		trsp = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
	
		offCoords = 
			[
			[ [0.25, 0.25], [0.75, 0.25], [0.75, 0.75], [0.25, 0.75], [0.25, 0.25] ],
			[ [0.25, 0.25], [0.75, 0.25], [0.5, 0.75], [0.25, 0.25], [0.25, 0.25] ]
			];
	
		boundsA = 
			[
			[0, 0, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1],
			[0, 0, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1], [0, 0, 1, 1]
			];
			
		boundsB = 
			[
			[0, 0, 0.25, 0.5], [0.25, 0, 0.25, 0.5], [0.5, 0, 0.25, 0.5], [0.75, 0, 0.25, 0.5],
			[0, 0.5, 0.25, 0.5], [0.25, 0.5, 0.25, 0.5], [0.5, 0.5, 0.25, 0.5], [0.75, 0.5, 0.25, 0.5]
			];
			
		trainBounds = Array.newClear(8);
		this.calcTrainBounds(0.0);
	
		coords = Array.newClear(8);
		8.do { |i|
			coords[i] = [ [0, 0], [0, 0], [0, 0], [0, 0], [0, 0] ];
		};
		
		historyCoords = Array.newClear(20);
		20.do { |i|
		
			historyCoords[i] = coords.deepCopy;
		
		};
		synthStatus = [0, 0, 0, 0, 0, 0, 0, 0];
		seqStatus = [0, 0, 0, 0, 0, 0, 0, 0];
		probability = [1, 1, 1, 1, 1, 1, 1, 1];
		probMult = [1, 1, 1, 1, 1, 1, 1, 1];
		flux = [0, 0, 0, 0, 0, 0, 0, 0];
		vol = [0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6];
		pan = [0, 0, 0, 0, 0, 0, 0, 0];
		style = [0, 0, 0, 0, 0, 0, 0, 0];

		background = Color.white;

		colors = [Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black];
	
			
	//	this.draw;
		
	
	}
	
	front { w.front }
	
	reportBounds { ^w.bounds }
	
	setBounds { |bounds| w.bounds_(bounds) }
	
	draw { |winX = 5, winY = 720, color|
	
		var startX, startY, x, y, defaults;
		var lastX = 0, lastY = 0;
	
		w = Window("Particularity : Picture", Rect(winX, winY, 640, 480)).front;
		w.userCanClose_(false);
		
		
		cv = CompositeView(w, Rect(0, 0, w.bounds.width, w.bounds.height));
		cv.background_(color ? Color.grey);
		uv = SCAnimationView(cv, Rect(10, 10, cv.bounds.width - 20, cv.bounds.height - 40));
		uv.background_(Color.black);
		uv.clearOnRefresh = false;
		this.disable;
		
	}
	
	enableByVal { |e = 0|
	
		if(e == 1) { this.enable } {this.disable };
		
	}
			
	enable {
	
		uv.drawFunc = drawFunc;
		thisProcess.setDeferredTaskInterval(1 / fps);		
	}
	
	disable {
	
		uv.drawFunc = {};
		thisProcess.setDeferredTaskInterval(1 / 4);
		
	}
	
	resize {
	
		cv.bounds = Rect(0, 0, w.bounds.width, w.bounds.height);
		uv.bounds = Rect(10, 10, cv.bounds.width - 20, cv.bounds.height - 40);
	
	
	}
	
	setCoords { |trainNo, argCoords, argSynthStatus, argSeqStatus, argProbability, argFlux, argVol, argPan, argTrsp, argAllTrsp = 0, argAllVol = 1|
	
		// take this array of 6 values and arrange them into 3 arrays of 2 values each
		// (ie some x, y co-ordinates)
		// pair element 1 and 6, 2 and 7, 3 and 8 etc.
		
		coords[trainNo] = 
			argCoords.resamp1(10).rotate(trainNo).clump(5).lace(10).clump(2)
			+ 
			[ [0.0, 0.0], [-0.2, -0.2], [0.2, -0.2], [0.2, 0.2], [-0.2, 0.2]].rotate(trainNo.neg);
		
		// .clump(5).lace(10)
	//	coords[trainNo] = coords[trainNo] ++ [ (coords[trainNo][0] + coords[trainNo][1]) * 0.5, (coords[trainNo][1] + coords[trainNo][2]) * 0.5 ];
	
//		coords[trainNo] = coords[trainNo] ++ argCoords.rotate(2).clump(3).lace(4).clump(2);
//		coords[trainNo] = coords[trainNo] + [ [-0.4, 0.5], [-0.1, 0.5], [-0.1, 0.4], [0.2, -0.2], [-0.3, 0.3] ];
	
	//	[trainNo, argCoords, argSynthStatus, argSeqStatus, argProbability, argFlux, argVol, argPan, argTrsp, argAllTrsp, argAllVol].postln;
		
		synthStatus = argSynthStatus;
		seqStatus = argSeqStatus;
		probability = argProbability.clip(0.01, inf);
		flux = argFlux * fluxSens;
		vol = [volMin, volMax].asSpec.map(argVol);
		pan = argPan;
		allVol = argAllVol;

		argTrsp.do { |item, index|
			trsp[index] = [-24.0, 24.0].asSpec.unmap(item);
			trsp[index] = [-0.4, 0.4].asSpec.map(trsp[index]);
		};
		
		argAllTrsp = [-24.0, 24.0].asSpec.unmap(argAllTrsp);
		allTrsp = [-0.4, 0.4].asSpec.map(argAllTrsp);
		
	//	{uv.refresh}.defer;
		
	}
	
	calcTrainBounds { |blend = 0.0|
	
		blend = blend.clip(0.0, 1.0);
		8.do { |i|
			var startX, startY, width, height;
			trainBounds[i] = boundsA[i].blend(boundsB[i], blend);
		};
		
	
	
	}
	
	updateFromCtrl { |args|
	
		var boundsBlend, argBackground, newBackground, argCols, styleSwitch, argStyle;
			
		#fps, boundsBlend, lineThickness, thicknessMult, naNos,
			volMax, movementAmt, fluxSens,
			blendMode, maskAlpha,
			blobWidthMult, dashMult, minimumDash,
			argStyle,
			
			argBackground ... argCols = args.deepCopy;
			
			for(0, 7) { |c|
				style[c] = argStyle;
				colors[c] = C2_Color.newFromFloat(argCols[c]);
			};

		blendMode = blendMode.round(1).asInt;
			
		newBackground = C2_Color.newFromFloat(argBackground);
		if(newBackground != background)
			{
			background = newBackground;
			{uv.background_(background)}.defer;
			};
			
		thisProcess.setDeferredTaskInterval(1 / fps);
		
		this.calcTrainBounds(boundsBlend);
	
	
	}	
	
	defineDrawFunc {
	
		drawFunc = 
			{
			|view, i|
			// temp vars
			var x, y, startX, startY, width, height, specX, specY, thisCoords, thisStatus;
			var transX, transY, thisFlux, thisWidth, thisBlobWidth, thisDash, thisCol;
			var specWidth, specHeight;
			
			specWidth = uv.bounds.width * allVol;
			specHeight = uv.bounds.height * allVol;
						
			specX = [(uv.bounds.width - specWidth) * 0.5, ((uv.bounds.width - specWidth) * 0.5) + specWidth].asSpec;
			specY = [(uv.bounds.height - specHeight) * 0.5, ((uv.bounds.height - specHeight) * 0.5) + specHeight].asSpec;
			
			
			
//"".postln;
//specX.postln;
//specY.postln;
			Pen.blendMode_(0);
//			Pen.strokeColor = Color.yellow;
//			Pen.strokeRect(Rect((uv.bounds.width - specWidth) * 0.5, (uv.bounds.height - specHeight) * 0.5, specWidth, specHeight));
			
			
			
			
			Pen.fillColor = this.colorChange(background, allTrsp).alpha_(maskAlpha);
			Pen.fillRect(Rect(0, 0, uv.bounds.width, uv.bounds.height));
				
			Pen.blendMode_(blendMode);
			
			for(0, 7)
				{
				|train|
				thisDash = (uv.bounds.width * dashMult);
				thisCol = this.colorChange(colors[train], trsp[train]);
				Pen.lineDash_(FloatArray[ probability[train].clip(minimumDash, 1) * thisDash, (1 - probability[train].clip(minimumDash, 1)) * thisDash ]);
				thisFlux = flux[train];
				transX = specX.map(trainBounds[train][0] + (trainBounds[train][2] * 0.5));
				transY = specY.map(trainBounds[train][1] + (trainBounds[train][3] * 0.5));
//				Pen.color = Color.black;
//				Pen.strokeRect(Rect(transX - 5, transY - 5, 10, 10));
			
				Pen.translate(transX, transY);
				Pen.moveTo(Point(0, 0));
				Pen.rotate((pan[train] * panAmt) * pi, 0, 0);
				Pen.strokeColor = thisCol; Pen.fillColor = thisCol;

				thisWidth = lineThickness * thicknessMult * vol[train] * allVol;
				thisBlobWidth = thisWidth * blobWidthMult * vol[train] * allVol;
				case
					{seqStatus[train] == 1}
					{thisCoords = coords[train].deepCopy}
					{synthStatus[train] == 1}
					{thisCoords = offCoords[0].deepCopy}
					{
					// synth inactive - display X
					thisCoords = offCoords[1].deepCopy;
					thisWidth = lineThickness * thicknessMult * naNos;
					Pen.lineDash_(FloatArray[1, 0]);
					thisFlux = 0;
					};
				Pen.width = thisWidth * allVol;
				
//				startX = (specX.map(trainBounds[train][0]) * 0.5).neg;
//				startY = (specY.map(trainBounds[train][1]) * 0.5).neg;
				
//				startX = ([0, specWidth].asSpec.map(trainBounds[train][0]) * 0.5).neg;
//				startY = ([0, specHeight].asSpec.map(trainBounds[train][1]) * 0.5).neg;
//
//				width = [0, specWidth].asSpec.map(trainBounds[train][2]);
//				height = [0, specHeight].asSpec.map(trainBounds[train][3]);

				width = specX.map(trainBounds[train][2]) * allVol;
				height = specY.map(trainBounds[train][3]) * allVol;
				startX = (width * 0.5).neg;
				startY = (height * 0.5).neg;
//				train.postln;
//				trainBounds[train].postln;
//				[width, height].postln;
				



				thisCoords.do { |item, index|
					// reverse y
					thisCoords[index][1] = 1 - thisCoords[index][1];
					thisCoords[index] = thisCoords[index] - [0.5, 0.5];
					thisCoords[index] = thisCoords[index] * vol[train];
					thisCoords[index] = thisCoords[index] + [0.5, 0.5];
					thisCoords[index][0] = [startX, startX + width].asSpec.mapWithoutClip(thisCoords[index][0] * (1 + rrand(thisFlux.neg, thisFlux)));
					thisCoords[index][1] = [startY, startY + height].asSpec.mapWithoutClip(thisCoords[index][1] * (1 + rrand(thisFlux.neg, thisFlux)));
				};
				
				
				case
					{style[train] == 0}
					{
					if(seqStatus[train] == 1)
						{
						C2PL_GUI_Pic_StyleFunc.return(0).value(thisCoords, thisWidth, thisBlobWidth, 4, 0)
						}
						{
						C2PL_GUI_Pic_StyleFunc.return(0).value(thisCoords, thisWidth, thisBlobWidth, 0, 1)
						};
						
					}
					{
					C2PL_GUI_Pic_StyleFunc.return(style[train]).value(thisCoords, thisWidth, thisBlobWidth);
					};
					Pen.rotate((pan[train].neg * panAmt) * pi, 0, 0);
					Pen.translate(transX.neg, transY.neg);
					
					
				
				};
				
		
			
			};
			
	}
	
	colorChange { |color, amt|
	
		case
			{amt >= 0.0}
			{color = color.blend(Color.white, amt)}
			{color = color.blend(Color.black, amt.neg)};
		
		^color

	}


}




