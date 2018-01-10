*==============================================================================
* Function:			GetChecksum
* Purpose:			Returns the checksum for the specified file and associated
*						files
* Author:			Doug Hennig
* Last Revision:	01/05/2018
* Parameters:		tcFileName - the name and path of the file
* Returns:			the checksum for the specified file and associated files
*						(comma-separated)
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcFileName
local lcChecksum, ;
	lcOther
CloseFile(tcFileName)
lcChecksum = ''
try
	lcChecksum = sys(2007, filetostr(tcFileName), 0, 1)
	lcOther    = GetVFPBinaryOtherFile(tcFileName)
	lcChecksum = lcChecksum + ',' + sys(2007, filetostr(lcOther), 0, 1)
	lcOther    = GetVFPBinaryOtherFile(tcFileName, .T.)
	if not empty(lcOther)
		lcChecksum = lcChecksum + ',' + sys(2007, filetostr(lcOther), 0, 1)
	endif not empty(lcOther)
catch
endtry
return lcChecksum
