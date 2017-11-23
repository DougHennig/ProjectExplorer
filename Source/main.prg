*==============================================================================
* Program:			MAIN.PRG
* Purpose:			Startup program for Project Explorer
* Author:			Doug Hennig
* Last Revision:	11/22/2017
* Parameters:		tuStartupParameter - a parameter to pass to the Project
*						Explorer (optional)
* Returns:			none
* Environment in:	if we're being run from this PRG, the current folder is
*						the root of the source code
* Environment out:	_screen.oProjectExplorers is a collection of
*						ProjectExplorer objects
*					one or more projects may be open
*==============================================================================

#include ProjectExplorer.H
lparameters tuStartupParameter
local lcCurrTalk, ;
	lcCurrPath, ;
	lcPath, ;
	loRegistry, ;
	lnWindowType, ;
	llDesktop, ;
	llDockable, ;
	loProjectExplorer

* Save the current TALK setting and turn it off.

if set('TALK') = 'ON'
	set talk off
	lcCurrTalk = 'ON'
else
	lcCurrTalk = 'OFF'
endif set('TALK') = 'ON'

* Set a path so we can find our files.

lcCurrPath = set('PATH')
lcProgram  = sys(16, program(-1))
lcPath     = justpath(lcProgram)
if not lcPath $ upper(lcCurrPath)
	if 'MAIN.FXP' $ lcProgram
		lcPath = left(lcPath, rat('\', lcPath) - 1)
	endif 'MAIN.FXP' $ lcProgram
	set path to lcPath + ',' + lcPath + '\Source,' + lcPath + ;
		'\Source\Images' additive
endif not lcPath $ upper(lcCurrPath)

* Create a collection of ProjectExplorers in _screen so there can be more than
* one and they can live once this program is done.

if type('_screen.oProjectExplorers.Name') <> 'C'
	addproperty(_screen, 'oProjectExplorers', createobject('Collection'))
endif type('_screen.oProjectExplorers.Name') <> 'C'

* See what type of window to use (note the Desktop and Dockable keys are used
* for backward compatibility).

loRegistry   = newobject('ProjectExplorerRegistry', ;
	'ProjectExplorerRegistry.vcx')
lnWindowType = val(loRegistry.GetKey(ccPROJECT_EXPLORER_KEY, 'WindowType', '0'))
if lnWindowType > 0
	llDesktop  = lnWindowType = 1
	llDockable = lnWindowType = 2
else
	llDesktop  = loRegistry.GetKey(ccPROJECT_EXPLORER_KEY, 'Desktop',  'Y') = 'Y'
	llDockable = loRegistry.GetKey(ccPROJECT_EXPLORER_KEY, 'Dockable', 'Y') = 'Y'
endif lnWindowType > 0

* Run the ProjectExplorer form and add it to the collection.

loProjectExplorer = newobject(icase(llDockable, 'ProjectExplorerFormDockable', ;
	llDesktop, 'ProjectExplorerFormDesktop', ;
	'ProjectExplorerForm'), 'ProjectExplorerUI.vcx', '', tuStartupParameter)
if vartype(loProjectExplorer) = 'O'
	_screen.oProjectExplorers.Add(loProjectExplorer, ;
		loProjectExplorer.cSolutionFolder)
	loProjectExplorer.cCurrPath = lcCurrPath
	loProjectExplorer.Show()
endif vartype(loProjectExplorer) = 'O'

* Restore the settings we changed.

if lcCurrTalk = 'ON'
	set talk on
endif lcCurrTalk = 'ON'
