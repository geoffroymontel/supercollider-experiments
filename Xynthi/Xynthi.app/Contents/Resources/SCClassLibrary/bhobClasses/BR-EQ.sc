LoShelf {
	*ar {|in, freq, amp|
		var wc, a0, allpass;
		wc=pi * freq * SampleDur.ir;
		a0=(1 - wc)/(1 + wc);
		allpass=FOS.ar(in, a0.neg, 1, a0, -1);
		^(0.5 * (in + allpass + (amp * (in-allpass))))
	}
}

HiShelf {
	*ar {|in, freq, amp|
		var wc, a0, allpass;
		wc=pi * freq * SampleDur.ir;
		a0=(1 - wc)/(1 + wc);
		allpass=FOS.ar(in, a0.neg, 1, a0, 1);
		^(0.5 * (in + allpass + (amp * (in-allpass))))
	}
}

Tone {
	*ar {|in, tone|
		in=HiShelf.ar(in, 8000, tone * 2);
		in=LoShelf.ar(in, 100, tone.reciprocal * 2);
		^in;
		// ^Mix.ar([HiShelf.ar(in, 10000, tone), LoShelf.ar(in, 100, tone.reciprocal)])
	}
}