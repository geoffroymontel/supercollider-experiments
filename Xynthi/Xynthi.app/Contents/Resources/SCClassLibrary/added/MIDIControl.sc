//id can be uid or index!
//by Jan Trutzschler von Falkenstein

MIDIControl : UGen {
	*kr {
		arg minval=0, maxval=1, warp=0, lag=0.1, channel=0, control=0, id=0;
		if (warp === \linear or: (warp === \lin), { warp = 0 }, {
			if (warp === \exponential or: (warp === \exp), { warp = 1 });
		});		
		^this.multiNew('control', id, channel, control, minval, maxval, warp, lag);
	}
}


MIDINote : UGen {
	*kr {
		arg minval=0, maxval=1, warp=0, lag=0.1, channel=0, note=0, id=0;
		if (warp === \linear or: (warp === \lin), { warp = 0 }, {
			if (warp === \exponential or: (warp === \exp), { warp = 1 });
		});		
		^this.multiNew('control', id, channel, note, minval, maxval, warp, lag);
	}
}

MIDIRawNote : UGen {
	*kr {arg channel=0, note=0, id=0;
		^this.multiNew('control', id, channel, note);
	}
}
