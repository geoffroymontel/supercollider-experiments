
(

Task({s.waitForBoot{
	var
	win,envs,envwin,envwins,envbuts,modboxs,rround,times,ratios,levs,view,winopen,testFreq,testBut,
	randLev1,randLev2,randLev3,randLev4,randLev5,
	randExe,randExe2,randExe3,randExe4,randExe5,randExe6,randExe7,randExe8,randExe9,randExe10,randExeAll,save,load,
	noSynths,synthArray,synTest,synTestArray,polyphon,reltime,debug,nodecoll;

	SynthDef(\feedback, {
		|in,out|

		var input;

		input = InFeedback.ar(in);

		Out.ar(out,input);
	}

	).send(s);

	SynthDef(\fmTex,
		{
			|t1,t2,t3,t4,in,out=0,amp=0,lev1,lev2,lev3,lev4,lev5,lfrate,lfoAmpDepth=0,freq,phase=0,pan=0,fmout=8,
			s1,m1,m2,m3,m4,m5,m6,m7,m8,fmouts,inbus=8,cur1,cur2,cur3,cur4,gate = 1,lfoPitDepth=0,lfoFade=0,envPitDepth|

			var env,osc,input,lfo,lfofade;

			input = In.ar(inbus,1);

			env = EnvGen.kr(Env.new([lev1,lev2,lev3,lev4,lev5],[t1,t2,t3,t4],[cur1,cur2,cur3,cur4],3,4),gate,doneAction:2);

			lfofade = Line.kr(0.0001,1,lfoFade);

			lfo = SinOsc.ar(lfrate,0,lfofade);

			osc = SinOsc.ar(freq+(input)+(lfo*lfoPitDepth)+(env*envPitDepth),phase,1+(lfo*lfoAmpDepth),0)*env;

			Out.ar(s1,[osc*m1,osc*m2,osc*m3,osc*m4,osc*m5,osc*m6,osc*m7,osc*m8]);

			Out.ar(out,Pan2.ar(osc,pan,amp));

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

	MIDIIn.connectAll;

	noSynths = 0;

	synTest = 0;

	synTestArray = polyphon.collect{0};

	synthArray = Array.newClear(128);
	nodecoll = 128.collect{List[]};

	winopen = [0,0,0,0,0,0,0,0];

	envwins = [0,0,0,0,0,0,0,0];

	~envtimes = 8.collect{[0.0,0.1,0.5,0.7,1.0]};

	~envlevs = 8.collect{[0.0,1.0,0.5,0.5,0.0]};

	~envPitDepth = 8.collect{0};

	~lfoAmpDepth = 8.collect{0};

	~lfoPitDepth = 8.collect{0};

	~lfoRate = 8.collect{0};

	~lfoFadeTime = 8.collect{0};

	~envcurves = 8.collect{[0,0,0,0]};

	~modlevs = 8.collect{8.collect{0}};

	~times = 8.collect{1};

	~fratio = 8.collect{|i| 8-i};

	~amplevs = 8.collect{0};

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
		});
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
	};

	envwin = {
		|eNum,chordX,chordY| var wind, env,knobs,curves,lfonums;

		wind = Window.new("OP Env"+(eNum+1),Rect(chordX,chordY,500,200));

		env = EnvelopeView(wind,Rect(10,10,480,130))
		.value_([~envtimes[eNum],~envlevs[eNum]])
		.resize_(5)
		.curves_(~envcurves[eNum])
		.action_({|a| ~envtimes.put(eNum,a.value[0]);
			~envlevs.put(eNum,a.value[1]);
			envs[eNum].value_([~envtimes[eNum],~envlevs[eNum]]);
		}
		)
		.onClose_({winopen.put(eNum,0)});
		knobs = 4.do{|k|
			Knob(wind,Rect(10+(k*50),150,40,40))
			.value_((~envcurves[eNum][k]+4)/8)
			.action_({|val| ~envcurves[eNum].put(k,(val.value*8)-4);
				env.curves_(~envcurves[eNum]);
				envs[eNum].curves_(~envcurves[eNum]);
			})
			.resize_(7);
			envwins.put(eNum,wind);
		};
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
				{k==4}{~envPitDepth.put(eNum,val.value)}

			})
			.scroll_step_(0.1)
			.align_(\center)
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
				.action_({|val|   ~modlevs[oo].put(o,val.value);
					if(val.value>0,
						{box.background_(Color.blue)},
						{box.background_(Color.new255(95, 158, 160))}
					);

					if(synTestArray.sum > 0,
						{
							synTestArray.do{|i|

								i.postln;
								case{i>0}{

									synthArray[i].do{|x,z|

										case{z==oo}
										{
											x.set(
												\m1,(i.midicps/10)*~modlevs[oo][0],
												\m2,(i.midicps/10)*~modlevs[oo][1],
												\m3,(i.midicps/10)*~modlevs[oo][2],
												\m4,(i.midicps/10)*~modlevs[oo][3],
												\m5,(i.midicps/10)*~modlevs[oo][4],
												\m6,(i.midicps/10)*~modlevs[oo][5],
												\m7,(i.midicps/10)*~modlevs[oo][6],
												\m8,(i.midicps/10)*~modlevs[oo][7]
										)};
									}

								}

							}
						}

					);

					if(testBut.value>0,
						{~test.do{
							|x,i| case{i==oo}
							{
								x.set(
									\m1,(testFreq.value/10)*~modlevs[oo][0],
									\m2,(testFreq.value/10)*~modlevs[oo][1],
									\m3,(testFreq.value/10)*~modlevs[oo][2],
									\m4,(testFreq.value/10)*~modlevs[oo][3],
									\m5,(testFreq.value/10)*~modlevs[oo][4],
									\m6,(testFreq.value/10)*~modlevs[oo][5],
									\m7,(testFreq.value/10)*~modlevs[oo][6],
									\m8,(testFreq.value/10)*~modlevs[oo][6]
								)
							}

						}

						},{}

					);

					envs[o].background_(Color.new255(95, 158+(val.value*2).min(255), 160+(val.value*3).min(255)));
					envs[oo].background_(Color.new255(95, 158+(val.value*2).min(255), 160+(val.value*3).min(255)));


				})



			};

		}

	};

	view  = CompositeView(win,Rect(15,520,663,120));
	view.background = Color.new255(95, 128, 190);

	levs = 8.collect{
		|o|
		Slider(win,Rect(17+(o*85),520,50,100))
		.value_(~amplevs[o])
		.knobColor_(Color.black)
		.action_({|val| ~amplevs.put(o,val.value)});
	};

	save = Button(win,Rect(680,520,50,20)).states_([["save"]])
	.action_({ File.saveDialog("",{|path|path},
		{
			|path| var sarray;

			sarray = [~envtimes,~envlevs,~envcurves,~modlevs,~times,~fratio,~amplevs,
				~lfoRate,~lfoPitDepth,~lfoAmpDepth,~lfoFadeTime,~envPitDepth];

			sarray[6].postln;

			sarray.writeArchive(path);
		}
	)
	});
	load =  Button(win,Rect(680,550,50,20)).states_([["load"]])
	.action_({
		File.openDialog("",{
			|path| var larray;

			larray = Object.readArchive(path);

			~envtimes = larray[0]; ~envlevs = larray[1];
			~envcurves = larray[2]; ~modlevs = larray[3];
			~times = larray[4]; ~fratio = larray[5];
			~amplevs = larray[6]; ~lfoRate = larray[7];
			~lfoPitDepth= larray[8]; ~lfoAmpDepth = larray[9];
			~lfoFadeTime = larray [10]; ~envPitDepth = larray[11];

			~amplevs.postln;

			envs.do{|a,b| a.value_([~envtimes[b],~envlevs[b]])
				.curves_(~envcurves[b]);


			};

			modboxs.do{|a,b|
				a.do{|c,d|
					case{c!=nil}{c.value_(~modlevs[d][b])}					                                             }
			};
			levs.do{|a,b| a.value_(~amplevs[b])};

			times.do{|a,b| a.value_(~times[b])};

			ratios.do{|a,b| a.value_(~fratio[b])}

		};

		)

	});

	randLev1  = 2.collect{|i| Knob(win,Rect(20+(i*35),650,30,30)); };


	randExe = Button(win,Rect(20,680,70,20))
	.states_([["Arc Rand"]])
	.action_({
		modboxs.do{|boxes,o|
			boxes.do{|box,oo| case{box == nil}{box = 0};

				if(randLev1[0].value.coin && (oo != o),
					{box.value_((1000.rand*randLev1[1].value.cubed).round(0.1))},
					{case{oo != o}{box.value_(0)}}
				);
				~modlevs[oo].put(o,box.value);
			}
		};


	});
	randExe2 = Button(win,Rect(20,700,70,20))
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
			}
		}
	});

	randLev2  = 2.collect{|i| Knob(win,Rect(100+(i*35),650,30,30)); };

	randExe3 =  Button(win,Rect(100,680,70,20))
	.states_([["Env Rand"]])
	.action_(
		{
			envs.do{|envy,i| var cur;
				cur = Array.fill(5,{8.0.rand2});
				envy.value_([~envtimes[i],Array.fill(5,{|o| ~envlevs[i][o]+(1.0.rand2*randLev2[0].value)})])
				.curves_(cur);
				~envlevs.put(i,envy.value[1]);
				~envcurves.put(i,cur);
				cur.postln;
			}

		}

	);
	randExe4 =  Button(win,Rect(100,700,70,20))
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
				~envtimes.put(i,envy.value[0].postln);

			}

		}

	);

	randLev3  = 2.collect{|i| Knob(win,Rect(180+(i*35),650,30,30)); };

	rround = NumberBox(win,Rect(250,680,30,30)).value_(0.01);

	randExe5 =  Button(win,Rect(180,680,70,20))
	.states_([["freq rand"]])
	.action_({

		ratios.do{|obj,x| case{randLev3[0].value.coin}
			{ratios[x].value_((20.0.rand*randLev3[1].value).round(rround.value))};

			~fratio.put(x,ratios[x].value);
		}
	});
	randExe6 =  Button(win,Rect(180,700,70,20))
	.states_([["freq rand+"]])
	.action_({
		ratios.do{|obj,x| case{randLev3[0].value.coin}
			{ratios[x].value_((~fratio[x]+(20.0.rand2.round*randLev3[1].value).round(rround.value)).max(0.001))};

			~fratio.put(x,ratios[x].value);}


	});

	randLev4  = 2.collect{|i| Knob(win,Rect(280+(i*35),650,30,30)); };

	randExe7 =  Button(win,Rect(280,680,70,20))
	.states_([["time rand"]])
	.action_({
		times.do{|lev,o|
			case{randLev4[0].value.coin}
			{times[o].value = (randLev4[1].value.squared*10).rand;
				~times.put(o,times[o].value)};

		}
	});

	randExe8 =  Button(win,Rect(280,700,70,20))
	.states_([["time rand2"]])
	.action_({
		times.do{|lev,o|
			case{randLev4[0].value.coin}
			{times[o].value = (times[o].value+randLev4[1].value.squared*10).rand2.max(0.001);
				~times.put(o,times[o].value)};

		}
	});

	randLev5  = 2.collect{|i| Knob(win,Rect(350+(i*35),650,30,30)); };

	randExe9 =  Button(win,Rect(350,680,70,20))
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
		levs.do{|lev,o| lev.value = ~amplevs[o]}
	});

	randExe10 =  Button(win,Rect(350,700,70,20))
	.states_([["lev rand2"]])
	.action_({});

	randExeAll = Button(win,Rect(20,730,170,20))
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
		.action_({|val| ~fratio.put(o,val.value)})

	};
	MIDIIn.noteOn_({ |src, chan, num, vel|
		case{noSynths < polyphon }
		{ synTest=0;

			if(synTestArray.includesEqual(num))
			{
				"wank".postln;
			}
			{
				"yay".postln;
			};

			synTest = synTestArray.detectIndex { |item| item == 0 };
			if(synTest.notNil) { synTestArray.put(synTest,num) } { /* else fail, maybe throw an error? */ };



			synthArray.put(num,
				8.collect{|i| var syn;

				syn=
					Synth(\fmTex,
						[
							\lev1,~envlevs[i][0],
							\lev2,~envlevs[i][1],
							\lev3,~envlevs[i][2],
							\lev4,~envlevs[i][3],
							\lev5,~envlevs[i][4],
							\t1,(~envtimes[i][1]-~envtimes[i][0])*~times[i],
							\t2,(~envtimes[i][2]-~envtimes[i][1])*~times[i],
							\t3,(~envtimes[i][3]-~envtimes[i][2])*~times[i],
							\t4,(~envtimes[i][3]-~envtimes[i][2])*~times[i],
							\cur1,~envcurves[i][0],
							\cur2,~envcurves[i][1],
							\cur3,~envcurves[i][2],
							\cur4,~envcurves[i][3],
							\freq,num.midicps*~fratio[i],
							\inbus,(16+i)+(synTest*16),
							\lfoPitDepth,~lfoPitDepth[i],
							\lfoAmpDepth,~lfoAmpDepth[i],
							\lfoFade,~lfoFadeTime[i],
							\lfrate,~lfoRate[i],
							\envPitDepth,~envPitDepth[i],
							\s1,8+(synTest*16),
							\m1,(num.midicps/10)*~modlevs[i][0],
							\m2,(num.midicps/10)*~modlevs[i][1],
							\m3,(num.midicps/10)*~modlevs[i][2],
							\m4,(num.midicps/10)*~modlevs[i][3],
							\m5,(num.midicps/10)*~modlevs[i][4],
							\m6,(num.midicps/10)*~modlevs[i][5],
							\m7,(num.midicps/10)*~modlevs[i][6],
							\m8,(num.midicps/10)*~modlevs[i][7],
							\amp,~amplevs[i]/8,
						],target:~synth
					);
					/*nodecoll[num].add(syn);
					nodecoll.postln;*/
					syn;
				}
			);

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
					synTestArray.postln;
			}}).play;

		}

	);

	testFreq = NumberBox(win,Rect(700,680,100,20))
	.value_(100);
	testBut = Button(win,
		Rect(700,650,100,20)
	)
	.states_([["test"],["off"]])
	.action_({ |o|

		case{o.value==1}	   {
			~test = 8.collect{|i| var freq; freq = 110;

				Synth(\fmTex,
					[
						\lev1,~envlevs[i][0],
						\lev2,~envlevs[i][1],
						\lev3,~envlevs[i][2],
						\lev4,~envlevs[i][3],
						\lev5,~envlevs[i][4],
						\t1,(~envtimes[i][1]-~envtimes[i][0])*~times[i],
						\t2,(~envtimes[i][2]-~envtimes[i][1])*~times[i],
						\t3,(~envtimes[i][3]-~envtimes[i][2])*~times[i],
						\t4,(~envtimes[i][3]-~envtimes[i][2])*~times[i],
						\cur1,~envcurves[i][0],
						\cur2,~envcurves[i][1],
						\cur3,~envcurves[i][2],
						\cur4,~envcurves[i][3],
						\lfoPitDepth,~lfoPitDepth[i],
						\lfoAmpDepth,~lfoAmpDepth[i],
						\lfoFade,~lfoFadeTime[i],
						\lfrate,~lfoRate[i],
						\envPitDepth,~envPitDepth[i],
						\freq,(testFreq.value).postln*~fratio[i],
						\inbus,8+i,
						\s1,16,
						\m1,(testFreq.value/10)*~modlevs[i][0],
						\m2,(testFreq.value/10)*~modlevs[i][1],
						\m3,(testFreq.value/10)*~modlevs[i][2],
						\m4,(testFreq.value/10)*~modlevs[i][3],
						\m5,(testFreq.value/10)*~modlevs[i][4],
						\m6,(testFreq.value/10)*~modlevs[i][5],
						\m7,(testFreq.value/10)*~modlevs[i][6],
						\m8,(testFreq.value/10)*~modlevs[i][7],
						\amp,~amplevs[i]/8,
					],target:~synth
				)

		}}
		{o.value==0}{ ~test.do{|o| o.set(\gate,0)}}
	});
	win.front;
}},AppClock).play);

