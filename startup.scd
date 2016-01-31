"loading ~/Library/Application Support/SuperCollider/startup.scd".postln;
Server.default = s = Server.internal;
// s.options.device = "Firewire";
// thisProcess.platform.recordingsDir = "d:\\supercollider";
s.recHeaderFormat = "wav";
s.options.sampleRate = 44100;
s.options.memSize = 65536;
s.boot;
s.makeGui;

