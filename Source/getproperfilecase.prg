*==============================================================================
* Function:			GetProperFileCase
* Purpose:			Returns the specified file or folder name in the case as it
*						exists on disk
* Author:			Doug Hennig
* Last revision:	05/11/2017
* Parameters:		tcName   - the name of the file or folder
*					tlFolder - .T. if the name is a folder
* Returns:			the file or folder name in the correct case
* Environment in:	Scripting.FileSystemObject can be instantiated
* Environment out:	none
*==============================================================================

lparameters tcName, ;
	tlFolder
local loFSO, ;
	loFile, ;
	lcName
try
	loFSO = createobject('Scripting.FileSystemObject')
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
			lcName   = addbs(loFolder.Path) + proper(justfname(tcName))
		otherwise
			lcName = proper(tcName)
	endcase
catch
	lcName = proper(tcName)
endtry
return lcName
