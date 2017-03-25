*==============================================================================
* Program:			MAIN.PRG
* Purpose:			Startup program for Project Explorer
* Author:			Doug Hennig
* Last Revision:	03/25/2017
* Parameters:		tuStartupParameter - a parameter to pass to the Project
*						Explorer (optional)
* Returns:			none
* Environment in:	if we're being run from this PRG, the current folder is
*						the root of the source code
* Environment out:	_screen.oProjectExplorers is a collection of
*						ProjectExplorer objects
*					one or more projects may be open
*==============================================================================

lparameters tuStartupParameter
local lcCurrTalk, ;
	lcCurrPath, ;
	lcPath, ;
	loProjectExplorer

* Save the current TALK setting and turn it off.

if set('TALK') = 'ON'
	set talk off
	lcCurrTalk = 'ON'
else
	lcCurrTalk = 'OFF'
endif set('TALK') = 'ON'

* If we're running from Main.prg rather than the app, set a path so we can find
* our files.

if lower(justfname(sys(16, 1))) = 'main.fxp'
	lcCurrPath = set('PATH')
	lcCurrPath = lcCurrPath + iif(empty(lcCurrPath), '', ',')
	lcPath     = justpath(sys(16, 1))
	set path to &lcCurrPath. &lcPath., &lcPath.\Images
else
	lcPath = ''
endif lower(justfname(sys(16, 1))) = 'main.fxp'

* Create a collection of ProjectExplorers in _screen so there can be more than
* one and they can live once this program is done.

if type('_screen.oProjectExplorers') <> 'O'
	addproperty(_screen, 'oProjectExplorers', createobject('Collection'))
endif type('_screen.oProjectExplorers') <> 'O'

*** TODO: check if already open for the project?

* Run the ProjectExplorer form and add it to the collection.

loProjectExplorer = newobject('ProjectExplorerForm', 'ProjectExplorerUI.vcx', ;
	'', tuStartupParameter)
if vartype(loProjectExplorer) = 'O'
	_screen.oProjectExplorers.Add(loProjectExplorer, ;
		justpath(loProjectExplorer.oSolution.cSolutionFile))
	loProjectExplorer.Show()
endif vartype(loProjectExplorer) = 'O'

* Restore the settings we changed.

if lcCurrTalk = 'ON'
	set talk on
endif lcCurrTalk = 'ON'
if empty(lcCurrPath)
	set path to
else
	set path to &lcCurrPath
endif empty(lcCurrPath)
