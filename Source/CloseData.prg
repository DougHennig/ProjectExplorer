*==============================================================================
* Function:			CloseData
* Purpose:			Closes the specified database container or table
* Author:			Doug Hennig
* Last Revision:	03/26/2017
* Parameters:		tcFile - the name and path of the database or table
* Returns:			.T.
* Environment in:	none
* Environment out:	the database or table is closed if it was open
*==============================================================================

lparameters tcFile
local lcExt, ;
	laTables[1], ;
	lnTables, ;
	lnI
lcExt = lower(justext(tcFile))
do case
	case lcExt = 'dbc'
		if dbused(tcFile)
			set database to (tcFile)
			close databases
		endif dbused(tcFile)
	case lcExt = 'dbf'
		lnTables = aused(laTables, set('DATASESSION'), tcFile)
		for lnI = 1 to lnTables
			use in (laTables[lnI, 1])
		next lnI
endcase
