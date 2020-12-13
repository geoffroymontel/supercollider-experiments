Pmbrot : Pattern {
	var <>xRes, <>xMid, <>yMid, <>w, <>maxIt;
	*new {|xRes=220, xMid=0.3515, yMid=0.42024, w=0.001, maxIt=255|
		^super.newCopyArgs(xRes, xMid, yMid, w, maxIt);
	}
	embedInStream {|inval|
		var localxRes, localxMid, localyMid, localw, localmaxIt, countX=0, countY=0, xStart,
			yStart, lamdaR, lamdaI, incr, out=0, z;
		localxRes=xRes.copy; localxMid=xMid.copy; localyMid=yMid.copy; localw=w.copy;
		localmaxIt=maxIt.copy;
		xStart=localxMid - (0.5 * localw);
		yStart=localyMid - (0.5 * localw);
		incr=localw/localxRes;
		loop {
			localxRes.do ({|i|
				lamdaI=yStart + (incr * i);
				localxRes.do ({|j|
					z=Complex(0,0);
					out=0;
					lamdaR=xStart + (incr * j);
					while ({out < localmaxIt} && {z.magnitude < 2.0}, {
						z=z*z + Complex(lamdaR, lamdaI);
						out=out+1;
					});
					out.yield;
				});
			});
		}
		^inval
	}
}

Plogistic : Pattern {
	var <>y, <>k;
	*new {|y=0.8, k=3.6|
		^super.newCopyArgs(y, k);
	}
	embedInStream {|inval|
		var localy, localk;
		localy=y.copy; localk=k.copy;
		loop {
			localy=(localk * localy)*(1-localy);
			localy.yield;
		}
		^inval
	}
}

Pmarkus : Pattern {
	var <>y, <>k, <>pat;
	*new {|y=0.8, k, pat|
		^super.newCopyArgs(y, k, pat);
	}
	embedInStream {|inval|
		var localy, localk, localPat, kVal;
		localy=y.copy; localk=k.copy; localPat=pat.copy;
		inf.do {|i|
			kVal=localk.at(localPat.wrapAt(i));
			localy=(kVal * localy)*(1-localy);
			localy.yield;
		}
		^inval
	}
}						