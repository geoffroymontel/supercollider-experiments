
Platform.userExtensionDir
Platform.systemExtensionDir
StageLimiter.activate
(
//////////////samples
(
(
~sound_array = [
//////put samples here


];
);
(
~buffer_array = Array.new;

~sound_array.size.do({arg i;
	i.postln;
	~buffeer_array = ~buffer_array.add( Buffer.read(s, ~sound_array[i]));
});
);

);

(
 SynthDef(\freeze, { arg out = 0,in = ~freezeBus, wich = 0, lpFreq = 20000, lpQ =1,loop = ~loop_bus,
	bufnum = 0, spread = 1, pan = 0, lfoRate = 2,dub = c, thresh = (-60),
	wipe = 0.5, width=0.1, lfoAmount = 0.5, volume = 0.5,
	rate = 1, rateLfoAmount = 0, wich2 = 0, t_trig = 1, density = 10, freeze = 0,lfoLo = 0.002, lfoHi = 20, wipeTrig = 0, wipeMode = 0, gateThresh = 0.01, smooth = 1,lfoRate2 = 2, panLfoAmount = 0.5, gain = 3, freqShift = 0,wipeLfoAmount = 0, pitchShift = 0,distortSmooth =0, distortAmp =0, fEnvAmount = 0, filterLfoAmount = 0,feedback=0.2,wetAmp = 0.5, highPass = 20, buf = 0, gate = 1,atk = 0.1, sus = 1, rel = 1;

var lfoMaster, ampTrig, sig,lfo1, select2, select, splay,
	input, comp1, chain, ampf, wipeEnv, comp, rateLfo,
	panLfo, imp, delimp, colum, env,osc,osc2,
	selectWipe, div,chainB, dust,lfoMaster2, ptr, ptr2,write,bufRec,bufRead,fShift, mic,chainA,wipeLfo, distort,envFollower,filterLfo,local,durLfo,pos,gran;


	/////Modules og LFO
	dust = Dust.kr(density);

	lfoMaster = LFNoise2.kr(0.2).range(lfoLo.lag(0.5),lfoHi.lag(0.5));

	lfoMaster2 = LFNoise2.kr(0.4).range(lfoLo.lag(0.5),lfoHi.lag(0.5));

    wipeLfo = LFNoise2.kr(lfoMaster).range(0.00,1)*wipeLfoAmount.lag(0.5);

	rateLfo = LFNoise2.kr(lfoMaster.clip(0.002,200).lag(0.5)).range(-5.0,5.0).clip(-5,5)*rateLfoAmount;

	panLfo = LFNoise2.ar(lfoMaster).range(-1.00,1.00)*panLfoAmount.lag(0.5);

	filterLfo = LFNoise2.ar(lfoMaster).range(0,19980.00)*filterLfoAmount.lag(0.5);
	durLfo = LFNoise2.kr(lfoRate).range(0.0001,0.5);

	////INPUTS
	select = [
		SoundIn.ar(in,gain)!2,
		PlayBuf.ar(2,
			bufnum,
			BufRateScale.kr(bufnum)*rate.lag(0.5)+rateLfo.lag(0.5),
			loop: 1,
			doneAction: 0);,
		Dust.ar(density)!2
	];

	input = Select.ar(wich,select);
	input =   Compander.ar(input, input,
        thresh: gateThresh,
        slopeBelow: 10,
        slopeAbove:  1,
        clampTime:   0.01,
        relaxTime:   0.01
   );

	/////amplitude follower
	ampf = Amplitude.kr(input).ampdb;
	ampf = Amplitude.kr(input).ampdb;
	ampf = K2A.ar(ampf);
	ampTrig = ampf <= thresh;



	select2 =
	[
		ampTrig,
		freeze
	];


	selectWipe =
	[
		wipeTrig,
		dust
	];

	/////FFT
	chain = FFT({LocalBuf(4096)}!2, input);


	chain = PV_MagFreeze(chain,
		Select.kr(wich2,select2)
	);

	chain = PV_MagShift(chain,1,freqShift.varlag(0.5));

	chain = PV_PitchShift(chain,pitchShift.varlag(0.5));

	chain = PV_BinScramble(chain,
		wipe.lag(0.5)+wipeLfo.clip(0,1),
		width.lag(0.5),
		Select.kr(wipeMode,selectWipe));


	chain = PV_MagSmooth(chain, 1 - smooth);


	chain = IFFT(chain);


	///Env follower á filter
	envFollower = Amplitude.kr(chain*20,10,20,20000)*fEnvAmount.varlag(0.5);

	splay = Splay.ar(chain,spread,1,panLfo.clip(-1,1));


	//////filters
	splay = RHPF.ar(splay,highPass.varlag(0.5));
	splay = RLPF.ar(splay,(envFollower+lpFreq.varlag(0.5)+filterLfo.varlag(0.5)).clip(20,20000),lpQ.varlag(0.5));



	////reverb
	local = LocalIn.ar(2)+splay.dup;
	16.do{local = AllpassN.ar(local, 0.06, Rand(0.001,0.09),3)};
	LocalOut.ar(local*feedback);
	local = RLPF.ar(local,15000,0.7);
	local = Splay.ar(local,1,1,0)*wetAmp;


	splay = Compander.ar(splay,splay,0.1,1,0.5,0.01,0.01,1)*volume.lag(0.5);
	splay = Limiter.ar(splay,0.6);

	/////meter
	imp = Impulse.kr(10);
    delimp = Delay1.kr(imp);
    colum = splay;
    // measure rms and Peak
    SendReply.kr(imp, '/levels', [Amplitude.kr(colum), K2A.ar(Peak.ar(colum, delimp).lag(0, 3))]);

    colum;

	Out.ar(out, splay+local);

}).add;
);



(

/////GUI
Window.closeAll;
w = Window.new("gui", Rect.new(350,20,600,500))
.front
.alwaysOnTop_(true);

~meter = LevelIndicator(w,bounds:Rect(500, 350, 40, 120));
    ~meter.onClose_({ x.free; o.free; });
o = OSCFunc({arg msg;
    {
        ~meter.value = msg[3].ampdb.linlin(-40, 0, 0, 1);
        ~meter.peakLevel = msg[4].ampdb.linlin(-40, 0, 0, 1);
    }.defer;
}, '/levels', s.addr);


//////////
~wipeSlider = Knob.new(w, Rect.new(20,50,30,30))
.action_({
	arg obj;
	var wp;
	wp = obj.value;
	if(
		x.isPlaying,
		{x.set(\wipe, wp)}
	);
	~wipeNumberBox.value_(obj.value)
});

~wipeNumberBox = NumberBox(w,Rect(20,20,30,20))
.value_(0)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~wipeSlider.valueAction_(obj.value)
});


~wipeLabel = StaticText(w,Rect(20,0,30,30))
.string_("wipe");


//////////
~widthSlider = Knob(w, Rect(60,50,30,30))
.action_({
	arg obj;
 	var wd;
	wd = obj.value.linexp(0,1,0.001,1);
	if(x.isPlaying,
		{x.set(\width, wd)}
	);
	~widthNumberBox.value_(obj.value.linexp(0,1,0.001,1))
});

 ~widthNumberBox = NumberBox(w,Rect(60,20,40,20))
.value_(0.5)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~widthSlider.valueAction_(obj.value.linexp(0,1,0.001,1))
});

~widthLabel = StaticText(w,Rect(60,0,30,30))
.string_("width");


//////////

~smoothSlider = Slider(w, Rect(150,100,30,100))
.action_({
	arg obj;
	var wd;
	wd = obj.value.linexp(0,1,0.000001,1);
	if(x.isPlaying,
		{x.set(\smooth, wd)}
	);
	~smoothNumberBox.value_(obj.value.linexp(0,1,0.000001,1));
});

 ~smoothNumberBox = NumberBox(w,Rect(200,180,30,20))
.value_(1)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~smoothSlider.valueAction_(obj.value.linexp(0,1,0.000001,1))
});

~smoothLabel = StaticText(w,Rect(200,150,130,30))
.string_("smooth");


/////////////lowpass filter

~lofilterSlider = Slider(w, Rect(250,390,30,100))
.action_({
	arg obj;
	var dn;
	dn = obj.value.linexp(0,1,20,20000).postln;
	if(x.isPlaying,
		{x.set(\lpFreq, dn)}
	);
	~lofilterNumberBox.value_(obj.value.linexp(0,1,20,20000).postln)});

 ~lofilterNumberBox = NumberBox(w,Rect(280,470,30,20))
.value_(20000)
.clipLo_(20)
.clipHi_(20000)
.action_({
	arg obj;
	~lofilterSlider.valueAction_(obj.value.linexp(0,1,0.20,20000).postln)
});

~lofilterLabel = StaticText(w,Rect(282,450,80,20))
.string_("lo freq");

/////////////highpass filter

~hifilterSlider = Slider(w, Rect(120,390,30,100))
.action_({
	arg obj;
	var dn;
	dn = obj.value.linexp(0,1,20,20000).postln;
	if(x.isPlaying,
		{x.set(\highPass, dn)}
	);
	~hifilterNumberBox.value_(obj.value.linexp(0,1,20,20000).postln)});

 ~hifilterNumberBox = NumberBox(w,Rect(155,470,30,20))
.value_(20)
.clipLo_(20)
.clipHi_(20000)
.action_({
	arg obj;
	~lofilterSlider.valueAction_(obj.value.linexp(0,1,0.20,20000).postln)
});

~hifilterLabel = StaticText(w,Rect(155,450,80,20))
.string_("hi freq");


////////////lowpass Q

~lofilterQSlider = Knob(w, Rect(300,390,30,100))
.action_({
	arg obj;
	var dn;
	dn = obj.value.linlin(0,1,1,0.3);
	if(x.isPlaying,
		{x.set(\lpQ, dn)}
	);
	~lofilterQNumberBox.value_(obj.value.linlin(0,1,1,0.3).postln)});

 ~lofilterQNumberBox = NumberBox(w,Rect(330,430,30,20))
.value_(0)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~lofilterQSlider.valueAction_(obj.value.linlin(0,1,1,0.3).postln)
});


/////////////enFollower
~envfollowerSlider = Knob(w, Rect(300,340,30,100))
.action_({
	arg obj;
	var dn;
	dn = obj.value.linexp(0,1,0.00001,1);
	if(x.isPlaying,
		{x.set(\fEnvAmount, dn)}
	);
	~envfollowerNumberBox.value_(obj.value.linexp(0,1,0.00001,1).postln)});

 ~envfollowerNumberBox = NumberBox(w,Rect(330,380,30,20))
.value_(0)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~envfollowerSlider.valueAction_(obj.value.linexp(0,1,0.00001,1).postln)
});


/////////////

~threshSlider = Slider(w, Rect(430,80,30,100))
.action_({
	arg obj;
	var th;
	th = -100*obj.value.postln;
	if(x.isPlaying,
		{x.set(\thresh, th)}
	);
	~thresNumberBox.value_(-100*obj.value)});

 ~thresNumberBox = NumberBox(w,Rect(465,150,30,30))
.value_(0.5)
.clipLo_(-100)
.clipHi_(1)
.action_({
	arg obj;
	~threshSlider.valueAction_(-100*obj.value)
});

~thresholdLabel = StaticText(w,Rect(465,130,80,20))
.string_("threshold");

//////////
~gateThreshSlider = Slider(w, Rect(350,80,30,100))
.action_({
	arg obj;
	var th;
	th = obj.value.linlin(0,1,0.0001,1).postln;
	if(x.isPlaying,
		{x.set(\gateThresh, th)}
	);
	~gateThresNumberBox.value_(obj.value.linlin(0,1,0.0001,1).postln)});

 ~gateThresNumberBox = NumberBox(w,Rect(390,150,30,30))
.value_(0.01)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~gateThreshSlider.valueAction_(obj.value.linllin(0,1,0.0001,1).postln)
});

~gateThresholdLabel = StaticText(w,Rect(390,130,80,20))
.string_("gate");



//////////density
~densitySlider = Knob(w, Rect(150,10,30,100))
.action_({
	arg obj;
	var dn;
	dn = obj.value.linexp(0,1,0.1,1000).postln;
	if(x.isPlaying,
		{x.set(\density, dn)}
	);
	~densityNumberBox.value_(obj.value.linexp(0,1,0.1,1000).postln)});

 ~densityNumberBox = NumberBox(w,Rect(150,75,30,20))
.value_(20)
.clipLo_(0)
.clipHi_(1000)
.action_({
	arg obj;
	~densitySlider.valueAction_(obj.value.linexp(0,1,0.1,1000).postln)
});

~densityLabel = StaticText(w,Rect(390,130,80,20))
.string_("gate");


//////////panLfoAmount

~panlfoAmountSlider = Knob(w, Rect(60,180,30,100))
.action_({
	arg obj;
	var lf;
	lf = obj.value;
	if(x.isPlaying,
		{x.set(\panLfoAmount, lf)}
	);
	~panlfoAmountNumberBox.value_(obj.value)});

 ~panlfoAmountNumberBox = NumberBox(w,Rect(60,190,30,20))
.value_(0)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~panlfoAmountSlider.valueAction_(obj.value)
});

~panlfoAmountLabel = StaticText(w,Rect(60,165,80,20))
.string_("pan lfo");

//////////

~spreadSlider = Knob(w, Rect(20,180,30,100))
.action_({
	arg obj;
	var lf;
	lf = obj.value;
	if(x.isPlaying,
		{x.set(\spread, lf)}
	);
	~spreadNumberBox.value_(obj.value)});

 ~spreadNumberBox = NumberBox(w,Rect(20,190,30,20))
.value_(1)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~spreadSlider.valueAction_(obj.value)
});

~spreadLabel = StaticText(w,Rect(20,165,80,20))
.string_("spread");

//////////

~lfoRange = RangeSlider(w, Rect(200, 100, 100, 30))
.action_({
	arg sl;
	if(x.isPlaying,
		{x.set(
		\lfoLo, sl.lo.value.linlin(0,1,0.0002,20),
			\lfoHi, sl.hi.value.linlin(0,1,0.0002,20))}
	);
});



//////////reverb
~reverbSlider = Knob(w, Rect(400,400,50,50))
.action_({
	arg obj;
	var fs;
	fs = obj.value.linlin(0,1,0,1);
	if(x.isPlaying,
		{x.set(\wetAmp, fs)}
	);
	~reverbNumberBox.value_(obj.value)});

 ~reverbNumberBox = NumberBox(w,Rect(400,380,30,20))
.value_(0.5)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~reverbSlider.valueAction_(obj.value)
});

~reverbLabel = StaticText(w,Rect(400,360,80,20))
.string_("reverb");

//////////
~pitchShiftSlider = Knob(w, Rect(400,300,50,50))
.action_({
	arg obj;
	var fs;
	fs = obj.value.linlin(0,1,0,1);
	if(x.isPlaying,
		{x.set(\pitchShift, fs)}
	);
	~pitchShiftNumberBox.value_(obj.value.linlin(0,1,0,1))});

 ~pitchShiftNumberBox = NumberBox(w,Rect(400,270,30,20))
.value_(0)
.clipLo_(-100)
.clipHi_(100)
.action_({
	arg obj;
	~pitchShiftSlider.valueAction_(obj.value.linlin(0,1,0,10.0))
});

~pitchShiftLabel = StaticText(w,Rect(400,250,80,20))
.string_("pitch shift");


//////////
~gainSlider = Knob(w, Rect(550,80,40,40))
.action_({
	arg obj;
	var fs;
	fs = obj.value.linlin(0,1,0,10);
	if(x.isPlaying,
		{x.set(\gain, fs)}
	);
	~gainNumberBox.value_(obj.value.linlin(0,1,0,10.0))});

 ~gainNumberBox = NumberBox(w,Rect(550,60,30,20))
.value_(1)
.clipLo_(0)
.clipHi_(100)
.action_({
	arg obj;
	~gainSlider.valueAction_(obj.value.linlin(0,1,0,10.0))
});

~gainLabel = StaticText(w,Rect(550,40,80,20))
.string_("gain");

//////////
~freqShiftSlider = Knob(w, Rect(500,300,50,50))
.action_({
	arg obj;
	var fs;
	fs = obj.value.linlin(0,1,-100.0,100.0);
	if(x.isPlaying,
		{x.set(\freqShift, fs)}
	);
	~freqShiftNumberBox.value_(obj.value.linlin(0,1,-100.0,100.0))});

 ~freqShiftNumberBox = NumberBox(w,Rect(500,270,30,20))
.value_(0)
.clipLo_(-100)
.clipHi_(100)
.action_({
	arg obj;
	~freqShiftSlider.valueAction_(obj.value.linlin(0,1,-100.0,100.0))
});

~freqShiftLabel = StaticText(w,Rect(500,250,80,20))
.string_("freq shift");




////////////////


~wipeLfoAmountSlider = Knob(w, Rect(20,90,30,100))
.action_({
	arg obj;
	var lf;
	lf = obj.value;
	if(x.isPlaying,
		{x.set(\wipeLfoAmount, lf)}
	);
	~wipeLfoAmountNumberBox.value_(obj.value)});

 ~wipeLfoAmountNumberBox = NumberBox(w,Rect(20,100,30,20))
.value_(0)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~wipeLfoAmountSlider.valueAction_(obj.value)
});

~wipeLfoAmountLabel = StaticText(w,Rect(20,80,80,20))
.string_("wipe lfo");

////////////////

~filterLfoSlider = Knob(w, Rect(200,420,30,100))
.action_({
	arg obj;
	var lf;
	lf = obj.value;
	if(x.isPlaying,
		{x.set(\filterLfoAmount, lf)}
	);
	~filterLfoNumberBox.value_(obj.value)});

 ~filterLfoNumberBox = NumberBox(w,Rect(200,430,30,20))
.value_(0)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~filterLfoSlider.valueAction_(obj.value)
});

~lfoRateLabel = StaticText(w,Rect(200,410,80,20))
.string_("filter lfo");

//////////


~freezeButton = Button(w, Rect(350,60,50,30))
.states_([
	["freeze", Color.black, Color.gray(0.8)],
	["stop", Color(0.2,0.75,0.95)],
])
.action_({
	arg obj;
	if(
		obj.value == 1,
		{x.set(\freeze, 1)},
		{x.set(\freeze, 0)}
	);
	obj.value.postln;
});


//////
~trigTypeButton = Button(w, Rect(350,20,50,30))
.states_([
	["amp", Color.black, Color.gray(0.8)],
	["trig", Color(0.2,0.75,0.95)]
])
.action_({
	arg obj;
	if(
		obj.value == 1,
		{x.set(\wich2, 1)},
		{x.set(\wich2, 0)}
	);
});

/////bufnum

~bufnumButton = PopUpMenu(w, Rect(250,20,50,30))
.items_([
	"hatidni", "ormur", "valley","karplus", "4"
])
.action_({
	arg obj;
	var bn;
	bn = obj.value;
	if(x.isPlaying,
		{x.set(\bufnum, bn)}
	);
});



//////////input buf

~rateSlider = Slider(w, Rect(20,300,30,100))
.action_({
	arg obj;
	var rt;
	//////hvernig fæ ég mínus tölur
	rt = obj.value.linlin(0,1,-10.0,10);
	if(x.isPlaying,
		{x.set(\rate, rt)}
	);
	~rateNumberBox.value_(obj.value.linlin(0,1,-10.0,10))});

 ~rateNumberBox = NumberBox(w,Rect(20,420,30,20))
.value_(1)
.clipLo_(-10)
.clipHi_(10)
.action_({
	arg obj;
	~rateSlider.valueAction_(obj.value.linlin(0,1,-10.0,10))
});

~rateLabel = StaticText(w,Rect(20,400,30,20))
.string_("rate");


//////////

~rateLfoSlider = Knob(w, Rect(20,330,150,50))
.action_({
	arg obj;
	var rl;
	//////hvernig fæ ég mínus tölur
	rl = obj.value;
	if(x.isPlaying,
		{x.set(\rateLfoAmount, rl)}
	);
	~rateLfoNumberBox.value_(obj.value)});

 ~rateLfoNumberBox = NumberBox(w,Rect(80,300,30,20))
.value_(0)
.clipLo_(0)
.clipHi_(1)
.action_({
	arg obj;
	~rateLfoSlider.valueAction_(obj.value)
});

~rateLfoLabel = StaticText(w,Rect(80,250,80,40))
.string_("rate lfo amount");

/////////////////

~inputButton = PopUpMenu(w, Rect(430,20,40,30))
.items_([
	"input", "sample", "dust",
])
.action_({
	arg obj;
	var in;
	in = obj.value.postln;
	if(x.isPlaying,
		{x.set(\wich, in)}
	);
});

/////////////
~wipeTrig = Button(w, Rect(100,10,40,30))
.states_([
	["wipeT", Color.black, Color.gray(0.8)],
	["stop", Color(0.2,0.75,0.95)],
])
.action_({
	arg obj;
	if(
		obj.value == 1,
		{x.set(\wipeTrig, 1)},
		{x.set(\wipeTrig, 0)}
	)
});


/////////////
~wipeMode = Button(w, Rect(150,10,40,30))
.states_([
	["trig", Color.black, Color.gray(0.8)],
	["dust", Color(0.2,0.75,0.95)],
])
.action_({
	arg obj;
	if(
		obj.value == 1,
		{x.set(\wipeMode, 1)},
		{x.set(\wipeMode, 0)}
	)
});

//////////on off

~volumeSlider = Slider(w, Rect(500,80,30,100))
.action_({
	arg obj;
	var vl;
	vl = obj.value.linlin(0,1,0,3).postln;
	if(x.isPlaying,
		{x.set(\volume, vl)}
	);
	~volumeNumberBox.value_(obj.value.linlin(0,1,0,3))});

 ~volumeNumberBox = NumberBox(w,Rect(550,150,30,30))
.value_(0.5)
.clipLo_(0)
.clipHi_(3)
.action_({
	arg obj;
	~volumeSlider.valueAction_(obj.value.linlin(0,1,0,3))
});

~volumeLabel = StaticText(w,Rect(550,120,30,30))
.string_("volume");


////////////
~onButton = Button(w, Rect(500,20,50,30))
.states_([
	["off", Color.black, Color.gray(0.8)],
	["on", Color(0.2,0.75,0.95)],
])
.action_({
	arg obj;
	if(
		obj.value == 1,
		{

			x = Synth.new(
				\freeze,
				[\wipe,~wipeSlider.value,
				/////muna bæta við herna
					\width, ~widthSlider.value,
					\threshold, ~threshSlider.value,
					\lfoRate, ~lfoRateSlider.value,
					\lfoAmount, ~lfoAmountSlider.value,
					\density, ~densitySlider.value,
					\volume, ~volumeSlider.value,
					\distortAmp, ~distortAmpSlider.value,
					\lpFreq, ~lowpassfilterSlider.value,
					\buf, b





				]
			).register;
		},
		{x.free}
	)
});

);
)