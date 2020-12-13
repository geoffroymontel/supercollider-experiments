ModPod {
	var <recNames, <recTargets, <recArgs, <recBusses, <modNames, <modBusses, <outbus, <prebus;
	var <numpods, <sliderSpec, <group;
	var <bypassButt, <recMenu, <viaMenu, <modMenu, <viaSlider, <modSlider;
	var view, <routeSynth, <mixSynth, isBypassed, isVia, hasGui=false;
	var recIndex, modIndex, <stateSet, <>quickPre;
	var activeIndexes;
	
	*initClass {
		SynthDef.writeOnce("mpRouter", {|in_mod=17, mod_out=16, scale=0.0, min= -1.0, max=1.0|
			Out.kr(mod_out, In.kr(in_mod) * scale.range(min, max))
		}, dir: String.scDir ++ "/synthdefs/");

		SynthDef.writeOnce("mpMixerring", {|value=1, in=17, out=16|
			Out.kr(out, value.ring1(In.kr(in)))
		}, dir: String.scDir ++ "/synthdefs/");
		
		SynthDef.writeOnce("mpMixeradd", {|value=1, in=17, out=16|
			Out.kr(out, value + In.kr(in))
		}, dir: String.scDir ++ "/synthdefs/");
	}
	
	*new {|numpods, receivers, modulators|
		^super.new.init(numpods, receivers, modulators)
	}
	
	init {|num, receivers, modulators|
		var recBundle, recMaps, routeBundle;
		numpods=num;
		quickPre=Array.newClear(24);
		bypassButt=Array.newClear(numpods);
		isBypassed=Array.fill(numpods, false);
		isVia=Array.fill(numpods, false);
		recMenu=Array.newClear(numpods);
		viaMenu=Array.newClear(numpods);
		modMenu=Array.newClear(numpods);
		viaSlider=Array.newClear(numpods);
		modSlider=Array.newClear(numpods);
		recIndex=Array.fill(numpods, 0);
		modIndex=Array.fill(numpods, 0);
		group=Array.fill(numpods, { Group.new });
		recNames=Array.newClear(receivers.size);
		recTargets=Array.newClear(receivers.size);
		recArgs=Array.newClear(receivers.size);
		recBusses=Array.newClear(receivers.size);
		prebus=Array.newClear(receivers.size);
		outbus=Array.newClear(receivers.size);
		mixSynth=Array.newClear(receivers.size);
		recBundle=Array.newClear(receivers.size);
		recMaps=Array.newClear(receivers.size);
		sliderSpec=Array.newClear(receivers.size);
		modNames=Array.newClear(modulators.size);
		modBusses=Array.newClear(modulators.size);
		stateSet=Array.fill(numpods, { [false, 0, 0, 0, 0, 0] });
		receivers.do({|each, count|
			var modtype, specfunc;
			prebus.put(count, Bus.control(Server.default, 1));
			outbus.put(count, Bus.control(Server.default, 1)); 
			recNames.put(count, each[0]);
			recArgs.put(count, each[1]);
			recTargets.put(count, each[2]);
			recBusses.put(count, each[3]);
			modtype=each[4] ? \add;
			specfunc=each[5] ? {|v| var val; val=\pan.asSpec.map(v); val.squared * val.sign; };
			sliderSpec.put(count, specfunc);
			mixSynth.put(count, Synth.basicNew(\mpMixer ++ modtype));
			recBundle.put(count, mixSynth.at(count).newMsg(nil, 
				[\in, prebus[count].index, \out, outbus[count].index])
			);
			recMaps.put(count, [14, mixSynth.at(count).nodeID, \value, recBusses[count]]);
			// mixSynth[count].map(\value, recBusses[count]);
		});
		Server.default.listSendBundle(0.1, recBundle ++ recMaps);
		modulators.do({|each, count|
			modNames.put(count, each[0]);
			modBusses.put(count, each[1]);
		});
		routeSynth=Array.fill2D(numpods, 127, nil);
		routeBundle=Array.newClear(numpods);
		numpods.do({|i|
			group[i].run(false);
			routeSynth[i][0]=Synth.basicNew(\mpRouter);
			routeBundle.put(i, routeSynth.at(i).at(0).newMsg(group[i]));
		});
		Server.default.listSendBundle(0.1, routeBundle);
		// activeIndexes=List.new;
		CmdPeriod.doOnce({ outbus.do({|each, count| Server.default.audioBusAllocator.free(each.index); Server.default.audioBusAllocator.free(prebus[count].index) }) });
	}
	
	checkModulated {|index|
			var isModulated=false;
			stateSet.do({|each, count|
				(((each[1] - 1) == recIndex[index]) &&
					(count != index) && (each[3] > 0) &&
					(each[0]==false)).if({
						isModulated=true;
					});
			});
			^isModulated;
	}
	
	bypass {|pod|
		(stateSet[pod][0].not).if({
			stateSet[pod][0]=true;
			group[pod].run(false);
			(this.checkModulated(pod).not).if({
				recTargets[recIndex[pod]].map(recArgs[recIndex[pod]], 
					recBusses[recIndex[pod]]);
			});
			(hasGui).if({ { bypassButt[pod].value_(1) }.defer });
		});
	}
	
	unbypass {|pod|
		(stateSet[pod][0]).if({
			stateSet[pod][0]=false;
				((stateSet[pod][1] > 0) && (stateSet[pod][3] > 0)).if({
					group[pod].run(true);
					recTargets[recIndex[pod]].map(recArgs[recIndex[pod]], 
						outbus[recIndex[pod]].index);
				});
			(hasGui).if({ { bypassButt[pod].value_(0) }.defer });
		});
	}
	
	setReceiver {|pod, val|
		var index, podState;
		stateSet[pod][1]=val;
		podState=stateSet[pod];
		(val==0).if({
			group[pod].run(false);
			(this.checkModulated(pod).not).if({
				recTargets[recIndex[pod]].map(recArgs[recIndex[pod]], 
					recBusses[recIndex[pod]]);
			});
		}, {
			index=val-1;
			group[pod].set(\mod_out, prebus[index].index);
			((podState[0].not) && (podState[3] > 0)).if({
				group[pod].run(true);
				recTargets[index].map(recArgs[index], outbus[index].index);
			});
			recIndex[pod]=index;
		});
		(hasGui).if({ { recMenu[pod].value_(val) }.defer });
	}
	
	setVia {|pod, val|
		var index, podState;
		stateSet[pod][2]=val;
		podState=stateSet[pod];
		(val==0).if({
			isVia[pod]=false;
			group[pod].set(\scale, podState[4], \min, -1, \max, 1);
			(hasGui).if({
				{
					viaSlider[pod].visible_(false);
					modSlider[pod].visible_(true);
					viaMenu[pod].value_(val);
				}.defer;
			});
		}, {
			index=val-1;
			(isVia[pod].not).if({
				isVia[pod]=true;
				(hasGui).if({
					{
						modSlider[pod].visible_(false);
						viaSlider[pod].visible_(true);
						viaMenu[pod].value_(val);
					}.defer;
				});
				group[pod].set(\min, podState[5],
					\max, podState[4])
			});
			group[pod].map(\scale, modBusses[index]);
		});
	}
	
	setModulator {|pod, val|
		var index, podState;
		stateSet[pod][3]=val;
		podState=stateSet[pod];
		(val==0).if({
			group[pod].run(false);
			(this.checkModulated(pod).not).if({
				recTargets[modIndex[pod]].map(recArgs[modIndex[pod]], 
					recBusses[modIndex[pod]]);
			});
		}, {
			index=val-1;
			group[pod].set(\in_mod, modBusses[index]);
			((podState[0].not) && (podState[1] > 0)).if({
				group[pod].run(true);
				recTargets[recIndex[pod]]
					.map(recArgs[recIndex[pod]], outbus[recIndex[pod]].index);
			});
			modIndex[pod]=index;
		});
		(hasGui).if({ { modMenu[pod].value_(val) }.defer });
	}
	
	setScale {|pod, val|
		var podState, unmapped, minval, maxval;
		(isVia[pod].not).if({
			stateSet[pod][4]=val;
			podState=stateSet[pod];
			group[pod].set(\scale, val);
			(hasGui).if({
				{
					/*
					minval=sliderSpec[recIndex[pod]].value(0);
					maxval=sliderSpec[recIndex[pod]].value(1);
					unmapped=val - minval * (maxval - minval).reciprocal;
					*/
					unmapped=val.abs.sqrt * val.sign + 1 * 0.5; 
					modSlider[pod].value_(unmapped);
					viaSlider[pod].lo_(unmapped);
					viaSlider[pod].hi_(unmapped);
				}.defer;
			});
		});
	}
	
	setRange {|pod, lo, hi|
		var podState, unmap, lo_unmap, hi_unmap, minval, maxval;
		(isVia[pod]).if({
			stateSet[pod][4]=hi;
			stateSet[pod][5]=lo;
			podState=stateSet[pod];
			group[pod].set(\min, lo, \max, hi);
			(hasGui).if({
				{
					/*
					minval=sliderSpec[recIndex[pod]].value(0);
					maxval=sliderSpec[recIndex[pod]].value(1);
					unmap=(maxval - minval).reciprocal;
					lo_unmap=lo - minval * unmap;
					hi_unmap=hi - minval * unmap;
					*/
					lo_unmap=lo.abs.sqrt * lo.sign + 1 * 0.5;
					hi_unmap=hi.abs.sqrt * hi.sign + 1 * 0.5;
					modSlider[pod].value_(hi_unmap);
					viaSlider[pod].lo_(lo_unmap);
					viaSlider[pod].hi_(hi_unmap);
				}.defer;
			});
		});
	}
	
	bypassMsg {|pod|
		var msg;
		msg=Array.new;
		stateSet[pod][0]=true;
		msg=msg.add(group[pod].runMsg(false));
		(this.checkModulated(pod).not).if({
			msg=msg.add(recTargets[recIndex[pod]].mapMsg(recArgs[recIndex[pod]], 
				recBusses[recIndex[pod]]));
		});
		(hasGui).if({ { bypassButt[pod].value_(1) }.defer });
		^msg;
	}
	
	unbypassMsg {|pod|
		var msg;
		stateSet[pod][0]=false;
		((stateSet[pod][1] > 0) && (stateSet[pod][3] > 0)).if({
			msg=Array.new;
			msg=msg.add(group[pod].runMsg(true));
			msg=msg.add(recTargets[recIndex[pod]].mapMsg(recArgs[recIndex[pod]], 
				outbus[recIndex[pod]].index));
		}, {
			msg=nil;
		});
		(hasGui).if({ { bypassButt[pod].value_(0) }.defer });
		^msg;
	}
	
	setReceiverMsg {|pod, val|
		var index, podState, msg;
		stateSet[pod][1]=val;
		podState=stateSet[pod];
		msg=Array.new;
		(val==0).if({
			msg=msg.add(group[pod].runMsg(false));
			(this.checkModulated(pod).not).if({
				msg=msg.add(recTargets[recIndex[pod]].mapMsg(recArgs[recIndex[pod]], 
					recBusses[recIndex[pod]]));
			});
		}, {
			index=val-1;
			msg=msg.add(group[pod].setMsg(\mod_out, prebus[index].index));
			((podState[0].not) && (podState[3] > 0)).if({
				msg=msg.add(group[pod].runMsg(true));
				msg=msg.add(recTargets[index].mapMsg(recArgs[index], outbus[index].index));
			});
			recIndex[pod]=index;
		});
		(hasGui).if({ { recMenu[pod].value_(val) }.defer });
		^msg;
	}
	
	setViaMsg {|pod, val|
		var index, podState, msg;
		stateSet[pod][2]=val;
		podState=stateSet[pod];
		msg=Array.new;
		(val==0).if({
			isVia[pod]=false;
			msg=msg.add(group[pod].setMsg(\min, -1, \max, 1));
			(hasGui).if({
				{
					viaSlider[pod].visible_(false);
					modSlider[pod].visible_(true);
					viaMenu[pod].value_(val);
				}.defer;
			});
		}, {
			index=val-1;
			(isVia[pod].not).if({
				isVia[pod]=true;
				(hasGui).if({
					{
						modSlider[pod].visible_(false);
						viaSlider[pod].visible_(true);
						viaMenu[pod].value_(val);
					}.defer;
				});
				msg=msg.add(group[pod].setMsg(\min, podState[5],
					\max, podState[4]))
			});
			msg=msg.add(group[pod].mapMsg(\scale, modBusses[index]));
		});
		^msg;
	}
	
	setModulatorMsg {|pod, val|
		var index, podState, msg;
		stateSet[pod][3]=val;
		podState=stateSet[pod];
		msg=Array.new;
		(val==0).if({
			msg=msg.add(group[pod].runMsg(false));
			(this.checkModulated(pod).not).if({
				msg=msg.add(recTargets[modIndex[pod]].mapMsg(recArgs[modIndex[pod]], 
					recBusses[modIndex[pod]]));
			});
		}, {
			index=val-1;
			msg=msg.add(group[pod].setMsg(\in_mod, modBusses[index]));
			((podState[0].not) && (podState[1] > 0)).if({
				msg=msg.add(group[pod].runMsg(true));
				msg=msg.add(recTargets[recIndex[pod]]
					.mapMsg(recArgs[recIndex[pod]], outbus[recIndex[pod]].index));
			});
			modIndex[pod]=index;
		});
		(hasGui).if({ { modMenu[pod].value_(val) }.defer });
		^msg;
	}
	
	setScaleMsg {|pod, val|
		var podState, unmapped, minval, maxval, msg;
		(isVia[pod].not).if({
			stateSet[pod][4]=val;
			podState=stateSet[pod];
			msg=[group[pod].setMsg(\scale, val)];
			(hasGui).if({
				{
					/*
					minval=sliderSpec[recIndex[pod]].value(0);
					maxval=sliderSpec[recIndex[pod]].value(1);
					unmapped=val - minval * (maxval - minval).reciprocal;
					*/
					unmapped=val.abs.sqrt * val.sign + 1 * 0.5;
					modSlider[pod].value_(unmapped);
					viaSlider[pod].lo_(unmapped);
					viaSlider[pod].hi_(unmapped);
				}.defer;
			});
			^msg;
		});
		^nil;
	}
	
	setRangeMsg {|pod, lo, hi|
		var podState, unmap, lo_unmap, hi_unmap, minval, maxval, msg;
		(isVia[pod]).if({
			stateSet[pod][4]=hi;
			stateSet[pod][5]=lo;
			podState=stateSet[pod];
			msg=[group[pod].setMsg(\min, lo, \max, hi)];
			(hasGui).if({
				{
					/*
					minval=sliderSpec[recIndex[pod]].value(0);
					maxval=sliderSpec[recIndex[pod]].value(1);
					unmap=(maxval - minval).reciprocal;
					lo_unmap=lo - minval * unmap;
					hi_unmap=hi - minval * unmap;
					*/
					lo_unmap=lo.abs.sqrt * lo.sign + 1 * 0.5;
					hi_unmap=hi.abs.sqrt * hi.sign + 1 * 0.5;
					modSlider[pod].value_(hi_unmap);
					viaSlider[pod].lo_(lo_unmap);
					viaSlider[pod].hi_(hi_unmap);
				}.defer;
			});
			^msg;
		});
		^nil;
	}
	
	gui {|parent, perRow=8|
		var podIncr=0, newview=false, prename;
		hasGui=true;
		(parent.isNil).if({ 
			view=MultiPageLayout.new("Mod Pod");
			newview=true;
		}, {
			view=parent;
		});
		numpods.do({|i|
			var composite;
			(podIncr >= perRow).if({ podIncr=0; view.startRow; });
			view.vert({|v|
					v.flow({|h|
					bypassButt[i]=SCButton(h, 60@17)
						.states_([["Bypass", Color.white, Color.black], 
							["Bypass", Color.black, Color.white]])
						.action_({|v|
							(v.value==1).if({ this.bypass(i); }, { this.unbypass(i); });
						});
					(stateSet[i][0]).if({ bypassButt[i].value_(1) });
					SCButton(h, 18@16)
						.states_([["0"], ["0"]])
						.action_({ 
							modSlider[i].valueAction_(0.5); 
							viaSlider[i].activeLo_(0.5); 
							viaSlider[i].activeHi_(0.5) 
						});
					}, 84@18);
				recMenu[i]=SCPopUpMenu(v, 80@17)
					.items_(["off"] ++ recNames)
					.action_({|v| this.setReceiver(i, v.value) })
					.value_(stateSet[i][1]);
				viaMenu[i]=SCPopUpMenu(v, 80@17)
					.items_(["off"] ++ modNames)
					.action_({|v| this.setVia(i, v.value); })
					.value_(stateSet[i][2]);
				modMenu[i]=SCPopUpMenu(v, 80@17)
					.items_(["off"] ++ modNames)
					.action_({|v| this.setModulator(i, v.value); })
					.value_(stateSet[i][3]);
			}, 86@82);
			composite=SCCompositeView(view, 15@86);
			viaSlider[i]=SCRangeSlider(composite, 
				Rect(composite.bounds.left, composite.bounds.top, 10, 85))
				.action_({|v|
					var min, max;
					min=sliderSpec[recIndex[i]].value(v.lo); 
					max=sliderSpec[recIndex[i]].value(v.hi);
					stateSet[i][4]=max;
					stateSet[i][5]=min;
					modSlider[i].value_(v.hi);
					group[i].set(\min, min, \max, max);
				})
				.visible_(false);
			modSlider[i]=SCSlider(composite, 
				Rect(composite.bounds.left, composite.bounds.top, 10, 85))
				.action_({|v|
					var val;
					val=sliderSpec[recIndex[i]].value(v.value);
					stateSet[i][4]=val;
					viaSlider[i].lo_(v.value);
					viaSlider[i].hi_(v.value);
					group[i].set(\scale, val)
				})
				.thumbSize_(2);
			this.setRange(i, stateSet[i][5], stateSet[i][4]);
			this.setScale(i, stateSet[i][4]);
			podIncr=podIncr + 1;
		});
		view.startRow;
		ActionButton(view, " S ", {
			CocoaDialog.savePanel({|path|
				var arr;
				arr=this.getValues;
				arr.writeTextArchive(path);
			})
		});
		ActionButton(view, " L ", {
			CocoaDialog.getPaths({|path|
				this.setValues(Object.readTextArchive(path[0]));
			})
		});	
		(min(numpods * 3, 24)).do({|i|
			SCButton(view, 18@16)
				.states_([[(i + 1).asString]])
				.mouseDownAction_({|v, x, y, mod|
					var state;
					((mod==131332) || (mod==131330)).if({
						state=this.getValues;
						this.quickPre.put(i, state);
					}, {
						(this.quickPre.at(i).notNil).if({
							state=this.quickPre.at(i);
							this.setValues(state);
							prename.string_(' ' ++ (i + 1).asString);
						});
					});
				});
		});
		prename=SCStaticText(view,18@16).string_('');
		view.onClose_({ hasGui=false });
		(newview).if({ view.resizeToFit; view.front; });
	}
	
	getValues { 
		var state;
		state=stateSet.deepCopy;
		^state;
	}
	
	setValues {|list|
		var msg, unpackMsg, tmpmsg;
		msg=List.new;
		tmpmsg=List.new;
		unpackMsg={|arr|
			arr.do({|e, c|
				(e.notNil).if({
					(e[0].isArray).if({
						unpackMsg.value(e);
					}, {
						msg=msg.add(e);
					});
				});
			});
		};
		numpods.do({|i|
			tmpmsg=tmpmsg.add(this.bypassMsg(i));
			tmpmsg=tmpmsg.add(this.setReceiverMsg(i, 0));
			tmpmsg=tmpmsg.add(this.setViaMsg(i, 0));
			tmpmsg=tmpmsg.add(this.setModulatorMsg(i, 0));
			tmpmsg=tmpmsg.add(this.setScaleMsg(i, 0));
			tmpmsg=tmpmsg.add(this.setRangeMsg(i, 0, 0));
		});
		unpackMsg.value(tmpmsg);
		Server.default.listSendBundle(0.03, msg);
		msg=List.new;
		tmpmsg=List.new;
		list.do({|e, c|
			(e[0]).if({ tmpmsg=tmpmsg.add(this.bypassMsg(c)) }, { tmpmsg=tmpmsg.add(this.unbypassMsg(c)) });
			tmpmsg=tmpmsg.add(this.setReceiverMsg(c, e[1]));
			tmpmsg=tmpmsg.add(this.setViaMsg(c, e[2]));
			tmpmsg=tmpmsg.add(this.setModulatorMsg(c, e[3]));
			tmpmsg=tmpmsg.add(this.setScaleMsg(c, e[4]));
			tmpmsg=tmpmsg.add(this.setRangeMsg(c, e[5], e[4]));
		});
		unpackMsg.value(tmpmsg);
		Server.default.listSendBundle(0.04, msg);
	}
}