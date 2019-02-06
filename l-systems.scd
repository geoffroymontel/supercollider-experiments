// if you have never done so, run the following code first
(
Quarks.install("https://github.com/shimpe/panola");
Quarks.install("https://github.com/shimpe/sc-lsystem");
)

// musical example
(
s.waitForBoot({
    var player;
    var lsys = LSystem(
        iterations:1,
        axiom:"FX",
        constants:Set[],
        rules:(\X : "X+YF+",
            \Y : "-FX-Y"));
    var interp = LSystemInterpreter(
        lsystem:lsys,
        globalstate:(
            \acceptablenotes : Set["c3", "d3", "e3", "g3", "a3", "c4", "d4", "e4", "g4", "a4"],
            \patternnotes : ["c3"],
            \transpose : 0,
            \tempo : 16,
        ),
        actions:(
            // whenever you encounter an F, extend the list of played notes
            'F' : [{ | glob, loc |
                // extend list notes being played (using some randomness :) )
                glob[\patternnotes] = glob[\patternnotes].add(glob[\acceptablenotes].choose.debug("add new note"));

                // always return state at the end
                [glob, loc];
            }, nil],
            // whenever you encounter a +, transpose up
            '+': [{ | glob, loc |
                glob[\transpose] = (glob[\transpose] + [1,2,3,4].choose.debug("transpose up")).clip(-12,12);
                // always return state at the end
                [glob, loc];
            }, nil],
            // whenever you encounter a -, transpose down
            '-': [{ | glob, loc |
                "transpose down".postln;
                glob[\transpose] = (glob[\transpose] - [1,2,3,4].choose.debug("transpose down")).clip(-12, 12);
                // always return state at the end
                [glob, loc];
            }, nil],
            // whenever you encounter an X, remove first note from the played notes
            'X' : [{ | glob, loc |
                "remove first note".postln;
                if (glob[\patternnotes].size > 1) {
                    // keep at least one note
                    glob[\patternnotes] = glob[\patternnotes].reverse;
                    glob[\patternnotes].pop;
                    glob[\patternnotes] = glob[\patternnotes].reverse;
                };
                // always return state at the end
                [glob, loc];
            }, nil],
            // whenever you encounter a Y, change tempo (randomly) )
            'Y' : [{ | glob, loc |
                glob[\tempo] = (glob[\tempo] * [0.3, 1.2, 1.4, 1.7, 2, 0.5, 3].choose.debug("tempo factor")).clip(8,32);
                // always return state at the end
                [glob, loc];
            }, nil],
        )
    );

    var interp2 = interp.deepCopy();

    SynthDef(\kalimba, {
        |out = 0, freq = 440, amp = 0.1, mix = 0.1|
        var snd, click;
        // Basic tone is a SinOsc
        snd = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.03, Rand(3.0, 4.0), 1, -7), doneAction: 2);
        snd = HPF.ar( LPF.ar(snd, 380), 120);
        // The "clicking" sounds are modeled with a bank of resonators excited by enveloped white noise
        click = DynKlank.ar(`[
            // the resonant frequencies are randomized a little to add variation
            // there are two high resonant freqs and one quiet "bass" freq to give it some depth
            [240*ExpRand(0.97, 1.02), 2020*ExpRand(0.97, 1.02), 3151*ExpRand(0.97, 1.02)],
            [-9, 0, -5].dbamp,
            [0.8, 0.07, 0.08]
        ], BPF.ar(PinkNoise.ar, 6500, 0.1) * EnvGen.ar(Env.perc(0.001, 0.01))) * 0.1;
        snd = (snd*mix) + (click*(1-mix));
        snd = Mix( snd );
        Out.ar(out, Pan2.ar(snd, 0, amp));
    }).add;

    SynthDef(\flute, {
		| out = 0, freq = 440, amp = 1.0, a = 0.1, r = 0.1|
		//var fmod = 1; // clean
		//var fmod = LFCub.kr(freq:1/12).range(1, LFNoise2.kr(freq:12.0).range(1,1.1)); // tone deaf flute
		var fmod = LFCub.kr(freq:1/12).range(1, LFNoise2.kr(freq:12.0).range(1,1.02)); // flute-like sound
		var env = EnvGen.ar(Env.perc(a, r), levelScale:0.5, doneAction:2);
		var snd = SinOsc.ar(freq * fmod)!2;
		Out.ar(bus:out, channelsArray:(env*(amp*snd).tanh));
	}).add;

    s.sync;

    fork {
        var skipfirstidx = 0; // increase to skip more steps at the beginning
        var sz = lsys.getCalculatedString.size();
        lsys.getCalculatedString.do({
            | chr, idx |
            var pattern;
            var transposedpattern;
            var transposition;
            var transposition2;
            ("*** PART" + (idx+1) + "OF" + sz + "***").postln;
            interp.step(idx);
            interp2.step(idx);
            // start playing from step skipfirstidx
            if (idx > skipfirstidx) {
                var repeats = inf;
                if (idx == (sz-1)) { repeats = 3; }; // don't repeat last pattern indefinitely
                transposition = interp.globalState()[\transpose].debug("transpose");
                transposition2 = interp2.globalState()[\transpose].debug("transpose2");
                pattern = Pn(
                    Ppar([
                        Padd(\midinote, Pfunc({transposition}),
                            Panola.new(
                                notation:interp.globalState()[\patternnotes].join(" ").debug("notes1"),
                                dur_default:interp.globalState()[\tempo]
                            ).asPbind(\kalimba)
                        ),
                        Padd(\midinote, Pfunc({transposition2}),
                            Panola.new(
                                notation:interp2.globalState()[\patternnotes].join(" ").debug("notes2"),
                                dur_default:interp2.globalState()[\tempo]*2,
                                playdur_default:1,
                                vol_default:0.1
                            ).asPbind(\flute),
                        )
                    ]),
                    repeats);
                if (player.notNil) { player.stop; };
                player = pattern.play();
                1.wait;
                if (idx == (sz-1)) {
                    "*** ABOUT TO FINISH ***".postln;
                };
            }
        });
    }
});
)

// The same LSystem can also be interpreted graphically
(
var win = Window("Example Graphical LSystem", bounds:Rect(0,0,1000,700));
var view = UserView(win, win.view.bounds.insetBy(50,50));
var lsys = LSystem(
    iterations:12,
    axiom:"FX",
    constants:Set[],
    rules:(\X : "X+YF+",
        \Y : "-FX-Y"));
var interp = LSystemInterpreter(
    lsystem:lsys,
    actions:(
        'F' : [{
            | globalstate, symbolstate |
            globalstate[\pos] = globalstate[\pos] + (globalstate[\dir]*globalstate[\len]);
            Pen.lineTo(globalstate[\pos]);
            [globalstate, symbolstate];
        }, nil],
        'X' : [{
            | globalstate, symbolstate |
            globalstate[\pos] = globalstate[\pos] + (globalstate[\dir]*globalstate[\len]);
            Pen.lineTo(globalstate[\pos]);
            [globalstate, symbolstate];
        }, nil],
        'Y' : [{
            | globalstate, symbolstate |
            globalstate[\pos] = globalstate[\pos] + (globalstate[\dir]*globalstate[\len]);
            Pen.lineTo(globalstate[\pos]);
            [globalstate, symbolstate];
        }, nil],
        '-' : [{| globalstate, symbolstate |
            globalstate[\dir] = (globalstate[\dir].rotate(globalstate[\angle].degrad));
            [globalstate, symbolstate];
        }, nil],
        '+' : [{| globalstate, symbolstate |
            globalstate[\dir] = (globalstate[\dir].rotate(globalstate[\angle].neg.degrad));
            [globalstate, symbolstate];
        }, nil]
    )
);

view.resize = 5;
view.background_(Color.white);
view.drawFunc_({
    |userview|
    Pen.use {
        interp.setGlobalState( globalstate:(
            \dir : 0@1.neg,
            \pos : (win.view.bounds.width/2)@(win.view.bounds.height/5),
            \len : 3,
            \angle: 90 ) );
        Pen.width = 2;
        Pen.strokeColor_(Color.black);
        Pen.fillColor_(Color.black);
        Pen.moveTo(interp.globalstate[\pos]);
        interp.run();
        Pen.stroke;
    };
});
win.front;
)