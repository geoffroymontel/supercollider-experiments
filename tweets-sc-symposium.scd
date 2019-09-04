// http://sccode.org/1-4RA
// SC tweets collection from the SC symposium London 2012

/* by  dan stowell */
{ Klank.ar(`[(33,44..77).midicps,nil,0.1], SinOsc.ar(LFSaw.kr(1/60).exprange(0.01, 200)).exprange(100,1000)).dup/9 }.play //#supercollider

/* by  tim walters */
play{HPF.ar(GVerb.ar(({|k|({|i|y=SinOsc;y.ar(i,y.ar(i+k**i)/Decay.kr(Impulse.kr(0.5**i/k),[1,2]+i,k))}!6).sum}!16).sum,1,1)/180,40)}

/* by  tim walters */
play{HPF.ar(({|k|({|i|SinOsc.ar(i/96,Saw.ar(2**(i+k))/Decay.ar(Impulse.ar(0.5**i/k),[k*i+1,k*i+1*2],3**k))}!6).product}!32).sum/2,40)}

/* by  miquel parera jaques */
{Pan2.ar(SinOsc.ar(Demand.kr(Impulse.kr(rrand(2,33)),0,Dseq([0.3.rand,0.3.rand]+rrand(99,200),inf)),0,SinOsc.ar(rrand(6,33))),0,0.08)}.play;

/* by  miquel parera jaques */
{Pan2.ar(FreeVerb.ar(SinOsc.ar(Demand.kr(Impulse.kr(Rand(10,100)),0,Dseq([Rand(100,333),Rand(100,333)],inf)),0,0.08),1,1,1),0)}.play;

/* by  miquel parera jaques */
{a=rrand(25,50);Pan2.ar(SinOsc.ar(Demand.ar(Impulse.ar(1/a),0,Dwhite(100,333)))*EnvGen.ar(Env.perc(a/2,a/2,0.1),Impulse.ar(1/a)),0)}.play;

/* by  redfrik */
r{99.do{|i|x={Pan2.ar(SinOsc.ar(i+1,SinOsc.ar((i%9).div(3)*100+(i%9)+500),0.03),1.0.rand2)}.play;2.wait;x.release(25)}}.play//#SuperCollider

/* by  redfrik */
r{99.do{x={Pan2.ar(BPF.ar(Impulse.ar(18.linrand+0.5),9999.linrand,0.3.linrand,5),1.0.rand2)}.play;3.wait;x.release(9)}}.play//#SuperCollider

/* by  redfrik */
r{loop{x=play{t=SinOsc.ar(999.rand).abs;Formlet.ar(TDuty.ar(t,0,t),4e3.linrand,t,1-t)!2};wait(9.rand+1);x.release(39)}}.play//#SuperCollider

/* by  redfrik */
r{loop{z=20.rand+6;x={y=LFTri.ar(z).abs/9/z;RLPF.ar(TDuty.ar(y,0,y),z*600,0.06,9)!2}.play(s,0,z);wait(26-z);x.release}}.play//#SuperCollider

/* by  redfrik */
r{loop{z=60.rand+1;x={y=LFTri.ar(z).abs/z;RLPF.ar(TDuty.ar(y,0,y),z*99+y,0.01,6+y)!2}.play(s,0,z);wait(z/3);x.release}}.play//#SuperCollider

/* by  redfrik */
r{loop{x={GVerb.ar(MoogFF.ar(ClipNoise.ar*0.4,LFPar.kr({0.3.rand}!2,0,600,990)),9,9,1)}.play(s,0,19);3.wait;x.release}}.play//#SuperCollider

/* by  redfrik */
r{loop{x={BPF.ar(Pluck.ar(Crackle.ar([1.9,1.8]),Impulse.ar(5.rand+1),0.05,0.05.linrand),1200.rand)}.play(s,0,9);wait(9);x.release(69)}}.play

/* by  redfrik */
play{x=LFNoise1.ar(0.5!2);Formlet.ar(Crackle.ar(x.range(1.8,1.98)),TExpRand.ar(200,2e3,x).lag(2),x.range(5e-4,1e-3),0.0012)}//#SuperCollider

/* by  redfrik */
{|i|x=i+6.rand;Pbind(\dur,0.06,\sustain,1,\amp,0.01,\degree,Pgauss(x,sin(x+Ptime()%6/6e3)*9),\pan,Pkey(\degree)-x*9).play}!6//#SuperCollider

/* by  redfrik */
play{a=SinOsc;LeakDC.ar(a.ar(a.ar(0.31),a.ar(a.ar(0.21),a.ar(a.ar(0.11,a.ar(0.01)),0,a.ar([2,3],0,400))),a.ar([0.3,0.21])))}//#SuperCollider

/* by  minkepatt */
(f=Duty.kr(_,16,Dseq("berlin_calling".ascii,inf));play{RHPF.ar(LFTri.ar(f.(5/34)*7),f.(1/13)*16,(LFSaw.ar(0.25,1)))};)

/* by  minkepatt */
(f=Duty.kr(_,3,Dseq("berlin_calling".ascii.mirror,inf));play{RLPF.ar(LFTri.ar(f.(5/34)*7),f.(1/13)*16,(LFSaw.ar(0.5,1)))};)

/* by  minkepatt */
(play{x=SinOsc.ar(gcd (441*SinOsc.ar(5),882*SinOsc.ar(3))); (x.distort % x)};)

/* by  minkepatt */
(play{LFTri.ar(CombL.ar(Dust.kr(GrayNoise.ar)*44.1,1e-17,1e-6).round(441/3.5))};)

/* by  minkepatt */
(9.rand.do{{LFCub.ar(441/3+441*5.rand)*LFGauss.kr(0.25+2.25.rand.round(0.125));}.play})

/* by  minkepatt */
(play{Schmidt.ar(Saw.ar([48,50,60].midicps), (LFPar.kr(0.87.rand)), (LFPar.ar(CuspL.ar(0.45.rand))))};)

/* by  minkepatt */
(play{Ringz.ar((Impulse.kr(4))+(Dust.kr(9))*2/3*(HPF.ar(ClipNoise.ar(1/6),3300)),[34,21].squared)};)

/* by  minkepatt */
(play{var a,f,t;a=Dseq([1,3,5,8,2,5]*[2,0,0.5],inf);t=(Impulse.kr([5,4,7]));f=Demand.kr(t,0,a)*[13,89];LFTri.ar(f)*0.2**Dust.ar(2)};)

/* by  minkepatt */
(play{var a,f,t;a=Dseq([1,8]*[2,0,0.5],inf);t=(Saw.kr([5,4]));f=Demand.kr(t,0,a)*[13,89];LFTri.ar(f)*0.2**Dust.ar(2)};)

/* by  minkepatt */
({PanB2.ar(Gendy1.ar(3,4,2,2,305,500,0.33)*LFNoise2.kr(0.2,0.5),Saw.kr(0.2,3))}.play;)

/* by  minkepatt */
({PanB2.ar(Gendy1.ar(6,2,3,4,rrand(15,250),5000,0.1)*LFNoise2.kr(0.2,2),LFNoise0.kr(0.2))}.play;)

/* by  lfsaw */
{Splay.ar({RHPF.ar(Saw.ar(Rand(0.5,9),LFSaw.ar(BrownNoise.ar(1299,500))),LFNoise2.ar(f=LFNoise2.ar(9,9,1),999,0))*((f)**10).clip2}!9)}.play;

/* by  Monocular Sludgebath the 7th */
{Mix.fill(99,{|i| var a=LFNoise2.kr(i*[0.001,0.01]); a*RLPF.ar(Saw.ar(40+(i*10).round(5.73),0.02),(a*2e3).max(100),(i+1)*0.001)})}.play

/* by  Monocular Sludgebath the 7th */
{b=99;GVerb.ar(Mix.fill(b,{|i|a=Saw.ar([b.rand+i,LFNoise0.ar(i*0.5.rand,b,rrand(b,2e3))]);RLPF.ar(Saw.ar(a,a)*0.05,(1000*a).max(b))}))}.play

/* by  Monocular Sludgebath the 7th */
{a=99; Mix.fill(a,{|i| e=EnvGen.ar(Env({1.0.rand}!a,{rrand(1,7)}!98,i.neg,97,0));e*Blip.ar(LFNoise2.ar(7*e,7,e*[a,1e3]+8),e*a%7,0.1)})}.play

/* by  juan alzate romero */
play{Splay.ar(SinOsc.ar(Latch.ar(SinOsc.ar(1.3,0,4e2,5e2),Impulse.ar([1,1.0001])*[1,2,3,4]).lag(0.05),0,0.9))}

/* by  juan alzate romero */
fork{loop{d=rrand(1,9.0);play{f=500.rand+60;Splay.ar(SinOsc.ar(XLine.kr(f,(f,f+1..f+f),d,1,0,2),0,0.1))};d.wait}}

/* by  juan alzate romero */
play{Resonz.ar(Crackle.ar!2,Duty.kr(Dseq([1,1,4,2,2]/8,inf),0,Dseq([99,Dwhite(99,9e3,1)],inf)),TExpRand.kr(0.001,1,Impulse.kr(8)))*4}

/* by  juan alzate romero */
play{a=LFNoise0;b=FBSineC.ar(a.kr(4,2e4,2e4),a.kr(10,16,17),1,1.005,0.7)!2;Latch.ar(b,Impulse.ar(a.kr(0.5,5e3,4e3)))*a.kr(5,0.4,0.5)}

/* by  juan alzate romero */
play{x=LFDNoise3;Blip.ar(x.kr(1,[400,100],500),x.kr([1,2],6,5))*Gendy3.ar(1,1,1,1,x.kr(1,99,91),1,0.1)*x.ar(0.5,0.5,0.5)}

/* by  pyoungryang ko */
Routine({inf.do{|i|{SinOsc.ar(263.rand-i%97.nthPrime*7,0,EnvGen.kr(Env.sine(9.9.rand,0.01.rand),doneAction:2))}.play;(i%0.13).wait}}).play

/* by  pyoungryang ko */
Routine({inf.do{|i|{SinOsc.ar(57.rand+i%181.nthPrime*5,0,EnvGen.kr(Env.sine(9.rand,0.01.rand),doneAction:2))}.play;(i%0.17).wait}}).play

/* by  matt rogalsky */
{Splay.ar(Array.fill(100, { Pulse.ar(LFNoise2.kr(1,2500,10000)) + BPF.ar(Dust.ar(rrand(0.001,0.009)),LFNoise2.kr(0.01,50,5000),0.01,500) }))}.play;

/* by  lfsaw */
{Splay.ar({SinOscFB.ar(LFSaw.ar(Sweep.ar(Impulse.ar(Rand()),2)).range(Rand(99,999), Rand()),Sweep.ar(Impulse.ar(Rand())))}!10)}.play

/* by  arthur carabott */
{a=99;Limiter.ar(FreeVerb.ar(Mix.fill(a, {|i|Saw.ar(55*i, Lag.kr(Impulse.kr(i*0.04), 1.0.rand))}),SinOsc.kr(6), FSinOsc.kr(0.01,0.5)))}.play

/* by  micromoog */
play{LFCub.ar(LFSaw.kr(LFPulse.kr(1/4,1/4,1/4)*2+2,1,-20,50))+(WhiteNoise.ar(LFPulse.kr(4,0,LFPulse.kr(1,3/4)/4+0.05))/8)!2}//#supercollider

/* by  micromoog */
play{BPF.ar(VarSaw.ar(LFNoise1.kr(3,40,200),0,0.25)+PinkNoise.ar(0.1),LFNoise2.kr(12,700,1000),0.3)!2};//#supercollider

/* by  micromoog */
4.do({{PanB2.ar(Gendy1.ar(1,1,1,1,rrand(150,250),500,0.1)*LFNoise1.kr(1,0.25,0.75),LFNoise1.kr(1))}.play})//#supercollider

/* by  micromoog */
play{a=VarSaw.ar(SinOsc.ar(1/20,7/3,80,80),0,LFNoise1.kr(1,1/2,1/2))*Line.ar(0,1)!2;CombN.ar(a,2,2,20,1,a).softclip}//#supercollider

/* by  micromoog */
play{VarSaw.ar((Hasher.ar(Latch.ar(SinOsc.ar((1..4)!2),Impulse.ar([5/2,5])))*300+300).round(60),0,LFNoise2.ar(2,1/3,1/2))/5}//#supercollider

/* by  micromoog */
{BPF.ar(DynKlang.ar(`[[3,5,[4,6]]],Demand.kr(Impulse.kr(1/3),0,Dseq([9,8,6,4],inf))*7).floor,LFPar.ar(1,2,911,999))/3}.play;//#supercollider

/* by  micromoog */
play{a=LFNoise1;SinOsc.ar(round(VarSaw.ar(a.kr(10,0.1),0,1)*a.kr(1!2!2,400),a.kr(1/50,32,76))).tanh}//#supercollider

/* by  mstep */
{LeakDC.ar((GVerb.ar(GrainIn.ar(2,LFSaw.ar(LFSaw.ar(10)),Trig.ar(SinOsc.ar(4),1)*200,SinOsc.ar([60, 70]),0,-1),15)).tanh*0.2) }.play

/* by  nathaniel virgo */
p={|f,a=5|GVerb.ar(LFPulse.ar(f)*a)+f};play{tanh(HPF.ar(p.(99-p.(1/2,20)*(1+p.(2,1/5))+p.(4+p.(1/2)),0.5),80,XLine.kr(4e-4,1/8,61,1,0,2)))}

/* by  nathaniel virgo */
Ndef(\,{LPF.ar(x=DelayN.ar(LeakDC.ar(Ndef(\).ar,1-2e-6)*0.99,1,0.01)+Dust.ar(0.5!2);x+(Trig1.ar(x<(x.mean.lag(30)),4e-3)*0.05),800)}).play

/* by  nathaniel virgo */
Ndef(\,{x=DelayL.ar(n=Ndef(\);n.ar,2,LFNoise0.kr(0.03*_!20)+1)+Blip.ar(0.5);LeakDC.ar(LPF.ar(x+x.mean*0.15,4e3)).sin});play{Splay.ar(n.ar)}

/* by  nathaniel virgo */
play{w=LFSaw;a=w.ar(-3,1)+1/2;f=Sweep.ar(0,3).floor;f=(f**3+f%8+4)*(f%3+3)%49*3;CombN.ar(RLPF.ar(w.ar(f)*a,f**a*30,0.3).tanh,5/6,5/6,6)!2}

/* by  nathaniel virgo */
play{PitchShift.ar(CombN.ar(Formant.ar(101,4**LFNoise1.kr(0.5)*450,200),1,0.5,99),1,Duty.kr(4,0,Dseq([[6,8,10],[6,7.2,7]]/8,inf))).sum/25!2}

/* by  nathaniel virgo */
p=Impulse;play{mean({|i|Pluck.ar(LFSaw.ar([102,101]),x=p.ar(1,i/10)+p.ar(0),1,1/Latch.ar(1.015**Sweep.ar(0,1)*64%1+1*200,x),4,0.2)}!10)}

/* by  nathaniel virgo */
play{x=Saw.ar([50,50.1]);8.do{|i|f=2**(8-i);x=BRF.ar(AllpassN.ar(x,1,0.1/(12-i),2),80**TRand.ar(0,1,Impulse.ar(f/32,1/2)).lag(1/f)*80,2)};x}

/* by  nathaniel virgo */
play{Splay.ar({|i|f=1.9**i/128;BPF.ar(PinkNoise.ar(1!2),4**LFNoise2.kr(1.2**i/16)*300,0.15)*(5**LFNoise2.ar(f)/(i+8)*20)}!15)}

/* by  nathaniel virgo */
play{x=Splay.ar({|i|RLPF.ar(0.6**i*40*Impulse.ar(2**i/32,1/2),4**LFNoise0.kr(1/16)*300,5e-3).sin}!8);2.do{x=FreeVerb2.ar(*x++[0.1,1,1])};x}

/* by  nathaniel virgo */
play{({|i|x=Dbufrd(b=LocalBuf(5).clear,i);x=x**x-LFNoise0.ar(1/(2**i),50).floor%16;Pulse.ar(Duty.ar(1/8,0,Dbufwr(x,b,i))*20)}!5).mean!2}

/* by  nathaniel virgo */
play{b=LocalBuf(4e5,2).clear;BufCombL.ar(b,LeakDC.ar(LPF.ar(PlayBuf.ar(2,b,16/15,0,0,1),300))+Blip.ar([20,21],1),2,40)/20}//#supercollider

/* by  nathaniel virgo */
play{b=LocalBuf(4e5,2).clear;BufCombL.ar(b,LeakDC.ar(BufRd.ar(2,b,LFNoise1.ar(0.25)+1*2e5)*0.98)+Blip.ar(2!2,10),2,20)/10}//#supercollider

/* by  nathaniel virgo */
play{b=LocalBuf(1e5,2).clear;x=BufRd.ar(2,b,Phasor.ar(0,1,0,1e5))*0.6;BufWr.ar(Blip.ar([1,1.01],10)/5+x,b,LFNoise1.ar(0.2)+1*5e4);x}//#sc

/* by  nathaniel virgo */
Ndef(\,{x=DelayN.ar(LeakDC.ar(Ndef(\).ar),1,z=1e-2);LPF.ar(Trig1.ar(Amplitude.kr(x,5,120)*1.5+x+z-Dust.ar(2),4e-3)*0.1+x*0.99,1200)}).play

/* by  nathaniel virgo */
f=g=0;Routine({loop{g=g+1e-3;f=f+g%1;play{l=Line.kr(1,0,3,doneAction:2);h=2**f*100;e=Pluck.ar(CuspL.ar,1,i=1/h,i,2,0.3)!2};0.15.wait}}).play

/* by  nathaniel virgo */
Ndef('x',{x=Ndef('x').ar+0.01;a=BPF.ar(x,6**Latch.ar(x,Dust.ar(x))*200,0.1).sin;9.do{a=AllpassN.ar(a,0.2,{0.2.rand}!2,9)};a+a.mean}).play;

/* by  nathaniel virgo */
Ndef('x',{x=(Ndef('x').ar*1.8).tanh;BPF.ar(x+[0.01,0.1],12**Latch.ar(x.mean,Impulse.ar(3)).lag(0.1)*200)}).play//#supercollider

/* by  nathaniel virgo */
b=Buffer.read(s,"sounds/a11wlk01.wav");play{t=Impulse.kr(5);PlayBuf.ar(1,b,1,t,Demand.kr(t,0,Dseq(1e3*[103,41,162,15,141,52,124,190],9)))!2}

/* by  nathaniel virgo */
Ndef(\x,{DelayN.ar(BRF.ar(Saw.ar(20!2)*0.01+Rotate2.ar(*(Ndef(\x).ar*2).tanh++0.1),20**LFNoise1.kr(0.6)*500,1),1,1)}).play//#supercollider

/* by  nathaniel virgo */
Ndef('x',{Normalizer.ar(FreqShift.ar(Rotate2.ar(*Ndef('x').ar++1/8).tanh,20*[-3,0.995])+Dust.ar(1!2,0.005),1,0.5)}).play//#supercollider

/* by  nathaniel virgo */
play{p=PinkNoise.ar(1!2);BRF.ar(p+Blip.ar(p+2,400),150,2,0.1)+LPF.ar(FreeVerb2.ar(*LPF.ar(p+0.2*Dust.ar(0.1),60)++[1,1,0.2,1e4]).tanh,2000)}

/* by  nathaniel virgo */
x=0;Pbind(*[type:\set,id:{|freq=10|f=freq;LPF.ar(Saw.ar(f),f.lag(1)*3)!2}.play.nodeID,freq:Pfunc{x=x+32%35;x%12+1*40},dur:1/6]).play

/* by  nathaniel virgo */
x=0;Pbind(*[type:\set,id:{|freq=10|LFTri.ar(freq.lag(0.1))!2}.play.nodeID,freq:Pfunc{x=x+32%355;x%12+1*40},dur:1/6]).play//#supercollider

/* by  nathaniel virgo */
n={|r,f,n=0,d=1|round(r**LFNoise0.ar([4,1,8,2]!d)*f,n)};play{Splay.ar(d=n.(3,0.6);Ringz.ar(d*0.01,n.(2,n.(20,400),40,20),d).mean.tanh)}

/* by  nathaniel virgo */
n={|r,f,d=1|2**LFNoise0.kr(1!d,r)*f};{p=n.(4,1e3);CombN.ar(Ringz.ar(LFPulse.ar(1,0,0.01),n.(2,p,80),0.6).sum,8/5,8/5,60)*4e-4!2}.play

/* by  nathaniel virgo */
x=LFPulse;d={|l,h,f,p,n|sum({Ringz.ar(x.ar(f,p,0.01),exprand(l,h).round(n),0.6)}!40)};{d.(30,150,2,[0,0.3],[1,x.kr(1/8)*10+40])*3e-4!2}.play

/* by  nathaniel virgo */
d={|l,h,f,p,n|sum({Ringz.ar(LFPulse.ar(f,p,0.01),exprand(l,h).round(n),0.5)}!20)};{d.(50,150,[2,1,1],[0,1/4,3/4],[1,40,50])*3e-4!2}.play

/* by  nathaniel virgo */
d={|l,h,f,p|({Ringz.ar(LFPulse.ar(f,p,0.01),exprand(l,h),0.5)}!20).sum};{d.(50,100,2,[0,1/4])+d.(3e3,1e4,4,0)+d.(2e2,3e3,1,0.5)*3e-4!2}.play

/* by  nathaniel virgo */
{LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play//#supercollider

/* by  nathaniel virgo */
f=0;Routine({inf.do{|i|f=i/12+f%[4,3];{Formant.ar(2**f*100,2**(i%8*f*0.2)*100,100)*Line.kr(0.1,0,1)}.play;0.25.wait;}}).play//#supercollider

/* by  nathaniel virgo */
p={|f,a=1|LFPulse.ar(f)*a*[1,1.01]};{p.(p.(100-p.(1/16,20))+p.(2,1+p.(1/4))-0.5*200)+p.(100-p.(1/8,20),p.(8))*0.1}.play//#supercollider

/* by  nathaniel virgo */
{a=LFTri.ar(1);20.do{a=BAllPass.ar(a,80,1);a=((a+0.02)*LFNoise0.kr(1/2)*8).tanh;a=LeakDC.ar(a,0.995)};a*0.1!2}.play//#supercollider

/* by  nathaniel virgo */
{a=PinkNoise.ar(1!2);50.do{a=BBandStop.ar(a,LFNoise1.kr(0.05.rand).exprange(40,15000),exprand(0.1,2))};LPF.ar(a,1e5)}.play//#supercollider

/* by  andrea valle */
{"|i|{Saw.ar(i.ascii.midicps,Line.kr(1,0,1,1,0,2))}.play;0.1.wait".do{|i|{Saw.ar(i.ascii.midicps,Line.kr(1,0,1,1,0,2))}.play;0.1.wait}}.fork

/* by  batuhan bozkurt */
{a=LocalIn.ar;LocalOut.ar(Mix.ar(x=SinOsc.ar((Decay.ar(Impulse.ar([4,4.005]),1e3*a.abs)*50), a).distort));x;}.play;//tryingharder_to_noavail

/* by  batuhan bozkurt */
{f=LocalIn.ar(2).tanh;k=Latch.kr(f[0].abs,Impulse.kr(0.5));LocalOut.ar(f+AllpassN.ar(Pulse.ar([2,3],k*0.01+1e-6,0.9),1,k*0.3,100*k));f}.play

/* by  batuhan bozkurt */
play{f=LocalIn.ar(2).tanh;k=Latch.kr(f[0].abs,Impulse.kr(1/4));LocalOut.ar(f+CombC.ar(Blip.ar([4,6],100*k+50,0.9),1,k*0.3,50*f));f}//44.1kHz

/* by  batuhan bozkurt */
play{t=Impulse.ar(75);Sweep.ar(t,150).fold(0,1)*PlayBuf.ar(1,Buffer.read(s,"s*/*".pathMatch[2]),1,t,Demand.ar(t,0,Dbrown(0,2e5,2e3,inf)))!2}

/* by  batuhan bozkurt */
play{f={LocalBuf(512)};r={|k,m|RecordBuf.ar(Pulse.ar(8,m,6e3),k)};r.(a=f.(),0.99);r.(b=f.(),0.99001);Out.ar(0,IFFT([a,b]).tanh)};//44.1kHz:)

/* by  batuhan bozkurt */
play{AllpassC.ar(SinOsc.ar(55).tanh,0.4,TExpRand.ar(2e-4, 0.4,Impulse.ar(8)).round([2e-3,4e-3]),2)};// #supercollider with bass please...

/* by  batuhan bozkurt */
play{Mix({a=LFNoise1.ar(0.2.rand);DelayC.ar(BPF.ar(WhiteNoise.ar(Dust2.ar(a*a*4**2).lag(8e-3)),10e3.rand+300,0.09),3,a*1.5+1.5,45)}!80).dup}

/* by  batuhan bozkurt */
play{a=BPF.ar(Saw.ar([40,40.001]),LFNoise0.kr(128)+1*4e3+146,LFNoise1.kr(1)+1*5e-2+0.01).tanh;CombC.ar(a,9,a.abs.lag(2)*9,a.abs.lag(1)*100)}

/* by  batuhan bozkurt */
play{LocalOut.ar(x=DelayC.ar(LPF.ar(LFNoise0.ar(8)**2+LocalIn.ar(2).tanh.round(0.05),6e3),1,LFNoise0.ar(8!2).range(1e-4,0.02)));x.tanh}//#sc

/* by  batuhan bozkurt */
play{t=Impulse.ar(8)*LFNoise1.ar(2);CombL.ar(Saw.ar([3,4],Decay.ar(t,0.1)).tanh,1,TRand.ar(0,0.01,t).round(15e-4),TRand.ar(-30,30,t))};//#sc

/* by  batuhan bozkurt */
play{LocalOut.ar(x=LFNoise1.ar(0.5*LocalIn.ar(1)+0.1,0.5,0.5));PitchShift.ar(PitchShift.ar(Pulse.ar([90,90.01],x),10,x*4,x),10,4-(x*4),1-x)}

/* by  batuhan bozkurt */
play{q=[0,3,5,7,10];t=Impulse.kr(4)*LFNoise0.kr>0;PitchShift.ar(Saw.ar(Demand.kr(t,0,Drand((q+12++q+33).midicps,inf)),Decay.kr(t,3)),7,2)!2}

/* by  batuhan bozkurt */
play{(HPF.ar(LFNoise1.ar(2),[10,10.1])*100).tanh}// #supercollider yay! (be very careful with this one, very loud)

/* by  batuhan bozkurt */
play{t=[0,3,5,7,10,12]+30;a=Demand.kr(Impulse.kr(8),0,Drand(t+24++t,inf));(BHiPass.ar(LFNoise1.ar(8)**3,[a,a+0.2].midicps,a/2e3,67-a)).tanh}

/* by  batuhan bozkurt */
play{t=[0,0,0,1,5,7,10,12,12,12]+30;a=Duty.kr(1/8,0,Dxrand(t+24++t++t,inf));(BHiPass.ar(LFNoise1.ar(8)**6,[a,a+7].midicps,a/3e3,67-a)).tanh}

/* by  batuhan bozkurt */
play{LeakDC.ar(BRF.ar(Saw.ar(8,Decay2.kr(x=Duty.kr(1/8,0,Drand([0,Drand((0.4,0.5..1))],inf)),0.01,0.3))**1.5,x*20+[45.1,45],0.1)).tanh}//#sc

/* by  batuhan bozkurt */
play{t=Impulse.kr(1/4);k=Duty.kr(2,0,Dxrand((50,52..90),inf));r={|a|Saw.ar(TIRand.kr(1,6,t),a+1*3)}!3;BPF.ar(r.sum,[k,k+0.5],1/9,50).tanh}

/* by  batuhan bozkurt */
play{Mix({|k|k=k+1/2;2/k*Mix({|i|i=i+1;Blip.ar(i*XLine.kr(rand(2e2,4e2),87+LFNoise2.kr(2)*k,15),2,1/(i/a=XLine.kr(0.3,1,9))/9)}!9)}!40)!2*a}

/* by  batuhan bozkurt */
play{t=[0,3,5,7,10,12]+40;p=Duty.ar(1/4,0,Drand((t+12++t).midicps,inf));Blip.ar([b=TRand.ar(1500,2e3,Impulse.ar(16)).lag,b+p],1).mean!2**2}

/* by  batuhan bozkurt */
play{n=LFNoise0.kr(_);v=Blip.ar([2e4,2e4-9],1,n.(16)*0.5+0.5**9);42.do{v=LeakDC.ar(AllpassC.ar(v,1,n.(5)*5e-2+(5e-2+1e-3),100))};tanh(v*99)}

/* by  batuhan bozkurt */
play{Mix(HPF.ar(MidEQ.ar(Limiter.ar(GVerb.ar(HPF.ar(Pulse.ar([[0.1,0.11],[0.12,0.13]],0.6,5e-3),99),[[1,5/4],[1.5,2]],99)),9e3,0.9,9),200))}

/* by  batuhan bozkurt */
{r=44100;BufRd.ar(1,Buffer.read(s,"s*/*".pathMatch[2]),[r,r+500]*LFNoise0.ar(8,9,9)+(Sweep.ar(t=Impulse.ar(8),r)%TRand.ar(100,r/2,t)))}.play

/* by  batuhan bozkurt */
play{i=Impulse.ar(_);SinOsc.ar(i.(2).lagud(0,0.4)*360,Integrator.ar(Integrator.ar(i.(64).lag(LFNoise1.ar(2!2,2,2))*99,0.9),0.99).fold2(pi))}

/* by  batuhan bozkurt */
play{Splay.ar(Integrator.ar(LFNoise0.ar(5!3,k=Duty.ar(6.4,0,Dseq([0.05,Drand([0.04,0.08],1)],inf))).round(k/10)).sin.sqrt.tanh,0.3)}//#sc...

/* by  batuhan bozkurt */
play{LocalOut.ar(k=LeakDC.ar(Integrator.ar(Pulse.ar(pi/[1,2.57],[0.54,0.46]),(1-LocalIn.ar(2)).fold(0,[0.9,0.85])).wrap2(pi).sin));k.mean!2}

/* by  batuhan bozkurt */
{n=LFNoise0.ar(_);f=[60,61];tanh(BBandPass.ar(max(max(n.(4),l=n.(6)),SinOsc.ar(f*ceil(l*9).lag(0.1))*0.7),f,n.(1).abs/2)*700*l.lag(1))}.play

/* by  batuhan bozkurt */
play{LocalOut.ar(k=tanh(500*(PinkNoise.ar(1!2)**(8/(LagUD.ar(y=LocalIn.ar(2).range(0, 0.9)+0.1,0,0.2))))));Splay.ar(k,1-y)}

/* by  batuhan bozkurt */
play{i=Impulse.ar(8).lag(0.3)!2;10.do{i=LeakDC.ar(AllpassC.ar(i,1,LFNoise0.ar(8).range(1e-5,0.2),-0.15,LFNoise0.ar(8).range(1,3))).tanh};i}

/* by  batuhan bozkurt */
play{n=LFNoise0.kr(*_);v=Blip.ar([60,61],5,n.(4)**8);12.do{v=LeakDC.ar(CombC.ar(v,1,n.([1,0.05,0.06]).lag(5e3),9))};Limiter.ar(v,0.9,1)}

/* by  batuhan bozkurt */
play{k=Pulse.ar([3,3.01,2,2.01]/2,[0.4,0.6]).lag(0.8,0);k=[k[0],k[1]]*[k[2],k[3]];Splay.ar((k*Blip.ar([80,81],2)*6.5).tanh,0.5)}

/* by  julian rohrhuber */
play { [0,0.08] * Pulse.ar(2020) * product(LFPulse.ar([8,1])) + [PinkNoise,WhiteNoise].sum(_.ar(XLine.kr(0.4, 0.02, 20) ! 2)) };

/* by  julian rohrhuber */
play { [0,0.08] * Pulse.ar(2020) * product(LFPulse.ar([8,1])) + Dust.ar(XLine.kr(10000, 10, 20) ! 2, 2) };

/* by  taylan cihan */
play{{Mix.fill(8,{a=LFDNoise0.kr(9);b=a.range(1e-4,0.2);c=a.abs*2e3;d=b.sqrt;RLPF.ar(CombL.ar(FBSineL.ar(c,a,a,a),b,b,d),c,d).tanh*0.2})}!2}

/* by  taylan cihan */
play{Mix.fill(8,{a=LFDNoise1.kr(18);b=a.range(1e-4,0.1);AllpassC.ar(CombC.ar(FBSineC.ar(a.abs*2e4,a,a,a),b,b,b**a),b,b,a).distort*0.2}!2)}

/* by  chad mckinney */
play{{|i|r=LFNoise2.ar(0.3,0.5,0.5);n=DelayC.ar(In.ar(i*r),1,i);Out.ar(i*r,Ringz.ar(n+Impulse.ar(),Pitch.kr(n)[0]*i,200).softclip)}!30};

/* by  pyoungryang ko */
play{Mix.fill(64,{Resonz.ar(Impulse.ar(0.1.rand,0.8,9.9.rand),9+99.rand.nthPrime*SinOsc.kr([1,1.7]*0.001).range([59,2],[2,11]),0.0004,33)})}

/* by  johannes quint */
{z=300;e=EnvGen.kr(Env([20,16000],[z],8),doneAction:2);Pan2.ar(RLPF.ar(RHPF.ar(BrownNoise.ar(0.5),e),e),Line.kr(-1,1,z))}.play

/* by  scott wilson */
{GVerb.ar(Formant.ar(Duty.kr({Drand([0.1,0.17],inf)},0,["SCBerlin10!","Vielen Dank,Andre!"].collect({|t|Dseq(t.ascii/2,inf)})))/4).sum}.play

/* by  scott wilson */
{Formant.ar(Duty.kr({Drand([0.01,0.3],inf)},0,["SCBerlin10!","Vielen Dank,Andre!"].collect({|t|Dseq(t.ascii/Drand([2,9]),inf)})))*0.4}.play

/* by  scott wilson */
{f=Duty.kr({Drand([0.1,0.13],inf)},0,["SCBerlin10!","Vielen Dank,Andre!"].collect({|t|Dseq(t.ascii/2,inf)}));Formant.ar(f,f*19,f*50)/4}.play

/* by  andre bartetzki */
{SinOsc.ar([20,23.7]*3,0,0.4).sqrt.thresh(LFNoise0.ar(11.3)).scaleneg(WhiteNoise.ar(0.4)).ring2(Impulse.ar([12.7, 10.1]))}.play

/* by  andre bartetzki */
{FSinOsc.ar([11,11.3],0,100).sqrt.thresh(LFNoise0.ar(1.3,70)).scaleneg(Pulse.ar([7,8]*1000)).distort.ring4(LFNoise2.ar([0.3,0.3]))}.play

/* by  tedthetrumpet */
Pbind(\freq,Pseq((40,43..400).pyramid(3)),\dur,0.01).play;

/* by  julian rohrhuber */
Ndef(\y, { a = { Drand([Dshuf({0.005.rand}!rrand(2,12),SinOsc.kr(0.1)*40), 0.1], inf)}; TDuty.ar(a!2,0,0.1)  }).play;

/* by  julian rohrhuber */
Ndef(\y, { a = {{ Drand([Dshuf({0.0001.rand}!rrand(2,11),SinOsc.kr(0.1)*40), 0.05], inf) }}; TDuty.ar(a!2!8,0,0.1).sum  }).play;

/* by  sciss */
play{{|i|b=LocalBuf(512);d=HPZ1.ar(Dust.ar(99));x=(IFFT(FFT(b,PlayBuf.ar(1,b)+d,0.5,0,1-d))).wrap;RecordBuf.ar(InFeedback.ar(i),b);x}!2}

/* by  sciss */
play{{|i|b=LocalBuf(64);d=HPZ1.ar(Dust.ar(99));x=CombN.ar(IFFT(FFT(b,PlayBuf.ar(1,b)+d,1,0,1-d)))%1;RecordBuf.ar(InFeedback.ar(i),b);x}!2}

/* by  xe kondo */
play{LPF.ar(SelectX.ar(LFNoise0.kr(0.2,20,20)lag:5,{Ringz.ar(TDuty.ar(Dseq([2,3,5].scramble*0.1,120)),Rand(110,440))*0.5}!40),999)!2}

/* by  tweety on a power cord */
{SinOsc.ar(SinOsc.ar([0.1, 0.2],0.5,{LFNoise2.kr(25, 0.5, 2.5)}!2)/SampleDur.ir)}.play;

/* by  mr proxxxy */
(q=4;q.do{|i|{BPF.ar(PinkNoise.ar(Impulse.kr([2*q,2*q+(0.01*q)])), 400*q,0.4/q)}.play;}; {SinOsc.ar([60,61],mul:0.25)}.play)

/* by  mr proxxxy */
(q=10;q.do{|i|{SinOscFB.ar([75+i,85+i],LFPulse.kr([60/q,60.05/q],add:0,mul:LFTri.kr(20/q,mul:20/q)),mul:1/q)}.play})

/* by  tedthetrumpet */
Ndef(\x,Pbind(\midinote,Prand((20..60),inf),\amp,20,\dur,0.2));Ndef(\y,{Ndef.ar(\x).clip2(0.1)}).play;

/* by  jonatan liljedahl */
play{a=PinkNoise.ar(LFNoise1.ar(9,0.05));9.do{a=LeakDC.ar(CombN.ar(a,0.3,{0.3.rand+0.03}!2,7))};LPF.ar(tanh(LPF.ar(a+a.mean,777)),7777)}

/* by  jonatan liljedahl */
n=LFNoise1;Ndef('x',{a=SinOsc.ar(65,Ndef('x').ar*n.ar(0.1,3),n.ar(3,6)).tanh;9.do{a=AllpassL.ar(a,0.3,{0.2.rand+0.1}!2,5)};a.tanh}).play

/* by  jonatan liljedahl */
play{tanh((z=Ringz).ar((i=Impulse).ar(1,[0,5.7/8,1.7/8],[4,1,0.2]).sum,[400,300],0.3)+z.ar(i.ar(1/2,3/4),50,0.7,1+PinkNoise.ar))}

/* by  jonatan liljedahl */
play{v=Saw.ar([40,41])*4;6.do{|n|v=LeakDC.ar(AllpassL.ar(v,0.2,n*0.004+0.014+Saw.ar(0.25+n*0.25,0.01),1))};v.clip2(1)}

/* by  jonatan liljedahl */
play{v=Dust2.ar(4!2);7.do{|n|v=LeakDC.ar(CombL.ar(v,0.2,n*0.001+0.03+LFNoise1.kr(10,0.001),3))};v.clip2(1)}

/* by  tristan strange */
play{GVerb.ar(Saw.ar(GbmanN.ar([4,9])*XLine.kr(30,1600,120))/3,10).tanh};// robotic guitarists and violinists were never likely to get on

/* by  marcus wrangoe */
play{GVerb.ar(CombC.ar(Dust.ar(100)/Blip.ar(200,Line.kr(5,50,200),0.1),Dust.ar(1),0.01,0.02),9,9,mul:0.0001)}

/* by  marcus wrangoe */
play{GVerb.ar(CombC.ar(Gendy1.ar(6,6,3,Dust.ar([100,101],1),20,400),1,0.01,0.02),9,9,mul:0.1)}

/* by  marcus wrangoe */
play{x=1500;b=SinOsc;d=Dust;t=Trig.ar(d.ar(x),b.ar(0.01));f=t*b.ar(x+b.ar*t);Limiter.ar(GVerb.ar(GrainIn.ar(2,t,f,f,b.ar(x)),9,9)*0.2,0.4)}

/* by  marcus wrangoe */
play{x=6666;b=SinOsc;d=Dust;t=Trig.ar(d.ar(x),b.ar(0.001));f=t*b.ar(x+b.ar*t);Limiter.ar(GVerb.ar(GrainIn.ar(2,t,f,f,b.ar(x)),9,9)*0.2,0.6)}

/* by  jonatan liljedahl */
play{i=Impulse;LocalOut.ar(b=DelayL.ar(HPF.ar(LocalIn.ar(2),2e2)+Ringz.ar(i.ar(1/2),TExpRand.kr(50,99,i.kr(1/2)),2,4).sin,7/6,7/6).tanh);b}

/* by  jonatan liljedahl */
play{GVerb.ar(Mix.fill(14,{|i|BPF.ar(Decay.ar(Impulse.ar(i*0.1+0.5),0.5,1.2),800*i+40)/(i+1)}),2.7,9).tanh}

/* by  jonatan liljedahl */
play{GVerb.ar(Mix.fill(10,{|i|Ringz.ar(Impulse.ar(i*0.05+0.5),300*i+40,0.12,3+PinkNoise.ar(3)).sin/(i+1)*0.6}),3.4,7).tanh}

/* by  josh parmenter */
{r={|y,z|50.collect{Rand(y,z)}};Pluck.ar(Crackle.ar*0.01,Dust.kr(r.(9,12)),0.01,SinOsc.kr(1/r.(50,20),r.(0,6),4e-4,5e-4),2,0.01).sum}.play

/* by  aucotsi */
play{c=LFPulse.kr(0.5);b=SinOsc.kr(0.0034);a=Line.kr(0.1,2pi,37);FreeVerb.ar(Blip.ar(a*340!2*Impulse.kr(b*34/pi),c*TIRand.kr(0,113,c),c))}

/* by  aucotsi */
play{b=SinOsc.kr(5);a=Line.kr(0.1,2pi,37);FreeVerb.ar(SinOsc.ar(a*341!2*Impulse.kr(b*680/pi),LFPulse.kr(2,0,pi/2),LFPulse.kr(3,0,1/pi*b)))}

/* by  aucotsi */
play{c=LFPulse.kr(50);a=Line.kr(0.1,2pi,37000);b=SinOsc.kr(a/pi);FreeVerb.ar(Blip.ar(a*340!2*Impulse.kr(b*340/pi),c*TIRand.kr(0,999,c),c))}

/* by  josh parmenter */
3.do({{b=Decay2.kr(Dust.kr(0.1),5,7);Pan2.ar(HPF.ar(LPF.ar(WhiteNoise.ar(b+0.4),b*1500+200),b*100+100)*5,1.0.rand2)}.play})//surf's up

/* by  aucotsi */
Array.fib(7,0,4)!2.do({|i|{SinOsc.kr(i)*Line.ar(0.3,0,36,1,0,2)*Blip.ar(340!2*LFPulse.kr(2,0,1/i),TRand.kr(-2pi,2pi,Impulse.kr(9)))}.play})

/* by  aucotsi */
play{b=SinOsc.kr(1);a=Line.kr(0.1,2*pi,37);FreeVerb.ar(SinOsc.ar(b*340!2*Impulse.kr(b*680),LFPulse.kr(2,0,pi/2),LFPulse.kr(3,0,1/pi*a)))}

/* by  marcus wrangoe */
play{Klank.ar(`[[99,98,953,923],nil,[1,1,1,1]],GVerb.ar(CombC.ar(Gendy1.ar(6,6,3,Dust.ar([99,98],1),20,400),1,0.01,0.02),9,9,mul:0.005))}

/* by  tim walters */
play{({|i|Resonz.ar({Gendy1.ar}!2,i*2+1*50,Blip.ar(i+1/99,i+8).squared*0.005*LFTri.kr(i+1*0.001).abs*25)*(i+1).sqrt}!15).sum/4}

/* by  jonatan liljedahl */
play{p=LFPulse;tanh(p.ar(40)*p.kr([0.5,1])+mean({|n|(p.ar(n*2e2+50*p.kr(2-n/[1,3,5],(1..3)/10).sum+4e2)*p.kr(n+1*6,0,0.8).lag)}!2)/2)}

/* by  jonatan liljedahl */
play{p=LFPulse;tanh(p.ar([50,52])*p.kr([2,1]/4)+mean({|n|(p.ar(n*3e2+100*p.kr(2-n/[1,5,7],(0..2)/10).sum+2e2)*p.kr(n+1*6,0,0.8).lag)}!2)/2)}

/* by  aucotsi */
play{#a,b,c=[LFSaw,TRand,SinOsc];a.ar(c.kr(5),b.kr(-2pi,2pi),b.kr(0.1,1.0,c.kr(340)))*c.ar(680!2*c.kr(b.kr(87,393,c.kr(7))),0,c.kr(pi/13))}

/* by  lucas samaruga */
q=play{SinOsc.ar({\freq.kr.lag(0.9.rand)}!2)*0.1};fork{inf.do{5.do{fork{var x=1.7.rand;(1800.rand!10).do{|i|q.set(\freq,i);x.wait}}};7.wait}}

/* by  lucas samaruga */
q=play{SinOsc.ar({\freq.kr.lag(0.9.rand)}!2)*0.1};fork{20.do{5.do{fork{(1800.rand!10).do{|i|q.set(\freq,i);0.9.rand.wait}}};7.wait};q.release}

/* by  aucotsi */
play{#a,b=[SinOsc,TIRand];FreeVerb.ar(a.kr(2)*Formant.ar(68!2*Stepper.kr(LFTri.kr(3),0,4*b.kr(-4,12,a.kr(3).ceil)),a.kr(8*11),222,16))}

/* by  aucotsi */
play{#a,b=[SinOsc,TIRand];FreeVerb.ar(a.kr(1.1)*Formant.ar(44!2*Stepper.kr(LFTri.kr(2.9),0,b.kr(-4,12,a.kr(0.61).ceil)/4),a.kr(0.1),99,8))}

/* by  josh parmenter */
{t=Dust.kr(1);FreeVerb.ar(GrainSin.ar(1,t,0.1,Select.kr(LFNoise1.kr(1,3,2),[[4,6,7,9,11,12],[0,4,4,7,7,7]].flop+84).midicps),1,1)*0.1}.play

/* by  tim walters */
play{GVerb.ar(({|i|Blip.ar(i+1/99,i+1).exprange(1/9999,0.008)*Gendy1.ar(6,6,1,Blip.ar(i+1*[2,3],3).abs,i+2*50,i+3*50)}!16).sum,3,9,0.3)}

/* by  julian rohrhuber */
Ppar({|i| Pbind(\dur, 0.01, \note, sin(i+1*0.002.rand*Pseries()+2.0.rand)*40.rand-10) } ! 5).play;

/* by  stefan nussbaumer */
play{e=Drand((3..65),inf);d={|i|p=Impulse.ar(i+1*2)}!2;GVerb.ar(Blip.ar(Demand.kr(A2K.kr(p),0,e),TExpRand.ar(2e4,20,d*10)),100,0.02,0.02)}

/* by  nathaniel virgo */
x=Ndef(\x,Pbind(\freq,Pseq(a=(3..5);a/.x a*.x[40,80],8)));Ndef(\,{Limiter ar:GVerb.ar(PitchShift.ar(Ndef ar:\,1,2,0,0.1),30,9)/4+x.ar}).play

/* by  nathaniel virgo */
x=Ndef(\x,Pbind(\freq,Pseq(a=(3..5);a*.x a*.x[4,8],8)));Ndef(\,{Limiter ar:GVerb.ar(PitchShift.ar(Ndef ar:\,1,2,0,0.1),20,20)/4+x.ar}).play

/* by  david granstroem */
play{z=SinOsc;y=222;GVerb.ar(z.ar(y+z.kr([27,81],0,y*LFDNoise1.kr(0.4,1.4).abs))*0.03+GVerb.ar(PinkNoise.ar(Decay2.kr(Dust.kr(1!2))*0.02)))}

/* by  david granstroem */
play{z=LFDNoise0;x=Blip.ar(Duty.kr(8,0,Dseq([220,174],inf)).lag,4);5.do{x=BPF.ar(x,z.kr(8!2,400,700).abs,z.kr(0.8!2).range(0.1,1).abs)};x*2}

/* by  david granstroem */
play{x=if(LFPulse.kr(2,0,LFNoise0.kr(1).range(0,1)),SinOsc.ar(1.5)*200,Saw.ar(4,Duty.kr(8,0,Dseq([400,800],inf))));LFTri.ar([120+x,480+x])}

/* by  alexandra cardenas */
{a=Dust;b=TRand;Splay.ar(Blip.ar(b.kr(1,40,a.kr(2.5)),b.kr(1,150,a.kr(0.5))!3),1,b.kr(0,1,a.kr(2)),b.kr(-1,1,a.kr(0.7)))}.play

/* by  alexandra cardenas */
{d=Dust;r=TRand.kr(1,2,d.kr(1));z=TRand.kr(1,2,d.kr(2));l=LFClipNoise;Crackle.ar([z,r], 0.6)+SinOsc.ar([l.ar(r,60,90),l.ar(z,40,100)])}.play

/* by  jonatan liljedahl */
play{GVerb.ar({|i|Ringz.ar(LPF.ar(Impulse.ar(2/(1.2+i)),6e3),1e3/(i+1),0.3)}.dup(20).scramble.sum/2,18,5).tanh}

/* by  jonatan liljedahl */
play{x=0;(100..110).do{|f|f=f/2;x=SinOsc.ar(f+[0,1],x*LFTri.kr(0.4,2).range(1.2,1.6))};x}

/* by  jonatan liljedahl */
play{sum({|i|GrainSin.ar(1,Impulse.ar(LFTri.kr(0.05*i+[0.2,0.201]).range(1,30)),0.02, 200*i+50)}!9).tanh}

/* by  jonatan liljedahl */
play{sum({|i|GrainSin.ar(1,Impulse.ar(LFNoise1.kr(0.5!2).range(1,30)),0.025, 200*i+100)}!7).tanh}

/* by  jonatan liljedahl */
play{a=ar(PinkNoise,5e-4);ar(GVerb,({ar(Ringz,a*LFNoise1.kr(0.2),exprand(60,8000),3)}!40).sum,50,99).tanh}

/* by  jonatan liljedahl */
play{GVerb.ar(GVerb.ar(Impulse.ar([8,6,4]/100,[0,0.2,0.6])*8,[2,3,1.5],90,drylevel:0).sum.sin.sum*0.5,62,24).tanh}

/* by  jonatan liljedahl */
play{LeakDC.ar(GVerb.ar(Mix.fill(14,{|i|BPF.ar(Decay.ar(Impulse.ar(i*0.1+0.5),0.5,1.5),1000*i+40)/(i+1)}),2.7,7)).tanh}

/* by  jonatan liljedahl */
play{GVerb.ar(Mix.fill(10,{|i|Ringz.ar(Impulse.ar(i*0.05+0.5),300*i+40,0.12,3+PinkNoise.ar(3)).sin/(i+1)*0.6}),3.4,7).tanh}

/* by  chad mckinney */
play{b=LocalBuf(8192,4);d=Dust.kr(9)+Dust2.kr([4,4]);r=PlayBuf.ar(2,b,TExpRand.kr(0.01,19,d),d,0,1)/4;FFT(b,d+(d*r));Out.ar(0,r.clip2(1))};

/* by  dan stowell */
d=(TChoose.kr(Impulse.kr(0.5),_));{([LPF,BPF,HPF].choose.ar(Saw.ar(d.((3..6)/3**2)*[44,45]),LFTri.ar(d.((1..8)))*9**3)*9).tanh}.play

/* by  andrea valle */
{t="With my prayers";999.do{|i|{MoogFF.ar(Saw.ar(t[i.postln%15].ascii),i%99*99)*EnvGen.kr(Env.perc)}.play;0.2.wait}}.fork

/* by  scacinto */
{var w,x,z;x=LFNoise0.kr(5,0.3,0.3);w=Mix(SinOsc.ar(x*99%50)!4);z=SinOsc.ar(x*500*w,w%pi+pi).clip(x,x*3)*w.clip;z!2}.play

/* by  alexandra cardenas */
{d=Dust;r=TRand.kr(40,100,d.kr(1));Splay.ar(Ringz.ar(LFPulse.ar([0.1,0.2,1,1.2]),[r,r*1.2,r*3,r*7],[0.6,0.4,0.2,0.1]),1,0.03,0.0)}.play

/* by  alexandra cardenas */
play{d=Dust;r=TRand.kr(50,800,d.kr(15));t=TRand.kr(100,700,d.kr(0.2));Splay.ar(SinOsc.ar({|i|LFNoise2.kr(rrand(10,200),r,t)}!9),1,0.3,0)}

/* by  redfrik */
play{f={|o,i|if(i>0,{SinOsc.ar([i,i+1e-4]**2*f.(o,i-1),f.(o,i-1)*1e-4,f.(o,i-1))},o)};f.(60,6)/60}//#SuperCollider

/* by  redfrik */
play{a=SinOscFB;sum({|i|a.ar(a.ar(a.ar(a.ar(i+1,1/9,999),1/9,a.ar(1/9,1,1/9)),a.ar(0.1,3),i+2*999),a.ar(1/9,1/9),1/9)}!9)!2}//#SuperCollider

/* by  redfrik */
play{b=LocalBuf(9e4,2).clear;i=Sweep.ar(BufRd.ar(2,b,Saw.ar(12,3e4,4e4)),9e4);BufWr.ar(Saw.ar([8,9]),b,i);BufRd.ar(2,b,i)/2}//#SuperCollider

/* by  redfrik */
play{b=LocalBuf(8e4,2).clear;i=Sweep.ar(BufRd.ar(2,b,Saw.ar(3.1,4e4,4e4)),8e4);BufWr.ar(Blip.ar([2,3]),b,i);BufRd.ar(2,b,i)}//#SuperCollider

/* by  redfrik */
play{b=LocalBuf(5e3,2).clear;i=Sweep.ar(BufRd.ar(2,b,Saw.ar(50,2e3,5e3)),6e4);BufWr.ar(Saw.ar([4,3]),b,i);BufRd.ar(2,b,i)/6}//#SuperCollider

/* by  redfrik */
play{b=LocalBuf(1e4,2).clear;i=Sweep.ar(BufRd.ar(2,b,Saw.ar(1,2e3,5e3)),5e5);BufWr.ar(Saw.ar([8,50]),b,i);BufRd.ar(2,b,i)/3}//#SuperCollider

/* by  redfrik */
play{a=LFPulse;b=(1..4);Mix(a.ar(a.ar(a.ar(a.ar(b/32)+1/8)+1*b)+(Mix(a.ar(b/64))+a.ar(4/b)*(a.ar(a.ar(b/8))*2+b))*100))/8!2}//#SuperCollider

/* by  redfrik */
r{{|j|a=play{sin(Decay.ar(Duty.ar(1/50,0,Dseq(flat({|i|asBinaryDigits(j+1*i)}!8),4),2),j+1*0.008))/2!2};5.12.wait}!256}.play//#SuperCollider

/* by  redfrik */
play{a=1/(2..5);GVerb.ar(Splay.ar(Ball.ar(LPF.ar(Impulse.ar(a),500),7-(1/a),1e-5,LFNoise2.kr(a/5,2e-4,12e-4))/2),5,0.5,0.9)}//#SuperCollider

/* by  redfrik */
play{Splay.ar({|i|f=i+5*99;RHPF.ar(Ringz.ar(Ball.ar(Saw.ar(i+1)>0,SinOsc.kr(0.1,0,1/5,0.3),0.05,0.02)/99,f,0.05),f,0.1)}!5)}//#SuperCollider

/* by  redfrik */
{|j|r{{|i|x=sin(i/5+(j*5));Ndef(i%5+(j*5),{Pan2.ar(LFCub.ar(j*2+x*40+400+i)/15,i%5/2-1)}).play;wait(x.abs+0.5)}!500}.play}!5//#SuperCollider

/* by  redfrik */
{CombL.ar(In.ar(8).tanh/8,1,1,8)!2}.play;Pbind(\amp,8,\dur,1/4,\degree,Pseq(List.fib(32)%(List.fib(64)%12),inf),\out,8).play//#SuperCollider

/* by  redfrik */
play{GVerb.ar(ceil(In ar:8*4+4)-4/10)};Pbind(\dur,2,\legato,Pgeom(0.5,1.1),\degree,Pseq(List fib:8+[[1,4]]-9,9),\out,8).play//#SuperCollider

/* by  redfrik */
play{MoogFF.ar(LFTri.ar(CombN.ar(Duty.ar(1/8,0,Dseq(Dshuf(List.fib(16)%8*99,8),inf)),4,4,16))/4,LFTri.kr(1/16,0,2e3,3e3))!2}//#SuperCollider

/* by  redfrik */
play{{|i|CombC.ar(In.ar(8),3+i,LFTri.ar(0.5,0,1,2+i),99)}!2};Pbind(\out,8,\note,Pstutter(8,Pseq(List.fib(32)%9/3,inf))).play//#SuperCollider

/* by  redfrik */
play{a=LFPar;GVerb.ar(VarSaw.ar(a.ar(1,0,5,a.ar([0.05,0.04],0,50,160).round(50)),0,a.ar(0.2,0,0.5,a.ar(3,0,0.2,0.5)))/8,80)}//#SuperCollider

/* by  redfrik */
x=0;{|i|Pbind(\dur,i+1/4,\lag,i/6/6,\octave,i+3,\legato,i+1/6,\degree,Pn(Plazy{x=x+1%6;Pseq(asDigits(x+1*142857))})).play}!6//#SuperCollider

/* by  alexandra cardenas */
{p=Pan2;n=LFNoise2;p.ar({Blip.ar(n.kr(0.1).range(12),n.kr(0.1).range(10,1200))}!8,0,0.2)}.play

/* by  alexandra cardenas */
play{n=LFDNoise3;Limiter.ar(Splay.ar(VarSaw.ar([n.kr(1).range(60,180),80,n.kr(2).range(70,120)])*n.ar(50).wrap2(n.kr(1.7)),1,1,0),0.5,0.01)}

/* by  juan alzate romero */
play{GVerb.ar(Blip.ar((Duty.kr(1/[1,2,4],0,Dseq([0,3,7,12,17]+24,inf))).midicps*[1,4,8],LFNoise1.kr(1/4,3,4)).sum,200,8)} // #sc

/* by  juan alzate romero */
play{d=Duty;t=d.kr(1,0,Dseq(0-[0,7,5,2],inf));f=d.kr(1/3,0,Dseq([0,3,7,12,8]+60,inf));GVerb.ar(Blip.ar(f.midicps*t.midiratio,4),99,4)} //#sc

/* by  juan alzate romero */
play{d=Duty;f=d.kr(1/[1,2,3],0,Dseq([0,3,7,12,8]+36,inf));GVerb.ar(Blip.ar(f.midicps*[1,2,3],LFNoise1.kr(1,8,8)).sum,99,4)} // #sc

/* by  juan alzate romero */
play{t=Impulse.kr(6);f=lag(Demand.kr(t,0,Drand(midicps((10,13..40)),inf)));RLPF.ar(Pulse.ar(f),1+Decay2.kr(t)*LFNoise2.kr(2,8,9)*f,1/9)!2}

/* by  juan alzate romero */
9.do{|i|Pbind(\scale,#[0,3,5,7,10],\octave,3.rand+3,\dur,(12.rand+1)/5,\degree,Pn(Plazy{Pseq(18.partition(8.rand+2)-1,4)})).play}

/* by  adina izarra */
({(Mix.fill(98,{SinOsc.ar(5000*rrand(1.0,1.9),0,1/18)}))*EnvGen.ar(Env.perc(0.01 * 0.5, 0.01 * 0.9),Dust.ar(6))!2}.play)

/* by  steel stylianou */
play{x=SinOsc;y=LFNoise1;a=y.ar(4);(MoogFF.ar(LFPulse.ar(y.ar(1,96,768))+x.ar(Pulse.ar(6)*64)+x.ar(8+(a*96)),a*XLine.ar(1,8,9,96,9,0)))!2/3}

/* by  scott wilson */
{f=Duty.kr({Drand([0.1,0.11],inf)}!2,0,Dseq("AllWorkAndNoPlayMakesPAaDullBoy".ascii/2,inf));Formant.ar(f,f*19,LFNoise2.kr(1!2,f*70))/4}.play

/* by  juan alzate romero */
Buffer.allocConsecutive(8,s,1024,1,{|b,i|b.sine1Msg(1/(1..((i+1)*6)))},0);{f=[50,75,99];VOsc3.ar(LFNoise1.kr(1/4,3,4),*f).lag(3e-3)!2}.play

/* by  juan alzate romero */
play{a=Decay2.ar(Impulse.ar(2),1e-4)*SinOsc.ar(40);Compander.ar(Blip.ar([40,40.5]*TChoose.kr(a>0.6,(1..8)),4),a,8e-3,1,0.001,0.1,1/3)+a}

/* by  juan alzate romero */
play{RandSeed.kr(1,5);e=ExpRand;Splay.ar(Decay2.ar(Impulse.ar({e.new(1,8).round/3}!9),5e-3,{e.new(0.1,1)}!9,LFCub.ar({e.new(66,666)}!9)))}

/* by  juan alzate romero */
play{e=ExpRand;Splay.ar(Decay2.ar(Impulse.ar({e.new(1,8).round/3}!9),5e-3,{e.new(0.1,1)}!9,LFCub.ar({e.new(66,666).round(20)}!9)))}

/* by  juan alzate romero */
play{o=LFCub.kr(1/[24,8,12,16]);PitchShift.ar(LFPulse.ar(o[0]*50+100,0,0.1).lag(1/1000),o[3]*0.299+0.3,o[2]*8+8,o[1],o[0]*0.1+0.1)!2}

/* by  juan alzate romero */
play{o=LFPulse.kr(1/[4,7,13,19]);PitchShift.ar(LFPar.ar(o@0*1e3+1e3,0,0.1).lag(1/1000),o@3*0.299+0.3,o@2*2+2,o@1,o[0]*0.1+0.1)!2}

/* by  juan alzate romero */
play{f=FreeVerb;x=Decay2.ar(Impulse.ar([3,4]),1/99,1/9,LFCub.ar({rrand(40,400)}!4,0,0.1)).sum;5.do{x=f.ar(x,LFTri.kr(1/16,0,1/4,0.3))};x!2}

/* by  juan alzate romero */
play{Splay.ar(LFCub.ar(LFTri.kr([1,1.1],0,LFPar.kr(1/7,0,10),{(100,150..500).choose}!5),0,LFSaw.kr(4/[1,3,4,6,8])**LFPar.kr(1/8,0,7,8)))}

/* by  juan alzate romero */
fork{loop{x=play{l=LFPar;Splay.ar(l.ar(l.kr(rrand(1,8)).wrap(l.kr(12/{rrand(1,9)}!9))*100+{(40,80..400).choose}!9))/9};16.wait;x.free}}//#sc

/* by  juan alzate romero */
play{l=LFCub;Splay.ar(l.ar(l.kr(9.1,0,100,(200,300..500)),0,(l.kr(9,0,1,l.kr(1/[2,3,5,7],0,0.5,0))>(l.kr(1/2,0,0.4,0.5))).lag/2))} // #sc

/* by  juan alzate romero */
play{l=LFTri;l.ar(l.kr(1/4,1/1.5,l.kr(1,0,10,10),{|i|50+i}!8+l.kr(1/3,0,3,40)),0,l.kr((1..8),0,0.2).excess(0.01)*({|i|16-i/20}!16)).sum!2}

/* by  juan alzate romero */
play{l=LFSaw;l.ar(l.kr(l.kr([1,3],0,4,[5,6]),l.kr(1/[4,8]),l.kr(1,0,99,100),l.kr(1/2,0,50,l.kr(1/4,1/3,50,100))))/2} // #sc LFSaw galore

/* by  juan alzate romero */
play{l=LocalIn.ar+Decay2.ar(Impulse.ar(3),3e-2,0.05,LFCub.ar(LFNoise2.kr(19,500,600)));l=DelayN.ar(l,1,1/2);LocalOut.ar(l/3);l!2}

/* by  juan alzate romero */
fork{loop{r=rrand(-9,9);9.do{play{Pan2.ar(SinOsc.ar(LinRand(40,900,r))*EnvGen.ar(Env.sine(9),1,0.1,0,1,2),rrand(-1,1.0))}};rrand(6,8).wait}}

/* by  juan alzate romero */
play{Splay.ar(Logistic.ar(LFCub.kr([1,2,4,8],0,1.9,2),LFNoise0.kr(1/[16,12,8,4],400,999).round(150)))}

/* by  juan alzate romero */
play{a={rrand(-1,1.0)}!1e3;e=InterplEnv(a,[1e-3],a*3);IEnvGen.ar(e,LFSaw.kr(LFCub.kr(8,0,300,300),0,e.times.sum)*LFNoise2.kr(99,1,10))!2}

/* by  juan alzate romero */
l=Line;fork{loop{play{Splay.ar(SinOsc.ar({x=rrand(1,7)*99;l.kr(x,x/(0.25,0.5..4).choose,9)}!9,0,1/9)*l.ar(1,0,9,0.5,0.5,2))};1.wait}}

/* by  matt barber */
{g=LFNoise2.ar(3,11,12);f=LFNoise0.ar(g,4,6).octcps;x=Resonz.ar(LFNoise0.ar(f),f/6,(g**2.3)/f).clip;AllpassC.ar([x,0-x],1,g/23,99)}.play

/* by  matt barber */
{g=LFNoise2.ar(3,11,12);f=LFNoise0.ar(g,4,6).octcps;x=Resonz.ar(LFNoise0.ar(f),f/6,(g**2.3)/f).clip;AllpassC.ar([x,0-x],1,g/230,99)}.play

/* by  matt barber */
{g=LFNoise2.ar(3,11,12);f=LFNoise0.ar(g,4,6).octcps;x=Resonz.ar(LFNoise0.ar(f),f/6,(g**2.3)/f).clip;AllpassC.ar([x,0-x],1,g/230,g)}.play

/* by  matt barber */
{g=LFNoise2.ar(3,11,12);f=LFNoise0.ar(g,4,6).octcps;x=Resonz.ar(LFNoise0.ar(f),f/6,(g**2.3)/f).clip;AllpassC.ar([x,0-x],1,g/230,g/9)}.play

/* by  alexandra cardenas */
play{l=LFDNoise3.kr(0.5);Splay.ar(MoogFF.ar(SinOsc.ar([150,200]*BrownNoise.ar(1)*LFPulse.ar([10,20])),l.range(10,5000),l.range(0,4)),1,1,0)}

/* by  alexandra cardenas */
{Splay.ar({Integrator.ar(LFPulse.ar(rrand(0.1,42.0),0.3,4e-4),0.999,VarSaw.ar(LFDNoise3.kr(2.1).range(100, 3600)),0)}!22,1,0.7,0)}.play

/* by  thor */
play{x=Decay;d=Dust.ar(4);FreeVerb.ar(LPF.ar(x.ar(d,0.5,WhiteNoise.ar),2000)+x.ar(d,0.15,SinOsc.ar([40,47],pi,5)), 0.4,0.6,TRand.ar(0,1,d))}

/* by  nathaniel virgo */
p={|x,a,f|9.do{x=BAllPass.ar(x*a,f).tanh};x};play{i=Dust.ar(2);p.(Dust.ar(EnvGen.ar(Env.perc,i,1e3,0,1).poll),1.4,50)/9+p.(i,1.8,40)!2}

/* by  aliaksandr tsurko */
{Mix.fill(100, {arg a = 1 + a; Pan2.ar(SinOsc.ar(70 * a, 0, Dust.kr(0.01 + (a * 0.009), 0.5)), {rrand(-0.2, 0.2)})})}.play

/* by  jonathan siemasko */
{CombC.ar(Klang.ar(`[[100,101,1000,1001]],1,0)*0.1,0.33,LFTri.ar(0.1, 0, 0.1, 0.11)+LFTri.ar(0.17, 0, 0.1, 0.22),10)!2}.play;

/* by  jonathan siemasko */
{CombC.ar(Klang.ar(`[[100,101,1000,1001]],1,0)*0.1,1.33,LFTri.ar(0.3, 0, 0.1, 0.71)+LFTri.ar(0.7, 0, 0.1, 0.52),10)!2}.play;

/* by  thor */
play{a=SinOsc.ar(0.15).clip(0,1);(Decay2.ar(LFSaw.ar(13)*a, 0.1)+DelayC.ar(RLPF.ar(PinkNoise.ar(0.3)*a,2300,0.1),3,3))!2}

/* by  thor */
play{x=SinOsc;y=LFNoise0;a=y.ar(8);(x.ar(Pulse.ar(1)*24)+x.ar(90+(a*90))+MoogFF.ar(Saw.ar(y.ar(4,333,666)),a*XLine.ar(1,39,99,99,0,2)))!2/3}

/* by  thor */
b=Buffer.read(s,"sounds/a11wlk01.wav");play{t=Dust.kr(99);r=TRand;o=Warp1.ar(1,b,r.kr(0,4e4,t),r.kr(0.5,1,t),1)*Linen.kr(t,1);GVerb.ar(o)}

/* by  mark hadman */
play{o=SinOsc;a=[2,3,5,7,11,13,17];Splay.ar(o.ar(o.ar(a,0,50,o.ar(0.119,0,5,32))*a,0,o.ar(0.027,-pi/2,9,9).dbamp/(1,2..7))).tanh}//#sc140

/* by  juan alzate romero */
play{a=Blip.ar(60,4,LFGauss.ar(4,1/8));a=a/4+LocalIn.ar(2);a=FreqShift.ar(a,LFNoise0.kr(1/4,90));LocalOut.ar(DelayC.ar(a,1,0.1,0.9));a}

/* by  juan alzate romero */
play{Splay.ar(SinOsc.ar(LastValue.kr(LFNoise0.kr(3!4,250,220),200).round(50)*LFPar.kr((1..4)/8,0,{0.02.rand}!4,1),0,1/2))}

/* by  juan alzate romero */
play{a=0;6.do{x=Sweep.ar(Dust2.kr(0.1+2.0.rand),9.rand+9)+LFNoise1.kr(0.1,60,80);a=a+Pan2.ar(Gendy1.ar(1,1,1,1,x,x+9),LFNoise2.kr(1))};a}

/* by  juan alzate romero */
play{GVerb.ar(Mix(9.collect{SetResetFF.ar(Dust.ar(8.rand+1),Dust.ar(8.rand+1)).lag*SinOsc.ar(LFNoise2.kr(0.1,25,exprand(40,1500)))/9}))}

/* by  juan alzate romero */
play{i=Impulse;a=Splay.ar((PulseCount.ar(i.ar((1..8)),i.ar(1/3))>4)*Blip.ar((40,44..62).midicps,2));a*0.1+GVerb.ar(HPF.ar(a,4e3),300,14)*4}

/* by  juan alzate romero */
play{f=LFPar.kr(0.22,0,100,150).round(50).lag;Gendy2.ar(6,6,0.5,0.01,f,f+[1,2],1/2,1/2,19,f/4)*SetResetFF.ar(Impulse.ar(4),Dust.ar(4)).lag}

/* by  juan alzate romero */
play{l=LFNoise2;FreeVerb2.ar(*XFade2.ar(SinOscFB.ar([80,81],l.kr(1)+1/2),SinOscFB.ar([121,160],l.kr(1)+1/2),l.kr(1)))}

/* by  juan alzate romero */
fork{loop{a=play{p=Pulse;p.ar(p.ar([p.kr(1)*3+4,4.01]*10,1/[3,4],[98,99],199),p.kr(1/4,1/2,1/2,1/2).lag)*p.kr([2,3],0.9)};4.wait;a.free;}}

/* by  juan alzate romero */
play{t=TDuty.kr(Dshuf([4,2,1]/8,inf));c=TChoose;Pan2.ar(SinOscFB.ar(c.kr(t,(50,75..300)),Decay2.kr(t)+0.8),c.kr(t,[-0.5,0,0.5]).lag)}

/* by  juan alzate romero */
play{r=LFNoise0.kr(1/4,6,6).round.midiratio;Splay.ar({ToggleFF.ar(Impulse.ar(8.rand+1)).lag(1/99)*SinOsc.ar((50,100..800).choose*r)}!40)}

/* by  juan alzate romero */
fork{loop{h=[100,800,3000].choose;play{Splay.ar({SinOsc.ar(exprand(60,h),0,0.1)}!40)*LFGauss.ar(19,1/4,0,0,2)};8.wait}};

/* by  juan alzate romero */
play{l=LFNoise2;RLPF.ar(Crackle.ar,SpecPcile.kr(FFT(LocalBuf(1024),LFGauss.ar(1/[6,8,20].choose,0.01)),0.5),l.kr(1/8,0.1,0.15),2).fold2!2}

/* by  juan alzate romero */
play{a=Decay2.ar(Impulse.ar(2),1e-4)*SinOsc.ar(40);Compander.ar(Blip.ar([40,40.5]*TChoose.kr(a>0.6,(1..8)),4),a,8e-3,1,0.001,0.1,1/3)+a}

/* by  juan alzate romero */
play{e=ExpRand;Splay.ar(Decay2.ar(Impulse.ar({e.new(1,8).round/3}!9),5e-3,{e.new(0.1,1)}!9,LFCub.ar({e.new(66,666).round(20)}!9)))}

/* by  juan alzate romero */
play{o=LFCub.kr(1/[24,8,12,16]);PitchShift.ar(LFPulse.ar(o[0]*50+100,0,0.1).lag(1/1000),o[3]*0.299+0.3,o[2]*8+8,o[1],o[0]*0.1+0.1)!2}

/* by  redfrik */
play{f=LFPar.ar(1/14).round*20+80;Splay.ar(LFPar.ar({|i|[i+1*f,i*f+(i+1/3)]}!4)>BrownNoise.ar(Pulse.ar({|i|i+1}!4,0.35))/3)}//#SuperCollider

/* by  redfrik */
play{x=CombN.ar(Phasor.ar(0,{|i|i+1/20}!22),0.042,0.042);y=Phasor.ar(LPF.ar(x,LFPar.ar(1/99,0,400,500)),x);Splay.ar(y)*0.25}//#SuperCollider

/* by  redfrik */
play{x=CombC.ar(Phasor.ar(0,{|i|i+1/4}!5),0.2,LFPar.ar(0.09,0,0.05,0.1).round(0.022));Splay.ar(Phasor.ar(BPF.ar(x,50),x)/4)}//#SuperCollider

/* by  redfrik */
play{a=LFCub;n=8;Splay.ar(a.ar({|i|pow(i+1,a.kr(1/n,i/n,1/n,1))}!n*150,0,a.kr({|i|pow(i+1,a.kr(i+0.5/n,i/n))}!n).max(0))/4)}//#SuperCollider

/* by  redfrik */
play{a=SinOsc;Splay.ar({|i|i=i+1;a.ar(a.ar(i)+1**a.ar(2**a.ar(i/500)*(9-i))*a.ar(9*i).exprange(90,2**a.ar(i/20)*800))}!5)/4}//#SuperCollider

/* by  redfrik */
play{o=SinOsc.ar(1/RunningMax.ar(Sweep.ar(LocalIn.ar(6)),Impulse.ar([1,0.749,6,12,3,4])));LocalOut.ar(o);Splay.ar(o).tanh/2}//#SuperCollider

/* by  redfrik */
play{c=[97,99];l=3**9;a=LocalBuf(l,2).clear;BufWr.ar(Saw.ar(c/5),a,BPF.ar(VarSaw.ar(c),98,0.1)*l);PlayBuf.ar(2,a,1/4,1,0,1)}//#SuperCollider

/* by  redfrik */
play{a=SinOsc;Limiter.ar(LeakDC.ar(a.ar(0.11,BRF.ar(a.ar(a.ar(0.12).exprange(1,1e4),2pi),1/a.ar(0.13).range(1,[99,100])))))}//#SuperCollider