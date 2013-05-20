// /Applications/SuperCollider/SuperCollider.app/Contents/Resources/sclang ~/dev/supercollider-experiments/SCMIR.sc file.wav

try {
  thisProcess.argv.do({|i|
    ("Processing "++i).postln;
    f = SCMIRAudioFile(i, [[MFCC, 13], [Chromagram, 12]]);
    f.extractFeatures();
    f.extractBeats(); //wait for me to finish
    o = File.new(i++".beats","w");
    o.write(f.beatdata.asCompileString());
    o.close;
  });
} { |error|
  e = "there was an error : "++error.errorString;
  e.postln;
};

0.exit;
