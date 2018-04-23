(
OSCdef.new(
	\toggle_start_stop,
	{
		arg msg, time, address, port;
		[msg, time, address, port].postln;
	},
	'/1/toggle_start_stop'
)
)

NetAddr.langPort; // Port SC is listening to for OSC communication

(
SynthDef.new(\player, { |out, bufnum, t_trig, rate, volume_l, volume_r|
	var sig;
	sig = PlayBuf.ar(numChannels: 2, bufnum: bufnum);
	Out.ar(0, [sig[0] * volume_l, sig[1] * volume_r]);
});
)

(
var window = Window.new.front;
var dragSink = DragSink(window,Rect(10,40, 200, 200)).align_(\center).string="Drag file";
dragSink.receiveDragHandler = { |v|
	dragSink.object = View.currentDrag.value;
	dragSink.object.postln;
};
)

