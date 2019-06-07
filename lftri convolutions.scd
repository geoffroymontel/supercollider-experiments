(
{
	var line = Array.with(
		Line.ar(147,5147,1200,1,0,2),
		Line.ar(1117,17,1200,1,0,2)
	);
	var tri = Array.with(
		1-LFTri.ar(line[0]),
		1-LFTri.ar(line[1]),
		1-LFTri.ar(100),
		1-LFTri.ar([55,55.1]),
	);
	var triScale = 0.05;
	var triMix = tri[0] * tri[1] * tri[2] * tri[3] * triScale;
	triMix = LeakDC.ar(triMix);
	triMix = HPF.ar(triMix, 20);
	triMix = HPF.ar(triMix, 20);
	triMix = HPF.ar(triMix, 20);
	triMix + (NHHall.ar(triMix, 0.5) * -6.dbamp);
}.play
)