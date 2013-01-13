(
Event.addEventType(\renoise, { |server|
  var renoiseOscServer = NetAddr("127.0.0.1", 8000);
  var notes = [~midinote.value, ~ctranspose.value, ~velocity.value, ~sustain.value, ~lag.value, ~timingOffset.value].flop;
  var timeNoteOn, timeNoteOff;

  notes.do {|note|
    // sustain and timingOffset are in beats, lag is in seconds
    timeNoteOn = (thisThread.clock.tempo.reciprocal*note[5])+note[4];
    timeNoteOff = (thisThread.clock.tempo.reciprocal*(note[3]+note[5]))+note[4];
    {renoiseOscServer.sendMsg("/renoise/trigger/note_on", -1, -1, (note[0]+note[1]).asInt, note[2].asInt)}.defer(timeNoteOn);
    {renoiseOscServer.sendMsg("/renoise/trigger/note_off", -1, -1, (note[0]+note[1]).asInt)}.defer(timeNoteOff);
  }
});
)

// all notes off
(
NetAddr("127.0.0.1",8000).sendMsg("/renoise/transport/stop");
)

TempoClock.default.tempo = 60/60;
TempoClock.default.tempo = 120/60;

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



