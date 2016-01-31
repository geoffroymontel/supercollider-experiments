(
SynthDef(\bubble, {	|out=0, t_trig=0, attack=0.01, decay=0.08, pitchcurvelen=0.1, freq=1000, amp=0.1, pan=0|
	var pitch, sound;
	amp   = amp * EnvGen.ar(Env.perc(attack, decay).delay(0.003), t_trig, doneAction: 2);
	pitch = freq * EnvGen.ar(Env.new([0,0,1],[0,1]).exprange(1, 2.718), t_trig, timeScale: pitchcurvelen);
	sound = SinOsc.ar(pitch);
	sound = HPF.ar(sound, 500) * amp;
  Out.ar(out, Pan2.ar(sound, pos: pan));
}).add
)

(
Pbind(*[
  instrument: \bubble,
  freq: Pwhite(1000,1200),
  attack: Pwhite(0.008,0.012),
  decay: Pwhite(0.06,0.10),
  pitchcurvelen: Pwhite(0.08,0.12),
  pan: Pwhite(0,1),
  dur: 1
]).play;
)
