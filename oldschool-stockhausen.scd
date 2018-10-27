{ LPF.ar(LPF.ar((FreeVerb.ar((SinOsc.ar(100) + SinOsc.ar(240)) * SinOsc.ar(TRand.ar(10, 1000, Dust.ar(8))), room: 1.0) * 10.dbamp).tanh, 3000), 3000) * -20.dbamp ! 2 }.play

{ LPF.ar(LPF.ar((FreeVerb.ar((SinOsc.ar(100) + SinOsc.ar(240)) * SinOsc.ar(MouseX.kr(1, 1000, 1)), room: 1.0) * 10.dbamp).tanh, 3000), 3000) * -20.dbamp ! 2 }.play

//so getting a good sounding 1950's tape deck emulation, and using it iteratively, is key here. so saturation + bandlimiting + pink noise + wow/flutter.