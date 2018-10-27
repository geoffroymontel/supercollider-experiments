// sine cluster refix, kind of, a little bit, of Arvo Pärt, "Fratres"

(
{
	b=fork{
		loop{
			h=[40,45,52].choose.midicps;
			play{Splay.ar({SinOsc.ar(exprand(h,h+(h/64)),0,0.2)}!16)*LFGauss.ar(9,1/4,0,0,2)};
			4.wait;
		}
	};
	{
		5.do{[[72,69,64], [70,64,62], [67,60,70], [65,60,69], [64,60,67],[65,60,69]].do{|i|
			x=i.postln;
			10.wait;}
		};
		10.wait;
		c.stop;
		4.wait;
		b.stop;
	}.fork;
	0.1.wait;
	c=fork{
		loop{
			h=x.choose.midicps;
			play{Splay.ar({SinOsc.ar(exprand(h-(h/128),h+(h/128)),0,0.1)}!16)*LFGauss.ar(6,1/4,0,0,2)};
			0.5.wait;
		}
	};
}.fork;
)