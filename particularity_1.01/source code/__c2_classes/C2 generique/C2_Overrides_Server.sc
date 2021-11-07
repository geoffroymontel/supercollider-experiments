+ Server {


	sendBundle2 { |time ... msgs|
	
	//[msgs].asOSCArgBundle.postln;
	
		addr.sendBundle(time, *msgs.asOSCArgBundle)
	}

 	listSendBundle2 { arg time, msgs;
 	
		this.sendBundle2(time, *msgs);
	}

	
}


