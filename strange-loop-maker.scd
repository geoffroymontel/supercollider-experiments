(
SynthDef.new(\player, { |out, bufnum, t_trig = 1, gate = 1, rate = 1.0, volume_l = 1.0, volume_r = 1.0|
	var sig;
	sig = PlayBuf.ar(numChannels: 2, bufnum: bufnum, trigger: t_trig, rate: BufRateScale.ir(bufnum) * Lag.kr(in: rate, lagTime: ~lag_time), loop: 1, doneAction: Done.freeSelf);
    sig = sig * EnvGen.kr(Env.asr(0, 1.0, 0), gate, doneAction: Done.freeSelf);
	Out.ar(0, [sig[0] * Lag.kr(in: volume_l, lagTime: ~lag_time), sig[1] * Lag.kr(in: volume_r, lagTime: ~lag_time)]);
}).add;
)