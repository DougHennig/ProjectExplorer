*==============================================================================
* Function:			ShellExecute
* Purpose:			Opens a file in the application it's associated with
* Author:			Adapted from the FFC _ShellExecute class by Doug Hennig
* Last revision:	02/21/2017
* Parameters:		tcFileName   - the filename to open
*					tcOperation  - the operation to perform (optional: if it
*						isn't specified, "Open" is used)
*					tcWorkDir    - the working directory for the application
*						(optional)
*					tcParameters - other parameters to pass to the application
*						(optional)
*					tlNoShow     - .T. to hide the window
* Returns:			-1: if no filename was passed
*					2:  file was not found
*					3:  path was not found
*					31: no application association
*					Values over 32 indicate success and return an instance
*						handle for the application
*					See http://support.microsoft.com/kb/238245 for other values
* Environment in:	none
* Environment out:	if a valid value is returned, the application is running
*==============================================================================

lparameters tcFileName, ;
	tcOperation, ;
	tcWorkDir, ;
	tcParameters, ;
	tlNoShow
local lcFileName, ;
	lcWorkDir, ;
	lcOperation, ;
	lcParameters, ;
	lnShow, ;
	lnReturn, ;
	loException as Exception
if empty(tcFileName)
	return -1
endif empty(tcFileName)
lcFileName   = alltrim(tcFileName)
lcWorkDir    = iif(vartype(tcWorkDir) = 'C', alltrim(tcWorkDir), '')
lcOperation  = iif(vartype(tcOperation) = 'C' and not empty(tcOperation), ;
	alltrim(tcOperation), 'Open')
lcParameters = iif(vartype(tcParameters) = 'C', alltrim(tcParameters), '')
lnShow       = iif(upper(lcOperation) = 'PRINT' or tlNoShow, 0, 1)
declare integer ShellExecute in SHELL32.DLL ;
	integer nWinHandle, ;	&& handle of parent window
	string cOperation, ;	&& operation to perform
	string cFileName, ;		&& filename
	string cParameters, ;	&& parameters for the executable
	string cDirectory, ;	&& default directory
	integer nShowWindow		&& window state
try
	lnReturn = ShellExecute(0, lcOperation, lcFilename, lcParameters, ;
		lcWorkDir, lnShow)
catch to loException when loException.ErrorNo = 12
	&& Variable is not found
catch to loException
endtry
return lnReturn
