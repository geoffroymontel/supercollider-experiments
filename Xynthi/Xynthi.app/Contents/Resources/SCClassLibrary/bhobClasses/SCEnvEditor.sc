// based on Lance Putnam's SCEnvelopeEdit

SCEnvEditor : SCEnvelopeView {
	var <>env, <pointsPerSegment, viewPoints;
	var <minLevel, <maxLevel, <timeScale, absTimes, numPoints;
	var <curver, <boundWidth, <mouseFunc, <curSelect;
	
	*viewClass { ^SCEnvelopeView }
	
	*new { arg parent, bounds, env, pointsPerSegment=10;
		^super.new(parent, bounds).initSCEnvelopeEdit(env, pointsPerSegment)
	}
	
	initSCEnvelopeEdit { arg argEnv, argPPS;
		var curspec, curspec_rec;
		env = argEnv;
		pointsPerSegment = argPPS.asInteger;
		minLevel = 0;
		maxLevel = 1;
		boundWidth=this.bounds.width;
		timeScale=env.times.sum;
		env.curves=env.curves.asArray;
		(env.curves.size < env.times.size).if({
			env.curves=env.curves ++ Array.fill(env.times.size-env.curves.size, env.curves[env.curves.size-1]);
		});
		
		absTimes = Array.newClear(env.times.size + 1);
		absTimes[0] = 0;
		for(1, env.times.size, { arg i;
			absTimes[i] = absTimes[i-1] + env.times[i-1];
		});
		
		numPoints = (pointsPerSegment * env.times.size) + 1;  // add 1 for the last point
		viewPoints = Array.with(Array.newClear(numPoints), Array.newClear(numPoints));
		curver = Array.newClear(env.times.size);
		
		this.selectionColor_(Color.clear)
			.drawLines_(true)
			.drawRects_(true);
		this.mouseUpAction_({ this.resizeCurvers; });
		this.action = {|view|
			var bp, bpm1, bpp1, bpLevel, timePos;
			// if it's a breakpoint
			if((view.index % pointsPerSegment) == 0, {
				bp = view.index.div(pointsPerSegment);
				bpm1 = bp - 1;
				bpp1 = bp + 1;
				
				bpLevel = view.currentvalue.linlin(0.0, 1.0, minLevel, maxLevel);
				env.levels[bp] = bpLevel;
				
				timePos = view.value[0][view.index] * timeScale;
					// first breakpoint
					if(bp == 0, {
						view.value[0][0]=0.0;
						this.updateSegment(bp);
					// end breakpoint
					},{ if(bp == env.times.size, {
						view.value[0][view.value[0].size - 1]=1.0;
						this.updateSegment(bpm1);		
					// a middle break point
					},{
						if(timePos > absTimes[bpp1], {	// past right break point
							env.times[bpm1] = absTimes[bp] - absTimes[bpm1];
							env.times[bp] = 0;
							absTimes[bp] = absTimes[bpp1];
						},{ if(timePos < absTimes[bpm1], { // past left break point
							env.times[bpm1] = 0;
							env.times[bp] = absTimes[bpp1] - absTimes[bp];
							absTimes[bp] = absTimes[bpm1];
						},{
							// set left segment dur
							env.times[bpm1] = timePos - absTimes[bpm1];
							
							// set right segment dur
							env.times[bp] = absTimes[bpp1] - timePos;
							
							absTimes[bp] = timePos;					
						}); 
						});
						this.updateSegment(bpm1);
						this.updateSegment(bp);
					}); 
				});
				this.redraw;
			});
		};
		this.mouseDownAction = {|v, x, y, mods|
			var between=false, inc=0, test;
			while({(between.not) && (inc < curver.size)}, {
				test=curver[inc];
				((x >= test[0]) && (x <= test[1])).if({
					between=true;
					curSelect=[y, inc];
				});
				inc=inc + 1;
			});
			(between.not).if({
				curSelect=nil;
			});
		};
		this.mouseMoveAction = {|v, x, y, mods|
			var base_y, index, oldcurve, newcurve;
			(curSelect.notNil).if({
				base_y=curSelect.at(0);
				index=curSelect.at(1);
				oldcurve=this.env.curves.at(index);
				(env.levels.at(index) < env.levels.at(index + 1)).if({
					newcurve=(oldcurve + (y - base_y * 0.1)).clip2(18);
				}, {
					newcurve=(oldcurve + (base_y - y * 0.1)).clip2(18);
				});
				this.env.curves.put(index, newcurve);
				curSelect.put(0, y);
				this.updateAll;
				this.value = viewPoints;
				this.resizeCurvers;
			});
		};	
		this.updateAll;
		this.redraw;
		this.drawIt;	
	}
	
	drawIt {
		this.value=viewPoints;
		numPoints.do({ arg i;
			// make a breakpoint
			if((i%pointsPerSegment) == 0, {
				this.setThumbSize(i, 5);
				
				// color code breakpoints
				if(i.div(pointsPerSegment) == env.releaseNode, {
					this.setFillColor(i, Color.red(0.7));
				},{
					if(i.div(pointsPerSegment) == env.loopNode, {
						this.setFillColor(i, Color.green(0.7));
					},{
						this.setFillColor(i, Color.blue(0.7));
					});
				});
			// Other points should be hidden.
			},{ this.setThumbSize(i, 0) });
		});
		this.resizeCurvers;
	}
	
	redraw {
		this.value = viewPoints;
	}
	
	refresh {|argEnv|
		(argEnv.notNil).if({ 
			env=argEnv;
			absTimes = Array.newClear(env.times.size + 1);
			absTimes[0] = 0;
			for(1, env.times.size, { arg i;
				absTimes[i] = absTimes[i-1] + env.times[i-1];
			});
			numPoints = (pointsPerSegment * env.times.size) + 1;  // add 1 for the last point
			viewPoints = Array.with(Array.newClear(numPoints), Array.newClear(numPoints));
			curver = Array.newClear(env.times.size);
			this.drawIt;
		});
		this.updateAll;
		this.value = viewPoints;
		this.resizeCurvers;
	}
	
	updateAll {
		env.times.size.do({ arg i;
			this.updateSegment(i);
		});	
	}
	
	// updates segment values in viewPoints array
	updateSegment { arg segNum;
		var time, slope, index1, index2, timeOffset;
		
		// update envelope cache
		env.times = env.times;
		env.levels = env.levels;
		env.curves = env.curves;

		segNum = segNum.asInteger;

		time = absTimes[segNum];
		timeOffset = absTimes[0];
		
		slope = env.times[segNum] / pointsPerSegment;

		index1 = pointsPerSegment * segNum;
		index2 = index1 + pointsPerSegment - 1;

		for(index1, index2, { arg i;
			viewPoints[0][i] = time.linlin(0, timeScale, 0.0, 1.0);
			viewPoints[1][i] = env[time - timeOffset].linlin(minLevel, maxLevel, 0.0, 1.0);
			time = time + slope;
		});
		
		// draw break point at right level
		if(slope == 0, {
			viewPoints[1][index1] = env.levels[segNum].linlin(minLevel, maxLevel, 0.0, 1.0);
		});
		
		// the last segment has an extra point at the end
		if(segNum == (env.times.size-1), {
			index2 = index2 + 1;
			viewPoints[0][index2] = time.linlin(0, timeScale, 0.0, 1.0);
			viewPoints[1][index2] = env.levels.last.linlin(minLevel, maxLevel, 0.0, 1.0);
		});		
	}
	
	resizeCurvers {
		var xPos, normtimes;
		normtimes=env.times.normalizeSum;
		normtimes.do({|each, count|
			(count > 0).if({
				xPos=normtimes[count - 1] * boundWidth + xPos;
			}, {
				xPos=this.bounds.left + 6;
			});
			curver[count]=[xPos, each * boundWidth - 12 + xPos];
		});
	}

	minLevel_ {|level|
		minLevel = level;
		this.refresh;
	}
	
	maxLevel_ {|level|
		maxLevel = level;
		this.refresh;
	}
	
	timeScale_ {|scale|
		var norm;
		timeScale=scale;
		norm=env.times.normalizeSum;
		env.times=norm * timeScale;
	}
	
	onMouseUp {|func|
		mouseFunc=func;
		this.mouseUpAction_({ func.value(env); this.resizeCurvers; });
	}
	
	valueAction_ {|argEnv|
		this.refresh(argEnv);
		(this.mouseFunc.notNil).if({
			mouseFunc.value(argEnv);
		});
	}
}