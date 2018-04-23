// Load files from hackathon folder and create buffers

(
// retrieve all files from a folder where file extension matches a regular expression
~filesInFolder = { |folder, match|
        var p;
        PathName(folder).filesDo { |x|
                match.matchRegexp(x.extension)
                        .if { p = p.add(x) }
        };
        p
};

// convert a binary file in a sound buffer
~bufferFromFile = { |fileName|
	var sign;
	f = File(fileName.fullPath,"rb");
	t = [];
	a = f.getFloatLE;
	sign = -1.0;

	while {a.notNil} { t = t.add((a * sign)) ; a = f.getFloatLE();sign = sign * -1 };
	b = Buffer.loadCollection(s, t, 1, {f.close});
	b.normalize;
	b
};

// convert all JS files from hackathon folder to sound buffers
~arrayOfBuffers = ~filesInFolder.("/Users/geoffroy/dev/hackathon", "js").collect { |f| ~bufferFromFile.(f) };
)

// Hackathon synth

(
SynthDef(\hackSynth, { |out = 0, buf = nil, pan = 0, amp = 0.1|
	Out.ar(out, Pan2.ar(PlayBuf.ar(1, buf, rate: 0.1, trigger: 1, doneAction: 2), pos: pan, level: amp));
}).add;
)

Synth(\hackSynth, [out: 0, buf: ~arrayOfBuffers[11], pan: 0, amp: 1.0]);

~arrayOfBuffers.do {|b| b.plot;}

Signal.sineFill(512, [1]).plot;


