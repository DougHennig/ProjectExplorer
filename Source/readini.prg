*==============================================================================
* Function:			ReadINI
* Purpose:			Reads an entry from a section in an INI file
* Author:			Doug Hennig
* Last revision:	02/05/2017
* Parameters:		tcINIFile - the INI file to look in
*					tcSection - the section to look for
*					tuEntry   - the entry to look for (pass 0 and taEntries
*						to enumerate all entries in the section)
*					tcDefault - the default value to use if the entry isn't
*						found
*					taEntries - an array to hold all entries in the section
*						(only needed if tuEntry is 0)
* Returns:			if tuEntry is a string (the entry), the value of the entry
*						or tcDefault if the entry isn't found
*					if tuEntry is 0, the number of entries in the array
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcINIFile, ;
	tcSection, ;
	tuEntry, ;
	tcDefault, ;
	taEntries
#include ProjectExplorerRegistry.H
local lcBuffer, ;
	lcDefault, ;
	lnSize, ;
	luReturn
declare integer GetPrivateProfileString in Win32API string cSection, ;
	string cEntry, string cDefault, string @ cBuffer, integer nBufferSize, ;
	string cINIFile
lcBuffer  = replicate(ccNULL, cnBUFFER_SIZE)
lcDefault = iif(vartype(tcDefault) <> 'C', '', tcDefault)
lnSize    = GetPrivateProfileString(tcSection, tuEntry, lcDefault, @lcBuffer, ;
	cnBUFFER_SIZE, tcINIFile)
lcBuffer  = left(lcBuffer, lnSize)
luReturn  = lcBuffer
do case
	case vartype(tuEntry) = 'C'
	case lnSize = 0
		luReturn = 0
	otherwise
		luReturn = alines(taEntries, lcBuffer, .T., ccNULL, ccCR)
endcase
return luReturn
