*==============================================================================
* Function:			GetVFPBinaryOtherFile
* Purpose:			Get the "other" filename for a VFP binary file
* Author:			Doug Hennig
* Last Revision:	10/07/2017
* Parameters:		tcFile  - the name of the file to check
*					tlOther - in the case of a DBC or DBF, specifies which of
*						the "other" filenames is returned: .F. = CDX/DCX,
*						.T. = FPT/DCT
* Returns:			the name of the "other" file from a VFP binary pair (for
*						example, returns "Form1.sct" if passed "Form1.scx") or
*						blank if there isn't such a file (for example, no CDX
*						for table)
* Environment in:	see GetProperFileCase.prg
* Environment out:	see GetProperFileCase.prg
*==============================================================================

lparameters tcFile, ;
	tlOther
local lcExt, ;
	lcFile
lcExt = lower(justext(tcFile))
do case
	case not inlist(lcExt, 'pjx', 'vcx', 'scx', 'mnx', 'frx', 'lbx', 'dbf', ;
		'dbc')
		lcExt  = ''
		lcFile = ''
	case lcExt = 'dbc' and tlOther
		lcExt = 'dct'
	case lcExt = 'dbc'
		lcExt = 'dcx'
	case lcExt = 'dbf' and tlOther
		lcExt = 'fpt'
	case lcExt = 'dbf'
		lcExt = 'cdx'
	case tlOther
		lcExt  = ''
		lcFile = ''
	otherwise
		lcExt = strtran(lcExt, 'x', 't')
endcase
if not empty(lcExt)
	lcFile = forceext(tcFile, lcExt)
	if file(lcFile)
		lcFile = GetProperFileCase(lcFile)
	else
		lcFile = ''
	endif file(lcFile)
endif not empty(lcExt)
return lcFile
