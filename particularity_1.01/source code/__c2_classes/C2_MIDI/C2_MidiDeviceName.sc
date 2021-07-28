/*
C2_MidiDeviceName.sources.dump;
C2_MidiDeviceName.getUid(\source, "E_MU Xboard61_E_MU Xboard61").postln;
C2_MidiDeviceName.getUid(\source, "E-MU Xboard61_E-MU Xboard61");

C2_MidiDeviceName.getIndex(\source, "EDIROL FA_101 [2869]_Plug 1");
C2_MidiDeviceName.getUid(\dest, "Bidule  3_Bidule  3");
C2_MidiDeviceName.sourceDict.idToObj.dump;
C2_MidiDeviceName.getNameByUid(\source, 1529606540).postln;
C2_MidiDeviceName.sourceDict.getID(-979024390).postln;

C2_MidiDeviceName.popDestinations.postln;
*/


C2_MidiDeviceName {

	classvar <sourceDict, <destDict, sourceUids, destUids, <sources, <popSources, <destinations, <popDestinations;
	
	*initClass {
	
		sources = []; popSources = []; sourceUids = [];
		destinations = []; popDestinations = []; destUids = [];
	
		MIDIIn.connectAll;
		MIDIClient.sources.do { |item, index|
	
			sources = sources.add(item.device ++ "_" ++ item.name);
			popSources = popSources.add(C2_MidiDeviceName.popName(sources[index]));
			sourceUids = sourceUids.add(item.uid);
		
		};
		
		MIDIClient.destinations.do { |item, index|
	
			destinations = destinations.add(item.device ++ "_" ++ item.name);
			popDestinations = popDestinations.add(C2_MidiDeviceName.popName(destinations[index]));
			destUids = destUids.add(item.uid);
		
		};
		
		sourceDict = TwoWayIdentityDictionary.new; destDict = TwoWayIdentityDictionary.new;
		
		sources.do { |item, index|
		
			sourceDict.put(C2_MidiDeviceName.popName(sources[index]).asSymbol, sourceUids[index]);
			sourceDict.put(sources[index].asSymbol, sourceUids[index]);
		
		};
		
		destinations.do { |item, index|
		
			destDict.put(C2_MidiDeviceName.popName(destinations[index]).asSymbol, destUids[index]);
			destDict.put(destinations[index].asSymbol, destUids[index]);
		
		};
	
	}
	
	*getUid { |type, name|
	
		var out;
	
		type = type ? \source;
		name = name.asSymbol;
		
		case
			{type == \source}
			{
			out = sourceDict[name];
			}
			{type == \dest}
			{
			out = destDict[name];
			};
	
		^out;
	
	}
	
	*getNameByUid { |type, uid|
	
		var out;
	
		if(uid == nil) {^nil};
		
		type = type ? \source;
		
		case
			{type == \source}
			{
			out = sourceDict.getID(uid);
			}
			{type == \dest}
			{
			out = destDict.getID(uid);
			};
			
		out = out.asString;
	
		^out;
	
	
	}
	
	*getIndex { |type, name|
	
		var indexOut;
	//	name = name.asSymbol;
		
		case
			{type == \source}
			{
			sources.do { |item, index|
			
				if(item == name)
					{
					indexOut = index
					};
			
			};
			
			if(indexOut == nil)
				{
				popSources.do { |item, index|
			
					if(item == name)
						{
						indexOut = index
						};
				
				};
				
				};
				
			
			}
			{type == \dest}
			{
			destinations.do { |item, index|
			
				if(item == name)
					{
					indexOut = index
					};
			
			};
			
//			if(indexOut == nil)
//				{
//				popDestinations.do { |item, index|
//				
//					if(item == name)
//						{
//						indexOut = index
//						};
//			
//				};				
//				
//				};
			
			};
		
	
		^indexOut
	
	
	
	}
	
	*popName { |name|
	
		// make a version of the name suitable for a pop up menu
		
		name = name.asString;
		
		name = name.replace("-", "_");
		name = name.replace("(", "[");
		name = name.replace(")", "]");
		
		^name;
	
	
	}
	



}




