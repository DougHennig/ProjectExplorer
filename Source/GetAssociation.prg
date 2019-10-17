*==============================================================================
* Function:			GetAssociation
* Purpose:			Gets the file used to open the specified extension
* Author:			Doug Hennig
* Last revision:	10/17/2019
* Parameters:		tcExt - the extension to get the association for
* Returns:			the executable associated with the extension
* Environment in:	none
* Environment out:	none
* Notes:			Modified from https://social.msdn.microsoft.com/Forums/en-US/d7a075ac-3a2a-40c5-89c9-87efc7d16563/pinvoking-assocquerystring-in-c-to-get-application-associated-with-a-file-extension?forum=csharplanguage
*==============================================================================

lparameters tcExt
local lcExt, ;
	lcBuffer, ;
	lnBufferSize, ;
	lcFile
#define ASSOCF_NOTRUNCATE		0x20
#define ASSOCSTR_EXECUTABLE		2
lcExt        = iif(left(tcExt, 1) = '.', '', '.') + tcExt
lcBuffer     = replicate(chr(0), 1024)
lnBufferSize = len(lcBuffer)
declare AssocQueryString in Shlwapi.dll integer ASSOCF, integer ASSOCSTR, ;
	string pszAssoc, string pszExtra, string @pszOut, integer @pcchOut
AssocQueryString(ASSOCF_NOTRUNCATE, ASSOCSTR_EXECUTABLE, lcExt, 'open', ;
	@lcBuffer, @lnBufferSize)
lcFile = left(lcBuffer, at(chr(0), lcBuffer) - 1)
return lcFile
