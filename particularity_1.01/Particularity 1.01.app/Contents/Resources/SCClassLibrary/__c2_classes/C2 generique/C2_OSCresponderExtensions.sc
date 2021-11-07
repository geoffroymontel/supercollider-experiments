+ OSCresponder {

	*splitMsg { |msg|

		msg[0] = msg[0].asString;
		msg = msg[0].split.copyToEnd(1) ++ msg.copyToEnd(1);
		msg[0] = ("/" ++ msg[0]).asSymbol;

		^msg	
	}

	*respond { arg time, addr, msg;
		var cmdName, hit = false;
				
		#cmdName = msg;
		all.do{ |resp|
			if((resp.cmdName == cmdName) and: { addr.matches(resp.addr) })
				{
				resp.value(time, msg, addr);
				hit = true;
				}
				{
				if(resp.cmdName == '/anything')
					{
					resp.value(time, msg, addr);
					hit = true;
					};
				}
		};
		if(hit == false)
			{
			msg = this.splitMsg(msg);
			#cmdName = msg;
			all.do{ |resp, index|

				if((resp.cmdName == cmdName) and: { addr.matches(resp.addr) })
					{
					resp.value(time, msg, addr);
					hit = true;
					}
			};
			
			};

		^hit
	}


}