(

Task({s.waitForBoot{
	var
	win,envs,envwin,envwins,envbuts,modboxs,rround,times,ratios,levs,view,winopen,testFreq,testBut,
	randLev1,randLev2,randLev3,randLev4,randLev5,randLev6,
	randExe,randExe2,randExe3,randExe4,randExe5,randExe6,randExe7,randExe8,randExe9,randExe10,randExe11,randExeAll,
	save,load,noSynths,synthArray,synTest,synTestArray,
	polyphon,reltime,contSynths,numParams,morphFunc,pans,fade,ftime,velmods,velconts,velParams,
	storeArr,storeButs,recalButs,saveArr,actPre,stored,modView,editFunc;




	ftime=2;

	SynthDef(\feedback, {
		|in,out|

		var input;
		input = InFeedback.ar(in);
		Out.ar(out,input);
	}

	).send(s);

	SynthDef(\fmCont,
		{
			|outbus,m1,m2,m3,m4,m5,m6,m7,m8,freq,lev,pan,t1,t2,t3,t4,
			lev1,lev2,lev3,lev4,lev5,cur1,cur2,cur3,cur4,
			lfoRate,lfoAmpDepth,lfoPitDepth=0,lfoFade=0,envPitDepth,
			ftime=1|

			var lag1,lag2,lag3,lag4,lag5,lag6,lag7,lag8,freqlag,levlag,panlag,t1lag,t2lag,t3lag,t4lag,
			lev1lag,lev2lag,lev3lag,lev4lag,lev5lag,cur1lag,cur2lag,cur3lag,cur4lag,
			lfrlag,lfalag,lfplag,lfflag,eplag;

			lag1= Lag3.kr(m1,ftime); lag2= Lag3.kr(m2,ftime); lag3= Lag3.kr(m3,ftime);
			lag4= Lag3.kr(m4,ftime); lag5= Lag3.kr(m5,ftime); lag6= Lag3.kr(m6,ftime);
			lag7= Lag3.kr(m7,ftime); lag8= Lag3.kr(m8,ftime); freqlag = Lag3.kr(freq,ftime);
			levlag= Lag3.kr(lev,ftime); panlag = Lag3.kr(pan,ftime); t1lag = Lag3.kr(t1,ftime);
			t2lag = Lag3.kr(t2,ftime);  t3lag = Lag3.kr(t3,ftime); t4lag = Lag3.kr(t4,ftime);
			lev1lag = Lag3.kr(lev1,ftime); lev2lag = Lag3.kr(lev2,ftime); lev3lag = Lag3.kr(lev3,ftime);
			lev4lag = Lag3.kr(lev4,ftime); lev5lag = Lag3.kr(lev5,ftime); cur1lag = Lag3.kr(cur1,ftime);
			cur2lag = Lag3.kr(cur2,ftime); cur3lag = Lag3.kr(cur3,ftime);cur4lag = Lag3.kr(cur4,ftime);
			lfrlag = Lag3.kr(lfoRate,ftime); lfalag =  Lag3.kr(lfoAmpDepth,ftime); lfplag =  Lag3.kr(lfoPitDepth,ftime);
			lfflag =  Lag3.kr(lfoFade,ftime); eplag =  Lag3.kr(envPitDepth,ftime);

			Out.kr(outbus,[
				lag1,lag2,lag3,lag4,lag5,lag6,lag7,lag8,
				freqlag,levlag,panlag,
				t1lag,t2lag,t3lag,t4lag,
				lev1lag,lev2lag,lev3lag,lev4lag,lev5lag,
				cur1lag,cur2lag,cur3lag,cur4lag,
				lfrlag,lfalag,lfplag,lfflag,eplag
			]);
		}

	).send(s);

	SynthDef(\fmTex,
		{
			|s1,inbus=8,gate = 1,
			out=0,freq,phase=0,
			m1,m2,m3,m4,m5,m6,m7,m8,fin,lin,pan,
			lev1,lev2,lev3,lev4,lev5,t1,t2,t3,t4,cur1,cur2,cur3,cur4,
			velFMmod,velAmpMod,velAtMod,velDecMod,velRelMod,
			lfoRate,lfoAmpDepth,lfoPitDepth=0,lfoFade=0,envPitDepth|

			var env,osc,input,lfo,lfofade,
			min1,min2,min3,min4,min5,min6,min7,min8,
			levIn,freqIn,panIn,
			t1in,t2in,t3in,t4in,
			lev1in,lev2in,lev3in,lev4in,lev5in,
			cur1in,cur2in,cur3in,cur4in,
			lfrin,lfain,lfpitin,lffin,epitin;

			input = In.ar(inbus,1);
			min1= In.kr(m1); min2= In.kr(m2); min3= In.kr(m3);
			min4= In.kr(m4); min5= In.kr(m5); min6= In.kr(m6);
			min7= In.kr(m7); min8= In.kr(m8); freqIn= In.kr(fin);
			levIn= In.kr(lin); panIn = In.kr(pan); t1in=In.kr(t1);
			t2in=In.kr(t2); t3in=In.kr(t3); t4in=In.kr(t4);
			lev1in = In.kr(lev1); lev2in = In.kr(lev2); lev3in = In.kr(lev3);
			lev4in = In.kr(lev4);lev5in = In.kr(lev5); cur1in = In.kr(cur1);
			cur2in = In.kr(cur2); cur3in = In.kr(cur3); cur4in = In.kr(cur4);
			lfrin= In.kr(lfoRate);lfain = In.kr(lfoAmpDepth);lfpitin= In.kr(lfoPitDepth);
			lffin= In.kr(lfoFade);epitin= In.kr(envPitDepth);

			env = EnvGen.ar(Env.new(
				[lev1in,lev2in,lev3in,lev4in,lev5in],
				[t1in+(t1in*velAtMod),t2in+(t2in*velDecMod),t3in,t4in+(t4in*velRelMod)],
				[cur1in,cur2in,cur3in,cur4in],3,4),gate,doneAction:2);

			lfofade = Line.kr(0.0001,1,lffin);

			lfo = SinOsc.ar(lfrin,0,lfofade);

			osc = SinOsc.ar((freq*freqIn)+(input)+(input*velFMmod)+(lfo*lfpitin)+(env*epitin),phase,1+(lfo*lfain),0)*env;

			Out.ar(s1,[osc*min1,osc*min2,osc*min3,osc*min4,osc*min5,osc*min6,osc*min7,osc*min8]);

			Out.ar(out,Pan2.ar(osc,panIn,levIn+(velAmpMod*levIn)));

		}

	).send(s);


	s.sync;

	~feedback = Group.new;

	s.sync;

	~synth =  Group.new(~feedback,\addAfter);

	s.sync;

	polyphon = 12;
	polyphon.do{|o|
		8.do{
			|i|
			Synth(\feedback,[\in,((8+i)+(16*o)),\out,((16+i)+(16*o))],target:~feedback)
		}
	};

	numParams = 29;
	contSynths =
	8.collect{|i|
		Synth(\fmCont,
			[\outbus,i*numParams ],target:~synth
		)
	};

	morphFunc =
	{contSynths.do{|syn,i|
		syn.set(
			\m1,~modlevs[i][0]*15,
			\m2,~modlevs[i][1]*15,
			\m3,~modlevs[i][2]*15,
			\m4,~modlevs[i][3]*15,
			\m5,~modlevs[i][4]*15,
			\m6,~modlevs[i][5]*15,
			\m7,~modlevs[i][6]*15,
			\m8,~modlevs[i][7]*15,
			\lev,~amplevs[i]/8,
			\freq,~fratio[i],
			\pan,~pan[i],
			\t1,(~envtimes[i][1]-~envtimes[i][0])*~times[i],
			\t2,(~envtimes[i][2]-~envtimes[i][1])*~times[i],
			\t3,(~envtimes[i][3]-~envtimes[i][2])*~times[i],
			\t4,(~envtimes[i][4]-~envtimes[i][3])*~times[i],
			\lev1,~envlevs[i][0],
			\lev2,~envlevs[i][1],
			\lev3,~envlevs[i][2],
			\lev4,~envlevs[i][3],
			\lev5,~envlevs[i][4],
			\cur1,~envcurves[i][0],
			\cur2,~envcurves[i][1],
			\cur3,~envcurves[i][2],
			\cur4,~envcurves[i][3],
			\lfoRate,~lfoRate[i],
			\lfoAmpDepth,~lfoAmpDepth[i],
			\lfoPitDepth,~lfoPitDepth[i],
			\lfoFade,~lfoFadeTime[i],
			\envPitDepth,~envPitDepth[i],
			\ftime,ftime

		)
	}};
	s.sync;
	editFunc =
	{|on|
		if(on==1)
		{
			contSynths.do{|syn|
				ftime = 0; syn.set(\ftime,0); };
		}
		{
			contSynths.do{|syn|
				ftime = fade.value;
				syn.set(\ftime,ftime);};
		}
	};
	MIDIIn.connectAll;

	noSynths = 0;

	synTest = 0;

	synTestArray = polyphon.collect{0};
	synthArray = Array.newClear(128);
	winopen = [0,0,0,0,0,0,0,0];
	envwins = [0,0,0,0,0,0,0,0];
	velmods = 5.collect{0};
	~envtimes = 8.collect{[0.0 , 0.1 , 0.5 , 0.7 , 1]};
	~envlevs = 8.collect{[0.0 , 1.0 , 0.5 , 0.5 , 0.0]};
	~envcurves = 8.collect{[0,0,0,0]};
	~envPitDepth = 8.collect{0};
	~lfoAmpDepth = 8.collect{0};
	~lfoPitDepth = 8.collect{0};
	~lfoRate = 8.collect{0};
	~lfoFadeTime = 8.collect{0};
	~modlevs = 8.collect{8.collect{0}};
	~pan = 8.collect{0};
	~times = 8.collect{1};
	~fratio = 8.collect{|i| 8-i};
	~amplevs = 8.collect{0};

	morphFunc.value;

	win = Window.new("FMer", Rect(0,50,850,800));
	win.view.background_(Color.new255(95, 158, 160));
	win.alwaysOnTop_(false);

	view  = CompositeView(win,Rect(695,0,130,500));
	view.background = Color.new255(95, 128, 190);

	envs = 8.collect{ |o|
		EnvelopeView(win,Rect(0+(o*85),0+(o*62),85,60))
		.value_([~envtimes[o],~envlevs[o]])
		.curves_(~envcurves[o])
		.action_({|a|
			~envtimes.put(o,a.value[0]);
			~envlevs.put(o,a.value[1]);
			morphFunc.value;
		})
		.mouseDownAction_({editFunc.value(on:1)})
		.mouseUpAction_({editFunc.value(on:0)});
	};

	envbuts = 8.collect{
		|o|
		Button(win, Rect(0+(o*85),60+(o*62),85,20))
		.states_([["open"]])
		.action_({
			case{winopen[o]==0}
			{envwin.value(o,85+(o*85),700-(o*62));
				winopen.put(o,1)}
			{winopen[o]==1}
			{envwins[o].front}
		})
		.mouseDownAction_({editFunc.value(on:1)})
		.mouseUpAction_({editFunc.value(on:0)});
	};

	envwin = {
		|eNum,chordX,chordY| var wind, env,knobs,curves,lfonums;

		wind = Window.new("OP Env"+(eNum+1),Rect(chordX,chordY,550,200));

		env = EnvelopeView(wind,Rect(10,10,480,130))
		.value_([~envtimes[eNum],~envlevs[eNum]])
		.resize_(5)
		.curves_(~envcurves[eNum])
		.action_({|a| ~envtimes.put(eNum,a.value[0]);
			~envlevs.put(eNum,a.value[1]);
			envs[eNum].value_([~envtimes[eNum],~envlevs[eNum]]);
			morphFunc.value;
		}
		)
		.mouseDownAction_({editFunc.value(on:1)})
		.mouseUpAction_({editFunc.value(on:0)})
		.onClose_({winopen.put(eNum,0)});
		knobs = 4.do{|k|
			Knob(wind,Rect(10+(k*50),150,40,40))
			.value_((~envcurves[eNum][k]+4)/8)
			.action_({|val| ~envcurves[eNum].put(k,(val.value*8)-4);
				env.curves_(~envcurves[eNum]);
				envs[eNum].curves_(~envcurves[eNum]);
				morphFunc.value;
			})
			.mouseDownAction_({editFunc.value(on:1)})
			.mouseUpAction_({editFunc.value(on:0)})
			.resize_(7);
			envwins.put(eNum,wind);
		};

		NumberBox(wind,Rect(500,150,40,40))
		.value_(~modlevs[eNum][eNum])
		.action_({
			|val|
			~modlevs[eNum].put(eNum,val.value);
			morphFunc.value;

		})
		.mouseDownAction_({editFunc.value(on:1)})
		.mouseUpAction_({editFunc.value(on:0)});

		lfonums = 5.collect{|k| NumberBox(wind,Rect(220+(k*50),160,40,20))
			.value_(
				case{k==0}{~lfoRate[eNum]}
				{k==1}{~lfoPitDepth[eNum]}
				{k==2}{~lfoAmpDepth[eNum]}
				{k==3}{~lfoFadeTime[eNum]}
				{k==4}{~envPitDepth[eNum]}
			)
			.action_({|val|
				case{k==0}{~lfoRate.put(eNum,val.value)}
				{k==1}{~lfoPitDepth.put(eNum,val.value)}
				{k==2}{~lfoAmpDepth.put(eNum,val.value)}
				{k==3}{~lfoFadeTime.put(eNum,val.value)}
				{k==4}{~envPitDepth.put(eNum,val.value)};
				morphFunc.value;
			})
			.mouseDownAction_({editFunc.value(on:1)})
			.mouseUpAction_({editFunc.value(on:0)})
			.scroll_step_(0.1)
			.align_(\center);
		};

		5.collect{
			|k|
			var text; text = ["rate","pitmod","ampmod","fade","envpit"];
			StaticText(wind,Rect(210+(k*50),140,60,20)).string_(text[k])
			.align_(\center)
		};

		wind.front

	};

	modboxs = 8.collect{ |o|

		8.collect{ |oo| var box;

			case{oo !=  o}{

				box =   NumberBox(win,
					Rect(17+(85*oo),18.5+(o*62),50,25))
				.value_(0.0)
				.clipLo_(0.0)
				.background_(Color.new255(95, 158, 160))
				.align_(\center)
				.mouseDownAction_({editFunc.value(on:1)})
				.mouseUpAction_({editFunc.value(on:0)})
				.action_({|val|   ~modlevs[oo].put(o,val.value);
					if(val.value>0,
						{box.background_(Color.blue)},
						{box.background_(Color.new255(95, 158, 160))}
					);

					morphFunc.value;

					envs[o].background_(Color.new255(95, 158+(val.value*2).min(255), 160+(val.value*3).min(255)));
					envs[oo].background_(Color.new255(95, 158+(val.value*2).min(255), 160+(val.value*3).min(255)));
				});

			};

		}

	};

	view  = CompositeView(win,Rect(15,520,663,130));
	view.background = Color.new255(95, 128, 190);

	levs = 8.collect{
		|o|
		Slider(win,Rect(17+(o*85),520,50,100))
		.value_(~amplevs[o])
		.knobColor_(Color.black)
		.action_({|val|
			~amplevs.put(o,val.value);

			contSynths.do
			{|syn,i|
				syn.set(\lev,~amplevs[i]/8)
			}
		};
		)
		.mouseDownAction_({editFunc.value(on:1);})
		.mouseUpAction_({editFunc.value(on:0)});
	};

	pans = 8.collect{
		|o|
		Knob(win,Rect(27+(o*85),620,30,30))
		.value_((~pan[o]+1)/2)
		.action_({|val| var pos;
			pos = (val.value*2)-1;
			~pan.put(o,pos);
			contSynths.do
			{|syn,i|
				syn.set(\pan,~pan[i])
			}
		};
		)
		.mouseDownAction_({editFunc.value(on:1)})
		.mouseUpAction_({editFunc.value(on:0)});
	};

	modView = CompositeView.new(win, Rect(695,520,130,130)).background_(Color.red);
	velParams = ["m-depth","amp","attack","dec","rel"];
	fade = EZNumber(modView,120@15,
		"Morph",
		ControlSpec(0.0,20,\lin,0.01)
	).action_({|val| ftime=val.value;
		contSynths.do{|syn| syn.set(\ftime,ftime); };
	});
	velconts = 5.collect{|i|

		StaticText(modView,Rect(0,15+(15*i),80,15))
		.string_(velParams[i]);

		NumberBox(
			modView,Rect(80,15+(i*15),50,15))
		.action_({
			|v|
			velmods.put(i,v.value);
			velmods;
		}).clipLo_(-127)
		.mouseDownAction_({editFunc.value(on:1)})
		.mouseUpAction_({editFunc.value(on:0)});
	};



	actPre = 24.collect{0};
	stored = 24.collect{0};
	storeArr = [~modlevs,~amplevs,~fratio,~envtimes,~envlevs,~envcurves,~pan,~lfoRate,~lfoPitDepth,~lfoAmpDepth,~lfoFadeTime,~envPitDepth,velmods];
	saveArr = 24.collect{ storeArr.deepCopy};

	storeButs = 24.collect{|i|

		Button(win,Rect(25+(i*27),650,25,25))
		.states_([["",Color.blue,Color.blue],["",Color.green,Color.green]])
		.action_({|o| var array,val; val=o.value;
			stored.put(i,1);
			storeButs.do{|ob,i| ob.value_(stored[i])};

			array=[~modlevs.deepCopy,~amplevs.deepCopy,~fratio.deepCopy,~envtimes.deepCopy,
				~envlevs.deepCopy,~envcurves.deepCopy,~pan.deepCopy,~lfoRate.deepCopy,
				~lfoPitDepth.deepCopy,~lfoAmpDepth.deepCopy,~lfoFadeTime.deepCopy,
				~envPitDepth.deepCopy,velmods.deepCopy];

			saveArr.put(i,array);
		})
	};
	recalButs = 24.collect{|i|
		Button(win,Rect(25+(i*27),680,25,25))
		.states_([["",Color.black,Color.black],["",Color.red,Color.red]])
		.action_({|o|
			var arr;
			actPre = 24.collect{0};
			actPre.put(i,1);
			arr = saveArr[i];
			~modlevs=arr[0].deepCopy;~amplevs=arr[1].deepCopy;~fratio=arr[2].deepCopy;
			~envtimes=arr[3].deepCopy;~envlevs=arr[4].deepCopy;~envcurves=arr[5].deepCopy;
			~pan=arr[6].deepCopy;~lfoRate=arr[7].deepCopy;
			~lfoPitDepth=arr[8].deepCopy;~lfoAmpDepth=arr[9].deepCopy;
			~lfoFadeTime=arr[10].deepCopy;~envPitDepth=arr[11].deepCopy;
			velmods = arr[12].deepCopy;

			recalButs.do{|a,i|a.value_(actPre[i])};
			envs.do{|a,b| a.value_([~envtimes[b],~envlevs[b]])
				.curves_(~envcurves[b]);
			};
			modboxs.do{|a,b|
				a.do{|c,d|
					case{c!=nil}{c.value_(~modlevs[d][b])};
				}
			};
			levs.do{|a,b| a.value_(~amplevs[b])};
			times.do{|a,b| a.value_(~times[b])};
			ratios.do{|a,b| a.value_(~fratio[b])};
			pans.do{|a,b| a.value_((~pan[b]+1)/2)};
			velconts.do{|a,b| a.value_(velmods[b])};
			morphFunc.value;
		})
	};

	save = Button(win,Rect(680,650,50,20)).states_([["save"]])
	.action_({ File.saveDialog("",{|path|path},
		{
			|path| var sarray;

			saveArr.writeArchive(path);
		}
	)
	});
	load =  Button(win,Rect(680,685,50,20)).states_([["load"]])
	.action_({
		File.openDialog("",{
			|path| var larray;

			saveArr = Object.readArchive(path);

			recalButs[0].doAction;

		};

		)

	});




	randLev1  = 2.collect{|i| Knob(win,Rect(20+(i*35),710,30,30)); };

	randExe = Button(win,Rect(20,740,70,20))
	.states_([["Arc Rand"]])
	.action_({
		modboxs.do{|boxes,o|
			boxes.do{|box,oo| case{box == nil}{box = 0};

				if(randLev1[0].value.coin && (oo != o),
					{box.value_((1000.rand*randLev1[1].value.cubed).round(0.1))},
					{case{oo != o}{box.value_(0)}}
				);
				~modlevs[oo].put(o,box.value);
				morphFunc.value;

			}
		}
	}
	;


	);
	randExe2 = Button(win,Rect(20,760,70,20))
	.states_([["Arc Rand2"]])
	.action_({
		modboxs.do{|boxes,o|
			boxes.do{|box,oo|
				case{box == nil}{box = 0};

				case{ (oo != o)}
				{  if((box.value > 0) && randLev1[0].value.coin  ,
					{
						box.value_((box.value+(1000.rand2*randLev1[1].value.cubed))
							.round(0.1).max(1))
					},
					{}
				);
				};
				~modlevs[oo].put(o,box.value);
				morphFunc.value;
			}
		}
	});

	randLev2  = 2.collect{|i| Knob(win,Rect(100+(i*35),710,30,30)); };

	randExe3 =  Button(win,Rect(100,740,70,20))
	.states_([["Env Rand"]])
	.action_(
		{
			envs.do{|envy,i| var cur;
				cur = Array.fill(5,{8.0.rand2});
				envy.value_([~envtimes[i],Array.fill(5,{|o| ~envlevs[i][o]+(1.0.rand2*randLev2[0].value)})])
				.curves_(cur);
				~envlevs.put(i,envy.value[1]);
				~envcurves.put(i,cur);
				cur;
			}

		}

	);
	randExe4 =  Button(win,Rect(100,760,70,20))
	.states_([["Env Rand2"]])
	.action_(
		{
			envs.do{|envy,i|
				var levs; levs = Array.fill(5,{|o|
					case{o==0}{0.0}
					{o==4}{1.0}
					{(o>0)&&(o<4)}{1.0.rand};
				});
				levs = levs.sort;
				envy.value_([levs,~envlevs[i]]);
				~envtimes.put(i,envy.value[0]);

			}

		}

	);

	randLev3  = 2.collect{|i| Knob(win,Rect(180+(i*35),710,30,30)); };

	rround = NumberBox(win,Rect(250,740,50,30)).value_(0.01);

	randExe5 =  Button(win,Rect(180,740,70,20))
	.states_([["freq rand"]])
	.action_({

		ratios.do{|obj,x| case{randLev3[0].value.coin}
			{ratios[x].value_((20.0.rand*randLev3[1].value).round(rround.value))};

			~fratio.put(x,ratios[x].value);
			morphFunc.value;
		}
	});
	randExe6 =  Button(win,Rect(180,760,70,20))
	.states_([["freq rand+"]])
	.action_({
		ratios.do{|obj,x| case{randLev3[0].value.coin}
			{ratios[x].value_((~fratio[x]+(20.0.rand2.round*randLev3[1].value).round(rround.value)).max(0.001))};

			~fratio.put(x,ratios[x].value);
			morphFunc.value;
		}


	});

	randLev4  = 2.collect{|i| Knob(win,Rect(290+(i*35),710,30,30)); };

	randExe7 =  Button(win,Rect(290,740,70,20))
	.states_([["time rand"]])
	.action_({
		times.do{|lev,o|
			case{randLev4[0].value.coin}
			{times[o].value = (randLev4[1].value.squared*10).rand;
				~times.put(o,times[o].value)};

		}
	});

	randExe8 =  Button(win,Rect(290,760,70,20))
	.states_([["time rand2"]])
	.action_({
		times.do{|lev,o|
			case{randLev4[0].value.coin}
			{times[o].value = (times[o].value+randLev4[1].value.squared*10).rand2.max(0.001);
				~times.put(o,times[o].value)};

		}
	});

	randLev5  = 2.collect{|i| Knob(win,Rect(370+(i*35),710,30,30)); };

	randExe9 =  Button(win,Rect(370,740,70,20))
	.states_([["lev rand"]])
	.action_({
		levs.do{|lev,o|
			if(randLev5[0].value.coin,
				{lev.value = (randLev5[1].value.squared).rand;
					~amplevs.put(o,levs[o].value);
				},
				{
					lev.value = 0;
					~amplevs.put(o,0);
				}
			)
		};
		~amplevs = ~amplevs;
		morphFunc.value;
		levs.do{|lev,o| lev.value = ~amplevs[o]}
	});

	randLev6  = 2.collect{|i| Knob(win,Rect(450+(i*35),710,30,30)); };
	randExe10 = Button(win,Rect(450,740,70,20))
	.states_([["Pan Rand"]])
	.action_({
		pans.do{|pan,o|
			if(randLev6[0].value.coin)
			{
				pan.value=( 0.5 + (randLev6[1].value/2).rand2);

			}
			{}
		}
	}
	);


	randExeAll = Button(win,Rect(20,780,170,20))
	.states_([["Everything Random"]])
	.action_({randExe.doAction;
		randExe2.doAction;
		randExe3.doAction;
		randExe4.doAction;
		randExe5.doAction;
		randExe6.doAction;
		randExe7.doAction;
		randExe8.doAction;
		randExe9.doAction;
		randExe10.doAction;
		morphFunc.value;

	});

	StaticText(win,Rect(700,0,50,20)).string_("time").align_(\center);
	StaticText(win,Rect(770,0,50,20)).string_("F ratio").align_(\center);

	times = 8.collect{
		|o|

		NumberBox(win,
			Rect(700,20+(o*62),50,25)
		)
		.value_(0.0)
		.action_({|val| ~times.put(o,val.value);})

	};

	ratios = 8.collect{
		|o|
		NumberBox(win,
			Rect(770,20+(o*62),50,25)
		)
		.value_(~fratio[o])
		.action_({|val| ~fratio.put(o,val.value);
			morphFunc.value;})

	};

	MIDIIn.noteOn_({ |src, chan, num, vel|
		case{noSynths < polyphon }
		{ synTest=0;

			synTest = synTestArray.detectIndex { |item| item == 0 };
			if(synTest.notNil) { synTestArray.put(synTest,num) } { /* else fail, maybe throw an error? */ };

			morphFunc.value;
			if(num >= 24)
			{
				synthArray.put(num,
					8.collect{|i| var syn;

						syn=
						Synth(\fmTex,
							[
								\freq,num.midicps,
								\velmod,0,
								\inbus,(16+i)+(synTest*16),
								\velFMmod,vel*(velmods[0]/127),
								\velAmpMod,vel*(velmods[1]/127),
								\velAtMod,vel*(velmods[2]/127),
								\velDecMod,vel*(velmods[3]/127),
								\velRelMod,vel*(velmods[4]/127),
								\s1,8+(synTest*16),
								\m1,0+(i*numParams),
								\m2,1+(i*numParams),
								\m3,2+(i*numParams),
								\m4,3+(i*numParams),
								\m5,4+(i*numParams),
								\m6,5+(i*numParams),
								\m7,6+(i*numParams),
								\m8,7+(i*numParams),
								\fin,8+(i*numParams),
								\lin,9+(i*numParams),
								\pan,10+(i*numParams),
								\t1,11+(i*numParams),
								\t2,12+(i*numParams),
								\t3,13+(i*numParams),
								\t4,14+(i*numParams),
								\lev1,15+(i*numParams),
								\lev2,16+(i*numParams),
								\lev3,17+(i*numParams),
								\lev4,18+(i*numParams),
								\lev5,19+(i*numParams),
								\cur1,20+(i*numParams),
								\cur2,21+(i*numParams),
								\cur3,22+(i*numParams),
								\cur4,23+(i*numParams),
								\lfoRate,24+(i*numParams),
								\lfoAmpDepth,25+(i*numParams),
								\lfoPitDepth,26+(i*numParams),
								\lfoFade,27+(i*numParams),
								\envPitDepth,28+(i*numParams),
							],target:~synth
						);

					}
				);
			}
			{
				recalButs[num].doAction;
			};
			reltime = 8.collect{|i|(~envtimes[i][3]-~envtimes[i][2])*~times[i]};
			reltime = reltime.maxItem;
			noSynths = noSynths +1;
		}
	});

	MIDIIn.noteOff_(

		{|src, chan, num, vel|

			synthArray[num].do{|syn| syn.set(\gate,0)};

			Routine({1.do{ var spot;
				spot = synTestArray.indicesOfEqual(num);
				synTestArray.put(spot,129);
				reltime.wait; noSynths = noSynths-1;
				synTestArray.put(spot,0);
				synTestArray;
			}}).play;

		}

	);


	win.front;
}},AppClock).play);

s.makeGui

Window

