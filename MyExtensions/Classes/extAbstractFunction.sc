+AbstractFunction {
	plotTransferFunction { |from = 0, to = 1|
		var n=500, res, array, plot;
		from = -1.0;
		to = 1.0;
		array = Array.interpolation(n, from, to);
		res = array.collect { |x| this.value(x) };
		plot = res.plot.domainSpecs_([from, to, \lin].asSpec).refresh
	}
}