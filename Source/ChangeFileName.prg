*==============================================================================
* Function:			ChangeFileName
* Purpose:			Returns a file path with a new stem name
* Author:			Doug Hennig
* Last Revision:	04/20/2017
* Parameters:		tcName1 - the name and path of the file
*					tcName2 - the new stem name
* Returns:			the file path with a new stem name
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcName1, ;
	tcName2
return forcepath(forceext(tcName2, justext(tcName1)), justpath(tcName1))
