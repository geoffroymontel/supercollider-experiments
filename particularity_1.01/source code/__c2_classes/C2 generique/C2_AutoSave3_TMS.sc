C2_AutoSave3_TMS {

	var fileExt, folderName, folderPath;
	var <>overwriteFlag = 0;
	
	// fileExt does not expect dot

	*new { |fileExt, folderPath| ^super.new.init(fileExt, folderPath) }
	
	init { |fileExtArg, folderPathArg|
	
		fileExt = fileExtArg;
		folderPath = folderPathArg;
		
		this.checkForFolderCreateIfNecessary;
				
		
	}
	
	checkForFolderCreateIfNecessary {
	
		var pathname, folderNames, folderExistsFlag = 0;
	
		pathname = PathName.new("./");
		folderNames = pathname.folders;
		folderNames.do { |item, index|
		
			if(item.fullPath == folderPath)
				{
				folderExistsFlag = 1;
				}
		};
		
		if(folderExistsFlag == 0)
			{
			// create the folder
			("mkdir " ++ folderPath).systemCmd;
			};
	}

	save { |name, args|
	
		var saveObjectTemp, fileSavePath, nextNameFlag = 0, thisName;
		
		if(overwriteFlag == 0)
			{
		
			while(
				{nextNameFlag == 0},
				{
				fileSavePath = folderPath ++ name ++ "." ++ fileExt;
				if(File.exists(fileSavePath))
					{
					name = PathName(name).nextName
					}
					{
					nextNameFlag = 1;
					};	
				}
			);
			
			}
			{
			fileSavePath = folderPath ++ name ++ "." ++ fileExt;
			};
			
		saveObjectTemp = args;
		saveObjectTemp.writeBinaryArchive(fileSavePath);
		
		^name;
	
	}
	
	open { |name, fileExtPresentFlag = 0|
	
		var filePath, temp;
		
		case
			{fileExtPresentFlag == 0}
			{
			filePath = folderPath ++ name.asString ++ "." ++ fileExt;
			}
			{
			filePath = folderPath ++ name.asString;
			};
		if(File.exists(filePath))
			{
			// load it up
			temp = Object.readBinaryArchive(filePath);
			}	
			
		^temp;
	
	}
	
	getFileNamesInFolder {
	
		var paths;
		
		paths = Cocoa.getPathsInDirectory(folderPath);
		^paths;

	}
	
}


//		var saveObjectTemp, fileSavePath, nextNameFlag = 0, thisName;
//		
//		while(
//			{nextNameFlag == 0},
//			{
//			fileSavePath = folderPath ++ name ++ fileExt;
//			if(File.exists(fileSavePath))
//				{
//				name = PathName(name).nextName
//				}
//				{
//				nextNameFlag = 1;
//				};	
//			}
//		);
//		saveObjectTemp = args;
//		saveObjectTemp.writeBinaryArchive(fileSavePath);
