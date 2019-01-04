// Normal style

(
SynthDef('synth1', { |out = 0, freq = 440, width = 0.5|
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
Ndef(\synth2).set(\freq, 110, \width, 0.5);
Ndef(\synth2).set(\freq, 220);
(
Ndef(\lfo2, { |freq|
    SinOsc.kr(freq: freq, add: 0.1);
});
)


Ndef(\lfo2).set(\freq, 1);
Ndef(\synth2).map(\width, Ndef(\lfo1));

// avec NodeProxy

a = NodeProxy(s);
a.source = { |freq,width|
    Pulse.ar(freq: freq, width: width);
};
a.play;
a.set(\freq, 110, \width, 0.5);

a[0] = { |freq,width|
    Pulse.ar(freq: freq, width: width);
};
a[1] = { |freq,width|
    SinOsc.ar(freq: freq*2);
};


a[0] = { PinkNoise.ar(0.1.dup) };
a.play;
a[1] = \filter -> { |in| RLPF.ar(in, LFNoise2.kr(1).exprange(300, 1000), 0.1) };
a.set(\wet1, 0.2);
a.clear(3);

a = NodeProxy(s);
a[0] = { |freq = 440, dt=0.1, rate=2| Ringz.ar(Impulse.ar(rate * [1, 1.2]), freq, dt)*0.1 };
a.play;
(
a[1] = \set -> Pbind(
    \dur, Prand([1, 0.5], inf),
    \freq, Pwhite(200.0, 1000, inf),
    \rate, Pstutter(4, Prand([1, 3, 6, 10], inf)),
    \dt, Pwhite(0.01, 0.1, inf)
)
);
a[2] = \filter -> { |in| RLPF.ar(in, LFNoise2.kr(1).exprange(300, 1000), 0.1) };
a.fadeTime = 10;
a[0] = { |freq = 440, dt=0.1, rate=2| BHiPass.ar(Impulse.ar(rate * [1, 1.2]), freq, dt)*0.1 };
a[0] = { |freq = 440, dt=0.1, rate=2| SinOsc.ar(freq * [1, 1.2]) *0.1 };

// proxy space
p = ProxySpace.new(s);    // create a new environment, store it in variable p for now.
p.push;            // push it, so i becomes the current environment.

(
~x = {
    RLPF.ar(Impulse.ar(4) * 20, [850, 950], 0.2)
}
)

~x.play

(
~x = {
    RLPF.ar(Impulse.ar([5, 7]) * 5, [1450, 1234], 0.2)
}
)

p.fadeTime = 10;

currentEnvironment
p.pop

// connecting node proxies

a = NodeProxy.new(s);
a[0] = Pbind(*[
	instrument: \synth1,
	degree: Prand([0, 2, 6, 9], inf)
]);
a.play;

b = NodeProxy.new(s);
b.source = { NHHall.ar(\in.ar(1) ! 2) };
b.play;

a <>>.in b;