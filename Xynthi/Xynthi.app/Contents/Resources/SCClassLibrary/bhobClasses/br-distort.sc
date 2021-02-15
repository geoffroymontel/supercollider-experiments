/* Distort {
	*ar {|sig=0, inGain=1, outGain=0.25, asym=0|
		^((sig * (1-asym)) + asym * inGain).tanh * outGain
	}
}

ModifiedTanh {
	*ar {|sig, drive=1, shape1=0, shape2=0, rect=0.5|
		var rms, i_drive, a1, a2, off1, off2, off3, offs, x1, x2, x3, out;
		rms=RunningSum.rms(sig);
		sig=rect * rms + sig;
		i_drive=drive * 0.125;
		a1=shape1 * 0.125;
		a2=shape2 * 0.125;
		off1=rect*rms*(drive + (shape1-0.5 * 0.125));
		off2=rect.neg*rms*(drive + (shape2-0.5 * 0.125));
		off3=rect*rms*drive;
		offs=exp(off1)-exp(off2)/(exp(off3) + exp(off3.neg));
		x1=i_drive + a1 * sig;
		x2=i_drive + a2 * sig.neg;
		x3=i_drive * sig;
		^out=exp(x1)-exp(x2)/(exp(x3) + exp(x3.neg)) - offs;
	}
} */

DisRectify {
	*ar {|sig, drive=1, rect=0.5|
		var rms, offs, dist, out;
		rms=RunningSum.rms(sig);
		sig=rect * rms + sig;
		offs=(rect*rms*drive).distort;
		dist=drive * sig;
		^out=dist.distort - offs;
	}
}

ModTan {
	*ar {|sig, drive=1, rect=0.5|
		var rms, offs, dist, out;
		rms=RunningSum.rms(sig);
		sig=rect * rms + sig;
		offs=(rect*rms*drive).tanh;
		dist=drive * sig;
		^out=dist.tanh - offs;
	}
}

Recti {
	*ar {|audio=0, ffreq=1200|
		^Mix.ar([LPF.ar(audio.min(0), ffreq), HPF.ar(audio.max(0), ffreq)])
	}
}

Shear {
	*ar {|audio=0, maxdelay=0.01, delay=0.01|
		^Mix.ar([audio.max(0), DelayL.ar(audio.min(0), maxdelay, delay)])
	}
}

CheapDist {
	*ar {|audio=0, a=1|
		var in, sq;
		in=audio.abs;
		sq=in.squared;
		^((sq + (a*in))/(sq + ((a-1)*in) + 1))
	}
}
