*==============================================================================
* Function:			ProjectExplorerGetValidName
* Purpose:			Returns a valid VFP name
* Author:			Doug Hennig
* Last revision:	06/29/2018
* Parameters:		tcName   - the name
* Returns:			the name with illegal characters converted to _
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcName
lcIllegal = ' ~!@#$%^&*()-+=-/?`{}|<>,:;\'
	&& illegal characters in VFP names
lcName    = chrtran(tcName, lcIllegal, replicate('_', len(lcIllegal)))
return lcName
