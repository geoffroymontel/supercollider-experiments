s.boot;
s.meter;

// pitch shift input - USE HEADPHONES to prevent feedback.
(play({
    PitchShift.ar(
        AudioIn.ar([1,2]), // stereo audio input
        0.1,               // grain size
        MouseX.kr(0.5,2),  // mouse x controls pitch shift ratio
		0,                 // pitch dispersion
		0.004              // time dispersion
    )
}))

// harmonizer
(
var table;
var gap = 40;
var mapped, mapped2, diffbuf, diffbuf2;
var miditoname;
var nametomidi;
var sound;
var difference, difference2;
var tf, tf2;
var row1, row2, row3, row4;

// define a function to convert a midi note number to a midi note name
miditoname = ({ arg note = 60, style = \American ;
		var offset = 0 ;
		var midi, notes;
		case { style == \French } { offset = -1}
			{ style == \German } { offset = -3} ;
		midi = (note + 0.5).asInteger;
		notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

		(notes[midi%12] ++ (midi.div(12)-1+offset))
});

// define a function to convert a midi note name to a midi note number
nametomidi = ({ arg name = "C4", style = \American ;
		var offset = 0 ; // French usage: +1 ; German usage: +3
		var twelves, ones, octaveIndex, midis;

		case { style == \French } { offset = 1}
			{ style == \German } { offset = 3} ;

		midis = Dictionary[($c->0),($d->2),($e->4),($f->5),($g->7),($a->9),($b->11)];
		ones = midis.at(name[0].toLower);

		if( (name[1].isDecDigit), {
			octaveIndex = 1;
		},{
			octaveIndex = 2;
			if( (name[1] == $#) || (name[1].toLower == $s) || (name[1] == $+), {
				ones = ones + 1;
			},{
				if( (name[1] == $b) || (name[1].toLower == $f) || (name[1] == $-), {
					ones = ones - 1;
				});
			});
		});
		twelves = (name.copyRange(octaveIndex, name.size).asInteger) * 12;

		(twelves + 12 + ones + (offset*12))
});

// define a table of reference notes [c c# d ... b]
table = Array.fill(12, {arg i; i + 60}); // [60,61,...,71]
// define a table of mapped notes (Default values)
mapped = ["e4", "a3", "c4", "c4", "c4", "d4", "d4", "e4", "e4", "e4", "f4", "g4"].collect(nametomidi.value(_));
mapped2= ["g3", "g3", "g3", "a3", "a4", "a4", "a4", "b4", "b4", "c4", "d4", "d4"].collect(nametomidi.value(_));

// define a table to store the difference between reference and mapped note
difference = Array.fill(table.size, {0});
// define a buffer on the server for consultation from the SynthDef
diffbuf= Buffer.loadCollection(s,table,action:{|msg| msg.postln;});
difference2= Array.fill(table.size, {0});
diffbuf2=Buffer.loadCollection(s,table,action:{|msg| msg.postln;});
tf = List.new(table.size);
tf2 = List.new(table.size);

// define a window called "Setup mapping", using empty rect to trigger autosize
w = Window.new("Setup mapping",bounds:Rect());
row1 = HLayout.new;
row2 = HLayout.new;
row3 = HLayout.new;
row4 = HLayout.new;
// add the reference notes as labels (fixed), and the mapped notes as text fields (editable)
// whenever a text field is updated, update the list of mapped notes (mapped)
table.do({arg item, i;
	var t, u;
	c = Button().states_([[miditoname.value(item),Color.black,Color.gray]]);
	c.action_({arg butt;
		if (butt.value == 0,
			{
				var env = Env.perc;
	            VarSaw.ar(item.midicps)*EnvGen.kr(env, doneAction:2)!2;
			}.play,
			{})
	});
	row1.add(c);

	t = TextField().string_(miditoname.value(mapped[i]));
	t.action = { mapped[i] = nametomidi.value(t.value); ("upper map note number " ++ i ++ " from " ++ table[i] ++ " to " ++  mapped[i]).postln;  diffbuf.set(i, (table[i] - mapped[i]).midiratio.reciprocal)};
	tf.add(t);
	row2.add(t);

	u = TextField().string_(miditoname.value(mapped2[i]));
	u.action = { mapped2[i] = nametomidi.value(u.value); ("lower map note number " ++ i ++ " from " ++ table[i] ++ " to " ++ mapped2[i]).postln; diffbuf2.set(i, (table[i]-mapped2[i]).midiratio.reciprocal)};
	tf2.add(u);
  row3.add(u);
});

// also add a start/stop button
// when the button is set to start, instantiate a new Synth, otherwise free the Synth
b= Button().states_([
	["Start",Color.black, Color.red],
	["Stop",Color.black, Color.green]]);
b.action_({arg butt;
	if (butt.value == 1,
		{
			tf.do({arg item; item.action});
			tf2.do({arg item; item.action});
			table.do({arg item, i;
				difference2[i] = (table[i] - mapped2[i]).midiratio.reciprocal;
				difference[i] = (table[i] - mapped[i]).midiratio.reciprocal;
			});
			diffbuf.setn(0,difference);
			diffbuf2.setn(0,difference2);
			sound = Synth.new("pitchFollow1");
		},
		{   sound.free;}
	);
});
row4.add(b);

w.layout = VLayout(row1, row2, row3, row4);

// define the Synth itself:
// - first it determines the pitch of what it hears in the microphone
// - then it harmonizes the pitch with the notes as defined in the ui
SynthDef.new("pitchFollow1", {
  var in, amp, freq, hasFreq, out;
	var t, midinum;
	var harmony, harmony2, partials;
  in = Mix.new(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, 0.05, 1);
  # freq, hasFreq = Tartini.kr(in);
	midinum = freq.cpsmidi.round(1);
	//midinum.postln;
  //freq = Lag.kr(midinum.midicps, 0.01);
	//freq = midinum.midicps;
	harmony2= WrapIndex.kr(diffbuf2.bufnum, midinum);
	harmony = WrapIndex.kr(diffbuf.bufnum, midinum);
	partials = [
		   0.5,
		   1,
		   2,
		 0.5*harmony,
		   1*harmony,
		   2*harmony,
		 0.5*harmony2,
		   1*harmony2,
		   2*harmony2,
	];
	out = Mix.new(PitchShift.ar(in, 0.2, partials, 0, 0.001));

    7.do({
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
    });

	Out.ar(0,(out/partials.size))

}).add;

// make the ui visible
w.front;

)



