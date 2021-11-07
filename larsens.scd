{ SoundIn.ar(2);; }.play


(
{
	var snd;
	var index;

	index = MouseX.kr(0, 3000);
	snd = LocalIn.ar(1);
	snd = snd + SinOsc.ar(({ ExpRand(30, 1000) } ! 8) *  (SoundIn.ar(2).tanh * index));
	LocalOut.ar(snd);
	snd = snd.fold2 * -10.dbamp;
}.play;
)