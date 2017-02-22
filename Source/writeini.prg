*==============================================================================
* Function:			WriteINI
* Purpose:			Writes an entry to a section in an INI file
* Author:			Doug Hennig
* Last revision:	02/05/2002
* Parameters:		tcINIFile - the INI file to look in
*					tcSection - the section to look for
*					tcEntry   - the entry to look for
*					tcValue   - the value to write
* Returns:			.T. if the INI file was updated
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcINIFile, ;
	tcSection, ;
	tcEntry, ;
	tcValue
local llReturn
declare integer WritePrivateProfileString in Win32API string cSection, ;
	string cEntry, string cValue, string cINIFile
llReturn = WritePrivateProfileString(tcSection, tcEntry, tcValue, tcINIFile) = 1
return llReturn
