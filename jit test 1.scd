p = ProxySpace.new;
p.push;

(
~z = {
    Splay.ar(
        SinOsc.ar(Rand(300,400) + ({exprand(1, 1.3)} ! rrand(1, 9)))
        * SinOsc.ar({exprand(30, 900)} ! rrand(1, 9))
		* LFSaw.kr({exprand(1.0, 8.0)} ! rrand(1, 9)).max(0)
        * 0.1
    )
};
)

~z.play;
~z.rebuild;
~z.fadeTime = 3;
~z.send;    // send just creates a new synth - new freq, all else remains the same
~z.rebuild;    // rebuild the synthdef, re-decide numbers of oscs
~z.end;

p.pop;
