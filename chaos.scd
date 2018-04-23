(
a = 200;
{ [((ChaosGen.allSubclasses.choose.ar(freq: exprand(20,22050))  * a).tanh) * -24.dbamp,
	((ChaosGen.allSubclasses.choose.ar(freq: exprand(20,22050)) * a).tanh) * -24.dbamp]
}.play;
)