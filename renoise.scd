(
Event.addEventType(\renoise, { |server|
  var renoiseOscServer = NetAddr("127.0.0.1", 8000);
  var notes = [~midinote.value, ~ctranspose.value, ~velocity.value, ~sustain.value, ~lag.value, ~timingOffset.value].flop;
  var timeNoteOn, timeNoteOff;
  var serverLatency;

  if (server.latency == nil, {serverLatency = 0}, {serverLatency = server.latency});

  notes.do {|note|
    // sustain and timingOffset are in beats, lag is in seconds
    timeNoteOn = (thisThread.clock.tempo.reciprocal*note[5])+note[4]+server.latency;
    timeNoteOff = (thisThread.clock.tempo.reciprocal*(note[3]+note[5]))+note[4]+server.latency;
    {renoiseOscServer.sendMsg("/renoise/trigger/note_on", -1, -1, (note[0]+note[1]).asInt, note[2].asInt)}.defer(timeNoteOn);
    {renoiseOscServer.sendMsg("/renoise/trigger/note_off", -1, -1, (note[0]+note[1]).asInt)}.defer(timeNoteOff);
  }
});
)

// straight timing
(
Pbind(*[
  type: \renoise,
  legato: Pgauss(0.2,0.05,inf),
  dur: 0.2,
  degree: [2,5,12],
  ctranspose: Pseq([0,0,0,0,4,4,4,4,5,5,5,5],inf),
  velocity: Pgauss(64,10,inf),
]).play;
)

// loose timing
(
Pbind(*[
  type: \renoise,
  legato: 0.1,
  dur: 0.2,
  midinote: [66, 69, 74],
  lag: Pwhite(-0.05!3, 0.05)
]).play;
)

// ravel chords

TempoClock.default.tempo = 50/60;

// one note to test
(
NetAddr("127.0.0.1",8000).sendMsg("/renoise/trigger/note_on", -1, -1, 60, 64);
)

// all notes off

(
NetAddr("127.0.0.1",8000).sendMsg("/renoise/transport/stop");
)

(
Pbind(*[
  type: \renoise,
  dur: Pseq((7..0), inf)*0.25+12+Pwhite(-1,1,inf),
  delta: Pseq([0.25,0.25,0.25,0.25,0.25,0.25,0.25,Pwhite(18,26,1)], inf),
  scale: [0, 2, 4, 5, 8, 9, 11],
  mtranspose: Pxrand([0,1,2,3,4,5,6,7], inf),
  lag: Pwhite(-0.02, 0.02, inf),
  velocity: Pgauss(64,4,inf),
  octave: Pseq([4,4,Prand([4,5]),5,5,6,Prand([5,6]),6], inf)
]).play;
)

(
var a, b;
a = Pxrand.new((1..10), 10);
b = a.asStream;
11.do({ b.next.postln;});
)

