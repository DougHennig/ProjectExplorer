*==============================================================================
* Function:			GetRelativePath
* Purpose:			Returns the relative path for a file in the case as it
*						exists on disk
* Author:			Doug Hennig
* Last revision:	06/26/2018
* Parameters:		tcTo   - the file to get the relative path for
*					tcFrom - the file to get the relative path from
* Returns:			the file or folder name in the correct case
* Environment in:	none
* Environment out:	none
*==============================================================================

#define cnMAX_PATH					260
#define cnFILE_ATTRIBUTE_DIRECTORY	0x10
#define cnFILE_ATTRIBUTE_NORMAL		0x80

lparameters tcTo, ;
	tcFrom
local lcPath, ;
	lcFrom, ;
	lnFromAttrib, ;
	lcTo, ;
	lnToAttrib
declare integer PathRelativePathTo in shlwapi.dll ;
	string @out, string @from, integer fromattrib, string @to, integer toattrib
lcPath       = space(cnMAX_PATH)
lcFrom       = iif(vartype(tcFrom) = 'C', tcFrom, sys(5) + curdir()) + chr(0)
lnFromAttrib = iif(directory(lcFrom), cnFILE_ATTRIBUTE_DIRECTORY, ;
	cnFILE_ATTRIBUTE_NORMAL)
lcTo         = iif(vartype(tcTo) = 'C', tcTo, sys(5) + curdir()) + chr(0)
lnToAttrib   = iif(directory(lcTo), cnFILE_ATTRIBUTE_DIRECTORY, ;
	cnFILE_ATTRIBUTE_NORMAL)
PathRelativePathTo(@lcPath, @lcFrom, lnFromAttrib, @lcTo, lnToAttrib)
lcPath = alltrim(strtran(lcPath, chr(0), ' '))
do case
	case empty(lcPath)
		lcPath = tcTo
	case left(lcPath, 2) = '.\'
		lcPath = substr(lcPath, 3)
endcase
return lcPath
