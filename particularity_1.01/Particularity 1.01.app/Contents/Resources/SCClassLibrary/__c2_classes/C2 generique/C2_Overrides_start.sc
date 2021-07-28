+ Main {

	run { 
		// called by command-R
	
		var x, a, w, b, cms_environment, doneFlag = 0;
		var m;
		
		C2_GlobalSeqTransport.new;


		GUI.menuItem.add(
			["CMS Environment 3009"], 
			{
			if( ~cms_environment_running != true,
				{
				CMS_Preferences.readPreferences;
				CMS_Vocal_Filter_1.phonemeDictionaryDefine;
				~displayAmountModulationStatus = 0;
				cms_environment = CMS_Environment.new;
				cms_environment.boot;	
				~cms_environment_running = true;
				doneFlag = 1; 
				}
			);
			
			}
		);
		
		GUI.menuItem.add(
			["Virtual Monome Start"], 
			{
			~vmon = C2_VirtualMonome_2009_B.new;
//			~vmonWindow = SCWindow.new(" ", Rect(0, 0, 1024, 768), resizable: true, border: true);
//			~vmonWindow.front;
			~vmon.guiDraw;
			~vmon.guiUpdate_lowerText("-");
			~vmon.startScrollRoutine;
			}
		);

		GUI.menuItem.add(
			["Virtual Monome Start Scroll Routine"], 
			{
			if(~vmon != nil)
				{
				~vmon.startScrollRoutine;
				};
			}
		);		
		
		GUI.menuItem.add(
			["Feurig"], 
			{
			x = C2_Feurig_Top.new;
			}
		);
		
		GUI.menuItem.add(
			["Kombine BeatHarvester"], 
			{
			if( ~cms_environment_running != true,
				{
				if( ~kombine_running != true,
					{
					x = C2_Kombine.new;
					x.guiDraw(0, 30);	
					~kombine_running = true;
					doneFlag = 1;
					}
				);
				
				}
			);
			
			}
		);
		
		GUI.menuItem.add(
			["Monome Music System"], 
			{
			if( ~mms_running != true,
				{
				x = C2_MMS_Top.new;
				~mms_running = true;
				doneFlag = 1;
				}
			);
			
			}
		);
		
		GUI.menuItem.add(
			["Clear Monome"], 
			{
			 m = C2_Monome.new(
				
				noOfColumns: 16, noOfRows: 8, 
				noOfStates: 2, 
				idNo: 0, 
				prefix: "/c2m", 
				hostname: "127.0.0.1", port: 8080
			);
			m.enable;
			m.clearAll;
			doneFlag = 1;
			}
		);
			
		GUI.menuItem.add(
			["FM7 Explorer"], 
			{
			C2_FM7_Explorer.new;
			doneFlag = 1;
			}
		);
		

		GUI.menuItem.add(
			["SBA Workshop"], 
			{
			x = C2_SBA_Workshop.new;
			x.guiDraw;
			doneFlag = 1;
			}
		);
		
		GUI.menuItem.add(
			["C2 Color Test"], 
			{
			C2_Color.test;
			doneFlag = 1;
			}
		);
				
		GUI.menuItem.add(
			["ambient letter editor"], 
			{
			x = C2_AmbientLetterEditor.new;
			doneFlag = 1;
			}
		);
		
		GUI.menuItem.add(
			["Open Random Helpfile"], 
			{
			Document.open(PathName("Help").deepFiles.choose.fullPath);
			}
		);


		
	}
	
}
