(
var serie = ["g#4","a4","d#4","g4","e4","c5","a#4","d4","f#4","b4","f4","c#4"].notemidi;
var inversedSerie = serie.deepCopy;

// série
"série initiale".postln;
serie.midinote.postln;

// rétrograde
"série rétrograde".postln;
serie.reverse.midinote.postln;

// série inverse
"série inverse / mirroir".postln;

serie.size.do({|i|
  if (i==0,{
    inversedSerie[i] = serie[i];
  },{
      inversedSerie[i] = inversedSerie[i-1]-(serie[i]-serie[i-1]);
  });
});
inversedSerie.midinote.postln;

// série inverse rétrograde
"série inverse rétrograde".postln;
inversedSerie.reverse.midinote.postln;
nil;
)

