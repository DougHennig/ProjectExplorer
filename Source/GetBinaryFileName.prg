*==============================================================================
* Function:			GetBinaryFileName
* Purpose:			Get the filename for the VFP binary file from its text
*						equivalent
* Author:			Doug Hennig
* Last Revision:	04/03/2017
* Parameters:		tcFile - the name of the file to get the binary filename for
* Returns:			the name of the VFP binary file for the text equivalent
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcFile
local lcExt, ;
	lcFile
lcExt = lower(justext(tcFile))
do case
	case lcExt = 'db2'
		lcFile = forceext(tcFile, 'dbf')
	case lcExt = 'dc2'
		lcFile = forceext(tcFile, 'dbc')
	otherwise
		lcFile = forceext(tcFile, strtran(lcExt, '2', 'x', -1, -1, 1))
endcase
return lcFile
