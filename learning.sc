(
  ~myPath = "d:/stromboli/puit/*.wav";
  ~wavFiles = ~myPath.pathMatch;

  b =  Buffer.read(s, ~wavFiles.choose);
  s.sync; // wait for server to finish what it's doing
  x = Synth(\playBuf, [\bufnum, b]);
)

Env.new([0,1,0.9,0], [0.1,0.5, 1],[\sqr,\sqr,\sqr]).plot;

Env.linen(1, 2, 3, 0.6).test.plot;

Env.linen(1, 2, 3, 0.6, 'sine').test.plot;

Env.linen(1, 2, 3, 0.6, 'welch').test.plot;
Env.sine(1, 1).test.plot;

Env.adsr(0.001, 0.2, 0.25, 1, 1, -4).test(2).plot;

Env.cutoff(1, 1, 'sine').test(2).plot;

thisProcess.platform.userConfigDir;

{RLPF.ar(Dust.ar([1, 4]), LFNoise1.ar(1/[100,100], 1500, 1600), 0.01)}.play();

{
  var sines=100, speed=6;
  Mix.fill(sines,
    {
      arg x;
      Pan2.ar(
        SinOsc.ar(exprand(100,500),mul: max(0,LFNoise0.kr(speed) + Line.kr(-1,1,30)))
        , 1.0.rand2())
    })/sines;
}.play();

exprand(1.0,100.0);

thisThread.randSeed = 666; {rand(10.0)} ! 10;

dup("echo",20)
"echo".dup(20);
[3.141, 5.9265].round(0.01);
[23,54,678,1,21].sort;
{exprand(1,10)}.dup(100).round(0.1).sort;

{LFNoise0.kr(1,100)}.scope();
50.midicps;
444.cpsmidi;
"hello".speak;

a={exprand(1,100)}
a.value();
a;
a();
a.();
a={|m| exprand(1,m)}
a;
a.value(3);

(
{
  Blip.ar(
    TRand.kr(100,1000,Impulse.kr(Line.kr(1,20,10))),
    TRand.kr(1,10,Impulse.kr(Line.kr(1,20,10))),
    Linen.kr(Impulse.kr(Line.kr(1,20,10)),0,0.5,1/Line.kr(1,20,10))
    )
}.scope
)

(
{
  r = MouseX.kr(1/3,10);
  SinOsc.ar(mul: Linen.kr(Impulse.kr(r),0,1,1/r));
}.play()
)


// 1.5
(
  p={
    r=Line.kr(1,20,60);
    r=LFTri.kr(1/10)*3+7;
    t=Impulse.kr(r);
    t=Dust.kr(r);
    e=Linen.kr(t,0,0.5,1/r);
    f=TRand.kr(1,10,t);
    f = e+1*4;
    Blip.ar(f*100,f,e)
  }.play
)

p.free

///////////// Figure 1.6 Phase modulation with modulator as ratio


(
  var l = Line.kr(1, 12);

  { // carrier and modulator not linked
    r = Impulse.kr(10);
    c = TRand.kr(100, 5000, r);
    m = TRand.kr(100, 5000, r);
    PMOsc.ar([c, c*1.01], m, l, mul: 0.3)
  }.play;

//  movingIndex.postln;
)

  {
    var rate = 4, carrier, modRatio; // declare variables
    carrier = LFNoise0.kr(rate) * 500 + 700;
    modRatio = MouseX.kr(1, 2.0);
    // modulator expressed as ratio, therefore timbre
    PMOsc.ar(carrier, carrier*modRatio, l)*0.3
  }.play

Env.perc(0.05, 1, 1, -4).test.plot;
Env.perc(0.001, 1, 1, -4).test.plot;    // sharper attack
Env.perc(0.001, 1, 1, -8).test.plot;    // change curvature
Env.perc(1, 0.01, 1, 4).test.plot;      // reverse envelope

(
  ~myPath = "d:/stromboli/puit/*.wav";
  ~wavFiles = ~myPath.pathMatch;

  ~houston =  Buffer.read(s, ~wavFiles.choose);

)

(  // speed and direction change
{
  var speed, direction;
  speed = MouseX.kr(-1,1);
  Out.ar(0,PlayBuf.ar(1, ~houston, speed, loop: 1));
}.play;
)
{ MouseX.kr(-1,1,1) }.plot(5,minval:-2,maxval:2);

x= { Out.ar(0, Pan2.ar( Pulse.ar(1)*SinOsc.ar(\freq.kr(200)), 1) ) }.play 
x= { Out.ar(0, Pan2.ar( Pulse.ar(1)*SinOsc.ar(\freq.kr(200,0.1)), 1) ) }.play 
x.trace

Pmeanrand(0.0, 1.0, inf).asStream.nextN(10000).histo(200, 0.0, 1.0).plot;

p = Pbind(
    \degree, Pseq(#[0, 0, 4, 4, 5, 5, 4], 1),
    \dur, Pseq(#[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1], 1)
).asStream;    // remember, you have to make a stream out of the pattern before using it

p.next(Event.new);    // shorter: p.next(())

( 'degree': 0, 'dur': 6 ).play;
( 'degree': 4, 'dur': 6 ).play;






