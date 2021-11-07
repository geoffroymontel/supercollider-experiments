
// nonprivate@cylob.com

+ CocoaMenuItem {

	*initDefaultMenu {
		default = CocoaMenuItem(nil, 1, "Cylobian", true);
	//	~default2 = CocoaMenuItem(nil, 2, "shit", true);
	}
	
}
	
+ NetAddr {

//	*new { arg hostname, port=0;
//		var addr;
//
//		
//		addr = 
//		if (hostname.notNil,
//			{ 
//				try 
//				{ hostname.gethostbyname } 
//				{ 
//				"*** C2_Overrides: NetAddr ***".postln;
//				("server " ++ hostname ++ " has not been found, so i.p. will be set to 0.0.0.0").postln;
//				"******************************".postln;
//				hostname = "0.0.0.0"; 
//				hostname.gethostbyname 
//				}
//			},
//			{ 
//			0 
//			}
//		);
//		^super.newCopyArgs(addr, port, hostname);
//	}
	
	*testAddr {
	
		arg addr;
		var result = true;
		try { addr.gethostbyname } { result = false }
		^result;
	
	}

	*myIP {
		var j, k, res;
		res = Pipe.findValuesForKey("ifconfig", "inet"); 
		^res !? {
			res = res.reject(_ == "127.0.0.1"); // remove loopback device ip
			if(res.size > 1) { warn("the first of those devices were chosen: " ++ res) };
			res[0]
		};
	}

}



+ Pipe {
	*do { arg commandLine, func;
		var line, pipe = this.new(commandLine, "r"), i=0;
		{
			line = pipe.getLine;
			while { line.notNil } {
				func.value(line, i);
				i = i + 1;
				line = pipe.getLine;
			}
		}.protect { pipe.close };

	}
	*findValuesForKey { arg commandLine, key, delimiter=$ ;
		var j, k, indices, res, keySize;
		key = key ++ delimiter;
		keySize = key.size;
		Pipe.do(commandLine, { |l|
			indices = l.findAll(key);
			indices !? {
				indices.do { |j|
					j = j + keySize;
					while { l[j] == delimiter } { j = j + 1 };
					k = l.find(delimiter.asString, offset:j) ?? { l.size } - 1;
					res = res.add(l[j..k])
				};
			};
		});
		^res
	}

}
