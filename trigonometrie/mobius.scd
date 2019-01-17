// Ruban de Möbius
// bande de largeur L et de hauteur / rayon R
// un point du ruban a pour coordonnées
// x = (R + V cos(-U/2)) cos(U)
// y = (R + V cos(-U/2)) sin(U)
// z = V sin(-U/2)
// U varie de -pi à pi
// V varie de -l/2 à l/2

(
[30.collect {|i| v = [
	sin(pi/1.5*i)*0.5,
	cos(pi/1.5*i)*0.5,
	i.linlin(0,30,-1,1)
]}]
)

(
var number_of_points = 100;
~paths = List.new;

number_of_points.do { |i|
	var u = pi.neg + (2 * pi  * i / number_of_points);

	number_of_points.do { |j|
		var l = 1;
		var r = 1;
		var v = l.neg + (2 * l * j / number_of_points);
		~paths.add([
			(r + v * cos(u.neg/2)) * cos(u),
			(r + v * cos(u.neg/2)) * sin(u),
			v * sin(u.neg/2)
		]);
	}
}
)

(
var width = 500, height = 400, rate = 0.005;
var w, u;
var number_of_points = 30;

w = Window("ruban", Rect(128, 64, width, height), false)
.front;

u = Canvas3D(w, Rect(0, 0, width, height))
.background_(Color.black)
.scale_(200)
.perspective_(0.4)
.distance_(2);

// add ruban
u.add(Canvas3DItem()
	.color_(Color.green)
	.width_(1.5)
	.paths_(
		[~paths.array]
	)
);

// spin canvas on mouse move
u.mouseMoveAction = {|v,x,y|
	u.transforms = [
		Canvas3D.mRotateY(x / -200 % 2pi),
		Canvas3D.mRotateX(y / 200 % 2pi)
	];
	u.refresh;
};

u.mouseMoveAction.value(nil, 50, 50); // initial rotation
)

(
SynthDef.new(\mobius, { |carfreq = 400, modfreq = 500, pmindex = 0, modphase = 0, duration = 1|
	var sig;
	sig = PMOsc.ar(carfreq: carfreq, modfreq: modfreq, pmindex: pmindex, modphase: modphase);
	sig = sig * EnvGen.ar(Env.linen(attackTime: 0.01, sustainTime: duration, releaseTime: 1, level: 1), doneAction: Done.freeSelf);
	sig = Pan2.ar(sig, Rand(-1,1));
	Out.ar(0,sig * -30.dbamp);
}).add;
)


(
~paths.do({ |point|
	postf("% % %\n", point[0], point[1], point[2]);
});
)

(
{
	~paths.do({ |point|
		var carfreq = point[0].linexp(-0.5,0.5,200, 2000);
		var modfreq = point[1].linexp(-0.5,0.5,200, 2000);
		var pmindex = cos(carfreq);
		var modphase = sin(modfreq);
		Synth(\mobius, [carfreq: carfreq, modfreq: modfreq, pmindex: pmindex, modphase: modphase]);
		(point[2].abs / 10).wait;
	});
}.fork
)