// Play it with the mouse
{DFM1.ar(PinkNoise.ar(mul: 0.5), MouseX.kr(80, 5000, 'exponential'), MouseY.kr(0.1, 1.2))}.play;

// Throbby bass
{DFM1.ar(Pulse.ar(100, mul:0.4) + Pulse.ar(100.1, mul:0.4), SinOsc.kr(SinOsc.kr(0.3).range(0.2, 5)).range(80, 2000), 1.1, inputgain: 2.0, mul:0.7)!2}.play;