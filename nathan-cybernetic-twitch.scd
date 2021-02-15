// https://gist.github.com/nhthn/8f0dcc1c85e662fe5bf7d0132155c0af

(
SynthDef(\cybernetic, {
	var snd;
	snd = LocalIn.ar(1);
	snd = SinOsc.ar(440 + snd);
	LocalOut.ar(snd);
	snd = Pan2.ar(snd, \pan.kr(0));
	snd = snd.clip2 * -10.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index;
	index = LFNoise2.kr(3).range(0, 3000);
	snd = LocalIn.ar(1);
	snd = SinOsc.ar(440 + (snd * index));
	LocalOut.ar(snd);
	snd = Pan2.ar(snd, \pan.kr(0));
	snd = snd.clip2 * -10.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index;
	index = LFNoise2.kr(3).range(0, 3000);
	snd = LocalIn.ar(8);
	snd = SinOsc.ar(({ ExpRand(100, 8000) } ! 8) + (snd * index));
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -10.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index;
	index = 3000;
	snd = LocalIn.ar(8);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 8e5));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 8) + (snd * index));
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index;
	index = 5000;
	snd = LocalIn.ar(3);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 1e5));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 3) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 1000));
	snd = LPF.ar(snd);
	snd = SinOsc.ar(440 + (snd * 500));
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)


// it seems that latch, pulsedivider, and really low LPFs are good for making LFO's out of audio signals and therefore make good cybernetic tools
(
SynthDef(\cybernetic, {
	var snd, index;
	index = 5000;
	snd = LocalIn.ar(3);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 1e5));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 3) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 1000));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10) * 3, [Pulse.ar(440 + (snd * 5000)), SinOsc.ar(100 + (snd * 1000))]);
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index;
	index = 5000;
	snd = LocalIn.ar(3);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 1e5));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 3) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 1000));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10) * 3, [Pulse.ar(440 + (snd * 5000)), SinOsc.ar(100 + (snd * 1000))]);
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)


(
SynthDef(\cybernetic, {
	var snd, index;
	index = 5000;
	snd = LocalIn.ar(4);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10) * 1e5));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 4) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10).cubed * 8000));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10) * 3, [Pulse.ar(440 + (snd * 5000)), SinOsc.ar(100 + (snd * 1000))]);
	LocalOut.ar(snd);
	snd = snd + SinOsc.ar(100 + (1000 * snd));
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index, divide, cutoff;
	index = MouseY.kr(0, 1000);
	divide = 1;
	cutoff = 1;
	snd = LocalIn.ar(4);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff) * 1e5 * divide));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 4) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff).cubed * 8000 * divide));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10 * cutoff) * 3, [Pulse.ar(440 + (snd * 5000)), SinOsc.ar(100 + (snd * 1000))]);
	LocalOut.ar(snd);
	snd = snd + SinOsc.ar(100 + (1000 * snd));
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index, divide, cutoff;
	index = MouseY.kr(1, 7000, 1);
	divide = 1;
	cutoff = 1;
	snd = LocalIn.ar(4);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff) * 1e5 * divide));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 4) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff).cubed * 8000 * divide));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10 * cutoff) * 3, [Pulse.ar(440 + (snd * index)), SinOsc.ar(100 + (snd * index))]);
	LocalOut.ar(snd);
	snd = snd + SinOsc.ar(100 + (1000 * snd));
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index, divide, cutoff;
	var freq;
	index = MouseY.kr(1, 7000, 1);
	freq = MouseX.kr(0.01, 40, 1);
	divide = 1;
	cutoff = 1;
	snd = LocalIn.ar(4);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff) * 1e5 * divide));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 4 * freq) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff).cubed * 8000 * divide));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10 * cutoff) * 3, [Pulse.ar(440 * freq + (snd * index)), SinOsc.ar(100 * freq + (snd * index))]);
	snd = Sanitize.ar(snd);
	LocalOut.ar(snd);
	snd = snd + SinOsc.ar(100 + (1000 * snd));
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index, divide, cutoff;
	var freq;
	index = MouseY.kr(1, 7000, 1);
	freq = MouseX.kr(0.01, 40, 1);
	divide = 1;
	cutoff = 1;
	snd = LocalIn.ar(4);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff) * 1e5 * divide));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 4 * freq) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff).cubed * 8000 * divide));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10 * cutoff) * 3, [Pulse.ar(440 * freq + (snd * index)), SinOsc.ar(100 * freq + (snd * index))]);
	snd = Sanitize.ar(snd);
	LocalOut.ar(snd);
	snd = snd + SinOsc.ar(100 + (1000 * snd));
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index, divide, cutoff;
	var freq;
	index = MouseY.kr(1, 7000, 1);
	freq = MouseX.kr(0.01, 40, 1);
	divide = 1;
	cutoff = 1;
	snd = LocalIn.ar(4);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff) * 1e5 * divide));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 4 * freq) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff).cubed * 8000 * divide));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10 * cutoff) * 3, [Pulse.ar(440 * freq + (snd * index)), SinOsc.ar(100 * freq + (snd * index))]);
	snd = Sanitize.ar(snd);
	4.do {
		snd = snd + SinOsc.ar(exprand(10, 800) * freq + LPF.ar(snd * index, 100));
	};
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic, {
	var snd, index, divide, cutoff;
	var freq;
	index = MouseY.kr(1, 7000, 1);
	freq = MouseX.kr(0.01, 40, 1);
	divide = 1;
	cutoff = 1;
	snd = LocalIn.ar(4);
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff) * 1e5 * divide));
	snd = SinOsc.ar(({ ExpRand(10, 100) } ! 4 * freq) + (snd * index));
	snd = Latch.ar(snd, PulseDivider.ar(snd.reverse, LPF.ar(snd, 10 * cutoff).cubed * 8000 * divide));
	snd = LPF.ar(snd);
	snd = Select.ar(LPF.ar(snd.reverse, 10 * cutoff) * 3, [Pulse.ar(440 * freq + (snd * index)), SinOsc.ar(100 * freq + (snd * index))]);
	snd = RLPF.ar(snd, 440 + (1000 * LPF.ar(LPF.ar(snd, 1), 1).clip), 0.1);
	snd = Sanitize.ar(snd);
	4.do {
		snd = snd + SinOsc.ar(exprand(10, 800) * freq + LPF.ar(snd * index, 100));
	};
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd;
	snd = LocalIn.ar(1);
	snd = RLPF.ar(Saw.ar(440), 1000 + (100 * snd));
	LocalOut.ar(snd);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd;
	snd = LocalIn.ar(1);
	snd = RLPF.ar(Saw.ar(1000 * snd), 1000 + (900 * snd));
	snd = LeakDC.ar(snd);
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq;
	snd = LocalIn.ar(1);
	freq = 1000 + (snd * 1000);
	snd = RLPF.ar(Saw.ar(freq * snd), 1000 + (900 * snd), snd.abs + 0.01);
	snd = LeakDC.ar(Sanitize.ar(snd));
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq;
	snd = LocalIn.ar(4);
	freq = 4000 + (snd * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(freq * snd), 1000 + (900 * snd), snd.abs + 0.01);
	snd = LeakDC.ar(Sanitize.ar(snd));
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = snd[0] ! 2;
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq;
	snd = LocalIn.ar(4);
	freq = 3000 + (LPF.ar(snd, 0.1) * 100 * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(freq * snd), 1000 + (900 * snd), snd.abs + 0.01);
	snd = LeakDC.ar(Sanitize.ar(snd));
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = snd[0] ! 2;
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq;
	snd = LocalIn.ar(4);
	freq = 3000 + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(freq.abs * snd), 1000 + (900 * snd), snd.abs + 0.01);
	snd = LeakDC.ar(Sanitize.ar(snd));
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = snd[0] ! 2;
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq;
	snd = LocalIn.ar(4);
	freq = 3000 + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 + (900 * snd), snd.abs + 0.01);
	snd = RLPF.ar(snd, 500 + (900 * LPF.ar(snd, 0.1).clip2), 0.03).tanh;
	snd = LeakDC.ar(Sanitize.ar(snd));
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = snd[0] ! 2;
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq;
	snd = LocalIn.ar(4);
	freq = 3000 + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 + (900 * snd), snd.abs + 0.01);
	snd = SelectX.ar(BPF.ar(snd, 1, 0.1) > 0.9, [
		snd,
		RLPF.ar(snd, 1000 + (100 * LPF.ar(snd, 0.1).clip2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd));
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq, freqScale;
	freqScale = MouseY.kr(0.1, 3, 1);
	snd = LocalIn.ar(4);
	freq = 3000 * freqScale + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 * freqScale + (900 * snd), snd.abs + 0.01);
	snd = SelectX.ar(BPF.ar(snd, 1, 0.1) > 0.9, [
		snd,
		RLPF.ar(snd, 1000 * freqScale + (100 * LPF.ar(snd, 0.1).clip2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd));
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq, freqScale;
	freqScale = MouseY.kr(0.5, 3, 1);
	snd = LocalIn.ar(4);
	freq = 3000 * freqScale + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 * freqScale + (900 * snd), snd.abs + 0.01);
	snd = SelectX.ar(BPF.ar(snd, 0.1, 0.1) > 0, [
		snd,
		RLPF.ar(snd, 1000 * freqScale + (100 * LPF.ar(snd, 0.1).clip2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd).clip2);
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq, freqScale;
	freqScale = MouseY.kr(0.5, 3, 1);
	snd = LocalIn.ar(4);
	freq = 3000 * freqScale + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 * freqScale + (900 * snd), snd.abs + 0.01);
	snd = SelectX.ar(BPF.ar(snd, 0.1, 0.1) > 0, [
		snd,
		RLPF.ar(snd, 1000 * freqScale + (100 * LPF.ar(snd, 0.1).clip2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd).clip2);
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq, freqScale;
	freqScale = MouseY.kr(0.5, 3, 1);
	snd = LocalIn.ar(4);
	freq = 3000 * freqScale + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 * freqScale + (900 * snd), snd.abs + 0.01);
	snd = SelectX.ar(BPF.ar(snd, 0.1, 0.1) > 0, [
		snd,
		RLPF.ar(snd, 1000 * freqScale + (100 * LPF.ar(snd, 0.1).clip2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd).clip2);
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq, freqScale, index;
	freqScale = MouseY.kr(0.01, 3, 1);
	snd = LocalIn.ar(4);
	freq = 3000 * freqScale + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 * freqScale + (900 * snd), snd.abs + 0.01);
	snd = SelectX.ar(BPF.ar(snd, 0.1, 0.1) > 0, [
		snd,
		RLPF.ar(snd, 1000 * freqScale + (100 * LPF.ar(snd, 0.1).fold2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd).clip2);
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq, freqScale, index;
	freqScale = MouseY.kr(0.01, 3, 1);
	snd = LocalIn.ar(4);
	freq = 3000 * freqScale + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 * freqScale + (900 * snd), snd.abs + 0.01);
	snd = SelectX.ar(BPF.ar(snd, 0.1, 0.1) > 0, [
		snd,
		RLPF.ar(snd, 1000 * freqScale + (100 * LPF.ar(snd, 0.1).fold2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd).clip2);
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)

(
SynthDef(\cybernetic2, {
	var snd, freq, freqScale, index;
	freqScale = MouseY.kr(0.01, 3, 1);
	snd = LocalIn.ar(4);
	freq = 3000 * freqScale + ((LPF.ar(snd, 0.1) * 100) * [1000, 1500, 1200, 1100]);
	snd = RLPF.ar(Saw.ar(LPF.ar(freq.abs, 1) * snd), 1000 * freqScale + (900 * snd), snd.abs + 0.01);
	snd = Select.ar(PulseDivider.ar(BPF.ar(snd, 0.1, 0.1), div: 1000), [
		snd,
		RLPF.ar(snd, 1000 * freqScale + (100 * LPF.ar(snd, 0.1).fold2), 0.5).tanh
	]);
	snd = LeakDC.ar(Sanitize.ar(snd).clip2);
	snd = [snd[1], snd[2], snd[3], snd[0]];
	LocalOut.ar(snd.clip2);
	snd = Splay.ar(snd[[0, 1]], 0.5);
	snd = snd.clip2 * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).play;
)