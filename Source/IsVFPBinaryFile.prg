*==============================================================================
* Function:			IsVFPBinaryFile
* Purpose:			Returns .T. for a VFP binary file
* Author:			Doug Hennig
* Last Revision:	04/11/2017
* Parameters:		tcFile  - the name of the file to check
* Returns:			.T. if the specified file is a VFP binary file
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcFile
local lcExt
lcExt = lower(justext(tcFile))
return inlist(lcExt, 'pjx', 'vcx', 'scx', 'mnx', 'frx', 'lbx', 'dbf', 'dbc')
