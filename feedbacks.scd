(
Ndef(\s1, {
    var trig = Impulse.kr(0.5);
    var freq = Demand.kr(trig, 0, Dseq( (220 * [0, -2, -5].midiratio ), inf));
    var sig = VarSaw.ar(freq * [1, 1.01], 0, SinOsc.kr(1/8).range(0.1, 0.9)) * Env.linen(2, 1).kr(gate:trig);
    var fb = DelayC.ar(LocalIn.ar(2), 1, 1) * 0.9 + sig;
    fb = PitchShift.ar(fb, 0.5, 7.midiratio, 0.01, 0.01);
    LocalOut.ar((fb + WaveLoss.ar(fb * 0.35)).tanh);
    sig = JPverb.ar(sig + fb, 10, 0, 5) * 0.4 + fb;
    Splay.ar(sig) * -6.dbamp;
}).play
)

(
x = {
    var sig, mode;
    sig = [SinOsc.ar, PinkNoise.ar].mean;
    mode = MouseY.kr(1,2).round;
    WaveLoss.ar(sig, MouseX.kr(0, 40), 40, mode: mode, mul: 0.1);
}.play;
)
x.free;

// Plotting shows quite clearly what's going on:
(
{
    var sig;
    sig = [SinOsc.ar, PinkNoise.ar].mean;
    [sig, WaveLoss.ar(sig, 20, 40, mode: 2)];
}.plot(0.15);
)

// A stereo example, evolves over a couple of minutes - specify a breakbeat loop sample below, sounds good
b = Buffer.read(s,"sounds/amenfast.wav"); // remember to free the buffer later.
(
x = {
    var sig, mode, woo;
    sig = PlayBuf.ar(1, b.bufnum, BufRateScale.kr(b.bufnum) * 0.75, startPos: 92898, loop: 1);
    woo = {
        WaveLoss.ar(sig,
            EnvGen.kr(Env.new([199, 199, 150, 150, 199, 250], [20, 40, 60, 60, 100]), doneAction:2)
            + (FSinOsc.kr(0.2 + XLine.kr(0.001, [1.3, 1.7], 90), 0, 50) * XLine.kr(0.00000001, 1, 60))
            ,
            200, mode: 2, mul: 0.4);
    }.dup;
    woo = (woo * 0.9) + (woo.reverse * 0.1);
}.play;
)
x.free;
b.free;