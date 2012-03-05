(
  ~myPath = "d:/stromboli/puit/*.wav";
  ~wavFiles = ~myPath.pathMatch;

  b =  Buffer.read(s, ~wavFiles.choose);
  s.sync; // wait for server to finish what it's doing
  x = Synth(\playBuf, [\bufnum, b]);
)