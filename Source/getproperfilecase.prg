*==============================================================================
* Function:			GetProperFileCase
* Purpose:			Returns the specified file or folder name in the case as it
*						exists on disk
* Author:			Doug Hennig
* Last revision:	06/26/2018
* Parameters:		tcName   - the name of the file or folder
*					tlFolder - .T. if the name is a folder
* Returns:			the file or folder name in the correct case
* Environment in:	Scripting.FileSystemObject can be instantiated
*					if a public variable named __FSO exists, it may contain a
*						reference to Scripting.FileSystemObject
* Environment out:	a public variable named __FSO exist contains a reference to
*						Scripting.FileSystemObject
*==============================================================================

lparameters tcName, ;
	tlFolder
local loFSO, ;
	llExists, ;
	loFile, ;
	lcName, ;
	lcFolder, ;
	loFolder
try
	if type('__FSO') = 'O'
		loFSO = __FSO
	else
		loFSO = createobject('Scripting.FileSystemObject')
		public __FSO
		__FSO = loFSO
	endif type('__FSO') = 'O'
	if tlFolder
		llExists = directory(tcName)
	else
		llExists = file(tcName)
	endif tlFolder
	do case
		case llExists and tlFolder
			loFile = loFSO.GetFolder(tcName)
			lcName = addbs(loFile.Path)
		case llExists
			loFile = loFSO.GetFile(tcName)
			lcName = loFile.Path
		case '\' $ tcName
			lcFolder = justpath(tcName)
			loFolder = loFSO.GetFolder(lcFolder)
			lcName   = addbs(loFolder.Path) + lower(justfname(tcName))
		otherwise
			lcName = lower(tcName)
	endcase
catch
	lcName = lower(tcName)
endtry
return lcName
