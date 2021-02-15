p = ProxySpace.new;

p.push;

~out = { SinOsc.ar([200, 210]) * -18.dbamp };
~out.play;

b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
g = GMultiLooper.new(1, [b]);
h = GMultiLooper.new(1, [c]);

~mouseX = { MouseX.kr(0.1,10) };
~mouseY = { MouseY.kr(0.1,10) };
~multilooper = { InFeedback.ar(b, 2) };
~multilooper2 = { InFeedback.ar(c, 2) };

~test = { DFM1.ar(~multilooper, ~mouseX *100, ~mouseY / 10) };
~out = { Resonz.ar(~multilooper, [SinOsc.kr(0.1).range(~mouseX*200, ~mouseY*600), LFSaw.kr(0.2).range(~mouseY*300, ~mouseY*800)], 0.1) };
~out.play;

~latch = { ~multilooper.tanh + ~multilooper2.tanh * SinOsc.ar([1000,2000],[0, pi / 2])  };
~latch.play;
~test.play;
~test.stop;
~multilooper.play;
~multilooper2.play;
~multilooper.stop(4);
~multilooper2.stop(4);
p.fadeTime = 4;
~out.stop(4);

p.pop;

{ Lag.ar(Impulse.ar(10)) }.plot(1)