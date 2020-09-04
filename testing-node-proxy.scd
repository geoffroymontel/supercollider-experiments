(
~saw = NodeProxy.new;
~saw.source = { Saw.ar(\freq.ar(440)) };
~sin = NodeProxy.new;
~sin.source = { SinOsc.ar(\freq.ar(440)) };
~convertAudioToFreq = NodeProxy.new;
~convertAudioToFreq.source = { \in.ar([0]).linlin(-1,1,20, 12000) };
~square = NodeProxy.new;
~square.source = { Pulse.ar(\freq.ar(440)) };
~out = NodeProxy.new;
~out.source = { \in.ar([0]) };
)

~out.play;
~saw <>> ~out;
~sin <>> ~convertAudioToFreq <>>.freq(~saw);
~sin.set(\freq, 1);
~out.stop;
