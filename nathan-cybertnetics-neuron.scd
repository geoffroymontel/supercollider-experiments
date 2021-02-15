// Nathan take on neurons
(
{
	var snd, neuron, out;
	neuron = LocalIn.kr(1);
	snd = [
		MoogFF.ar(Saw.ar(100 * (1 + (8 * neuron))), 100 * (1 + (160 * neuron)), 3 * neuron),
		MoogFF.ar(Saw.ar(10 * (1 + (160 * (1 - neuron)))), 100 * (1 + (16 * neuron)), 3 * neuron),
		MoogFF.ar(Saw.ar(300 * (1 + (20 * neuron))), 100 * (1 + (16 * neuron)), 3 * neuron),
	];
	snd = snd * 10.dbamp;
	out = snd[0];
	snd = snd.collect { |x| Pitch.kr(x)[0].explin(60, 6000, 0, 1).lag(0.1) };
	snd = snd * [0.5 * (1 - neuron), -0.7 * neuron, 0.9 * (1 - neuron)];
	snd = (((snd.sum + MouseY.kr(-1, 1)) * 8).tanh + 1) * 0.5;
	LocalOut.kr(snd);
	snd = out;
	snd = LeakDC.ar(snd);
	snd = Limiter.ar(snd);
	snd = snd ! 2;
	// optional
	snd = snd + NHHall.ar(snd * -10.dbamp, 4, modDepth: 1);
	snd = snd * -20.dbamp;
}.play
)
