*==============================================================================
* Function:			GetTextFileName
* Purpose:			Get the filename for the text equivalent of a VFP binary
*						file
* Author:			Doug Hennig
* Last Revision:	03/21/2017
* Parameters:		tcFile - the name of the file to get the text filename for
* Returns:			the name of the text equivalent of the VFP binary file
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcFile
local lcExt, ;
	lcFile
lcExt = lower(justext(tcFile))
do case
	case lcExt = 'dbf'
		lcFile = forceext(tcFile, 'db2')
	case lcExt = 'dbc'
		lcFile = forceext(tcFile, 'dc2')
	otherwise
		lcFile = forceext(tcFile, strtran(lcExt, 'x', '2', -1, -1, 1))
endcase
return lcFile
