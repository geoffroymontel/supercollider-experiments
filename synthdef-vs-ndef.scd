// Normal style

(
SynthDef('synth1', { |out,freq,width|
    Out.ar(out,Pulse.ar(freq: freq, width: width));
}).add;
)

(
SynthDef('lfo1', { |out,freq|
    Out.kr(out,SinOsc.kr(freq: freq));
}).add;

)

~s=Synth('synth1', [out: 0, freq: 440, width: 0.5]);
~s.set(\freq, 220);
~s.free();

~bus1=Bus.control(s, 1);
~lfo1=Synth('lfo1', [out: ~bus1, freq: 5]);
~s.set(\freq, 220);
~s.map(\width, ~bus1);

// JIT style

(
Ndef(\synth2, { |freq,width|
    Pulse.ar(freq: freq, width: width);
});
)

Ndef(\synth2).play;
Ndef(\synth2).set(\freq, 110, \width, 0.0);
Ndef(\synth2).set(\freq, 220);
(
Ndef(\lfo2, { |freq|
    SinOsc.kr(freq: freq, add: 0.1);
});
)


Ndef(\lfo2).set(\freq, 1);
Ndef(\synth2).map(\width, Ndef(\lfo1));
