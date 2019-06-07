SynthDef(\sin, {
	Out.ar(\out.ar(0), SinOsc.ar(freq: \freq.kr(440)));
}).add;

SynthDef(\saw, {
	Out.ar(\out.ar(0), Saw.ar(freq: \freq.kr(440)));
}).add;

~synthsGroup = Group.new;
~effectsGroup = Group.after(~synthsGroup);

10.do({ |i|


});