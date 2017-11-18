{ SinOsc.ar(freq: MouseX.kr(minval:[1200,1282], maxval:[1200,1202]),mul: MouseY.kr(minval: 0, maxval: 1)) }.play;

(
{ FBSineC.ar(
	freq: MouseX.kr(minval:[1200,1282], maxval:[1200,1202]),mul: MouseY.kr(minval: 0, maxval: 1),
    LFNoise2.kr(1, 1e4, 1e4),
    LFNoise2.kr(1, 32, 33),
    LFNoise2.kr(1, 0.5),
    LFNoise2.kr(1, 0.05, 1.05),
    LFNoise2.kr(1, 0.3, 0.3)
) * 0.2 }.play(s);
)