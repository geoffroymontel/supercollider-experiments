(
var randomNumbers, histogram, minValue = 5.0, maxValue = 500, numVals = 10000, numBins = 500;

randomNumbers = Array.fill(numVals, { exprand(minValue, maxValue); });

histogram = Signal.newClear(numBins);

randomNumbers.do({ arg each; var count, histoIndex;
	histoIndex = ( each - minValue ).round(1).asInteger;
	count = histogram.at(histoIndex);
	histogram.put(histoIndex, count + 1);
});

histogram.plot("histogram for exprand: " ++ minValue ++ " to " ++ maxValue);
)
