*===========================================================================
* Function:			PUTPROP
* Purpose:			Update/store a property in the PROPERTY field of a DBC
* Author:			Doug Hennig
* Last Revision:	10/06/95
* Parameters:		lnID    - the ID # of the property to store/update
*					lcVALUE - the value to store
* Returns:			.T.
* Environment in:	the database is open as a table in the current work
*						area and is positioned to the record to be updated
* Environment out:	the property has been updated if it existed or added if
*						not
* Routines used:	DEC2HEX		(internal routine)
*===========================================================================

lparameters lnID, lcVALUE
#define dcNULL chr(0)
local llDONE, lnPOSN, llGOT_PROP, lnVALUE_LEN, lcLEN, lnLEN, lnI, ;
	lnID_LEN, lnID_CODE
llDONE      = .F.
lnPOSN      = 1
llGOT_PROP  = .F.
lnVALUE_LEN = len(lcVALUE)

* Keep looking for the desired property in the PROPERTY field until we find
* it.

do while not llDONE

* Starting from the current position, take the next four bytes and convert
* them into the length of this property.

	lcLEN = substr(PROPERTY, lnPOSN, 4)
	lnLEN = 0
	for lnI = 4 to 1 step -1
		lnLEN = lnLEN + asc(substr(lcLEN, lnI, 1)) * 256^(lnI - 1)
	next lnI

* Take the next two bytes and convert it into the length of the property code.

	lcLEN = substr(PROPERTY, lnPOSN + 4, 2)
	lnID_LEN = 0
	for lnI = 2 to 1 step -1
		lnID_LEN = lnID_LEN + asc(substr(lcLEN, lnI, 1)) * 256^(lnI - 1)
	next lnI

* Take as many bytes as the property code length is to get the property code.

	lcLEN = substr(PROPERTY, lnPOSN + 6, lnID_LEN)
	lnID_CODE = 0
	for lnI = lnID_LEN to 1 step -1
		lnID_CODE = lnID_CODE + asc(substr(lcLEN, lnI, 1)) * 256^(lnI - 1)
	next lnI

* If this is the code we're looking for, replace the current property value
* with the new one and flag that we’re done.

	if lnID_CODE = lnID
		replace PROPERTY with stuff(PROPERTY, lnPOSN, lnLEN, ;
			DEC2HEX(len(lcVALUE) + lnID_LEN + 6 + ;
			iif(lnVALUE_LEN = 1, 0, 1), 4) + DEC2HEX(lnID_LEN, 2) + ;
			DEC2HEX(lnID, lnID_LEN) + lcVALUE + ;
			iif(lnVALUE_LEN = 1, '', dcNULL))
		llGOT_PROP = .T.
		llDONE     = .T.

* This isn't the one, so skip to the start of the next property. If we're out
* of properties, we're done.

	else
		lnPOSN = lnPOSN + lnLEN
		if lnPOSN > len(PROPERTY)
			llDONE = .T.
		endif lnPOSN > len(PROPERTY)
	endif lnID_CODE = lnID
enddo while not llDONE

* If we didn't find the property, let's add it to the end of PROPERTY.

if not llGOT_PROP
	lnID_LEN = int(lnID/256) + 1
	replace PROPERTY with PROPERTY + ;
		DEC2HEX(len(lcVALUE) + lnID_LEN + 6 + iif(lnVALUE_LEN = 1, 0, 1), 4) + ;
		DEC2HEX(lnID_LEN, 2) + DEC2HEX(lnID, lnID_LEN) + lcVALUE + ;
		iif(lnVALUE_LEN = 1, '', dcNULL)
endif not llGOT_PROP
return .T.

*===========================================================================
* Function:			DEC2HEX
* Purpose:			Convert a decimal number to a hex string
* Author:			Doug Hennig
* Last Revision:	05/24/95
* Parameters:		lnVALUE  - the decimal value
*					lnPLACES - the number of places needed
* Returns:			the hex string
* Environment in:	none
* Environment out:	none
* Routines used:	none
*===========================================================================

function DEC2HEX
parameters lnVALUE, lnPLACES
private lnDEC, lcHEX, lnCURR_DEC, lnI, lnEXP, lnTEMP, lcOUT
lnDEC      = lnVALUE
lcHEX      = ''
lnCURR_DEC = set('DECIMALS')
set decimals to 17
for lnI = lnPLACES to 1 step -1
	lnEXP  = 256 ^ (lnI - 1)
	lnTEMP = int(lnDEC/lnEXP)
	lcHEX  = lcHEX + chr(lnTEMP)
	lnDEC  = lnDEC - lnTEMP * lnEXP
next lnI
lcOUT = ''
for lnI = 1 to lnPLACES
	lcOUT = lcOUT + substr(lcHEX, lnPLACES - lnI + 1, 1)
next lnI
set decimals to lnCURR_DEC
return lcOUT
