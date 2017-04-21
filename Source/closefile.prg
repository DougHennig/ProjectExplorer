*==============================================================================
* Function:			CloseFile
* Purpose:			Closes the specified project, database container, table, or
*						class library in all data sessions
* Author:			Doug Hennig
* Last Revision:	04/21/2017
* Parameters:		tcFile - the name and path of the project, database, table,
*						table name of a table, or class library
* Returns:			.T.
* Environment in:	none
* Environment out:	the file is closed if it was open
*==============================================================================

lparameters tcFile
local lcExt, ;
	lnDataSession, ;
	laSessions[1], ;
	lnSessions, ;
	lnI, ;
	lnSession, ;
	laTables[1], ;
	lnTables, ;
	lnJ
lcExt = lower(justext(tcFile))
do case
	case lcExt = 'pjx'
		try
			loProject = _vfp.Projects[tcFile]
			loProject.Close()
		catch to loException
		endtry
	case lcExt = 'vcx'
		try
			clear classlib (tcFile)
		catch to loException
		endtry
	case lcExt = 'dbc' and dbused(tcFile)
		try
			set database to (tcFile)
			close databases
		catch to loException
		endtry
	case lcExt = 'dbf' or empty(lcExt)
		lnDataSession = set('DATASESSION')
		lnSessions    = asessions(laSessions)
		for lnI = lnSessions to 1 step -1
			lnSession = laSessions[lnI]
			set datasession to lnSession
			lnTables = aused(laTables, lnSession, tcFile)
			for lnJ = 1 to lnTables
				use in (laTables[lnJ, 1])
			next lnJ
		next lnI
		set datasession to lnDataSession
endcase
