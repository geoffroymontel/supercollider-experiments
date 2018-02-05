/*
Monophonic Triplets (Ver 1.0)
by Joo Won Park (2017) : joowon@joowonpark.net
http://joowonpark.net/monotriple/

Instructions:
This code is for the "Singer" computers. You can have up to 6 Singer computers for this version
1. Open this code with SuperCollider  (http://supercollider.github.io/download)
2. Select Menu->Language->Evaluate File. A GUI window will appear
3. Click on the GUI window's fullscreen button (green)
4. Repeat 1-3 for all the singer computers
5. The computer will play sound and visuals when it receives a message from the Conductor computer

* Important: MonoTriplets-Singer.scd should be running and ready BEFORE MonoTriplet-Conductor.scd. Make sure to find out the IP addresses of the Singer computer before running/editing the Conductor file. The IP address of a Mac can be found at System Preferences->Network

To stop the program from receiving network messages from the Conductor computer, move the mouse cursor to upper left corner and click on the red button. Then select Menu->Language->Stop

*/

~prep=1;
~begin=~prep+1;

~bpm=100;
~beat=60/~bpm;
~key=58;



~phrase0=Array.fill(20,{[0.5,1].choose});
~phrase1=Array.fill(20,{[0.5,0.25,0.25,1].choose});
~phrase2=Array.fill(25,{[0.5,1/3,1/6].choose});
~phrase3 = Array.fill(20,{[0.5,1,0.25,1/6,1/3].choose});
~phrase4 = Array.fill(15,{0.5});

~phrase5=Array.fill(10,{[0.5,1].choose});
~phrase6=Array.fill(10,{[0.5,0.25,0.25,1].choose});
~phrase7=Array.fill(35,{[0.5,1/3,1/6].choose});
~phrase8 = Array.fill(10,{[0.5,1,0.25,1/6,1/3].choose});
~phrase9 = Array.fill(5,{0.5});

~sumphrase=[~phrase0,~phrase1,~phrase2,~phrase3,~phrase4,~phrase5,~phrase6,~phrase7,~phrase8,~phrase9];

//graphics
~scopebuff = Buffer.alloc(s,1024/32,1);
~window2=Window("Blerk", Rect(0,0, Window.screenBounds.width*0.5,Window.screenBounds.height*0.5)).front;
~scope = ScopeView(~window2,Rect(0,0, Window.screenBounds.width,Window.screenBounds.height)); // this is SCScope
~scope.bufnum = ~scopebuff.bufnum;

~colors={
	var linecolor, bkgcolor,bw;
	linecolor=[2.rand,2.rand,2.rand,1];
	bw= 1.0.rand;
	bkgcolor=[bw,bw,bw,1];
	{~scope.waveColors=[Color(linecolor[0],linecolor[1],linecolor[2],linecolor[3])]}.defer;
	{~scope.background=Color(bkgcolor[0],bkgcolor[1],bkgcolor[2],bkgcolor[3])}.defer;
};


//~window2.fullScreen;
~window2.onClose={~scopebuff.free};

// IMPORTANT
~scope.server_(s);



s.waitForBoot{
	~scope.start; //graphics start
	SynthDef("Peek",{
		arg freq,fb,modf,shrange,panpos,vol;
		var sound, modu,modusound,flag,fblag,noise,snh,mix;

		flag = Lag.kr(freq,0.05);
		fblag = Lag.kr(fb,0.2);
		sound = SinOscFB.ar(flag,fblag);
		sound = Pan2.ar(sound,panpos);
		modu = LFPulse.ar(modf,0,0.5,0.5);
		modusound = Lag.ar(modu,1/modf*0.02);
		mix = sound*modusound*vol;

		Out.ar(10,mix);
	}).load(s);

	SynthDef("Pad",{
		arg freq,vol;
		var source, res,res2,vollag;
		source = WhiteNoise.ar;
		res = Resonz.ar(source,[freq,freq*1.5],0.04,2);
		res2 = Resonz.ar(res,freq,0.04,4);
		vollag = Lag.kr(vol,Rand(1,4));
		Out.ar(12,res2*vollag);
	}).load(s);


	SynthDef("Nim",{
		arg
		vol,origvol,lowvol,midvol,highvol,centerfreq,resonance,sourcevol,sourcevol2,sourcevol3,
		pulsefreq,delayt,decayt,delayvol,inputfilt,panner,control,lagger,schoose;

		var source,source2,source3,cf,reso,sound2,sound3,mix,delaytlag,delayvx;

		source = PinkNoise.ar(sourcevol*0.3);

		source2 = Impulse.ar(pulsefreq)*sourcevol2;

		source3 = SoundIn.ar(0,sourcevol3*2);
		source3 = source3*(SinOsc.ar((~key-12).midicps));
		source3 = LPF.ar(source3,30+(3000*inputfilt));
		source3=HPF.ar(source3,50);

		sound2 =source+source2+source3;

		cf = Lag.kr(centerfreq*100+20,lagger);
		reso = Lag.kr(resonance+0.02,lagger);
		delaytlag=Lag.kr(delayt,lagger);
		delayvx=Lag.kr(delayvol,lagger);
		sound3 = 0;

		13.do({
			sound2 =(sound2*origvol*1.5)+(sound3*delayvx);
			sound2 = sound2+(RLPF.ar(sound2,cf,reso*0.88)*lowvol);
			sound2 = MidEQ.ar(sound2,cf*10,reso,midvol*30-15);
			sound2 = sound2+(RHPF.ar(sound2,cf*100,reso*0.3)*highvol);
			sound2 = Clip.ar(sound2,-0.9,0.9);

			sound3 = sound2;
			sound3 = CombL.ar(sound3,0.2,0.0001+(delaytlag*0.1),decayt*0.5);
			sound3 = Fold.ar(sound3,-0.9,0.9);


		});

		mix = Pan2.ar(HPF.ar(sound2,100),panner);
		Out.ar(14,mix*vol);

	}).load(s);


	SynthDef("Mixer",{
		arg vol0=1,vol1=1,vol2=1,mastervol=1;
		var peek,pad,nim,mix,gmix;
		peek = In.ar(10,2);
		pad = In.ar(12,2);
		nim=In.ar(14,2);
		mix = (peek*Lag.kr(vol0,0.3.rand))+(pad*Lag.kr(vol1,0.3.rand))+(nim*Lag.kr(vol2,0.3.rand));
		gmix = (peek*Lag.kr(vol0*2,1))+(pad*Lag.kr(vol1*2,1))+(nim*Lag.kr(vol2*0.67,0.3.rand));
		Out.ar(0,mix*(Lag.kr(mastervol,0.3.rand)));
		//scopeout
		ScopeOut2.ar(mastervol*gmix.sum,~scopebuff.bufnum);


	}).load(s);

	SystemClock.sched(~prep,{
		~nim0=Synth("Nim",[\vol,0,\origvol,0.8,\lowvol,0.5,\midvol,0.5,\highvol,0.5,\centerfreq,1,\resonance,0.8,\sourcevol,0.5,\sourcevol2,0.5,\sourcevol3,0,\pulsefreq,3,\delayt,0.02,\decayt,0.1,\delayvol,0.1,\panner,0,\lagger,2.0.rand]);
		~nim1=Synth("Nim",[\vol,0,\origvol,0.8,\lowvol,0.5,\midvol,0.5,\highvol,0.5,\centerfreq,1,\resonance,0.8,\sourcevol,0.0,\sourcevol2,0.0,\sourcevol3,0.4,\pulsefreq,3,\delayt,0.02,\decayt,0.1,\delayvol,0.1,\panner,-1,\lagger,3.0.rand]);
		~nim2=Synth("Nim",[\vol,0,\origvol,0.8,\lowvol,0.8,\midvol,0.02,\highvol,0.5,\centerfreq,1,\resonance,0.8,\sourcevol,0.2,\sourcevol2,0.0,\sourcevol3,0.4,\pulsefreq,4.3,\delayt,0.02,\decayt,0.0,\delayvol,0.1,\panner,1,\lagger,2.0.rand]);
		~peek=Synth("Peek",[\vol,0.0,\freq,(~key+48).midicps,\fb,0,\modf,4,\panpos,0]);
		~pad =Synth("Pad",[\vol,0,\freq,(~key-5+20.rand).midicps]);
		~mixer=Synth.tail(1,"Mixer",[\vol0,1,\vol1,1,\vol2,1,\mastervol,1]);

		~quarter=Array.fill(30,1);

		~sourcepick0={
			arg schoo;
			var sourcemix,sourcechoose;
			sourcemix = [[1,0,0],[0,1,0],[0,0,1]];
			sourcechoose=sourcemix[schoo];
			~nim0.set(\sourcevol,sourcechoose[0],\sourcevol2,sourcechoose[1],\sourcevol3,sourcechoose[2])
		};

		~sourcepick1={
			arg schoo;
			var sourcemix,sourcechoose;
			sourcemix = [[1,0,0],[0,1,0],[0,0,1]];
			sourcechoose=sourcemix[schoo];
			~nim1.set(\sourcevol,sourcechoose[0],\sourcevol2,sourcechoose[1],\sourcevol3,sourcechoose[2])
		};

		~sourcepick2={
			arg schoo;
			var sourcemix,sourcechoose;
			sourcemix = [[1,0,0],[0,1,0],[0,0,1]];
			sourcechoose=sourcemix[schoo];
			~nim2.set(\sourcevol,sourcechoose[0],\sourcevol2,sourcechoose[1],\sourcevol3,sourcechoose[2])
		};


		~whichnim=[~nim0,~nim1,~nim2];
		~whichsource=[~sourcepick0,~sourcepick1,~sourcepick2];


		~seq={
			arg vol,which,phrase;
			//phrase.sum.postln;
			Routine({
				phrase.do{
					arg wtime;
					//graphics
					~colors.value(0);

					~whichnim[which].set(\vol,vol.rand+0.4,\lowvol,0.6.rand,\midvol,0.6.rand,\highvol,0.6.rand,\resonance,0.5+(0.4.rand),
						\delayt,0.03.rand,\decayt,0.1.rand,\delayvol,0.2.rand,\centerfreq,1.2.rand,\lagger,2.0.rand);
					~whichsource[which].value(3.rand);
					~whichnim[which].set(\pulsefreq,[2,3,4,6,8,12].choose*~beat);
					(wtime*~beat).wait;}
			}).play
		};

		~seqpan={
			arg vol,which,phrase;
			//phrase.sum.postln;
			Routine({
				phrase.do{
					arg wtime;
					//graphics
					~colors.value(0);

					~whichnim[which].set(\vol,vol.rand+0.2,\lowvol,0.3.rand,\midvol,0.8.rand,\highvol,0.6.rand,\resonance,0.5+(0.4.rand),
						\delayt,0.03.rand,\decayt,0.2.rand,\delayvol,0.3.rand,\centerfreq,0.1.rand+0.3,\lagger,0.7.rand,\panner,1.0.rand2);
					~whichsource[which].value(2.rand);
					~whichnim[which].set(\pulsefreq,[2,3,4,6,8,12].choose*~beat);
					(wtime*~beat).wait;}
			}).play
		};

		~seqdelay={
			arg vol,which,phrase;
			//phrase.sum.postln;
			Routine({
				phrase.do{
					arg wtime;
					//graphics
					~colors.value(0);

					~whichnim[which].set(\vol,vol.rand+0.4,\lowvol,0.6.rand,\midvol,0.6.rand+0.2,\highvol,0.3.rand,\resonance,0.6+(0.3.rand),
						\delayt,0.9.rand,\decayt,0.4.rand,\delayvol,0.5.rand,\centerfreq,1.2.rand,\lagger,2.0.rand);
					~whichsource[which].value(3.rand);
					~whichnim[which].set(\pulsefreq,[2,3,4,6,8,12].choose*~beat);
					(wtime*~beat).wait;}
			}).play
		};

		~bassdrum={
			arg vol, freq,phrase;
			//phrase.sum.postln;
			Routine({
				phrase.do{
					arg wtime;
					Synth("BD",[\freq,freq,\dur,wtime,\vol,vol]);
					(wtime*~beat).wait;}
			}).play
		};

		//osc reactions

		~click0={
			var choose;
			choose = ~sumphrase.choose.scramble;
			~mixer.set(\vol0,0,\vol1,0,\vol2,1,\mastervol,1);
			~seq.value(0.5,0,choose);~nim0.set(\panner,0);
			~seq.value(0.5,1,choose);~nim1.set(\panner,1);
			~seq.value(0.5,2,choose);~nim2.set(\panner,-1);
		};

		~click1={
			var choose;
			choose = ~sumphrase.choose;
			~mixer.set(\vol0,0,\vol1,0,\vol2,1,\mastervol,1);
			~seq.value(0.5,0,choose);~nim0.set(\panner,0);
			~seq.value(0.5,1,choose);~nim1.set(\panner,-1);
			~seq.value(0.5,2,choose);~nim2.set(\panner,1);
		};
		~click2={
			var choose;
			choose = ~sumphrase.choose;
			~mixer.set(\vol0,0,\vol1,0,\vol2,1,\mastervol,1);
			~seqpan.value(0.5,0,choose);~nim0.set(\panner,0);
			~seqpan.value(0.5,1,choose);~nim1.set(\panner,-1);
			~seqpan.value(0.5,2,choose);~nim2.set(\panner,1);
			//~peek.set(\vol,0);
		};
		~click3={
			var choose;
			choose = ~sumphrase.choose;
			~mixer.set(\vol0,0,\vol1,0,\vol2,1,\mastervol,1);
			~seqdelay.value(0.5,0,choose);~nim0.set(\panner,0);
			~seqdelay.value(0.5,1,choose);~nim1.set(\panner,-1);
			~seqdelay.value(0.5,2,choose);~nim2.set(\panner,1);
			//~peek.set(\vol,0);
		};
		~click4={
			var choose;
			choose = ~sumphrase.choose.scramble;
			~mixer.set(\vol0,0,\vol1,0,\vol2,1,\mastervol,1);
			~seq.value(0.5,0,choose);~nim0.set(\panner,0);
			~seqdelay.value(0.5,1,choose);~nim1.set(\panner,-1);
			~seqdelay.value(0.5,2,choose);~nim2.set(\panner,1);
			//~peek.set(\vol,0);
		};
		~click5={
			var choose;
			choose = ~sumphrase.choose.scramble;
			~mixer.set(\vol0,0,\vol1,0,\vol2,1,\mastervol,1);
			~seqdelay.value(0.5,0,choose);~nim0.set(\panner,0);
			~seqpan.value(0.5,1,choose);~nim1.set(\panner,-1);
			~seqdelay.value(0.5,2,choose);~nim2.set(\panner,1);
			//~peek.set(\vol,0);
		};
		~click6={
			var choose;
			choose = ~sumphrase.choose;
			~mixer.set(\vol0,0,\vol1,0,\vol2,1,\mastervol,1);
			~seqdelay.value(0.5,0,choose);~nim0.set(\panner,0);
			~seq.value(0.5,1,choose);~nim1.set(\panner,-1);
			~seq.value(0.5,2,choose);~nim2.set(\panner,1);
			//~peek.set(\vol,0);
		};


		~clickpeek={
			arg interval;
				~colors.value(0);
			~mixer.set(\vol0,1,\vol1,0,\vol2,0,\mastervol,1);
			~peek.set(\vol,0.2+0.5.rand,\modf,[1,2,8,12].choose*~beat,\freq,(~key+interval).midicps,\fb,3.0.rand);



		};

		~clicknoise={
			arg interval;
			~colors.value(0);
			~mixer.set(\vol0,0,\vol1,1,\vol2,0,\mastervol,1);
			~pad.set(\vol,1,\freq,(~key+20.rand).midicps);



		};

		~pausing={
				~colors.value(0);

			~mixer.set(\vol0,0.5,\vol1,1,\vol2,0,\mastervol,1);
			/*~nim0.set(\vol,0.3.rand+0.1,\lowvol,0.2.rand,\midvol,0.4.rand+0.3,\highvol,0.4.rand,\resonance,0.2+(0.7.rand),
					\delayt,0.6.rand,\decayt,0.4.rand,\delayvol,0.2.rand,\centerfreq,(~key.midicps)/(2**7),\lagger,2.0.rand);*/
				~pad.set(\vol,1,\freq,(~key+([0,7,12,19,24,-5,-12].choose)).midicps);
				~peek.set(\vol,0.2+0.5.rand,\modf,[2,8,12,16].choose*~beat,\freq,(~key+([0,7,12,19,24,-5,-12].choose)).midicps,\fb,3.0.rand);


		};
		~gotosc={
			arg dice,pitch;
			dice.postln;
			if(dice==8,{~clicknoise.value(pitch)},
				if (dice==7,{~clickpeek.value(pitch)},{
					[~click1.value(0),~click2.value(0),~click3.value(0),~click4.value(0),~click5.value(0),~click6.value(0)].choose;
			}));

		};

		OSCFunc({
			//OPCFunc has four default arguments. We are generally interested in the message (msg)
			arg msg, time, addr, recvPort;
			if (msg[1]>0, {
				//[msg[0],msg[1],msg[2],msg[3],msg[4]].postln;
				~gotosc.value(msg[2],msg[3]);
				~mixer.set(\mastervol,msg[4]);

			});
		},\event);


		OSCFunc({
			//OPCFunc has four default arguments. We are generally interested in the message (msg)
			arg msg, time, addr, recvPort;
			if (msg[1]>0, {
				//"00000".postln;

				~pausing.value(0);

			});
		},\unevent);

				OSCFunc({
			//OPCFunc has four default arguments. We are generally interested in the message (msg)
			arg msg, time, addr, recvPort;
			if (msg[1]>0, {
				"TheEnd".postln;
				~mixer.set(\mastervol,0);

			});
		},\end);



	});//end of score prep

}//end of wait for boot


