
AbstractPlayerGui : ObjectGui { 
	
	gui { arg lay,bounds ... args;
		var layout;
		layout=this.guify(lay,bounds);
		if(lay.isNil,{ 
			// top level controls
			this.synthConsole(layout);
			this.saveConsole(layout);
			Do(\topGuiPlugIns,model,layout);
			layout.startRow;
		});
		layout.flow({ arg layout;
			this.view = layout;
			this.writeName(layout);
			this.guiBody(layout);
		},bounds).background_(this.background);
		this.enableKeyDowns;
		if(lay.isNil,{
			layout.resizeToFit.front;
			view.focus;
		})
	}
	background { ^Color.yellow(0.3,alpha:0.1) }
	topGui { arg lay,bounds ... args;
		var layout;
		layout=this.guify(lay,bounds);
		// top level controls
		this.synthConsole(layout);
		this.saveConsole(layout);
		layout.startRow;
		this.performList(\gui,[layout,bounds] ++ args);

		/** plug in **/
		Do(\topGuiPlugIns,model,layout);

		this.enableKeyDowns;
		if(lay.isNil,{
			layout.resizeToFit.front;
			view.focus;
		})
	}	
	
	writeName { arg layout,big=false; 
			//color it based on whether it has a .path 
							// (was loaded from disk)
		/*if(big,{
			InspectorLink.big(model,layout);
		},{
			InspectorLink.new(model,layout);
		});*/
		super.writeName(layout);
		if(model.path.notNil,{
			ActionButton(layout,"edit file",{
				model.path.openTextFile;
			});
		});
	}
//	keyDowns {
//		view.keyDownAction = this.keyDownResponder;
//	}
	keyDownResponder {
		var k;
		k = KeyCodeResponder.new;
		k.registerKeycode(KeyCodeResponder.normalModifier,49,{
			if(model.isPlaying,{
				model.stop
			},{
				model.play
			})
		});
		^k
	}
	saveConsole { arg layout;
		^SaveConsole(model,model.path,layout).save
			.saveAs({arg path;
				model.didSaveAs(path)
			})
			.printPath
			.print;
	}
	
	synthConsole { arg layout;
		var s;
		Server.local.gui(layout);
		s = //SynthConsole(model,layout).play.registerPlayKey.record.pauseableRecord.write({ 
			// model.timeDuration }).scope.stop.formats.tempo;
		SynthConsole(model,layout).play.record.stop.free.tempo;

		ServerErrorGui(Server.default).gui(layout);

		//NotificationCenter.register(s,\didRecordOrWrite,model,{ 
			// NotificationCenter.notify(model,\didRecordOrWrite) });
	}
	
	durationString { // time
		var dur,div;
		dur = model.timeDuration;
		if(dur.notNil,{
			^dur.asTimeString; //(dur / 60.0).asInteger.asString ++ ":" ++ (dur % 60.0).round(0.01).asString
		},{
			^"inf"
		});
	}
	durationGui { arg layout;
		var durb;
		var durv;
		// make switchable between beats and secs
		
		durv= CXLabel(layout, "dur:_____");

		layout.removeOnClose(
			Updater(model,{  arg changed,changer;// any change to model at all
				durv.label_("dur:" + this.durationString).refresh;
			}).update;
		);
		
		layout.removeOnClose(
			Updater(Tempo.default,{ // any change to Tempo
				durv.label_("dur:" + this.durationString).refresh;
			}).update;
		);
	}

}


KrPlayerGui : AbstractPlayerGui {}


