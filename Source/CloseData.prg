*==============================================================================
* Function:			CloseData
* Purpose:			Closes the specified database container or table in all
*						data sessions
* Author:			Doug Hennig
* Last Revision:	03/28/2017
* Parameters:		tcFile - the name and path of the database or table
* Returns:			.T.
* Environment in:	none
* Environment out:	the database or table is closed if it was open
*==============================================================================

lparameters tcFile
local lcExt, ;
	lnDataSession, ;
	laSessions[1], ;
	lnSessions, ;
	lnI, ;
	laTables[1], ;
	lnTables, ;
	lnJ
lcExt = lower(justext(tcFile))
do case
	case lcExt = 'dbc'
		if dbused(tcFile)
			try
				set database to (tcFile)
				close databases
			catch
			endtry
		endif dbused(tcFile)
	case lcExt = 'dbf'
		lnDataSession = set('DATASESSION')
		lnSessions    = asessions(laSessions)
		for lnI = lnSessions to 1 step -1
			set datasession to lnI
			lnTables = aused(laTables, lnI, tcFile)
			for lnJ = 1 to lnTables
				use in (laTables[lnJ, 1])
			next lnJ
		next lnI
		set datasession to lnDataSession
endcase
