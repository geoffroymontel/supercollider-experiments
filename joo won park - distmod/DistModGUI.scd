/*

DistMod
for 18 knobs (2017)
by Joo Won Park
Last Update:1/2/2017

How to run the patch
1. Open this file in SuperCollider (available for free at http://supercollider.github.io/ )
2. Select Menu->Language->Evaluate File

For an example of a performance, visit www.joowonpark.net/distmod
For a version with MIDI controller, contact the author at
joowon@joowonpark.net

*/


//MIDIIn.connectAll;
s.waitForBoot{

SynthDef("FoldFM",{
	arg vol,modfreqmidi,distmidi, indexmidi,freqmidi,shmidi=0,
	freqscale,modfreqscale,shscale;
	var modfreq,moddist,modindex,lfo,lfo2,lfo3,carrier,freq,mix;
	freq = freqmidi*freqscale;
	freq = Lag.kr(freq,0.1);
	moddist = distmidi*30;
	modfreq = modfreqmidi*(modfreqscale);
	modindex =indexmidi*(freq*0.5);
	lfo = SinOsc.ar(modfreq,mul:moddist+1);
	lfo3 =Fold.ar(lfo,-1,1)*(modindex+(freq*0.1));
	lfo3 = Latch.ar(lfo3,Impulse.ar(shmidi*shscale+6));
	carrier = Pulse.ar(freq+lfo3,0.5,0.2);
	carrier = HPF.ar(carrier,freq*0.5);
	mix = carrier!2;
	Out.ar(0,mix*vol);
}).load(s);

SynthDef("WrapFM",{
	arg vol,modfreqmidi,distmidi, indexmidi,freqmidi,shmidi=0,
	freqscale,modfreqscale,shscale;
	var modfreq,moddist,modindex,lfo,lfo2,lfo3,carrier,freq,mix;
	freq = freqmidi*freqscale;
	freq = Lag.kr(freq,0.1);
	moddist = distmidi*30;
	modfreq = modfreqmidi*(modfreqscale);
	modindex =indexmidi*(freq*0.5);
	lfo = SinOsc.ar(modfreq,mul:moddist+1);
	lfo3 =Wrap.ar(lfo,-1,1)*(modindex+(freq*0.1));
	lfo3 = Latch.ar(lfo3,Impulse.ar(shmidi*shscale+6));
	carrier = Saw.ar(freq+lfo3,0.2);
	carrier = HPF.ar(carrier,freq*0.5);
	mix = carrier!2;
	Out.ar(0,mix*vol);
}).load(s);

SynthDef("FoldFM2",{
	arg vol,modfreqmidi,distmidi, indexmidi,freqmidi,shmidi=0,
	freqscale,modfreqscale,shscale;
	var modfreq,moddist,modindex,lfo,lfo2,lfo3,carrier,freq,mix;
	freq = freqmidi*freqscale;
	freq = Lag.kr(freq,0.1);
	moddist = distmidi*30;
	modfreq = modfreqmidi*(modfreqscale);
	modindex =indexmidi*(freq*0.5);
	lfo = SinOsc.ar(modfreq,mul:moddist+1);
	lfo3 =Fold.ar(lfo,-1,freqmidi)*(modindex+(freq*0.1));
	lfo3 = Latch.ar(lfo3,Impulse.ar(shmidi*shscale+3));
	carrier = Pulse.ar(freq+lfo3,0.4,0.2);
	carrier = LPF.ar(carrier,freq*4);
	mix = carrier!2;
	Out.ar(0,mix*vol);
}).load(s);

~dhoriz=1366;~dvert=768;
~dwindow = Window.new("DistMod");
~dwindow.front;
~dwindow.bounds=Rect(600,200,~dhoriz,~dvert);
~dwindow.background = Color.white;
~dwindow.fullScreen;

~ksize=1/6;
~ksizev=1/3;

~dsyn =Synth("FoldFM",[\vol,1.0,\modfreqscale,5,\freqscale,5000,\freqmidi,1,\shscale,100]);
~dsyn2 =Synth("WrapFM",[\vol,1.0,\modfreqscale,4,\freqscale,3000,\freqmidi,1,\shscale,100]);
~dsyn3 =Synth("FoldFM2",[\vol,1.0,\modfreqscale,3,\freqscale,2000,\freqmidi,1,\shscale,150]);

//modulation frequency
~dknob = Knob(~dwindow, Rect(~dhoriz*0.0,0*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknob.mode = \vert;
~dknob.step = 0.005;
~dknob.color = [Color.white,Color.black,Color.green,Color.black];
~dknob.action = {arg fader;NodeControl(~dsyn,1).value = (fader.value)};

//modulation shape (distortion)
~dknob2 = Knob(~dwindow, Rect(~dhoriz*~ksize*1,0*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknob2.mode = \vert;
~dknob2.step = 0.005;
~dknob2.color = [Color.white,Color.black,Color.green,Color.black];
~dknob2.action = {arg fader;NodeControl(~dsyn,2).value = (fader.value)};

//modulation index
~dknob3 = Knob(~dwindow, Rect(~dhoriz*~ksize*2,0*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknob3.mode = \vert;
~dknob3.step = 0.005;
~dknob3.color = [Color.white,Color.black,Color.green,Color.black];
~dknob3.action = {arg fader;NodeControl(~dsyn,3).value = (fader.value)};

//modulation index
~dknob4 = Knob(~dwindow, Rect(~dhoriz*~ksize*3,0*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknob4.mode = \vert;
~dknob4.step = 0.005;
~dknob4.color = [Color.white,Color.black,Color.green,Color.black];
~dknob4.action = {arg fader;NodeControl(~dsyn,4).value = (fader.value)};

//sample and hold
~dknob5 = Knob(~dwindow, Rect(~dhoriz*~ksize*4,0*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknob5.mode = \vert;
~dknob5.step = 0.005;
~dknob5.color = [Color.grey,Color.black,Color.green,Color.black];
~dknob5.action = {arg fader;NodeControl(~dsyn,5).value = (fader.value)};

//volume
~dknob6 = Knob(~dwindow, Rect(~dhoriz*~ksize*5,0*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknob6.mode = \vert;
~dknob6.step = 0.005;
~dknob6.color = [Color.red,Color.black,Color.green,Color.black];
~dknob6.action = {arg fader;NodeControl(~dsyn,0).value = (fader.value)};

//modulation frequency
~dknobB = Knob(~dwindow, Rect(~dhoriz*0.0,~dvert*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobB.mode = \vert;
~dknobB.step = 0.005;
~dknobB.color = [Color.white,Color.black,Color.yellow,Color.black];
~dknobB.action = {arg fader;NodeControl(~dsyn2,1).value = (fader.value)};

//modulation shape (distortion)
~dknobB2 = Knob(~dwindow, Rect(~dhoriz*~ksize*1,~dvert*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobB2.mode = \vert;
~dknobB2.step = 0.005;
~dknobB2.color = [Color.white,Color.black,Color.yellow,Color.black];
~dknobB2.action = {arg fader;NodeControl(~dsyn2,2).value = (fader.value)};

//modulation index
~dknobB3 = Knob(~dwindow, Rect(~dhoriz*~ksize*2,~dvert*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobB3.mode = \vert;
~dknobB3.step = 0.005;
~dknobB3.color = [Color.white,Color.black,Color.yellow,Color.black];
~dknobB3.action = {arg fader;NodeControl(~dsyn2,3).value = (fader.value)};

//modulation index
~dknobB4 = Knob(~dwindow, Rect(~dhoriz*~ksize*3,~dvert*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobB4.mode = \vert;
~dknobB4.step = 0.005;
~dknobB4.color = [Color.white,Color.black,Color.yellow,Color.black];
~dknobB4.action = {arg fader;NodeControl(~dsyn2,4).value = (fader.value)};

//sample and hold
~dknobB5 = Knob(~dwindow, Rect(~dhoriz*~ksize*4,~dvert*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobB5.mode = \vert;
~dknobB5.step = 0.005;
~dknobB5.color = [Color.grey,Color.black,Color.yellow,Color.black];
~dknobB5.action = {arg fader;NodeControl(~dsyn2,5).value = (fader.value)};

//volume
~dknobB6 = Knob(~dwindow, Rect(~dhoriz*~ksize*5,~dvert*~ksizev, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobB6.mode = \vert;
~dknobB6.step = 0.005;
~dknobB6.color = [Color.red,Color.black,Color.yellow,Color.black];
~dknobB6.action = {arg fader;NodeControl(~dsyn2,0).value = (fader.value)};

//modulation frequency
~dknobC = Knob(~dwindow, Rect(~dhoriz*0.0,~dvert*~ksizev*2, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobC.mode = \vert;
~dknobC.step = 0.005;
~dknobC.color = [Color.white,Color.black,Color.magenta,Color.black];
~dknobC.action = {arg fader;NodeControl(~dsyn3,1).value = (fader.value)};

//modulation shape (distortion)
~dknobC2 = Knob(~dwindow, Rect(~dhoriz*~ksize*1,~dvert*~ksizev*2, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobC2.mode = \vert;
~dknobC2.step = 0.005;
~dknobC2.color = [Color.white,Color.black,Color.magenta,Color.black];
~dknobC2.action = {arg fader;NodeControl(~dsyn3,2).value = (fader.value)};

//modulation index
~dknobC3 = Knob(~dwindow, Rect(~dhoriz*~ksize*2,~dvert*~ksizev*2, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobC3.mode = \vert;
~dknobC3.step = 0.005;
~dknobC3.color = [Color.white,Color.black,Color.magenta,Color.black];
~dknobC3.action = {arg fader;NodeControl(~dsyn3,3).value = (fader.value)};

//modulation index
~dknobC4 = Knob(~dwindow, Rect(~dhoriz*~ksize*3,~dvert*~ksizev*2, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobC4.mode = \vert;
~dknobC4.step = 0.005;
~dknobC4.color = [Color.white,Color.black,Color.magenta,Color.black];
~dknobC4.action = {arg fader;NodeControl(~dsyn3,4).value = (fader.value)};

//sample and hold
~dknobC5 = Knob(~dwindow, Rect(~dhoriz*~ksize*4,~dvert*~ksizev*2, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobC5.mode = \vert;
~dknobC5.step = 0.005;
~dknobC5.color = [Color.grey,Color.black,Color.magenta,Color.black];
~dknobC5.action = {arg fader;NodeControl(~dsyn3,5).value = (fader.value)};

//volume
~dknobC6 = Knob(~dwindow, Rect(~dhoriz*~ksize*5,~dvert*~ksizev*2, ~dhoriz*~ksize,~dvert*~ksizev));
~dknobC6.mode = \vert;
~dknobC6.step = 0.005;
~dknobC6.color = [Color.red,Color.black,Color.magenta,Color.black];
~dknobC6.action = {arg fader;NodeControl(~dsyn3,0).value = (fader.value)};


/*
MIDIFunc.cc({
 	arg cval,cnum,chan,device;
 	//[cval,cnum].postln;
	if (cnum==13, {
		{~dknob.value= cval/127}.defer;
		NodeControl(~dsyn,1).value =cval/127;
	});
	if (cnum==14, {
		{~dknob2.value= cval/127}.defer;
		NodeControl(~dsyn,2).value =cval/127;
	});
	if (cnum==16, {
		{~dknob3.value= cval/127}.defer;
		NodeControl(~dsyn,3).value =cval/127;
	});
	if (cnum==17, {
		{~dknob4.value= cval/127}.defer;
		NodeControl(~dsyn,4).value =cval/127;
	});
	if (cnum==19, {
		{~dknob5.value= cval/127}.defer;
		NodeControl(~dsyn,5).value =cval/127;
	});
	if (cnum==20, {
		{~dknob6.value= cval/127}.defer;
		NodeControl(~dsyn,0).value =cval/127;
	});

	//
		if (cnum==29, {
		{~dknobB.value= cval/127}.defer;
		"bang".postln;
		NodeControl(~dsyn2,1).value =cval/127;
	});
	if (cnum==30, {
		{~dknobB2.value= cval/127}.defer;
		NodeControl(~dsyn2,2).value =cval/127;
	});
	if (cnum==32, {
		{~dknobB3.value= cval/127}.defer;
		NodeControl(~dsyn2,3).value =cval/127;
	});
	if (cnum==33, {
		{~dknobB4.value= cval/127}.defer;
		NodeControl(~dsyn2,4).value =cval/127;
	});
	if (cnum==35, {
		{~dknobB5.value= cval/127}.defer;
		NodeControl(~dsyn2,5).value =cval/127;
	});
	if (cnum==36, {
		{~dknobB6.value= cval/127}.defer;
		NodeControl(~dsyn2,0).value =cval/127;
	});

		//
	if (cnum==49, {
		{~dknobC.value= cval/127}.defer;
		"bang".postln;
		NodeControl(~dsyn3,1).value =cval/127;
	});
	if (cnum==50, {
		{~dknobC2.value= cval/127}.defer;
		NodeControl(~dsyn3,2).value =cval/127;
	});
	if (cnum==52, {
		{~dknobC3.value= cval/127}.defer;
		NodeControl(~dsyn3,3).value =cval/127;
	});
	if (cnum==53, {
		{~dknobC4.value= cval/127}.defer;
		NodeControl(~dsyn3,4).value =cval/127;
	});
	if (cnum==55, {
		{~dknobC5.value= cval/127}.defer;
		NodeControl(~dsyn3,5).value =cval/127;
	});
	if (cnum==56, {
		{~dknobC6.value= cval/127}.defer;
		NodeControl(~dsyn3,0).value =cval/127;
	});
},(13..56));
*/

//initialization - needs to initialize the MIDI controller
~dknob.valueAction=1.0.rand;~dknobB.valueAction=1.0.rand;~dknobC.valueAction=1.0.rand;
~dknob2.valueAction=1.0.rand;~dknobB2.valueAction=1.0.rand;~dknobC2.valueAction=1.0.rand;
~dknob3.valueAction=1.0.rand;~dknobB3.valueAction=1.0.rand;~dknobC3.valueAction=1.0.rand;
~dknob4.valueAction=1.0.rand;~dknobB4.valueAction=1.0.rand;~dknobC4.valueAction=1.0.rand;
~dknob5.valueAction=0.5;~dknobB5.valueAction=0.5;~dknobC5.valueAction=0.5;
~dknob6.valueAction=0;~dknobB6.valueAction=0;~dknobC6.valueAction=0.0;

~dwindow.onClose={ ~dsyn.free;~dsyn2.free;~dsyn3.free};

} //waitforboot