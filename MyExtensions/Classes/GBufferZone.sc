GBufferZone {
	var <items;
	var lastReturnedItem = nil;

	*new {
		^super.new.init;
	}

	init {
		items = List.new;
	}

	mapBufferToFrequency { |buffer, freq = 440|
		var item;
		item = (buffer: buffer, freq: freq);
		items.add(item);
	}

	getBufferAndRateForFrequency { |freq = 440|
		var closestFreq, candidates, sortedItems;
		sortedItems = items.sort( { |a, b| abs(a.freq - freq) < abs(b.freq - freq) } );
		closestFreq = sortedItems.first.freq;
		candidates = items.select( { |a| abs(a.freq - closestFreq) < 0.001 } );
		if (candidates.size == 1, {
			lastReturnedItem = candidates[0];
		}, {
			lastReturnedItem = candidates.reject( { |i| i == lastReturnedItem } ).choose;
		});
		^[lastReturnedItem.buffer, freq / lastReturnedItem.freq]
	}

	free {
		items.do { |i|
			i.buffer.free;
		};
		items.clear;
	}
}