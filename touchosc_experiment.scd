NetAddr.langPort; // Port SC is listening to for OSC communication

(
var window, dragSink;
~buffer = nil;
~player = nil;
~rate = 1.0;
~volume_l = 1.0;
~volume_r = 1.0;s
~lag_time = 0.01;

OSCdef.new(
	\toggle_start_stop,
	{
		arg msg, time, address, port;
		~player.set(\t_trig, msg[1]);
		"rettrigering".postln;
	},
	'/1/toggle_start_stop'
);

OSCdef.new(
	\fader_speed,
	{
		arg msg, time, address, port;
		~rate = msg[1];
		~player.set(\rate, ~rate);
		("new rate : " ++ ~rate).postln;
	},
	'/1/fader_speed'
);

OSCdef.new(
	\fader_volume_l,
	{
		arg msg, time, address, port;
		~volume_l = msg[1];
		~player.set(\volume_l, ~volume_l);
		("new volume_l : " ++ ~volume_l).postln;
	},
	'/1/fader_volume_l'
);

OSCdef.new(
	\fader_volume_r,
	{
		arg msg, time, address, port;
		~volume_r = msg[1];
		~player.set(\volume_r, ~volume_r);
		("new volume_r : " ++ ~volume_r).postln;
	},
	'/1/fader_volume_r'
);

SynthDef.new(\player, { |out, bufnum, t_trig = 1, gate = 1, rate = 1.0, volume_l = 1.0, volume_r = 1.0|
	var sig;
	sig = PlayBuf.ar(numChannels: 2, bufnum: bufnum, trigger: t_trig, rate: BufRateScale.ir(bufnum) * Lag.kr(in: rate, lagTime: ~lag_time), loop: 1, doneAction: Done.freeSelf);
    sig = sig * EnvGen.kr(Env.asr(0, 1.0, 0), gate, doneAction: Done.freeSelf);
	Out.ar(0, [sig[0] * Lag.kr(in: volume_l, lagTime: ~lag_time), sig[1] * Lag.kr(in: volume_r, lagTime: ~lag_time)]);
}).add;

window = Window.new.front;
dragSink = DragSink(window,Rect(10,40, 200, 200)).align_(\center).string="Drag file";
dragSink.receiveDragHandler = { |v|
	var path;
	dragSink.object = View.currentDrag.value;
	path = dragSink.object;
	~buffer.free;
	~player.set(\gate, 0);
	~buffer = Buffer.read(s, path, action: { |buf|
		(path ++ " loaded.").postln;
		~player = Synth(\player, [out: 0, bufnum: ~buffer, rate: ~rate, volume_l: ~volume_l, volume_r: ~volume_r]);
	});
};
)

