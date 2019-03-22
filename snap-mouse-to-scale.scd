(
r = {
    var scale = Scale.choose.postln;
    SinOsc.ar(
        (
            DegreeToKey.kr(
                scale.as(LocalBuf),
				MouseX.kr(0, (scale.size*3)+1), // mouse indexes into scale
                scale.stepsPerOctave,
                1, // mul = 1
                60 // offset by 72 notes
            ).poll
        ).midicps // convert midi notes to hertz
    ) * -3.dbamp;
}.play;
)

r.free;

(
var scale = Scale.choose.postln;
var array = scale.as(Array);
array.postln;
)