*==============================================================================
* Function:			ProjectExplorerGetValidName
* Purpose:			Returns a valid VFP name
* Author:			Doug Hennig
* Last revision:	01/13/2024
* Parameters:		tcName   - the name
*					tlObject - .T. to only allow characters in an object name;
*						.F. to allow characters in a file name
* Returns:			the name with illegal characters converted to _
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcName, ;
	tlObject
local lcName, ;
	lnI, ;
	lcChar, ;
	lcIllegal
if tlObject
	lcName = tcName
	for lnI = 1 to len(lcName)
		lcChar = substr(lcName, lnI, 1)
		if not isalpha(lcChar) and not isdigit(lcChar)
			lcName = stuff(lcName, lnI, 1, '_')
		endif not isalpha(lcChar) ...
	next lnI
else
	lcIllegal = ' ~!@#$%^&*()-+=-/?`{}|<>,:;\'
		&& illegal characters in VFP names
	lcName    = chrtran(tcName, lcIllegal, replicate('_', len(lcIllegal)))
endif tlObject
return lcName
