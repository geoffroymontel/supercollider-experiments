(
var sines = 200;
var fond_freq = 1000;
var start_ratio = 1.025;
var line_duration = 48;
var max_freq = fond_freq*(pow(start_ratio,sines/2));
var min_freq = fond_freq/(pow(start_ratio,sines/2));
Post << min_freq << nl;
Post << max_freq << nl;

{
for (1, sines/2,
	{
		arg i;
		{ Pan2.ar(
			in: SinOsc.ar(
				freq: fond_freq*(pow(Line.kr(start_ratio,1,line_duration),i)),
				phase: 0,
				mul: 10/sines,
				add: 0),
			pos: 0,
			level: (4*i)/sines-1)
		}.play;
	}
);

	line_duration.wait;


}.fork
)

