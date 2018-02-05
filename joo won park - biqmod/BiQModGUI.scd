/*

BiQMod
for 18 knobs (2016)
by Joo Won Park
Last Update: 6/7/2016

How to run the patch
1. Open this file in SuperCollider (available for free at www.audiosynth.com)
2. Select Menu->Language->Evaluate File

For an example of a performance, visit https://youtu.be/BKHIHSaNoK0
For a version with MIDI controller or Android phone, contact the author at
joowon@joowonpark.net

*/

s.waitForBoot{
SynthDef("BiQ",{
	arg amp,thex,they,themod,thebase,pos,modrate,basefreq;
	var freq,mag,b1,b2,vib,sound,mrate,mamp,bfreq,panpan;
	freq = LinLin.kr(Lag3.kr(thex,0.2),0,1.0,0.2pi, 0.8pi);
	mag = LinLin.kr(Lag3.kr(they,0.2),0,1.0,0.39, 0.999);
	b1 = 2.0 * mag * cos(freq);
    b2 = mag.squared.neg;

	mrate = Lag3.kr(modrate*themod,0.2);
	bfreq = Lag3.kr(basefreq*thebase,0.18);

	panpan = LinLin.kr(Lag3.kr(pos,0.1),0,1.0,-1.0,1.0);

	vib = SOS.kr(LFSaw.kr(mrate), 1.0, 0.0, 0.0, b1, b2);
	sound =  SinOsc.ar( vib * (bfreq*0.41) + bfreq) * Lag3.kr(amp,0.2)*0.5;
	sound  = Pan2.ar(sound,panpan);
	Out.ar(0,sound);
}).load(s);

SynthDef("BiQ2",{
	arg amp,thex,they,themod,thebase,pos,modrate,basefreq;
	var freq,mag,b1,b2,vib,sound,mrate,mamp,bfreq,panpan;
	freq = LinLin.kr(Lag3.kr(thex,0.2),0,1.0,0.2pi, 0.8pi);
	mag = LinLin.kr(Lag3.kr(they,0.2),0,1.0,0.39, 0.999);
	b1 = 2.0 * mag * cos(freq);
    b2 = mag.squared.neg;

	mrate = Lag3.kr(modrate*themod,0.2);
	bfreq = Lag3.kr(basefreq*thebase,0.18);
	//bfreq = basefreq*thebase;
	panpan = LinLin.kr(Lag3.kr(pos,0.1),0,1.0,-1.0,1.0);

	vib = SOS.kr(LFPulse.kr(mrate), 1.0, 0.0, 0.0, b1, b2);
	sound =  SinOsc.ar( vib * (bfreq*0.41) + bfreq) * Lag3.kr(amp,0.2)*0.5;
	sound  = Pan2.ar(sound,panpan);
	Out.ar(0,sound);
}).load(s);

SynthDef("BiQ3",{
	arg amp,thex,they,themod,thebase,pos,modrate,basefreq;
	var freq,mag,b1,b2,vib,sound,mrate,mamp,bfreq,panpan;
	freq = LinLin.kr(Lag3.kr(thex,0.2),0,1.0,0.2pi, 0.8pi);
	mag = LinLin.kr(Lag3.kr(they,0.2),0,1.0,0.39, 0.999);
	b1 = 2.0 * mag * cos(freq);
    b2 = mag.squared.neg;

	mrate = Lag3.kr(modrate*themod,0.2);
	bfreq = Lag3.kr(basefreq*thebase,0.18);
	//bfreq = basefreq*thebase;
	panpan = LinLin.kr(Lag3.kr(pos,0.1),0,1.0,-1.0,1.0);

	vib = SOS.kr(LFTri.kr(mrate), 1.0, 0.0, 0.0, b1, b2);
	sound =  SinOsc.ar( vib * (bfreq*0.41) + bfreq) * Lag3.kr(amp,0.2)*0.5;
	sound  = Pan2.ar(sound,panpan);
	Out.ar(0,sound);
}).load(s);

//GUI
~horiz=900;~vert=600;
~inhoriz = ~horiz*0.9;~invert=~vert*0.9;
~column=6;~row=3;
~knobsize = ~invert/~row*0.5;
~knobx = {
	arg x;
	~inhoriz/~column*x+(~horiz*0.08);
};
~knoby = {
	arg y;
	~invert/~row*y+(~vert*0.1);
};

~window = Window.new("Panel");
~window.front;
~window.bounds=Rect(600,50,~horiz,~vert);
~window.background = Color.white;

//SYNTH1
~syn=Synth("BiQ",[\amp,0.2,\modrate,300,\basefreq,8000,\thex,0.2pi,\they,0.34,\themod,1,\thebase,1,\pos,0.5]);
//filter freq
~knob = Knob(~window, Rect(~knobx.value(0),~knoby.value(0), ~knobsize, ~knobsize));
~knob.mode = \vert;
~knob.step = 0.005;
~knob.color = [Color.white,Color.black,Color.green,Color.black];
~knob.action = {arg fader;NodeControl(~syn,1).value = (fader.value)};
//resonance
~knob2 = Knob(~window, Rect(~knobx.value(1),~knoby.value(0), ~knobsize, ~knobsize));
~knob2.mode = \vert;
~knob2.step = 0.005;
~knob2.color = [Color.white,Color.black,Color.green,Color.black];
~knob2.action = {arg fader;NodeControl(~syn,2).value = (fader.value)};
//modulation rate
~knob3 = Knob(~window, Rect(~knobx.value(2),~knoby.value(0), ~knobsize, ~knobsize));
~knob3.mode = \vert;
~knob3.step = 0.005;
~knob3.color = [Color.white,Color.black,Color.green,Color.black];
~knob3.action = {arg fader;NodeControl(~syn,3).value = (fader.value)};
//basefreq
~knob4 = Knob(~window, Rect(~knobx.value(3),~knoby.value(0), ~knobsize, ~knobsize));
~knob4.mode = \vert;
~knob4.step = 0.005;
~knob4.color = [Color.white,Color.black,Color.green,Color.black];
~knob4.action = {arg fader;NodeControl(~syn,4).value = (fader.value)};
//pan
~knob5 = Knob(~window, Rect(~knobx.value(4),~knoby.value(0), ~knobsize, ~knobsize));
~knob5.mode = \vert;
~knob5.step = 0.005;
~knob5.color = [Color.white,Color.black,Color.green,Color.black];
~knob5.action = {arg fader;NodeControl(~syn,5).value = (fader.value)};
//vol
~knob6 = Knob(~window, Rect(~knobx.value(5),~knoby.value(0), ~knobsize, ~knobsize));
~knob6.mode = \vert;
~knob6.step = 0.01;
~knob6.color = [Color.black,Color.black,Color.green,Color.white];
~knob6.action = {arg fader;NodeControl(~syn,0).value = (fader.value)};

//SYNTH2
~syn2=Synth("BiQ2",[\amp,0.2,\modrate,300,\basefreq,2000,\thex,0.2pi,\they,0.34,\themod,1,\thebase,1,\pos,0.5]);
//filter freq
~bknob = Knob(~window, Rect(~knobx.value(0),~knoby.value(1), ~knobsize, ~knobsize));
~bknob.mode = \vert;
~bknob.step = 0.005;
~bknob.color = [Color.white,Color.black,Color.yellow,Color.black];
~bknob.action = {arg fader;NodeControl(~syn2,1).value = (fader.value)};
//resonance
~bknob2 = Knob(~window, Rect(~knobx.value(1),~knoby.value(1), ~knobsize, ~knobsize));
~bknob2.mode = \vert;
~bknob2.step = 0.005;
~bknob2.color = [Color.white,Color.black,Color.yellow,Color.black];
~bknob2.action = {arg fader;NodeControl(~syn2,2).value = (fader.value)};
//modulation rate
~bknob3 = Knob(~window, Rect(~knobx.value(2),~knoby.value(1), ~knobsize, ~knobsize));
~bknob3.mode = \vert;
~bknob3.step = 0.005;
~bknob3.color = [Color.white,Color.black,Color.yellow,Color.black];
~bknob3.action = {arg fader;NodeControl(~syn2,3).value = (fader.value)};
//basefreq
~bknob4 = Knob(~window, Rect(~knobx.value(3),~knoby.value(1), ~knobsize, ~knobsize));
~bknob4.mode = \vert;
~bknob4.step = 0.005;
~bknob4.color = [Color.white,Color.black,Color.yellow,Color.black];
~bknob4.action = {arg fader;NodeControl(~syn2,4).value = (fader.value)};
//pan
~bknob5 = Knob(~window, Rect(~knobx.value(4),~knoby.value(1), ~knobsize, ~knobsize));
~bknob5.mode = \vert;
~bknob5.step = 0.005;
~bknob5.color = [Color.white,Color.black,Color.yellow,Color.black];
~bknob5.action = {arg fader;NodeControl(~syn2,5).value = (fader.value)};
//vol
~bknob6 = Knob(~window, Rect(~knobx.value(5),~knoby.value(1), ~knobsize, ~knobsize));
~bknob6.mode = \vert;
~bknob6.step = 0.01;
~bknob6.color = [Color.black,Color.black,Color.yellow,Color.white];
~bknob6.action = {arg fader;NodeControl(~syn2,0).value = (fader.value)};

//SYNTH3
~syn3=Synth("BiQ3",[\amp,0.2,\modrate,100,\basefreq,1000,\thex,0.2pi,\they,0.34,\themod,1,\thebase,1,\pos,0.5]);
//filter freq
~cknob = Knob(~window, Rect(~knobx.value(0),~knoby.value(2), ~knobsize, ~knobsize));
~cknob.mode = \vert;
~cknob.step = 0.005;
~cknob.color = [Color.white,Color.black,Color.red,Color.black];
~cknob.action = {arg fader;NodeControl(~syn3,1).value = (fader.value)};
//resonance
~cknob2 = Knob(~window, Rect(~knobx.value(1),~knoby.value(2), ~knobsize, ~knobsize));
~cknob2.mode = \vert;
~cknob2.step = 0.005;
~cknob2.color = [Color.white,Color.black,Color.red,Color.black];
~cknob2.action = {arg fader;NodeControl(~syn3,2).value = (fader.value)};
//modulation rate
~cknob3 = Knob(~window, Rect(~knobx.value(2),~knoby.value(2), ~knobsize, ~knobsize));
~cknob3.mode = \vert;
~cknob3.step = 0.005;
~cknob3.color = [Color.white,Color.black,Color.red,Color.black];
~cknob3.action = {arg fader;NodeControl(~syn3,3).value = (fader.value)};
//basefreq
~cknob4 = Knob(~window, Rect(~knobx.value(3),~knoby.value(2), ~knobsize, ~knobsize));
~cknob4.mode = \vert;
~cknob4.step = 0.005;
~cknob4.color = [Color.white,Color.black,Color.red,Color.black];
~cknob4.action = {arg fader;NodeControl(~syn3,4).value = (fader.value)};
//pan
~cknob5 = Knob(~window, Rect(~knobx.value(4),~knoby.value(2), ~knobsize, ~knobsize));
~cknob5.mode = \vert;
~cknob5.step = 0.005;
~cknob5.color = [Color.white,Color.black,Color.red,Color.black];
~cknob5.action = {arg fader;NodeControl(~syn3,5).value = (fader.value)};
//vol
~cknob6 = Knob(~window, Rect(~knobx.value(5),~knoby.value(2), ~knobsize, ~knobsize));
~cknob6.mode = \vert;
~cknob6.step = 0.01;
~cknob6.color = [Color.black,Color.black,Color.red,Color.white];
~cknob6.action = {arg fader;NodeControl(~syn3,0).value = (fader.value)};

//MIDI

MIDIFunc.cc({
 	arg cval,cnum,chan,device;
 	//[cval,cnum].postln;
	if (cnum==13, {
		{~knob.value= cval/127}.defer;
		NodeControl(~syn,1).value =cval/127;
	});
	if (cnum==14, {
		{~knob2.value= cval/127}.defer;
		NodeControl(~syn,2).value =cval/127;
	});
		if (cnum==16, {
		{~knob3.value= cval/127}.defer;
		NodeControl(~syn,3).value =cval/127;
	});
		if (cnum==17, {
		{~knob4.value= cval/127}.defer;
		NodeControl(~syn,4).value =cval/127;
	});
		if (cnum==19, {
		{~knob5.value= cval/127}.defer;
		NodeControl(~syn,5).value =cval/127;
	});
			if (cnum==20, {
		{~knob6.value= cval/127}.defer;
		NodeControl(~syn,0).value =cval/127;
	});
},(13..20));

MIDIFunc.cc({
 	arg cval,cnum,chan,device;
 	//[cval,cnum].postln;
	if (cnum==29, {
		{~bknob.value= cval/127}.defer;
		NodeControl(~syn2,1).value =cval/127;
	});
	if (cnum==30, {
		{~bknob2.value= cval/127}.defer;
		NodeControl(~syn2,2).value =cval/127;
	});
		if (cnum==32, {
		{~bknob3.value= cval/127}.defer;
		NodeControl(~syn2,3).value =cval/127;
	});
		if (cnum==33, {
		{~bknob4.value= cval/127}.defer;
		NodeControl(~syn2,4).value =cval/127;
	});
		if (cnum==35, {
		{~bknob5.value= cval/127}.defer;
		NodeControl(~syn2,5).value =cval/127;
	});
			if (cnum==36, {
		{~bknob6.value= cval/127}.defer;
		NodeControl(~syn2,0).value =cval/127;
	});
},(29..36));

MIDIFunc.cc({
 	arg cval,cnum,chan,device;
 	//[cval,cnum].postln;
	if (cnum==49, {
		{~cknob.value= cval/127}.defer;
		NodeControl(~syn3,1).value =cval/127;
	});
	if (cnum==50, {
		{~cknob2.value= cval/127}.defer;
		NodeControl(~syn3,2).value =cval/127;
	});
		if (cnum==52, {
		{~cknob3.value= cval/127}.defer;
		NodeControl(~syn3,3).value =cval/127;
	});
		if (cnum==53, {
		{~cknob4.value= cval/127}.defer;
		NodeControl(~syn3,4).value =cval/127;
	});
		if (cnum==55, {
		{~cknob5.value= cval/127}.defer;
		NodeControl(~syn3,5).value =cval/127;
	});
			if (cnum==56, {
		{~cknob6.value= cval/127}.defer;
		NodeControl(~syn3,0).value =cval/127;
	});
},(49..56));


//initialization - needs to initialize the MIDI controller
~knob.valueAction=1.0.rand;~bknob.valueAction=1.0.rand;~cknob.valueAction=1.0.rand;
~knob2.valueAction=1.0.rand;~bknob2.valueAction=1.0.rand;~cknob2.valueAction=1.0.rand;
~knob3.valueAction=1.0.rand;~bknob3.valueAction=1.0.rand;~cknob3.valueAction=1.0.rand;
~knob4.valueAction=1.0.rand;~bknob4.valueAction=1.0.rand;~cknob4.valueAction=1.0.rand;
~knob5.valueAction=0.5;~bknob5.valueAction=0.5;~cknob5.valueAction=0.5;
~knob6.valueAction=0.5;~bknob6.valueAction=0.5;~cknob6.valueAction=0.5;

~window.onClose={ ~syn.free;~syn2.free;~syn3.free};

//waitforboot
}