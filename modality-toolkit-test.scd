// Without Modality Toollkit

OSCFunc.trace(true);
OSCFunc.trace(false);
OSCdef('/1/fader1', { |msg, time, addr, recvPort| msg.postln }, '/1/fader1', nil);

// With Modality Toolkit
t = MKtl(\tosca, "touchosc-simple1");
t.device.updateSrcDstAddr("192.168.1.12", 63763); // IP and port of TouchOsc on my iPad as printed
t.gui;

t.postElements;

t.elAt.action = { |el|
    "tOsc %: %\n".postf(el.name, el.value.round(0.001))
};

t.setValueAt('sl_1', 1.0.rand);

t.free;

// test feedback to iPad with OSC
~touchOsc = NetAddr("192.168.1.12", 63763);
~touchOsc.sendMsg("/1/fader1", rrand(0.0,1.0));

// install
Quarks.gui
Quarks.openFolder
