*==============================================================================
* Function:			GetLastModified
* Purpose:			Returns the last modified date for a file
* Author:			Doug Hennig
* Last Revision:	05/08/2017
* Parameters:		tcFileName - the name and path of the file
* Returns:			the most recent last modified date of the file or any
*						associated file in the case of a VFP binary file
* Environment in:	Scripting.FileSystemObject can be instantiated
* Environment out:	none
*==============================================================================

lparameters tcFileName
local loFSO, ;
	loFile, ;
	ltModified, ;
	lcOther
loFSO      = createobject('Scripting.FileSystemObject')
loFile     = loFSO.GetFile(tcFileName)
ltModified = loFile.DateLastModified
lcOther    = GetVFPBinaryOtherFile(tcFileName)
if not empty(lcOther)
	loFile     = loFSO.GetFile(lcOther)
	ltModified = max(loFile.DateLastModified, ltModified)
	lcOther    = GetVFPBinaryOtherFile(tcFileName, .T.)
	if not empty(lcOther)
		loFile     = loFSO.GetFile(lcOther)
		ltModified = max(loFile.DateLastModified, ltModified)
	endif not empty(lcOther)
endif not empty(lcOther)
return ltModified
