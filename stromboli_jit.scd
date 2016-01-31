~buffer = Buffer.read(server: s, path: "/Users/geoffroy/music/stromboli/samples/mandoline_tri.wav", action: { "buffer loaded".postln; });

Ndef(\player, {
  |out = 0, bufnum = 0, gate = 1, speed = 1, pos = 0, pan = 0, amp = 1, loop = 0|
  var audio, rate, env;
  env = EnvGen.ar(Env.asr(0.1,1,0.1), gate, doneAction:2);
  rate = BufRateScale.kr(bufnum)*speed*(PulseCount.kr(gate) >= 1);
  audio = PlayBuf.ar(numChannels: 2, bufnum: bufnum, rate: rate, trigger: gate, startPos: pos, loop: loop, doneAction:2);
  audio = Balance2.ar(audio[0], audio[1], pan, amp);
  Out.ar(out, audio * env);
});

Ndef(\player).set(\bufnum, ~buffer);
Ndef(\player).set(\loop, 1);
Ndef(\player).play;

Ndef(\player).set(\speed,1.0);
Ndef(\player).set(\speed,0.5);
Ndef(\player).fadeTime = 0;
Ndef(\player).xset(\speed,1);
Ndef(\player).xset(\speed,0.5);

Ndef(\player).play;
Ndef(\player).free;
Ndef(\player).set(\gate, 1);
Ndef(\player).set(\gate, 0);
Ndef(\player, {SinOsc.ar(440)});
Ndef(\onesecosc, {SinOsc.kr(freq: 0.1)});
Ndef(\player).set(\speed, 1);
Ndef(\player).map(\speed, Ndef(\onesecosc));

Ndef(\player)[1] = \set -> Pbind(*[
    dur: Prand([1,2,3,5,8,13,21]*4,10),
    speed: 1
]);

Ndef(\player).play;

Ndef(\a, { |freq=440| SinOsc.ar(freq) }).play;

Ndef(\a)[1] = \set -> Pbind(\dur, 0.1, \freq, Pwhite(200.0, 400.0));
