

+ ArrayedCollection {

	plot { arg name, bounds, discrete=false, numChannels = 1, minval, maxval, parent, labels=true;
		var plotter, txt, chanArray, unlaced, val, window, thumbsize, zoom, width,
			layout, write=false, msresize, gui;

		gui = GUI.current;

		bounds = bounds ?? { parent.notNil.if({
				if(parent.respondsTo(\view)){
					parent.view.bounds
				}{
					parent.bounds
				}
			}, {
				Rect(200 ,140, 705, 410);
 			});
 		};

		width = bounds.width-8;

		name = name ? "plot";

		unlaced = this.unlace(numChannels);
		minval = if(minval.isArray, {
			numChannels.collect{|index| minval.wrapAt(index) ?? { unlaced[index].minItem } }
		}, {
			{minval ?? { this.minItem }}.dup(numChannels);
		});
		maxval = if(maxval.isArray, {
			numChannels.collect{|index| maxval.wrapAt(index) ?? { unlaced[index].maxItem } }
		}, {
			{maxval ?? { this.maxItem }}.dup(numChannels);
		});

		chanArray = Array.newClear(numChannels);
		if( discrete, {
			zoom = 1;
			thumbsize = max(1.0, width / (this.size / numChannels));
			unlaced.do({ |chan, j|
				chanArray[j] = chan.linlin( minval[j], maxval[j], 0.0, 1.0 );
			});
		}, {
			zoom = (width / (this.size / numChannels));
			thumbsize = 1;
			unlaced.do({ |chan, j|
				val = Array.newClear(width);
				width.do { arg i;
					var x;
					x = chan.blendAt(i / zoom);
					val[i] = x.linlin(minval[j], maxval[j], 0.0, 1.0);
				};
				chanArray[j] = val;
			});
		});
		window = parent ?? { gui.window.new( name, bounds )};

		layout = gui.vLayoutView.new( window, parent.notNil.if({
			Rect(bounds.left+4, bounds.top+4, bounds.width-10, bounds.height-10);
		}, {
			Rect(4, 4, bounds.width - 10, bounds.height - 10);
		})).resize_(5);

		if(labels){
			txt = gui.staticText.new(layout, Rect( 8, 0, width, 18))
					.string_("index: 0, value: " ++ this[0].asString);
		};

		numChannels.do({ |i|
			plotter = gui.multiSliderView.new(layout, Rect(0, 0,
					layout.bounds.width, layout.bounds.height - if(labels, {26}, {0}))) // compensate for the text
				.readOnly_(true)
				.drawLines_(discrete.not)
				.drawRects_(discrete)
				.indexThumbSize_(thumbsize)
				.valueThumbSize_(1)
				.background_(Color.white)
				.colors_(Color.black, Color.blue(1.0,1.0))
				.action_({|v|
					var curval;
					curval = v.currentvalue.linlin(0.0, 1.0, minval[i], maxval[i]);

					if(labels){
						txt.string_("index: " ++ (v.index / zoom).roundUp(0.01).asString ++
						", value: " ++ curval);
					};
					if(write) { this[(v.index / zoom).asInteger * numChannels + i ]  = curval };
				})
				.keyDownAction_({ |v, char|
					if(char === $l) { write = write.not; v.readOnly = write.not;  };
				})
				.value_(chanArray[i])
				.elasticMode_(1);
			(numChannels > 1).if({ // check if there is more then 1 channel
				plotter.resize_(5);
			});
		});

		^window.tryPerform(\front) ?? { window }

	}
}

/*
+ Signal {
	plot { arg name, bounds;
		//this.asciiPlot;
		super.plot(name, bounds);

	}
}
*/

+ Wavetable {
	plot { arg name, bounds, minval, maxval, parent, labels=true;
		^this.asSignal.plot(name, bounds, minval: minval, maxval: maxval, parent: parent, labels: labels);
	}
}

+ Buffer {
	plot { arg name, bounds, minval = -1.0, maxval = 1.0, parent, labels=true;
		var gui;
		gui = GUI.current;
		this.loadToFloatArray(action: { |array, buf|
			{
				GUI.use( gui, {
					array.plot(name, bounds, numChannels: buf.numChannels, minval: minval, maxval: maxval, parent: parent, labels: labels);
				});
			}.defer;
		});
	}
}

+ Function {

	loadToFloatArray { arg duration = 0.01, server, action;
		var buffer, def, synth, name, numChannels, val, rate;
		server = server ? Server.default;
		if(server.serverRunning.not) { "Server not running!".warn; ^nil };

		name = this.hash.asString;
		def = SynthDef(name, { |bufnum|
			var	val = this.value;
			if(val.isValidUGenInput.not) {
				val.dump;
				Error("loadToFloatArray failed: % is no valid UGen input".format(val)).throw
			};
			rate = val.rate;
			if(val.size == 0) { numChannels = 1 } { numChannels = val.size };
			RecordBuf.perform(RecordBuf.methodSelectorForRate(rate), val, bufnum, loop:0);
			Line.perform(Line.methodSelectorForRate(rate), dur: duration, doneAction: 2);
		});

		Routine.run({
			var c;
			c = Condition.new;
			buffer = Buffer.new(server, duration
				* server.sampleRate * if(rate==\control, 1/server.options.blockSize, 1),
				numChannels);
			server.sendMsgSync(c, *buffer.allocMsg);
			server.sendMsgSync(c, "/d_recv", def.asBytes);
			synth = Synth(name, [\bufnum, buffer], server);
			OSCpathResponder(server.addr, ['/n_end', synth.nodeID], {
				buffer.loadToFloatArray(action: { |array, buf|
					action.value(array, buf);
					buffer.free;
				});
			}).add.removeWhenDone;
		});
	}

	plot { arg duration  = 0.01, server, bounds, minval = -1.0, maxval = 1.0, parent, labels=true;
		var gui;
		gui = GUI.current;
		this.loadToFloatArray(duration, server, { |array, buf|
			var numChan;
			numChan = buf.numChannels;
			{
				GUI.use( gui, {
					array.plot(bounds: bounds, numChannels: numChan, minval: minval, maxval: maxval,
						parent: parent, labels: labels)
				});
			}.defer;
		})
	}


}


+ SoundFile{
	plot{ arg bounds;
		var win, view, gui;
		gui = GUI.current;
		bounds = bounds ?? { Rect( 200, 140, 705, 410 )};
		win = gui.window.new(this.path.split.last, bounds);
		view = gui.soundFileView.new(win, win.bounds.width@win.bounds.height).resize_(5);
		view.soundfile_(this);
		view.elasticMode_(1);
		win.front;
		view.readWithTask;
	}
}
