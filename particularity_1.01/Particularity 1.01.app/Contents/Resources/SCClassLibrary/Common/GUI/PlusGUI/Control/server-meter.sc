+ Server {
	meter {
		var clzz;
		if( GUI.id == \swing and: {�\JSCPeakMeter.asClass.notNil }, {
			\JSCPeakMeter.asClass.meterServer( this );
		}, { if( \SCLevelIndicator.asClass.notNil, {
			\SCLevelIndicator.asClass.meterServer( this );
		})});
	}
}
